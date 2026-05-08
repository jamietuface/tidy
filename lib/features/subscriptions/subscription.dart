import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    this.lastUsed,
    this.renewsAt,
    this.status = 'active',
    this.iconName,
    this.colorHex,
  });

  final String id;
  final String name;
  final double price;
  final String currency;
  final DateTime? lastUsed;
  final DateTime? renewsAt;
  final String status;
  final String? iconName;
  final String? colorHex;

  factory Subscription.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    return Subscription(
      id: doc.id,
      name: (d['name'] as String?) ?? 'Unknown',
      price: ((d['price'] as num?) ?? 0).toDouble(),
      currency: (d['currency'] as String?) ?? 'GBP',
      lastUsed: (d['lastUsed'] as Timestamp?)?.toDate(),
      renewsAt: (d['renewsAt'] as Timestamp?)?.toDate(),
      status: (d['status'] as String?) ?? 'active',
      iconName: d['iconName'] as String?,
      colorHex: d['colorHex'] as String?,
    );
  }
}
