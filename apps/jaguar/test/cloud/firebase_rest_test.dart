import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jaguar/src/cloud/firebase_rest.dart';

/// The calls FirebaseRest makes, checked against a server that only answers.
/// The real server is tested in rest_backend_emulator_test.dart.
void main() {
  group('valores de Firestore', () {
    test('ida y vuelta de cada tipo', () {
      final when = DateTime.utc(2026, 11, 5, 12, 30);
      final original = <String, Object?>{
        'texto': 'hola, "mundo"\n',
        'entero': 42,
        'negativo': -7,
        'real': 2.5,
        'si': true,
        'nada': null,
        'fecha': when,
        'lista': [1, 'dos', false],
        'mapa': {
          'a': 1,
          'b': {'c': 'd'},
        },
        'vacia': <Object?>[],
      };
      final decoded = decodeValue(encodeValue(original));
      expect(decoded, {...original, 'fecha': when});
    });

    test('los enteros viajan como texto, como pide Firestore', () {
      expect(encodeValue(42), {'integerValue': '42'});
      expect(encodeValue(2.5), {'doubleValue': 2.5});
      expect(decodeValue({'integerValue': '9007199254740993'}), 9007199254740993);
    });

    test('un tipo que Firestore no guarda avisa', () {
      expect(() => encodeValue(Object()), throwsArgumentError);
    });
  });

  group('autenticación', () {
    test('entrar como anónimo y como profe, y guardar la sesión', () async {
      final calls = <http.Request>[];
      final rest = _rest((request) {
        calls.add(request);
        if (request.url.path.endsWith('accounts:signUp')) {
          return _json({'idToken': 'T1', 'refreshToken': 'R1', 'localId': 'u1', 'expiresIn': '3600'});
        }
        return _json({
          'idToken': 'T2',
          'refreshToken': 'R2',
          'localId': 'u2',
          'email': 'profe@correo.mx',
          'expiresIn': '3600',
        });
      });
      await rest.signUpAnonymously();
      expect(rest.uid, 'u1');
      expect(rest.refreshToken, 'R1');
      expect(jsonDecode(calls.single.body), {'returnSecureToken': true});

      await rest.signInWithPassword('profe@correo.mx', 'secreto');
      expect(rest.uid, 'u2');
      expect(rest.email, 'profe@correo.mx');
      expect(calls.last.url.path, endsWith('accounts:signInWithPassword'));
      expect(calls.last.url.queryParameters['key'], 'clave');
      expect(jsonDecode(calls.last.body), {
        'email': 'profe@correo.mx',
        'password': 'secreto',
        'returnSecureToken': true,
      });

      rest.signOut();
      expect(rest.signedIn, isFalse);
      expect(rest.uid, isNull);
    });

    test('recuperar la contraseña pide el correo en español', () async {
      late http.Request sent;
      final rest = _rest((request) {
        sent = request;
        return _json({'email': 'a@b.mx'});
      });
      await rest.sendPasswordReset('a@b.mx');
      expect(sent.headers['X-Firebase-Locale'], 'es');
      expect(jsonDecode(sent.body), {'requestType': 'PASSWORD_RESET', 'email': 'a@b.mx'});
    });

    test('restaurar una sesión renueva el token y averigua el correo', () async {
      final paths = <String>[];
      final rest = _rest((request) {
        paths.add(request.url.path);
        if (request.url.path.endsWith('/v1/token')) {
          expect(request.bodyFields, {'grant_type': 'refresh_token', 'refresh_token': 'guardado'});
          return _json({'id_token': 'T', 'refresh_token': 'R-nuevo', 'user_id': 'u9', 'expires_in': '3600'});
        }
        return _json({
          'users': [
            {'email': 'x@y.mx'},
          ],
        });
      });
      await rest.restore('guardado');
      expect(rest.uid, 'u9');
      expect(rest.email, 'x@y.mx');
      expect(rest.refreshToken, 'R-nuevo');
      expect(paths, [endsWith('/v1/token'), endsWith('accounts:lookup')]);
    });

    test('un token vencido se renueva solo antes de la siguiente llamada', () async {
      var now = DateTime.utc(2026, 11, 5, 12);
      final tokens = <String>[];
      final rest = FirebaseRest(
        apiKey: 'clave',
        projectId: 'p',
        now: () => now,
        client: MockClient((request) async {
          if (request.url.path.endsWith('accounts:signUp')) {
            return _json({'idToken': 'viejo', 'refreshToken': 'R', 'localId': 'u', 'expiresIn': '3600'});
          }
          if (request.url.path.endsWith('/v1/token')) {
            return _json({'id_token': 'nuevo', 'refresh_token': 'R', 'user_id': 'u', 'expires_in': '3600'});
          }
          tokens.add(request.headers['Authorization']!);
          return http.Response('{}', 404);
        }),
      );
      await rest.signUpAnonymously();
      await rest.get('users/u');
      now = now.add(const Duration(hours: 2));
      await rest.get('users/u');
      expect(tokens, ['Bearer viejo', 'Bearer nuevo']);
    });

    test('si el servidor dice que el token no sirve, reintenta con uno nuevo', () async {
      var vueltas = 0;
      final rest = _rest((request) {
        if (request.url.path.endsWith('accounts:signUp')) {
          return _json({'idToken': 'A', 'refreshToken': 'R', 'localId': 'u', 'expiresIn': '3600'});
        }
        if (request.url.path.endsWith('/v1/token')) {
          return _json({'id_token': 'B', 'refresh_token': 'R', 'user_id': 'u', 'expires_in': '3600'});
        }
        vueltas++;
        return vueltas == 1
            ? http.Response('{"error":{"code":401,"status":"UNAUTHENTICATED"}}', 401)
            : _json({'name': 'x/documents/users/u', 'fields': {}});
      });
      await rest.signUpAnonymously();
      expect(await rest.get('users/u'), isNotNull);
      expect(vueltas, 2);
    });

    test('los errores de Firebase traen su código', () async {
      final rest = _rest((request) => http.Response('{"error":{"code":400,"message":"EMAIL_EXISTS"}}', 400));
      await expectLater(
        rest.signUpWithPassword('a@b.mx', '123456'),
        throwsA(
          isA<FirebaseRestError>()
              .having((e) => e.code, 'code', 'EMAIL_EXISTS')
              .having((e) => e.statusCode, 'status', 400),
        ),
      );
    });

    test('sin red, el error lo dice', () async {
      final rest = FirebaseRest(
        apiKey: 'k',
        projectId: 'p',
        client: MockClient((_) async => throw http.ClientException('sin red')),
      );
      await expectLater(
        rest.signUpAnonymously(),
        throwsA(
          isA<FirebaseRestError>().having((e) => e.code, 'code', 'NETWORK').having((e) => e.statusCode, 'status', 0),
        ),
      );
    });
  });

  group('Firestore', () {
    FirebaseRest signedIn(http.Response Function(http.Request) onFirestore) => _rest((request) {
      if (request.url.path.endsWith('accounts:signUp')) {
        return _json({'idToken': 'T', 'refreshToken': 'R', 'localId': 'u', 'expiresIn': '3600'});
      }
      return onFirestore(request);
    });

    test('leer un documento da sus campos y un documento que no existe da null', () async {
      final rest = signedIn((request) {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/projects/p/databases/(default)/documents/users/ana');
        return request.url.path.endsWith('ana')
            ? _json({
                'name': 'projects/p/databases/(default)/documents/users/ana',
                'fields': {
                  'alias': {'stringValue': 'Ana'},
                  'clases': {
                    'arrayValue': {
                      'values': [
                        {'stringValue': 'c1'},
                      ],
                    },
                  },
                },
              })
            : http.Response('{}', 404);
      });
      await rest.signUpAnonymously();
      final doc = (await rest.get('users/ana'))!;
      expect(doc.id, 'ana');
      expect(doc.path, 'users/ana');
      expect(doc.data, {
        'alias': 'Ana',
        'clases': ['c1'],
      });
    });

    test('escribir reemplaza el documento y pide la hora al servidor', () async {
      late Map<String, Object?> body;
      final rest = signedIn((request) {
        expect(request.url.path, '/v1/projects/p/databases/(default)/documents:commit');
        body = jsonDecode(request.body) as Map<String, Object?>;
        return _json({});
      });
      await rest.signUpAnonymously();
      await rest.set('classes/c1', {'name': 'Lógica', 'createdAt': ServerValue.timestamp});
      final write = ((body['writes']! as List).single as Map);
      expect(write['update'], {
        'name': 'projects/p/databases/(default)/documents/classes/c1',
        'fields': {
          'name': {'stringValue': 'Lógica'},
        },
      });
      expect(write.containsKey('updateMask'), isFalse, reason: 'sin máscara, el documento se reemplaza');
      expect(write['updateTransforms'], [
        {'fieldPath': 'createdAt', 'setToServerValue': 'REQUEST_TIME'},
      ]);
    });

    test('mezclar solo toca los campos dados y arrayUnion no repite', () async {
      late Map<String, Object?> body;
      final rest = signedIn((request) {
        body = jsonDecode(request.body) as Map<String, Object?>;
        return _json({});
      });
      await rest.signUpAnonymously();
      await rest.set('users/u', {
        'clases': ArrayUnion(['c1']),
      }, merge: true);
      final write = ((body['writes']! as List).single as Map);
      expect(write['updateMask'], {'fieldPaths': <String>[]});
      expect(write['updateTransforms'], [
        {
          'fieldPath': 'clases',
          'appendMissingElements': {
            'values': [
              {'stringValue': 'c1'},
            ],
          },
        },
      ]);
    });

    test('borrar y escribir varios a la vez', () async {
      late Map<String, Object?> body;
      final rest = signedIn((request) {
        body = jsonDecode(request.body) as Map<String, Object?>;
        return _json({});
      });
      await rest.signUpAnonymously();
      await rest.commit([
        Write.delete('a/1'),
        Write.set('a/2', {'x': 1}),
      ]);
      final writes = body['writes']! as List;
      expect(writes.first, {'delete': 'projects/p/databases/(default)/documents/a/1'});
      expect(
        (writes.last as Map)['update'],
        containsPair('fields', {
          'x': {'integerValue': '1'},
        }),
      );
    });

    test('una consulta con filtros, orden y límite', () async {
      late Map<String, Object?> body;
      late Uri url;
      final rest = signedIn((request) {
        url = request.url;
        body = jsonDecode(request.body) as Map<String, Object?>;
        return _json([
          {'readTime': 'x'},
          {
            'document': {
              'name': 'projects/p/databases/(default)/documents/publications/p1',
              'fields': {
                'title': {'stringValue': 'Uno'},
              },
            },
          },
          {
            'document': {
              'name': 'projects/p/databases/(default)/documents/publications/p2',
              'fields': {
                'title': {'stringValue': 'Dos'},
              },
            },
          },
        ]);
      });
      await rest.signUpAnonymously();
      final docs = await rest.query(
        'publications',
        where: {'status': 'publicado', 'kind': 'programa'},
        orderBy: 'createdAt',
        descending: true,
        limit: 60,
      );
      expect(url.path, '/v1/projects/p/databases/(default)/documents:runQuery');
      expect(docs.map((d) => d.id), ['p1', 'p2']);
      final query = body['structuredQuery']! as Map;
      expect(query['from'], [
        {'collectionId': 'publications'},
      ]);
      expect(query['limit'], 60);
      expect(query['orderBy'], [
        {
          'field': {'fieldPath': 'createdAt'},
          'direction': 'DESCENDING',
        },
      ]);
      final filters = ((query['where']! as Map)['compositeFilter']! as Map)['filters']! as List;
      expect(filters, hasLength(2));
      expect(((filters.first as Map)['fieldFilter']! as Map)['op'], 'EQUAL');
    });

    test('una subcolección se consulta desde su documento', () async {
      late Uri url;
      final rest = signedIn((request) {
        url = request.url;
        return _json([
          {'readTime': 'x'},
        ]);
      });
      await rest.signUpAnonymously();
      expect(await rest.query('members', parent: 'classes/c1'), isEmpty);
      expect(url.path, '/v1/projects/p/databases/(default)/documents/classes/c1:runQuery');
    });

    test('contar usa la agregación del servidor', () async {
      final rest = signedIn((request) {
        expect(request.url.path, endsWith('documents/publications/p1:runAggregationQuery'));
        return _json([
          {
            'result': {
              'aggregateFields': {
                'n': {'integerValue': '7'},
              },
            },
          },
        ]);
      });
      await rest.signUpAnonymously();
      expect(await rest.count('useful', parent: 'publications/p1'), 7);
    });

    test('los permisos y la cuota llegan con su código', () async {
      final rest = signedIn(
        (request) => http.Response(
          '{"error":{"code":403,"message":"Missing or insufficient permissions.","status":"PERMISSION_DENIED"}}',
          403,
        ),
      );
      await rest.signUpAnonymously();
      await expectLater(
        rest.get('users/otro'),
        throwsA(isA<FirebaseRestError>().having((e) => e.code, 'code', 'PERMISSION_DENIED')),
      );
      final agotado = signedIn(
        (request) =>
            http.Response('[{"error":{"code":429,"message":"Quota exceeded.","status":"RESOURCE_EXHAUSTED"}}]', 429),
      );
      await agotado.signUpAnonymously();
      await expectLater(
        agotado.query('classes'),
        throwsA(isA<FirebaseRestError>().having((e) => e.code, 'code', 'RESOURCE_EXHAUSTED')),
      );
    });

    test('los ids nuevos tienen 20 letras y números y no se repiten', () {
      final ids = {for (var i = 0; i < 200; i++) newDocumentId()};
      expect(ids, hasLength(200));
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[A-Za-z0-9]{20}$')));
      }
    });
  });
}

FirebaseRest _rest(http.Response Function(http.Request) onRequest) =>
    FirebaseRest(apiKey: 'clave', projectId: 'p', client: MockClient((request) async => onRequest(request)));

http.Response _json(Object body) => http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
