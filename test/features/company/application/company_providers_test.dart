import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/features/company/data/company_repository.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/entreprise.dart';
import 'package:mywork/models/offre.dart';

class FakeCompanyRepository implements CompanyRepository {
  FakeCompanyRepository({this.company});

  Entreprise? company;
  bool myOffersCalled = false;
  bool allApplicationsCalled = false;
  String? lastEntrepriseIdForOffers;
  String? lastEntrepriseIdForApplications;
  List<Offre> offers = const [];
  List<Candidature> applications = const [];

  @override
  Future<Entreprise?> myCompany() async => company;

  @override
  Future<List<Offre>> myOffers(String entrepriseId) async {
    myOffersCalled = true;
    lastEntrepriseIdForOffers = entrepriseId;
    return offers;
  }

  @override
  Future<List<Candidature>> allApplications(String entrepriseId) async {
    allApplicationsCalled = true;
    lastEntrepriseIdForApplications = entrepriseId;
    return applications;
  }

  @override
  Future<void> updateCompany(String entrepriseId, Map<String, dynamic> changes) {
    throw UnimplementedError();
  }

  @override
  Future<String> uploadDocument({
    required String folderId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Offre> createOffer(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateOffer(String id, Map<String, dynamic> changes) {
    throw UnimplementedError();
  }

  @override
  Future<void> archiveOffer(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Candidature>> applicationsForOffer(String offreId) {
    throw UnimplementedError();
  }
}

const _entreprise = Entreprise(id: 'ent1', userId: 'user1', nom: 'Acme');

void main() {
  group('myOffersProvider', () {
    test('returns an empty list without calling the repository when there is no company', () async {
      final repo = FakeCompanyRepository(company: null);
      final container = ProviderContainer(
        overrides: [companyRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final offers = await container.read(myOffersProvider.future);

      expect(offers, isEmpty);
      expect(repo.myOffersCalled, isFalse);
    });

    test('resolves the offers for the current company when one exists', () async {
      final offre = const Offre(id: 'o1', titre: 'Développeur Flutter');
      final repo = FakeCompanyRepository(company: _entreprise)..offers = [offre];
      final container = ProviderContainer(
        overrides: [companyRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final offers = await container.read(myOffersProvider.future);

      expect(offers, [offre]);
      expect(repo.lastEntrepriseIdForOffers, 'ent1');
    });
  });

  group('recruiterApplicationsProvider', () {
    test('returns an empty list without calling the repository when there is no company', () async {
      final repo = FakeCompanyRepository(company: null);
      final container = ProviderContainer(
        overrides: [companyRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final applications = await container.read(recruiterApplicationsProvider.future);

      expect(applications, isEmpty);
      expect(repo.allApplicationsCalled, isFalse);
    });

    test('resolves all applications for the current company when one exists', () async {
      final candidature = Candidature(id: 'c1', createdAt: DateTime(2026, 1, 1), statut: 'envoyee');
      final repo = FakeCompanyRepository(company: _entreprise)..applications = [candidature];
      final container = ProviderContainer(
        overrides: [companyRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final applications = await container.read(recruiterApplicationsProvider.future);

      expect(applications, [candidature]);
      expect(repo.lastEntrepriseIdForApplications, 'ent1');
    });
  });
}
