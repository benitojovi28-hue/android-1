import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mywork/features/auth/data/role_repository.dart';
import 'package:mywork/features/auth/domain/role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef _Handler = Future<http.Response> Function(http.Request request);

RoleRepository _buildRepository(_Handler handler) {
  final client = SupabaseClient(
    'https://example.supabase.co',
    'anon-key',
    httpClient: MockClient(handler),
  );
  return RoleRepository(client);
}

http.Response _json(http.Request request, Object? body, {int status = 200}) {
  return http.Response(jsonEncode(body), status, request: request);
}

http.Response _notFound(http.Request request) {
  return http.Response(jsonEncode({'message': 'not found'}), 404, request: request);
}

void main() {
  group('RoleRepository.fetchAccountRole', () {
    test('maps the RPC result to admin/entreprise/candidat', () async {
      for (final entry in {'admin': Role.admin, 'entreprise': Role.entreprise, 'candidat': Role.candidat}.entries) {
        final repo = _buildRepository((request) async {
          if (request.url.path.endsWith('/rpc/mon_espace_compte')) {
            return _json(request, entry.key);
          }
          return _notFound(request);
        });

        expect(await repo.fetchAccountRole('user-1'), entry.value);
      }
    });

    test('falls back to the user_roles table when the RPC value is unrecognized', () async {
      final repo = _buildRepository((request) async {
        if (request.url.path.endsWith('/rpc/mon_espace_compte')) {
          return _json(request, 'not_a_role');
        }
        if (request.url.path.endsWith('/user_roles')) {
          expect(request.url.queryParameters['user_id'], 'eq.user-1');
          return _json(request, [
            {'role': 'recruteur'},
          ]);
        }
        return _notFound(request);
      });

      expect(await repo.fetchAccountRole('user-1'), Role.entreprise);
    });

    test('falls back to the user_roles table when the RPC call throws', () async {
      final repo = _buildRepository((request) async {
        if (request.url.path.endsWith('/rpc/mon_espace_compte')) {
          return _json(request, {'message': 'function not found'}, status: 404);
        }
        if (request.url.path.endsWith('/user_roles')) {
          return _json(request, [
            {'role': 'user'},
          ]);
        }
        return _notFound(request);
      });

      expect(await repo.fetchAccountRole('user-1'), Role.candidat);
    });

    test('maps user_roles rows to admin over recruteur/user when multiple roles exist', () async {
      final repo = _buildRepository((request) async {
        if (request.url.path.endsWith('/rpc/mon_espace_compte')) {
          return _json(request, {'message': 'nope'}, status: 500);
        }
        if (request.url.path.endsWith('/user_roles')) {
          return _json(request, [
            {'role': 'user'},
            {'role': 'admin'},
          ]);
        }
        return _notFound(request);
      });

      expect(await repo.fetchAccountRole('user-1'), Role.admin);
    });

    test('returns unknown when the user_roles table has no matching role', () async {
      final repo = _buildRepository((request) async {
        if (request.url.path.endsWith('/rpc/mon_espace_compte')) {
          return _json(request, {'message': 'nope'}, status: 500);
        }
        if (request.url.path.endsWith('/user_roles')) {
          return _json(request, <Map<String, dynamic>>[]);
        }
        return _notFound(request);
      });

      expect(await repo.fetchAccountRole('user-1'), Role.unknown);
    });

    test('returns unknown when both the RPC and the table fallback fail', () async {
      final repo = _buildRepository((request) async {
        return _json(request, {'message': 'down'}, status: 500);
      });

      expect(await repo.fetchAccountRole('user-1'), Role.unknown);
    });
  });

  group('RoleRepository.ensureCandidatProfile', () {
    test('returns the provisioned candidat id on success', () async {
      final repo = _buildRepository((request) async {
        expect(request.url.path, endsWith('/rpc/assurer_profil_candidat'));
        return _json(request, 'candidat-123');
      });

      expect(await repo.ensureCandidatProfile(), 'candidat-123');
    });

    test('swallows RPC errors into null', () async {
      final repo = _buildRepository((request) async {
        return _json(request, {'message': 'boom'}, status: 500);
      });

      expect(await repo.ensureCandidatProfile(), isNull);
    });
  });

  group('RoleRepository.ensureEntrepriseProfile', () {
    test('returns the provisioned entreprise id on success', () async {
      final repo = _buildRepository((request) async {
        expect(request.url.path, endsWith('/rpc/assurer_profil_entreprise'));
        return _json(request, 'entreprise-456');
      });

      expect(await repo.ensureEntrepriseProfile(), 'entreprise-456');
    });

    test('swallows RPC errors into null', () async {
      final repo = _buildRepository((request) async {
        return _json(request, {'message': 'boom'}, status: 500);
      });

      expect(await repo.ensureEntrepriseProfile(), isNull);
    });
  });
}
