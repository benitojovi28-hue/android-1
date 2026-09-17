import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/core/router/app_router.dart';
import 'package:mywork/features/auth/domain/role.dart';

void main() {
  group('resolveAppRedirect — unauthenticated', () {
    test('sends /splash to the welcome screen', () {
      expect(resolveAppRedirect(isAuthenticated: false, role: null, loc: '/splash'), '/bienvenue');
    });

    test('sends a non-public route to the welcome screen', () {
      expect(resolveAppRedirect(isAuthenticated: false, role: null, loc: '/'), '/bienvenue');
      expect(resolveAppRedirect(isAuthenticated: false, role: null, loc: '/mon-profil'), '/bienvenue');
    });

    test('allows the public pre-auth routes through, including both signup screens', () {
      for (final loc in ['/bienvenue', '/auth', '/reset-password', '/choisir-espace', '/inscription', '/entreprises/inscription']) {
        expect(resolveAppRedirect(isAuthenticated: false, role: null, loc: loc), isNull, reason: loc);
      }
    });
  });

  group('resolveAppRedirect — authenticated, role still resolving', () {
    test('sends non-splash locations to /splash while role is null', () {
      expect(resolveAppRedirect(isAuthenticated: true, role: null, loc: '/'), '/splash');
    });

    test('leaves /splash alone while role is null', () {
      expect(resolveAppRedirect(isAuthenticated: true, role: null, loc: '/splash'), isNull);
    });
  });

  group('resolveAppRedirect — authenticated, role unknown (no profile yet)', () {
    test('forces unrelated locations to /choisir-espace', () {
      expect(resolveAppRedirect(isAuthenticated: true, role: Role.unknown, loc: '/'), '/choisir-espace');
    });

    test('leaves /choisir-espace alone', () {
      expect(resolveAppRedirect(isAuthenticated: true, role: Role.unknown, loc: '/choisir-espace'), isNull);
    });

    // Regression test: choisir-espace's own buttons push to /inscription and
    // /entreprises/inscription — these must stay reachable for a role==unknown
    // user or the choose-a-profile-type flow can never complete.
    test('allows /inscription and /entreprises/inscription through', () {
      expect(resolveAppRedirect(isAuthenticated: true, role: Role.unknown, loc: '/inscription'), isNull);
      expect(resolveAppRedirect(isAuthenticated: true, role: Role.unknown, loc: '/entreprises/inscription'), isNull);
    });
  });

  group('resolveAppRedirect — authenticated with a known role', () {
    test('bounces /splash and the pure auth screens to the role\'s home', () {
      for (final loc in ['/splash', '/bienvenue', '/auth', '/reset-password']) {
        expect(resolveAppRedirect(isAuthenticated: true, role: Role.candidat, loc: loc), '/', reason: loc);
        expect(resolveAppRedirect(isAuthenticated: true, role: Role.entreprise, loc: loc), '/entreprise/dashboard',
            reason: loc);
      }
    });

    // Regression test for the "Devenir recruteur" crash: a signed-in
    // candidat pushing /entreprises/inscription used to be immediately
    // redirected back home (it was in the old combined _authRoutes set),
    // which raced with the in-flight push and threw a duplicate-page-key
    // assertion in go_router's Navigator. It must be left alone now.
    test('leaves /entreprises/inscription alone for a signed-in candidat (Devenir recruteur)', () {
      expect(resolveAppRedirect(isAuthenticated: true, role: Role.candidat, loc: '/entreprises/inscription'), isNull);
    });

    test('leaves /inscription alone for a signed-in entreprise user', () {
      expect(resolveAppRedirect(isAuthenticated: true, role: Role.entreprise, loc: '/inscription'), isNull);
    });

    test('leaves ordinary in-app routes alone', () {
      expect(resolveAppRedirect(isAuthenticated: true, role: Role.candidat, loc: '/mon-profil'), isNull);
      expect(resolveAppRedirect(isAuthenticated: true, role: Role.entreprise, loc: '/entreprise/offres'), isNull);
    });

    test('admin lands on the candidat home like candidat/guest', () {
      expect(resolveAppRedirect(isAuthenticated: true, role: Role.admin, loc: '/splash'), '/');
    });
  });
}
