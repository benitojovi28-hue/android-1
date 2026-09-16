import 'package:intl/intl.dart';

/// FCFA amount formatting (e.g. "150 000 FCFA"), matching the web app's
/// French/Cameroon number formatting.
String formatFcfa(num? amount) {
  if (amount == null) return '—';
  final formatter = NumberFormat.decimalPattern('fr_FR');
  return '${formatter.format(amount)} FCFA';
}

String formatSalaryRange({num? min, num? max, String? texte}) {
  if (texte != null && texte.trim().isNotEmpty) return texte;
  if (min != null && max != null) return '${formatFcfa(min)} - ${formatFcfa(max)}';
  if (min != null) return 'À partir de ${formatFcfa(min)}';
  if (max != null) return "Jusqu'à ${formatFcfa(max)}";
  return 'Salaire non précisé';
}
