import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/reviews/presentation/favorite_screen.dart';
import '../../features/reviews/presentation/reviews_screen.dart';
import '../../features/reviews/presentation/sessionsummary_screen.dart';
import '../../features/scenes/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../utils/dev_screen.dart';
import '../utils/root_wrapper.dart';
import '../widgets/app_shell_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const RootWrapper()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const AppShellScaffold(
        currentIndex: 0,
        title: 'Home',
        child: HistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const AppShellScaffold(
        currentIndex: 2,
        title: 'Chat',
        child: HomeScreen(showChrome: false),
      ),
    ),
    GoRoute(path: '/history', redirect: (context, state) => '/chat'),
    GoRoute(
      path: '/reviews',
      builder: (context, state) => const AppShellScaffold(
        currentIndex: 1,
        title: 'Reviews',
        child: FavoritesScreen(),
      ),
    ),
    GoRoute(
      path: '/reviews/session',
      builder: (context, state) => const ReviewCardScreen(),
    ),

    GoRoute(
      path: '/review-summary',
      builder: (context, state) => const SessionSummaryScreen(),
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => const AppShellScaffold(
        currentIndex: 3,
        title: 'Settings',
        child: SettingsScreen(),
      ),
    ),
    GoRoute(path: '/dev', builder: (context, state) => const DevScreen()),
  ],
);
