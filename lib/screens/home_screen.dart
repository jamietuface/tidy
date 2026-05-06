import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../widgets/tidy_card.dart';
import '../widgets/section_header.dart';
import 'swipe_screen.dart';
import 'subscriptions_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  static const _tabs = [
    NavigationDestination(icon: Icon(CupertinoIcons.photo), label: 'Photos'),
    NavigationDestination(icon: Icon(CupertinoIcons.app), label: 'Apps'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [SwipeScreen(), SubscriptionsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Theme.of(context).extension<TidyThemeExtension>()!.cardBackground,
        indicatorColor: AppColors.systemBlue.withOpacity(0.12),
        destinations: _tabs,
      ),
    );
  }
}
