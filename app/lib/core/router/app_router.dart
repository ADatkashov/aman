import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analyses/presentation/analyses_screen.dart';
import '../../features/analyses/presentation/analysis_detail_screen.dart';
import '../../features/appointments/presentation/appointment_detail_screen.dart';
import '../../features/appointments/presentation/appointments_screen.dart';
import '../../features/appointments/presentation/reschedule_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/booking/presentation/booking_success_screen.dart';
import '../../features/catalog/presentation/doctor_detail_screen.dart';
import '../../features/catalog/presentation/doctors_screen.dart';
import '../../features/clinics/presentation/clinic_detail_screen.dart';
import '../../features/clinics/presentation/clinics_screen.dart';
import '../../features/documents/presentation/document_detail_screen.dart';
import '../../features/documents/presentation/documents_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/medical_record/presentation/medical_record_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/settings/application/settings_providers.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/main_shell.dart';

/// Minimum time the splash is displayed. Overridden in tests.
final splashDoneProvider = FutureProvider<void>(
  (ref) => Future.delayed(const Duration(milliseconds: 1400)),
);

abstract final class Routes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const forgot = '/forgot';
  static const profileSetup = '/profile-setup';
  static const home = '/home';

  /// Screens reachable without a session.
  static const publicRoutes = {splash, welcome, login, register, forgot};
}

/// Pure redirect rule (unit-tested).
String? redirectFor({
  required String location,
  required bool booting,
  required bool signedIn,
  required bool onboarded,
}) {
  if (booting) return location == Routes.splash ? null : Routes.splash;
  if (!signedIn) {
    if (location == Routes.otp ||
        (Routes.publicRoutes.contains(location) && location != Routes.splash)) {
      return null;
    }
    return onboarded ? Routes.login : Routes.welcome;
  }
  if (Routes.publicRoutes.contains(location)) return Routes.home;
  return null;
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(authControllerProvider, (_, _) => refresh.value++)
    ..listen(splashDoneProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(
      location: state.matchedLocation,
      booting:
          ref.read(authControllerProvider).isLoading ||
          ref.read(splashDoneProvider).isLoading,
      signedIn: ref.read(authControllerProvider).value != null,
      onboarded: ref.read(onboardedProvider),
    ),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: Routes.otp,
        redirect: (_, state) => state.extra is OtpArgs ? null : Routes.register,
        builder: (_, state) => OtpScreen(args: state.extra! as OtpArgs),
      ),
      GoRoute(
        path: Routes.forgot,
        builder: (_, state) =>
            ForgotPasswordScreen(initialPhone: state.extra as String?),
      ),
      GoRoute(
        path: Routes.profileSetup,
        builder: (_, _) => const ProfileSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/appointments',
                builder: (_, _) => const AppointmentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/services',
                builder: (_, _) => const ServicesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/doctors', builder: (_, _) => const DoctorsScreen()),
      GoRoute(
        path: '/doctors/:id',
        builder: (_, s) =>
            DoctorDetailScreen(doctorId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/favorites',
        builder: (_, _) => const DoctorsScreen(favoritesOnly: true),
      ),
      GoRoute(path: '/booking', builder: (_, _) => const BookingScreen()),
      GoRoute(
        path: '/booking/success/:id',
        builder: (_, s) =>
            BookingSuccessScreen(appointmentId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/appointments/:id',
        builder: (_, s) =>
            AppointmentDetailScreen(appointmentId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'reschedule',
            builder: (_, s) =>
                RescheduleScreen(appointmentId: s.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: '/analyses', builder: (_, _) => const AnalysesScreen()),
      GoRoute(
        path: '/analyses/:id',
        builder: (_, s) =>
            AnalysisDetailScreen(resultId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/medical-record',
        builder: (_, _) => const MedicalRecordScreen(),
      ),
      GoRoute(path: '/clinics', builder: (_, _) => const ClinicsScreen()),
      GoRoute(
        path: '/clinics/:id',
        builder: (_, s) =>
            ClinicDetailScreen(clinicId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/documents', builder: (_, _) => const DocumentsScreen()),
      GoRoute(
        path: '/documents/:id',
        builder: (_, s) =>
            DocumentDetailScreen(documentId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/security', builder: (_, _) => const SecurityScreen()),
      GoRoute(path: '/help', builder: (_, _) => const HelpScreen()),
    ],
  );
});
