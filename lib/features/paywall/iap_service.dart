import 'dart:async';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../services/auth_service.dart';
import '../auth/user_repository.dart';

const monthlyProductId = 'tidy_pro_monthly';
const annualProductId = 'tidy_pro_annual';
const _allProductIds = {monthlyProductId, annualProductId};

@immutable
sealed class IapStatus {
  const IapStatus();
}

class IapIdle extends IapStatus {
  const IapIdle();
}

class IapPending extends IapStatus {
  const IapPending();
}

class IapSuccess extends IapStatus {
  const IapSuccess(this.productId);
  final String productId;
}

class IapCanceled extends IapStatus {
  const IapCanceled();
}

class IapError extends IapStatus {
  const IapError(this.message);
  final String message;
}

/// Wraps Apple's in_app_purchase. If the products aren't configured in
/// App Store Connect (or the .storekit file isn't selected in the scheme),
/// [products] returns empty and the paywall falls back to the mock upgrade
/// path so dev still works.
class IapService {
  IapService(this._users, this._auth);

  final UserRepository _users;
  final FirebaseAuth _auth;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final _statusController = StreamController<IapStatus>.broadcast();

  Stream<IapStatus> get status => _statusController.stream;

  Future<void> init() async {
    if (!await _iap.isAvailable()) return;
    _purchaseSub ??= _iap.purchaseStream.listen(_onPurchases,
        onError: (Object e) => dev.log('purchaseStream error: $e',
            name: 'iap_service'));
  }

  /// Returns the configured products, or an empty list if none are configured.
  Future<List<ProductDetails>> products() async {
    if (!await _iap.isAvailable()) return const [];
    try {
      final response = await _iap.queryProductDetails(_allProductIds);
      if (response.notFoundIDs.isNotEmpty) {
        dev.log('Products not found: ${response.notFoundIDs}',
            name: 'iap_service');
      }
      return response.productDetails;
    } catch (e) {
      dev.log('queryProductDetails failed: $e', name: 'iap_service');
      return const [];
    }
  }

  Future<void> buy(ProductDetails product) async {
    _statusController.add(const IapPending());
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() => _iap.restorePurchases();

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _statusController.add(const IapPending());
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantPro(purchase);
          _statusController.add(IapSuccess(purchase.productID));
        case PurchaseStatus.canceled:
          _statusController.add(const IapCanceled());
        case PurchaseStatus.error:
          _statusController.add(
              IapError(purchase.error?.message ?? 'Purchase failed'));
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _grantPro(PurchaseDetails purchase) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final billing =
        purchase.productID == annualProductId ? 'annual' : 'monthly';
    try {
      await _users.setPlan(user.uid, 'pro', billing: billing);
    } catch (e) {
      dev.log('setPlan failed after purchase: $e', name: 'iap_service');
    }
  }

  void dispose() {
    _purchaseSub?.cancel();
    _statusController.close();
  }
}

final iapServiceProvider = Provider<IapService>((ref) {
  final svc = IapService(
    ref.watch(userRepositoryProvider),
    ref.watch(firebaseAuthProvider),
  );
  svc.init();
  ref.onDispose(svc.dispose);
  return svc;
});

final iapProductsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  return ref.watch(iapServiceProvider).products();
});
