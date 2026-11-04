import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Firebase without its SDKs: Authentication and Firestore through their public
/// REST APIs, in plain Dart. It works the same on every platform (including
/// Linux and Windows, where the SDKs do not exist) and brings no native code,
/// which is what stores like F-Droid ask for.
///
/// What each person can read and write is still decided by `firestore.rules`:
/// every request carries the person's ID token, and the server checks it.
class FirebaseRest {
  FirebaseRest({
    required this.apiKey,
    required this.projectId,
    http.Client? client,
    this.authHost = 'https://identitytoolkit.googleapis.com',
    this.tokenHost = 'https://securetoken.googleapis.com',
    this.firestoreHost = 'https://firestore.googleapis.com',
    this.emulator = false,
    DateTime Function()? now,
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  /// The Firebase emulators on this computer (`firebase emulators:start`).
  factory FirebaseRest.emulator({required String projectId, http.Client? client}) => FirebaseRest(
    apiKey: 'emulator',
    projectId: projectId,
    client: client,
    authHost: 'http://127.0.0.1:9099/identitytoolkit.googleapis.com',
    tokenHost: 'http://127.0.0.1:9099/securetoken.googleapis.com',
    firestoreHost: 'http://127.0.0.1:8080',
    emulator: true,
  );

  /// The public key of the Firebase project. It identifies the project, it is
  /// not a secret: the rules are what protect the data.
  final String apiKey;
  final String projectId;
  final String authHost;
  final String tokenHost;
  final String firestoreHost;
  final bool emulator;
  final http.Client _client;
  final DateTime Function() _now;

  String? _idToken;
  String? _refreshToken;
  DateTime _expiresAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// A restored session has to ask once for the email; the others bring it.
  bool _emailKnown = false;

  /// The signed-in person, or null.
  String? uid;
  String? email;

  /// The token to keep between runs, so the person stays signed in.
  String? get refreshToken => _refreshToken;
  bool get signedIn => _refreshToken != null && uid != null;

  // Authentication ----------------------------------------------------------------

  Future<void> signUpAnonymously() async {
    _useSession(await _auth('accounts:signUp', {'returnSecureToken': true}));
  }

  Future<void> signInWithPassword(String email, String password) async {
    _useSession(
      await _auth('accounts:signInWithPassword', {'email': email, 'password': password, 'returnSecureToken': true}),
    );
  }

  Future<void> signUpWithPassword(String email, String password) async {
    _useSession(await _auth('accounts:signUp', {'email': email, 'password': password, 'returnSecureToken': true}));
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth('accounts:sendOobCode', {'requestType': 'PASSWORD_RESET', 'email': email}, locale: 'es');
  }

  /// Deletes the account in Authentication. Firestore data is deleted before.
  Future<void> deleteAccount() async {
    final token = await _token();
    await _auth('accounts:delete', {'idToken': token});
    signOut();
  }

  /// Picks up a saved session. Throws [FirebaseRestError] if it no longer works.
  Future<void> restore(String refreshToken) async {
    _refreshToken = refreshToken;
    _expiresAt = DateTime.fromMillisecondsSinceEpoch(0);
    await _token();
  }

  void signOut() {
    _idToken = null;
    _refreshToken = null;
    uid = null;
    email = null;
    _expiresAt = DateTime.fromMillisecondsSinceEpoch(0);
    _emailKnown = false;
  }

  void _useSession(Map<String, Object?> json) {
    _idToken = json['idToken'] as String?;
    _refreshToken = json['refreshToken'] as String?;
    uid = json['localId'] as String?;
    email = json['email'] as String?;
    _emailKnown = true;
    _expiresAt = _now().add(Duration(seconds: int.tryParse('${json['expiresIn']}') ?? 3600));
  }

  Future<String> _token() async {
    final token = _idToken;
    if (token != null && _now().isBefore(_expiresAt.subtract(const Duration(minutes: 1)))) return token;
    final refresh = _refreshToken;
    if (refresh == null) throw const FirebaseRestError(401, 'NO_SESSION', 'Primero entra a tu cuenta.');
    final response = await _send(
      'POST',
      Uri.parse('$tokenHost/v1/token?key=$apiKey'),
      body: 'grant_type=refresh_token&refresh_token=${Uri.encodeQueryComponent(refresh)}',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );
    final json = _decodeOrThrow(response);
    _idToken = json['id_token'] as String?;
    _refreshToken = json['refresh_token'] as String? ?? refresh;
    uid = json['user_id'] as String? ?? uid;
    _expiresAt = _now().add(Duration(seconds: int.tryParse('${json['expires_in']}') ?? 3600));
    if (!_emailKnown) {
      _emailKnown = true;
      final lookup = await _auth('accounts:lookup', {'idToken': _idToken});
      email = ((lookup['users'] as List?)?.firstOrNull as Map?)?['email'] as String?;
    }
    return _idToken!;
  }

  Future<Map<String, Object?>> _auth(String method, Map<String, Object?> body, {String? locale}) async {
    final response = await _send(
      'POST',
      Uri.parse('$authHost/v1/$method?key=$apiKey'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json', 'X-Firebase-Locale': ?locale},
    );
    return _decodeOrThrow(response);
  }

  // Firestore ---------------------------------------------------------------------

  String get _documents => 'projects/$projectId/databases/(default)/documents';

  /// The key goes along always: without a session it is all that identifies the
  /// project, and the rules then see an anonymous visitor (they let anyone read
  /// the published programs of the community).
  Uri _firestore(String path) => Uri.parse('$firestoreHost/v1/$path?key=$apiKey');

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    if (signedIn) 'Authorization': 'Bearer ${await _token()}',
  };

  /// The document at [path], or null if it does not exist.
  Future<Doc?> get(String path) async {
    final response = await _retrying(
      () async => _send('GET', _firestore('$_documents/$path'), headers: await _headers()),
    );
    if (response.statusCode == 404) return null;
    return Doc._fromJson(_decodeOrThrow(response));
  }

  /// Writes a document: replaces it, or with [merge] only changes the fields given.
  /// Values can be [ServerValue.timestamp] and [ArrayUnion].
  Future<void> set(String path, Map<String, Object?> data, {bool merge = false}) =>
      commit([Write.set(path, data, merge: merge)]);

  Future<void> delete(String path) => commit([Write.delete(path)]);

  /// Several writes, applied together.
  Future<void> commit(List<Write> writes) async {
    final body = jsonEncode({
      'writes': [for (final w in writes) w._toJson(_documents)],
    });
    final response = await _retrying(
      () async => _send('POST', _firestore('$_documents:commit'), body: body, headers: await _headers()),
    );
    _decodeOrThrow(response);
  }

  /// The documents of [collection] (inside [parent] when it is a subcollection)
  /// that pass every filter of [where], in the order of [orderBy].
  Future<List<Doc>> query(
    String collection, {
    String parent = '',
    Map<String, Object?> where = const {},
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    final response = await _retrying(
      () async => _send(
        'POST',
        _firestore('${_parentPath(parent)}:runQuery'),
        body: jsonEncode({'structuredQuery': _structured(collection, where, orderBy, descending, limit)}),
        headers: await _headers(),
      ),
    );
    final results = _decodeList(response);
    return [
      for (final item in results)
        if (item is Map && item['document'] != null) Doc._fromJson((item['document'] as Map).cast<String, Object?>()),
    ];
  }

  /// How many documents [collection] has.
  Future<int> count(String collection, {String parent = '', Map<String, Object?> where = const {}}) async {
    final response = await _retrying(
      () async => _send(
        'POST',
        _firestore('${_parentPath(parent)}:runAggregationQuery'),
        body: jsonEncode({
          'structuredAggregationQuery': {
            'structuredQuery': _structured(collection, where, null, false, null),
            'aggregations': [
              {'alias': 'n', 'count': <String, Object?>{}},
            ],
          },
        }),
        headers: await _headers(),
      ),
    );
    final first = _decodeList(response).firstOrNull as Map?;
    final fields = ((first?['result'] as Map?)?['aggregateFields'] as Map?) ?? const {};
    return int.tryParse('${(fields['n'] as Map?)?['integerValue'] ?? 0}') ?? 0;
  }

  String _parentPath(String parent) => parent.isEmpty ? _documents : '$_documents/$parent';

  Map<String, Object?> _structured(
    String collection,
    Map<String, Object?> where,
    String? orderBy,
    bool descending,
    int? limit,
  ) {
    final filters = [
      for (final entry in where.entries)
        {
          'fieldFilter': {
            'field': {'fieldPath': entry.key},
            'op': 'EQUAL',
            'value': encodeValue(entry.value),
          },
        },
    ];
    return {
      'from': [
        {'collectionId': collection},
      ],
      if (filters.length == 1) 'where': filters.single,
      if (filters.length > 1)
        'where': {
          'compositeFilter': {'op': 'AND', 'filters': filters},
        },
      if (orderBy != null)
        'orderBy': [
          {
            'field': {'fieldPath': orderBy},
            'direction': descending ? 'DESCENDING' : 'ASCENDING',
          },
        ],
      'limit': ?limit,
    };
  }

  // HTTP ----------------------------------------------------------------------------

  /// Retries once with a fresh token when the server says the token is not good.
  Future<http.Response> _retrying(Future<http.Response> Function() request) async {
    final first = await request();
    if (first.statusCode != 401) return first;
    _expiresAt = DateTime.fromMillisecondsSinceEpoch(0);
    return request();
  }

  Future<http.Response> _send(String method, Uri uri, {Object? body, Map<String, String>? headers}) async {
    try {
      final request = http.Request(method, uri);
      if (headers != null) request.headers.addAll(headers);
      if (body is String) request.body = body;
      final streamed = await _client.send(request).timeout(const Duration(seconds: 30));
      return await http.Response.fromStream(streamed);
    } on FirebaseRestError {
      rethrow;
    } on Exception {
      // A network failure: no answer, a timeout, a closed connection.
      throw const FirebaseRestError(0, 'NETWORK', 'No hay conexión a internet.');
    }
  }

  Map<String, Object?> _decodeOrThrow(http.Response response) {
    final decoded = _tryDecode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map ? decoded.cast<String, Object?>() : <String, Object?>{};
    }
    throw _errorOf(response, decoded);
  }

  List<Object?> _decodeList(http.Response response) {
    final decoded = _tryDecode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) return decoded is List ? decoded : const [];
    throw _errorOf(response, decoded);
  }

  Object? _tryDecode(http.Response response) {
    try {
      return response.body.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }

  FirebaseRestError _errorOf(http.Response response, Object? decoded) {
    // Firestore's queries answer with a list; the rest, with an object.
    final body = decoded is List && decoded.isNotEmpty ? decoded.first : decoded;
    final error = body is Map ? body['error'] : null;
    final message = (error is Map ? error['message'] : error)?.toString() ?? 'HTTP ${response.statusCode}';
    final status = error is Map ? error['status']?.toString() : null;
    return FirebaseRestError(response.statusCode, status ?? message.split(' ').first.split(':').first, message);
  }
}

/// A failed call. [code] is Firebase's: `EMAIL_EXISTS`, `PERMISSION_DENIED`...
class FirebaseRestError implements Exception {
  const FirebaseRestError(this.statusCode, this.code, this.message);

  /// The HTTP status, or 0 when there was no answer.
  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'FirebaseRestError($statusCode, $code): $message';
}

/// A document: its id, its full path and its fields as plain Dart values.
class Doc {
  const Doc(this.path, this.data);

  factory Doc._fromJson(Map<String, Object?> json) {
    final name = json['name'] as String? ?? '';
    final path = name.contains('/documents/') ? name.split('/documents/').last : name;
    final fields = ((json['fields'] as Map?) ?? const {}).cast<String, Object?>();
    return Doc(path, {for (final e in fields.entries) e.key: decodeValue(e.value)});
  }

  final String path;
  final Map<String, Object?> data;

  String get id => path.split('/').last;
}

/// Something the server fills in when it writes.
enum ServerValue { timestamp }

/// Adds these elements to a list field, without repeating the ones already there.
class ArrayUnion {
  const ArrayUnion(this.values);

  final List<Object?> values;
}

/// One write of a [FirebaseRest.commit].
class Write {
  Write.set(this.path, this.data, {this.merge = false}) : delete = false;
  Write.delete(this.path) : data = const {}, merge = false, delete = true;

  final String path;
  final Map<String, Object?> data;
  final bool merge;
  final bool delete;

  Map<String, Object?> _toJson(String documents) {
    final name = '$documents/$path';
    if (delete) return {'delete': name};
    final fields = <String, Object?>{};
    final transforms = <Map<String, Object?>>[];
    for (final entry in data.entries) {
      final value = entry.value;
      if (value == ServerValue.timestamp) {
        transforms.add({'fieldPath': entry.key, 'setToServerValue': 'REQUEST_TIME'});
      } else if (value is ArrayUnion) {
        transforms.add({
          'fieldPath': entry.key,
          'appendMissingElements': {
            'values': [for (final v in value.values) encodeValue(v)],
          },
        });
      } else {
        fields[entry.key] = encodeValue(value);
      }
    }
    return {
      'update': {'name': name, 'fields': fields},
      if (merge) 'updateMask': {'fieldPaths': fields.keys.toList()},
      if (transforms.isNotEmpty) 'updateTransforms': transforms,
    };
  }
}

/// A new id for a document, like the ones Firestore makes: 20 letters and digits.
String newDocumentId([Random? random]) {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final r = random ?? Random.secure();
  return String.fromCharCodes([for (var i = 0; i < 20; i++) alphabet.codeUnitAt(r.nextInt(alphabet.length))]);
}

/// A Dart value as Firestore writes it in JSON.
Map<String, Object?> encodeValue(Object? value) => switch (value) {
  null => {'nullValue': null},
  bool b => {'booleanValue': b},
  int i => {'integerValue': '$i'},
  double d => {'doubleValue': d},
  String s => {'stringValue': s},
  DateTime t => {'timestampValue': t.toUtc().toIso8601String()},
  List l => {
    'arrayValue': {
      'values': [for (final v in l) encodeValue(v)],
    },
  },
  Map m => {
    'mapValue': {
      'fields': {for (final e in m.entries) '${e.key}': encodeValue(e.value)},
    },
  },
  _ => throw ArgumentError('Firestore no guarda un ${value.runtimeType}.'),
};

/// A Firestore JSON value as a Dart one.
Object? decodeValue(Object? json) {
  if (json is! Map) return null;
  if (json.containsKey('stringValue')) return json['stringValue'];
  if (json.containsKey('integerValue')) return int.tryParse('${json['integerValue']}') ?? 0;
  if (json.containsKey('doubleValue')) return (json['doubleValue'] as num).toDouble();
  if (json.containsKey('booleanValue')) return json['booleanValue'];
  if (json.containsKey('timestampValue')) return DateTime.tryParse('${json['timestampValue']}');
  if (json.containsKey('arrayValue')) {
    return [for (final v in ((json['arrayValue'] as Map)['values'] as List?) ?? const []) decodeValue(v)];
  }
  if (json.containsKey('mapValue')) {
    final fields = (((json['mapValue'] as Map)['fields']) as Map?) ?? const {};
    return {for (final e in fields.entries) '${e.key}': decodeValue(e.value)};
  }
  return null;
}
