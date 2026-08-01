import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/sync/catalogue_sync.dart';
import '../core/theme/spraylog_theme.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/auth_state.dart';
import '../features/history/history_screen.dart';
import '../features/history/record_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/record/confirm_screen.dart';
import '../features/record/record_draft.dart';
import '../features/record/record_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    // Watch so the router rebuilds (and re-runs redirect) when the
    // profile finishes resolving or changes after onboarding.
    final profileAsync = ref.watch(currentProfileProvider);
    // Activate the outbox startup drain + reconnect listener.
    ref.watch(outboxReconnectSyncProvider);
    ref.watch(catalogueSyncProvider);

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final value = auth.valueOrNull;
        if (value == null) return null; // session still resolving

        final loggingIn = state.matchedLocation == '/auth';
        if (value.status == AuthStatus.unauthenticated) {
          return loggingIn ? null : '/auth';
        }
        if (loggingIn) return '/';

        // Authenticated: require a company profile before anything else.
        // While the profile is still resolving, hold navigation where it is.
        final onboarding = state.matchedLocation == '/onboarding';
        if (profileAsync.isLoading) return null;
        final profile = profileAsync.valueOrNull;
        if (profile == null && !onboarding) return '/onboarding';
        if (profile != null && onboarding) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/record',
          builder: (context, state) => const RecordScreen(),
          routes: [
            GoRoute(
              path: 'confirm',
              builder: (context, state) {
                final draft = state.extra;
                if (draft is! RecordDraft) return const RecordScreen();
                return ConfirmScreen(draft: draft);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => RecordDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'SprayLog',
      debugShowCheckedModeBanner: false,
      theme: SpraylogTheme.light,
      darkTheme: SpraylogTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
