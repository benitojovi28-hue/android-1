import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/entreprise.dart';
import 'package:mywork/models/offre.dart';
import 'package:mywork/features/company/data/company_repository.dart';

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepository(ref.watch(supabaseProvider));
});

final myCompanyProvider = FutureProvider.autoDispose<Entreprise?>((ref) {
  return ref.watch(companyRepositoryProvider).myCompany();
});

final myOffersProvider = FutureProvider.autoDispose<List<Offre>>((ref) async {
  final company = await ref.watch(myCompanyProvider.future);
  if (company == null) return const [];
  return ref.watch(companyRepositoryProvider).myOffers(company.id);
});

final recruiterApplicationsProvider = FutureProvider.autoDispose<List<Candidature>>((ref) async {
  final company = await ref.watch(myCompanyProvider.future);
  if (company == null) return const [];
  return ref.watch(companyRepositoryProvider).allApplications(company.id);
});
