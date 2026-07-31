import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

/// Company setup: first company + owner profile via the
/// create_company_and_profile RPC (spec §4, /onboarding).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _companyName = TextEditingController();
  final _fullName = TextEditingController();
  final _licenseNumber = TextEditingController();
  final _licenseState = TextEditingController();
  final _states = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _companyName.dispose();
    _fullName.dispose();
    _licenseNumber.dispose();
    _licenseState.dispose();
    _states.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_companyName.text.trim().isEmpty ||
        _fullName.text.trim().isEmpty) {
      setState(() => _error = 'Company name and your name are required');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final states = _states.text
          .split(RegExp(r'[,\s]+'))
          .map((s) => s.trim().toUpperCase())
          .where((s) => s.isNotEmpty)
          .toList();
      await ref.read(supabaseClientProvider).rpc(
        'create_company_and_profile',
        params: {
          'company_name': _companyName.text.trim(),
          'company_operating_states': states,
          'profile_full_name': _fullName.text.trim(),
          'profile_license_number':
              _licenseNumber.text.trim().isEmpty
                  ? null
                  : _licenseNumber.text.trim(),
          'profile_license_state': _licenseState.text.trim().isEmpty
              ? null
              : _licenseState.text.trim().toUpperCase(),
        },
      );
      ref.invalidate(currentProfileProvider);
      if (mounted) context.go('/');
    } catch (e) {
      // Profile already created by an earlier attempt — treat as done.
      if (e.toString().contains('duplicate key') ||
          e.toString().contains('profiles_pkey')) {
        ref.invalidate(currentProfileProvider);
        if (mounted) context.go('/');
        return;
      }
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your company')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                controller: _companyName,
                decoration: const InputDecoration(
                  labelText: 'Company name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _states,
                decoration: const InputDecoration(
                  labelText: 'Operating states (e.g. FL, TX)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text('First applicator (you)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _fullName,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _licenseNumber,
                decoration: const InputDecoration(
                  labelText: 'License number (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _licenseState,
                decoration: const InputDecoration(
                  labelText: 'License state (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _create,
                child: Text(_busy ? 'Creating…' : 'Create company'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
