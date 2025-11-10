import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/admin/presentation/bloc/admin_event.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/booking/presentation/pages/main_navigation_page.dart';
import '../dependency_injection/service_locator.dart';

/// Configuración centralizada de rutas usando GoRouter
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<AuthBloc>()..add(CheckAuthStatus())),
            BlocProvider(create: (context) => sl<BookingBloc>()),
          ],
          child: const MainNavigationPage(),
        ),
      ),
      GoRoute(
        path: adminLogin,
        name: 'adminLogin',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: const AdminLoginPage(),
        ),
      ),
      GoRoute(
        path: adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<AuthBloc>()..add(CheckAuthStatus())),
            BlocProvider(create: (context) => sl<AdminBloc>()..add(const LoadAllBookingsEvent())),
          ],
          child: const AdminDashboardPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: const LoginPage(),
    ),
  );
}
