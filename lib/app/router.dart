import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/posts/presentation/post_detail_screen.dart';
import '../features/posts/presentation/post_feed_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/spaces/application/space_controller.dart';
import '../features/spaces/presentation/pending_screen.dart';
import '../features/spaces/presentation/space_home_screen.dart';
import '../features/spaces/presentation/space_join_screen.dart';
import '../features/whispers/presentation/whisper_map_screen.dart';
import '../shared/models/membership.dart';

enum AppRoute {
  splash('/splash'),
  login('/login'),
  register('/register'),
  join('/join-space'),
  pending('/space-pending'),
  home('/home'),
  posts('/posts'),
  whispers('/whispers'),
  settings('/settings');

  const AppRoute(this.path);
  final String path;
}

final routerRefreshProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this.ref) {
    ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) => notifyListeners(),
    );
    ref.listen<SpaceState>(
      spaceControllerProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final location = state.uri.path;
      final auth = ref.read(authControllerProvider);
      final space = ref.read(spaceControllerProvider);

      final isBootstrapping = !auth.bootstrapped || !space.bootstrapped;
      if (isBootstrapping && location != AppRoute.splash.path) {
        return AppRoute.splash.path;
      }
      if (isBootstrapping) {
        return null;
      }

      if (!auth.isAuthenticated) {
        final isAuthRoute =
            location == AppRoute.login.path ||
            location == AppRoute.register.path;
        return isAuthRoute ? null : AppRoute.login.path;
      }

      final membership = space.membership;
      final hasJoinedSpace = membership != null && space.currentSpace != null;
      if (!hasJoinedSpace) {
        return location == AppRoute.join.path ? null : AppRoute.join.path;
      }

      if (membership.status == MembershipStatus.pending) {
        return location == AppRoute.pending.path ? null : AppRoute.pending.path;
      }

      if (membership.isBlockedFromSpace) {
        return location == AppRoute.join.path ? null : AppRoute.join.path;
      }

      if (location == AppRoute.login.path ||
          location == AppRoute.register.path ||
          location == AppRoute.splash.path ||
          location == AppRoute.pending.path ||
          location == AppRoute.join.path) {
        return AppRoute.home.path;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoute.join.path,
        builder: (context, state) => const SpaceJoinScreen(),
      ),
      GoRoute(
        path: AppRoute.pending.path,
        builder: (context, state) => const SpacePendingScreen(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        builder: (context, state) => const SpaceHomeScreen(),
      ),
      GoRoute(
        path: AppRoute.posts.path,
        builder: (context, state) => const PostFeedScreen(),
      ),
      GoRoute(
        path: '${AppRoute.posts.path}/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: AppRoute.whispers.path,
        builder: (context, state) => const WhisperMapScreen(),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
