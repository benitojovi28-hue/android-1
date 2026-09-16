import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/auth/domain/role.dart';

class _TabItem {
  const _TabItem({required this.path, required this.label, required this.icon});

  final String path;
  final String label;
  final IconData icon;
}

const _candidatTabs = [
  _TabItem(path: '/', label: 'Accueil', icon: Icons.home_outlined),
  _TabItem(path: '/offres', label: 'Offres', icon: Icons.work_outline),
  _TabItem(path: '/mes-candidatures', label: 'Candidatures', icon: Icons.description_outlined),
  _TabItem(path: '/mes-notifications', label: 'Alertes', icon: Icons.notifications_none),
  _TabItem(path: '/mon-profil', label: 'Profil', icon: Icons.person_outline),
];

const _entrepriseTabs = [
  _TabItem(path: '/entreprise/dashboard', label: 'Tableau', icon: Icons.dashboard_outlined),
  _TabItem(path: '/entreprise/offres', label: 'Offres', icon: Icons.work_outline),
  _TabItem(path: '/entreprise/candidatures', label: 'Candidatures', icon: Icons.description_outlined),
  _TabItem(path: '/entreprise/notifications', label: 'Alertes', icon: Icons.notifications_none),
  _TabItem(path: '/entreprise/profil', label: 'Entreprise', icon: Icons.business_outlined),
];

const _guestTabs = [
  _TabItem(path: '/', label: 'Accueil', icon: Icons.home_outlined),
  _TabItem(path: '/offres', label: 'Offres', icon: Icons.work_outline),
  _TabItem(path: '/auth', label: 'Profil', icon: Icons.person_outline),
];

/// Bottom tab bar shell — mirrors MobileTabBar.tsx's three role-based arrays
/// (candidat / entreprise / guest) exactly.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(roleProvider).valueOrNull;

    final tabs = user == null
        ? _guestTabs
        : role == Role.entreprise
            ? _entrepriseTabs
            : _candidatTabs;

    final location = GoRouterState.of(context).matchedLocation;
    var currentIndex = tabs.indexWhere((t) => t.path == location);
    if (currentIndex < 0) currentIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: tabs
            .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
            .toList(),
        onTap: (index) => context.go(tabs[index].path),
      ),
    );
  }
}
