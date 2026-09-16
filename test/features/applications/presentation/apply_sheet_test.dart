import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/applications/application/candidatures_providers.dart';
import 'package:mywork/features/applications/data/candidatures_repository.dart';
import 'package:mywork/features/applications/presentation/apply_sheet.dart';
import 'package:mywork/models/candidat_cv.dart';
import 'package:mywork/models/candidature.dart';

class FakeCandidaturesRepository implements CandidaturesRepository {
  FakeCandidaturesRepository({
    this.cvs = const [],
    this.cvsCompleter,
    this.applyResult,
    this.applyError,
    this.applyCompleter,
  });

  final List<CandidatCvFile> cvs;
  final Completer<List<CandidatCvFile>>? cvsCompleter;
  Map<String, dynamic>? applyResult;
  Object? applyError;
  final Completer<void>? applyCompleter;
  Map<String, dynamic>? lastApplyArgs;

  @override
  Future<List<CandidatCvFile>> myCvs() {
    if (cvsCompleter != null) return cvsCompleter!.future;
    return Future.value(cvs);
  }

  @override
  Future<Map<String, dynamic>> apply({
    required String offreId,
    String? cvId,
    bool cvNumerique = false,
    Uint8List? cvFichierBytes,
    String? cvFichierNom,
    String? cvFichierMime,
    String? message,
    String? prenom,
    String? nom,
    String? email,
    String? telephone,
  }) async {
    lastApplyArgs = {
      'offreId': offreId,
      'cvId': cvId,
      'cvNumerique': cvNumerique,
      'message': message,
    };
    if (applyCompleter != null) await applyCompleter!.future;
    if (applyError != null) throw applyError!;
    return applyResult ?? {'ok': true, 'candidature': {'id': 'c1'}};
  }

  @override
  Future<CandidatCvFile> addCv({
    required Uint8List bytes,
    required String filename,
    required String mime,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCv(String cvId) {
    throw UnimplementedError();
  }

  @override
  Future<void> changeStatus(String candidatureId, String statut) {
    throw UnimplementedError();
  }

  @override
  Future<List<Candidature>> myApplications({DateTime? du, DateTime? au}) {
    throw UnimplementedError();
  }
}

Widget buildTestApp(FakeCandidaturesRepository repo) {
  return ProviderScope(
    overrides: [candidaturesRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showApplySheet(context, offreId: 'offre-1'),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ApplySheet', () {
    testWidgets('shows a loader while the CV list is loading', (tester) async {
      final cvsCompleter = Completer<List<CandidatCvFile>>();
      final repo = FakeCandidaturesRepository(cvsCompleter: cvsCompleter);

      await tester.pumpWidget(buildTestApp(repo));
      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      cvsCompleter.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('lists the CV MyWork option plus each uploaded CV', (tester) async {
      final repo = FakeCandidaturesRepository(cvs: const [
        CandidatCvFile(id: 'cv1', nom: 'Mon CV.pdf', fichierUrl: 'path/cv1.pdf'),
        CandidatCvFile(id: 'cv2', nom: 'Autre CV.pdf', fichierUrl: 'path/cv2.pdf'),
      ]);

      await tester.pumpWidget(buildTestApp(repo));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('CV MyWork (en ligne)'), findsOneWidget);
      expect(find.text('Mon CV.pdf'), findsOneWidget);
      expect(find.text('Autre CV.pdf'), findsOneWidget);
      expect(find.text('Envoyer ma candidature'), findsOneWidget);
    });

    testWidgets('submit is enabled even with no CV selected and surfaces cvManquant as an error', (tester) async {
      final repo = FakeCandidaturesRepository(
        cvs: const [],
        applyResult: {'ok': false, 'cvManquant': true},
      );

      await tester.pumpWidget(buildTestApp(repo));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton).last);
      expect(button.onPressed, isNotNull);

      await tester.tap(find.text('Envoyer ma candidature'));
      await tester.pumpAndSettle();

      expect(find.text('Choisissez ou téléversez un CV.'), findsOneWidget);
      expect(repo.lastApplyArgs?['cvId'], isNull);
      expect(repo.lastApplyArgs?['cvNumerique'], isFalse);
    });

    testWidgets('shows a spinner on the submit button while apply is pending', (tester) async {
      final applyCompleter = Completer<void>();
      final repo = FakeCandidaturesRepository(cvs: const [], applyCompleter: applyCompleter);

      await tester.pumpWidget(buildTestApp(repo));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Envoyer ma candidature'));
      await tester.pump();

      expect(find.text('Envoyer ma candidature'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      applyCompleter.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('closes the sheet and returns true on a successful submission', (tester) async {
      final repo = FakeCandidaturesRepository(
        cvs: const [CandidatCvFile(id: 'cv1', nom: 'Mon CV.pdf', fichierUrl: 'path/cv1.pdf')],
        applyResult: {'ok': true, 'candidature': {'id': 'c1'}},
      );

      await tester.pumpWidget(buildTestApp(repo));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mon CV.pdf'));
      await tester.pump();
      await tester.tap(find.text('Envoyer ma candidature'));
      await tester.pumpAndSettle();

      expect(find.text('Envoyer ma candidature'), findsNothing);
      expect(find.text('open'), findsOneWidget);
      expect(repo.lastApplyArgs?['cvId'], 'cv1');
    });

    testWidgets('shows the duplicate-application error message', (tester) async {
      final repo = FakeCandidaturesRepository(
        cvs: const [],
        applyResult: {'ok': false, 'duplicate': true},
      );

      await tester.pumpWidget(buildTestApp(repo));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Envoyer ma candidature'));
      await tester.pumpAndSettle();

      expect(find.text('Vous avez déjà postulé à cette offre.'), findsOneWidget);
    });

    testWidgets('shows a generic error message when apply throws', (tester) async {
      final repo = FakeCandidaturesRepository(cvs: const [], applyError: Exception('network down'));

      await tester.pumpWidget(buildTestApp(repo));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Envoyer ma candidature'));
      await tester.pumpAndSettle();

      expect(find.text('Une erreur est survenue. Réessayez.'), findsOneWidget);
    });
  });
}
