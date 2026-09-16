/// Mirrors the web app's Role type (src/hooks/useAuth.tsx) exactly —
/// note "entreprise" (not "recruteur") is the effective UI role for companies.
enum Role { guest, unknown, candidat, entreprise, admin }

String homePathForRole(Role role) {
  switch (role) {
    case Role.admin:
      // Admin back-office is out of scope for this app; land admins on the
      // candidate home instead (mirrors the web app only opening a candidat
      // espace for admins who also have a candidats row).
      return '/';
    case Role.entreprise:
      return '/entreprise/dashboard';
    case Role.candidat:
      return '/';
    case Role.unknown:
      return '/choisir-espace';
    case Role.guest:
      return '/';
  }
}
