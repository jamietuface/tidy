import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _annual = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.systemBlue, AppColors.systemIndigo]),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text('Tidy Pro', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Unlimited photos · AI grouping · App tracker', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
              const Spacer(),
              // Plan toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  _PlanButton(label: 'Monthly', subtitle: '£3.99/mo', selected: !_annual, onTap: () => setState(() => _annual = false)),
                  _PlanButton(label: 'Annual', subtitle: '£23.99/yr', badge: 'BEST VALUE', selected: _annual, onTap: () => setState(() => _annual = true)),
                ]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.systemBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_annual ? 'Start Free Trial · £23.99/yr' : 'Subscribe · £3.99/mo',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(context),
                child: Text('Restore Purchase', style: TextStyle(color: Colors.white.withOpacity(0.5)))),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanButton extends StatelessWidget {
  const _PlanButton({required this.label, required this.subtitle, this.badge, required this.selected, required this.onTap});
  final String label, subtitle;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.systemBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            if (badge != null) Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(color: AppColors.systemGreen, borderRadius: BorderRadius.circular(4)),
              child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}
