import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/providers.dart';
import 'plan_status.dart';

/// RevenueCat seam, degrading gracefully (AgroConectSH pattern): with no
/// public SDK keys compiled in, [isConfigurable] is false and every
/// method is a safe no-op — "Manage subscription" stays a placeholder
/// until keys exist. Keys come from
/// `--dart-define=REVENUECAT_PUBLIC_SDK_KEY_ANDROID/_IOS`.
class BillingService {
  static const _androidKey =
      String.fromEnvironment('REVENUECAT_PUBLIC_SDK_KEY_ANDROID');
  static const _iosKey =
      String.fromEnvironment('REVENUECAT_PUBLIC_SDK_KEY_IOS');

  static String get _key => Platform.isAndroid
      ? _androidKey
      : Platform.isIOS
          ? _iosKey
          : '';

  bool get isConfigurable => _key.isNotEmpty;

  bool _configured = false;

  /// Lazily configures the SDK with the company as the app user id.
  /// No-op when keys are absent.
  Future<void> configure(String companyId) async {
    if (!isConfigurable || _configured) return;
    try {
      final configuration = PurchasesConfiguration(_key)
        ..appUserID = companyId;
      await Purchases.configure(configuration);
      await Purchases.logIn(companyId);
      _configured = true;
    } catch (_) {
      // Store misconfiguration must never break the app.
    }
  }

  /// Currently available packages; empty when not configurable or the
  /// store has nothing set up.
  Future<List<Package>> packages() async {
    if (!isConfigurable || !_configured) return const [];
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? const [];
    } catch (_) {
      return const [];
    }
  }

  /// Returns true when the purchase completed.
  Future<bool> purchasePackage(Package package) async {
    if (!isConfigurable || !_configured) return false;
    try {
      await Purchases.purchasePackage(package);
      return true;
    } catch (_) {
      // User cancelled or store error — both are fine.
      return false;
    }
  }

  /// Returns true when restore found an entitlement-bearing purchase.
  Future<bool> restore() async {
    if (!isConfigurable || !_configured) return false;
    try {
      await Purchases.restorePurchases();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final billingServiceProvider = Provider<BillingService>(
  (ref) => BillingService(),
);

/// Paywall modal: price buttons when packages load, otherwise a plain
/// "not configured" notice. Successful purchase/restore refreshes
/// [planStatusProvider] (the webhook updates the company server-side;
/// the refresh picks it up on the next read).
Future<void> showSubscriptionPaywall(
  BuildContext context,
  WidgetRef ref,
) async {
  final billing = ref.read(billingServiceProvider);

  if (!billing.isConfigurable) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage subscription'),
        content: const Text(
          'Store not configured yet. Self-serve checkout arrives with the '
          'RevenueCat app keys — contact support to change plans meanwhile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  final profile = await ref.read(currentProfileProvider.future);
  if (profile == null || !context.mounted) return;
  await billing.configure(profile.companyId);
  final packages = await billing.packages();
  if (!context.mounted) return;

  if (packages.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store not configured yet.')),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose a plan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final package in packages)
              ListTile(
                title: Text(package.storeProduct.title),
                subtitle: Text(package.storeProduct.description),
                trailing: FilledButton(
                  onPressed: () async {
                    final purchased =
                        await billing.purchasePackage(package);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          purchased
                              ? 'Subscription updated.'
                              : 'Purchase not completed.',
                        ),
                      ),
                    );
                    if (purchased) ref.invalidate(planStatusProvider);
                  },
                  child: Text(package.storeProduct.priceString),
                ),
              ),
            TextButton(
              onPressed: () async {
                final restored = await billing.restore();
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      restored
                          ? 'Purchases restored.'
                          : 'Nothing to restore.',
                    ),
                  ),
                );
                if (restored) ref.invalidate(planStatusProvider);
              },
              child: const Text('Restore purchases'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
