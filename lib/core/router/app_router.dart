import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/features/applications/presentation/my_applications_screen.dart';
import 'package:mywork/features/applications/presentation/recruiter_applications_screen.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/auth/domain/role.dart';
import 'package:mywork/features/auth/presentation/choose_space_screen.dart';
import 'package:mywork/features/auth/presentation/login_screen.dart';
import 'package:mywork/features/auth/presentation/reset_password_screen.dart';
import 'package:mywork/features/auth/presentation/splash_screen.dart';
import 'package:mywork/features/auth/presentation/welcome_screen.dart';
import 'package:mywork/features/company/presentation/company_profile_screen.dart';
import 'package:mywork/features/company/presentation/dashboard_screen.dart' as company;
import 'package:mywork/features/company/presentation/edit_offer_screen.dart';
import 'package:mywork/features/company/presentation/manage_offers_screen.dart';
import 'package:mywork/features/favorites/presentation/favorites_screen.dart';
import 'package:mywork/features/jobs/presentation/home_screen.dart';
import 'package:mywork/features/jobs/presentation/job_detail_screen.dart';
import 'package:mywork/features/jobs/presentation/job_search_screen.dart';
import 'package:mywork/features/missions/presentation/missions_screen.dart';
import 'package:mywork/features/notifications/presentation/notifications_screen.dart';
import 'package:mywork/features/onboarding_signup/presentation/candidate_signup_screen.dart';
import 'package:mywork/features/onboarding_signup/presentation/company_signup_screen.dart';
import 'package:mywork/features/profile_candidate/presentation/alerts_screen.dart';
import 'package:mywork/features/profile_candidate/presentation/become_recruiter_screen.dart';
import 'package:mywork/features/profile_candidate/presentation/cv_builder_screen.dart';
import 'package:mywork/features/profile_candidate/presentation/dashboard_screen.dart' as candidate;
import 'package:mywork/features/profile_candidate/presentation/edit_profile_screen.dart';
import 'package:mywork/features/profile_candidate/presentation/my_cvs_screen.dart';
import 'package:mywork/features/profile_candidate/presentation/profile_hub_screen.dart';
import 'package:mywork/features/profile_candidate/presentation/reviews_screen.dart';
import 'package:mywork/features/services_marketplace/presentation/my_services_screen.dart';
import 'package:mywork/features/services_marketplace/presentation/services_browse_screen.dart';
import 'package:mywork/features/shared_misc/presentation/coming_soon_screen.dart';
import 'package:mywork/features/support_chat/presentation/contact_screen.dart';
import 'package:mywork/features/support_chat/presentation/messages_screen.dart';
import 'app_shell.dart';

const _authRoutes = {
  '/bienvenue',
  '/auth',
  '/reset-password',
  '/choisir-espace',
  '/inscription',
  '/entreprises/inscription',
};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final loc = state.matchedLocation;

      if (user == null) {
        if (loc == '/splash' || !_authRoutes.contains(loc)) return '/bienvenue';
        return null;
      }

      final role = ref.read(roleProvider).valueOrNull;
      if (role == null) {
        return loc == '/splash' ? null : '/splash';
      }

      if (role == Role.unknown) {
        return loc == '/choisir-espace' ? null : '/choisir-espace';
      }

      if (loc == '/splash' || _authRoutes.contains(loc)) {
        return homePathForRole(role);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/bienvenue', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/choisir-espace', builder: (context, state) => const ChooseSpaceScreen()),
      GoRoute(path: '/inscription', builder: (context, state) => const CandidateSignupScreen()),
      GoRoute(
        path: '/entreprises/inscription',
        builder: (context, state) => const CompanySignupScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Candidate tabs
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/offres', builder: (context, state) => const JobSearchScreen()),
          GoRoute(path: '/mes-candidatures', builder: (context, state) => const MyApplicationsScreen()),
          GoRoute(path: '/mes-notifications', builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: '/mon-profil', builder: (context, state) => const ProfileHubScreen()),

          // Entreprise tabs
          GoRoute(path: '/entreprise/dashboard', builder: (context, state) => const company.CompanyDashboardScreen()),
          GoRoute(path: '/entreprise/offres', builder: (context, state) => const ManageOffersScreen()),
          GoRoute(
            path: '/entreprise/candidatures',
            builder: (context, state) => const RecruiterApplicationsScreen(),
          ),
          GoRoute(
            path: '/entreprise/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(path: '/entreprise/profil', builder: (context, state) => const CompanyProfileScreen()),
        ],
      ),

      // Full-screen routes pushed on top of the shell
      GoRoute(
        path: '/offres/:id',
        builder: (context, state) => JobDetailScreen(offreId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/favoris', builder: (context, state) => const FavoritesScreen()),
      GoRoute(path: '/missions', builder: (context, state) => const MissionsScreen()),
      GoRoute(path: '/messages', builder: (context, state) => const MessagesScreen()),
      GoRoute(path: '/services', builder: (context, state) => const ServicesBrowseScreen()),
      GoRoute(path: '/mes-services', builder: (context, state) => const MyServicesScreen()),
      GoRoute(
        path: '/mon-tableau-de-bord',
        builder: (context, state) => const candidate.CandidateDashboardScreen(),
      ),
      GoRoute(path: '/mon-profil/edit', builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: '/mon-cv', builder: (context, state) => const CvBuilderScreen()),
      GoRoute(path: '/mes-cv', builder: (context, state) => const MyCvsScreen()),
      GoRoute(path: '/mes-alertes', builder: (context, state) => const AlertsScreen()),
      GoRoute(path: '/mes-avis', builder: (context, state) => const ReviewsScreen()),
      GoRoute(path: '/devenir-recruteur', builder: (context, state) => const BecomeRecruiterScreen()),
      GoRoute(path: '/contact', builder: (context, state) => const ContactScreen()),
      GoRoute(
        path: '/entreprise/offres/new',
        builder: (context, state) => const EditOfferScreen(),
      ),
      GoRoute(
        path: '/entreprise/offres/:id/edit',
        builder: (context, state) => EditOfferScreen(offreId: state.pathParameters['id']),
      ),

      // Tier 5 — coming soon
      GoRoute(
        path: '/entreprise/fiscal',
        builder: (context, state) => const ComingSoonScreen(
          title: 'Espace fiscal',
          icon: Icons.receipt_long_outlined,
        ),
      ),
      GoRoute(
        path: '/tutoriels',
        builder: (context, state) => const ComingSoonScreen(
          title: 'Tutoriels',
          icon: Icons.play_circle_outline,
        ),
      ),
      GoRoute(
        path: '/securite',
        builder: (context, state) => const ComingSoonScreen(
          title: 'Sécurité',
          icon: Icons.shield_outlined,
        ),
      ),
      GoRoute(
        path: '/verifier',
        builder: (context, state) => const ComingSoonScreen(
          title: 'Vérifier un badge',
          icon: Icons.qr_code_scanner,
        ),
      ),
      GoRoute(
        path: '/c/:id',
        builder: (context, state) => const ComingSoonScreen(
          title: 'Profil candidat vérifié',
          icon: Icons.verified_outlined,
        ),
      ),
      GoRoute(
        path: '/e/:id',
        builder: (context, state) => const ComingSoonScreen(
          title: 'Entreprise vérifiée',
          icon: Icons.verified_outlined,
        ),
      ),
    ],
  );
});

/// Bridges Riverpod provider changes into GoRouter's refreshListenable so
/// auth/role transitions re-run the redirect logic above.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
    ref.listen(roleProvider, (_, __) => notifyListeners());
  }
}
