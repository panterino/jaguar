import 'ast.dart';
import 'builtins.dart';
import 'errors.dart';
import 'lexer.dart';
import 'text.dart';
import 'token.dart';

/// Parses PSeInt-compatible pseudocode (flexible profile) into a [Program].
///
/// Throws a [JaguarError] with a Spanish message on invalid code.
Program parse(String source) => Parser(Lexer(source).tokenize()).parseProgram();

/// Words that cannot be used as variable names.
const _reserved = {
  'algoritmo', 'finalgoritmo', 'proceso', 'finproceso', 'funcion', 'finfuncion', //
  'subproceso', 'finsubproceso', 'subalgoritmo', 'finsubalgoritmo', 'definir',
  'como', 'dimension', 'dimensionar', 'escribir', 'imprimir', 'mostrar', 'leer',
  'si', 'entonces', 'sino', 'finsi', 'segun', 'hacer', 'finsegun', 'mientras',
  'finmientras', 'repetir', 'hasta', 'que', 'para', 'con', 'paso', 'finpara',
  'cada', 'esperar', 'fin', 'y', 'o', 'no', 'mod', 'verdadero', 'falso',
};

/// Words that close a block. Finding one where it does not belong means a
/// block above was left open.
const _closers = {
  'finalgoritmo', 'finproceso', 'finfuncion', 'finsubproceso', 'finsubalgoritmo', //
  'finsi', 'sino', 'finsegun', 'finmientras', 'finpara', 'fin', 'algoritmo',
  'proceso', 'funcion', 'subproceso', 'subalgoritmo',
};

/// Display names used to suggest a fix for a misspelled instruction.
const _statementKeywords = [
  'Definir', 'Dimension', 'Escribir', 'Leer', 'Si', 'Sino', 'Segun', 'Mientras', //
  'Repetir', 'Para', 'Esperar', 'FinSi', 'FinMientras', 'FinPara', 'FinSegun',
  'FinAlgoritmo', 'FinFuncion', 'FinSubProceso',
];

const _types = {
  'entero': JType.entero,
  'real': JType.real,
  'numero': JType.real,
  'numerico': JType.real,
  'logico': JType.logico,
  'caracter': JType.texto,
  'texto': JType.texto,
  'cadena': JType.texto,
};

const _typeNames = ['Entero', 'Real', 'Numero', 'Logico', 'Caracter', 'Texto', 'Cadena'];

const _comparisons = {
  '=': '=', '==': '=', '<>': '<>', '!=': '<>', //
  '<': '<', '>': '>', '<=': '<=', '>=': '>=',
};

class Parser {
  Parser(this._tokens);

  final List<Token> _tokens;
  int _pos = 0;

  /// Every call found, validated once all functions are known. The flag is
  /// true for calls used as a statement.
  final List<(CallExpr, bool)> _calls = [];

  final SourceSpans _spans = SourceSpans();

  /// Line of the last token read.
  int get _previousLine => _tokens[_pos > 0 ? _pos - 1 : 0].line;

  /// Names made with Dimension, so `V(3)` reads as an index (DFD style).
  final Set<String> _arrays = {};

  Program parseProgram() {
    Subprogram? main;
    final functions = <String, Subprogram>{};
    _skipSeparators();
    while (_current.type != TokenType.eof) {
      if (_isWord('algoritmo') || _isWord('proceso')) {
        final sub = _parseMain();
        if (main != null) {
          throw JaguarError.syntax(
            'Solo puede haber un Algoritmo por archivo; ya hay uno en la línea ${main.line}.',
            line: sub.line,
          );
        }
        main = sub;
      } else if (_isWord('funcion') || _isWord('subproceso') || _isWord('subalgoritmo')) {
        final sub = _parseFunction();
        final previous = functions[normalize(sub.name)];
        if (previous != null) {
          throw JaguarError.syntax(
            "La función '${sub.name}' ya fue definida en la línea ${previous.line}.",
            line: sub.line,
          );
        }
        functions[normalize(sub.name)] = sub;
      } else {
        throw _error(
          "El código debe ir dentro de 'Algoritmo' ... 'FinAlgoritmo'.",
          hint: 'Empieza con "Algoritmo mi_programa" y termina con "FinAlgoritmo".',
        );
      }
      _skipSeparators();
    }
    if (main == null) {
      throw JaguarError.syntax(
        "Falta el bloque principal 'Algoritmo ... FinAlgoritmo'.",
        line: 1,
        hint: 'Empieza con "Algoritmo mi_programa" y termina con "FinAlgoritmo".',
      );
    }
    _validateCalls(functions);
    return Program(main, functions, spans: _spans);
  }

  // -------------------------------------------------------------------------
  // Token helpers

  Token get _current => _tokens[_pos];

  Token _lookahead(int offset) {
    final index = _pos + offset;
    return index < _tokens.length ? _tokens[index] : _tokens.last;
  }

  Token _advance() {
    final token = _current;
    if (token.type != TokenType.eof) _pos++;
    return token;
  }

  bool _isWord(String word, [int offset = 0]) {
    final token = _lookahead(offset);
    return token.type == TokenType.word && token.norm == word;
  }

  bool _isSymbol(String symbol, [int offset = 0]) {
    final token = _lookahead(offset);
    return token.type == TokenType.symbol && token.lexeme == symbol;
  }

  bool _isSeparator([int offset = 0]) {
    final token = _lookahead(offset);
    return token.type == TokenType.newline || token.type == TokenType.eof || _isSymbol(';', offset);
  }

  bool _acceptWord(String word) {
    if (!_isWord(word)) return false;
    _advance();
    return true;
  }

  bool _acceptSymbol(String symbol) {
    if (!_isSymbol(symbol)) return false;
    _advance();
    return true;
  }

  bool _acceptAssign() => _acceptSymbol('<-') || _acceptSymbol('=') || _acceptSymbol(':=');

  void _skipSeparators() {
    while (_current.type == TokenType.newline || _isSymbol(';')) {
      _advance();
    }
  }

  JaguarError _error(String message, {Token? at, String? hint}) {
    final token = at ?? _current;
    return JaguarError.syntax(message, line: token.line, column: token.column, hint: hint);
  }

  void _expectWord(String word, String display, String context) {
    if (_acceptWord(word)) return;
    throw _error("Se esperaba '$display' $context, pero encontré ${_current.describe()}.");
  }

  void _expectSymbol(String symbol, String context) {
    if (_acceptSymbol(symbol)) return;
    throw _error("Se esperaba '$symbol' $context, pero encontré ${_current.describe()}.");
  }

  Token _expectIdentifier(String context) {
    final token = _current;
    if (token.type == TokenType.word && !_reserved.contains(token.norm)) return _advance();
    if (token.type == TokenType.word) {
      throw _error("'${token.lexeme}' es una palabra reservada y no puede usarse como nombre $context.");
    }
    throw _error('Se esperaba un nombre $context, pero encontré ${token.describe()}.');
  }

  /// Accepts both `FinSi` and `Fin Si`.
  bool _isEnd(String block) => _isWord('fin$block') || (_isWord('fin') && _isWord(block, 1));

  void _consumeEnd() {
    if (_isWord('fin')) _advance();
    _advance();
  }

  bool _isStrayCloser() =>
      (_current.type == TokenType.word && _closers.contains(_current.norm)) ||
      (_isWord('hasta') && _isWord('que', 1)) ||
      (_isWord('mientras') && _isWord('que', 1)) ||
      _isOtherwise();

  bool _isOtherwise() => _isWord('de') && _isWord('otro', 1) && _isWord('modo', 2);

  void _endStatement() {
    if (_isSeparator()) return;
    // Flexible profile: a keyword may follow on the same line.
    if (_current.type == TokenType.word && _reserved.contains(_current.norm)) return;
    throw _error(
      'Sobra ${_current.describe()} al final de la instrucción.',
      hint: 'Pon cada instrucción en su propia línea o sepáralas con ";".',
    );
  }

  // -------------------------------------------------------------------------
  // Program structure

  Subprogram _parseMain() {
    final start = _advance();
    final isAlgorithm = start.norm == 'algoritmo';
    var name = isAlgorithm ? 'Algoritmo' : 'Proceso';
    if (!_isSeparator()) name = _expectIdentifier('para el algoritmo').lexeme;
    _endStatement();
    final body = _parseBlock(
      open: start,
      endDisplay: isAlgorithm ? 'FinAlgoritmo' : 'FinProceso',
      isTerminator: () => _isEnd('algoritmo') || _isEnd('proceso'),
    );
    _consumeEnd();
    final endLine = _previousLine;
    _endStatement();
    final main = Subprogram(name: name, params: const [], returnVar: null, body: body, line: start.line, isMain: true);
    _spans.setSubprogramEnd(main, endLine);
    return main;
  }

  Subprogram _parseFunction() {
    final start = _advance();
    String? returnVar;
    var nameToken = _expectIdentifier('para la función');
    if (_acceptSymbol('<-') || _acceptSymbol('=')) {
      returnVar = nameToken.lexeme;
      nameToken = _expectIdentifier('para la función');
    }
    final params = <Param>[];
    if (_acceptSymbol('(')) {
      if (!_isSymbol(')')) {
        do {
          final param = _expectIdentifier('para el parámetro');
          var byRef = false;
          if (_acceptWord('por')) {
            if (_acceptWord('referencia')) {
              byRef = true;
            } else if (!_acceptWord('valor')) {
              throw _error("Después de 'Por' se esperaba 'Referencia' o 'Valor'.");
            }
          }
          params.add(Param(param.lexeme, byRef: byRef));
        } while (_acceptSymbol(','));
      }
      _expectSymbol(')', 'para cerrar la lista de parámetros');
    }
    _endStatement();
    final body = _parseBlock(
      open: start,
      endDisplay: 'Fin${start.lexeme}',
      isTerminator: () => _isEnd('funcion') || _isEnd('subproceso') || _isEnd('subalgoritmo'),
    );
    _consumeEnd();
    final endLine = _previousLine;
    _endStatement();
    final function = Subprogram(
      name: nameToken.lexeme,
      params: params,
      returnVar: returnVar,
      body: body,
      line: start.line,
      isMain: false,
    );
    _spans.setSubprogramEnd(function, endLine);
    return function;
  }

  List<Stmt> _parseBlock({required Token open, required String endDisplay, required bool Function() isTerminator}) {
    final statements = <Stmt>[];
    while (true) {
      _skipSeparators();
      if (_current.type == TokenType.eof) throw _missingEnd(open, endDisplay);
      if (isTerminator()) return statements;
      if (_isStrayCloser()) {
        throw _error(
          "Encontré ${_current.describe()}, pero antes falta '$endDisplay' para cerrar "
          "el '${open.lexeme}' de la línea ${open.line}.",
        );
      }
      statements.add(_parseStatement());
    }
  }

  JaguarError _missingEnd(Token open, String endDisplay) => JaguarError.syntax(
    "Falta '$endDisplay' para cerrar el '${open.lexeme}' de la línea ${open.line}.",
    line: open.line,
    column: open.column,
  );

  // -------------------------------------------------------------------------
  // Statements

  Stmt _parseStatement() {
    final token = _current;
    if (token.type != TokenType.word) {
      throw _error('Esta línea no empieza con una instrucción válida (encontré ${token.describe()}).');
    }
    final Stmt statement = switch (token.norm) {
      'definir' => _parseDefine(),
      'dimension' || 'dimensionar' => _parseDimension(),
      'escribir' || 'imprimir' || 'mostrar' => _parseWrite(),
      'leer' => _parseRead(),
      'si' => _parseIf(),
      'segun' => _parseSwitch(),
      'mientras' => _parseWhile(),
      'repetir' => _parseRepeat(),
      'para' => _isWord('cada', 1) ? _parseForEach() : _parseFor(),
      'esperar' => _parseWait(),
      'borrarpantalla' || 'limpiarpantalla' => _parseClear(),
      'borrar' || 'limpiar' when _isWord('pantalla', 1) => _parseClear(),
      _ => _parseAssignmentOrCall(),
    };
    _spans.setEnd(statement, _previousLine);
    _endStatement();
    return statement;
  }

  Stmt _parseAssignmentOrCall() {
    final name = _current;
    if (_reserved.contains(name.norm)) {
      if (_isSymbol('<-', 1) || _isSymbol('=', 1) || _isSymbol('[', 1)) {
        throw _error(
          "'${name.lexeme}' es una palabra reservada y no puede usarse como nombre de variable.",
          hint: switch (name.norm) {
            'y' => "'Y' es el operador lógico. Usa otro nombre, por ejemplo 'y1' o 'coordY'.",
            'o' => "'O' es el operador lógico. Usa otro nombre, por ejemplo 'o1'.",
            _ => 'Usa otro nombre.',
          },
        );
      }
      throw _error("No se esperaba '${name.lexeme}' aquí.");
    }
    if (_isSymbol('<-', 1) || _isSymbol('=', 1) || _isSymbol(':=', 1) || _isSymbol('[', 1) || _isArrayParen(1)) {
      final target = _parseTarget();
      if (!_acceptAssign()) {
        throw _error("Se esperaba '<-' para asignar un valor a '${name.lexeme}'.");
      }
      return AssignStmt(target, _parseExpression(), name.line, name.column);
    }
    if (_isSymbol('(', 1)) {
      _advance();
      _advance();
      final call = _parseCall(name);
      _calls.add((call, true));
      return CallStmt(call, name.line, name.column);
    }
    if (_isSeparator(1)) {
      _advance();
      final call = CallExpr(name.lexeme, const [], name.line, name.column);
      _calls.add((call, true));
      return CallStmt(call, name.line, name.column);
    }
    // Something like `Escrivir "hola"`: most likely a misspelled keyword.
    final suggestion = closestMatch(name.lexeme, _statementKeywords);
    throw _error(
      "No entiendo la instrucción '${name.lexeme}'.",
      hint: suggestion != null
          ? "¿Quisiste decir '$suggestion'?"
          : "Revisa que esté bien escrita. Si querías guardar un valor, usa '${name.lexeme} <- valor'.",
    );
  }

  Expr _parseTarget() {
    final isArray = _isArrayParen(1);
    final name = _expectIdentifier('de variable');
    if (_isSymbol('[')) return IndexExpr(name.lexeme, _parseIndices(), name.line, name.column);
    if (isArray) return IndexExpr(name.lexeme, _parseParenIndices(), name.line, name.column);
    return VarRef(name.lexeme, name.line, name.column);
  }

  /// DFD indexes arrays with parentheses, `V(3)`. For a name made with
  /// Dimension that means the same as `V[3]`; otherwise it's a call.
  bool _isArrayParen(int offset) =>
      _isSymbol('(', offset) &&
      _arrays.contains(_lookahead(offset - 1).norm) &&
      _lookahead(offset - 1).type == TokenType.word;

  List<Expr> _parseParenIndices() {
    _expectSymbol('(', 'para el índice');
    final indices = [_parseExpression()];
    while (_acceptSymbol(',')) {
      indices.add(_parseExpression());
    }
    _expectSymbol(')', 'para cerrar el índice');
    return indices;
  }

  List<Expr> _parseIndices() {
    final indices = <Expr>[];
    while (_acceptSymbol('[')) {
      indices.add(_parseExpression());
      while (_acceptSymbol(',')) {
        indices.add(_parseExpression());
      }
      _expectSymbol(']', 'para cerrar el índice');
    }
    return indices;
  }

  Stmt _parseDefine() {
    final start = _advance();
    final names = <String>[];
    do {
      names.add(_expectIdentifier('de variable').lexeme);
    } while (_acceptSymbol(','));
    if (!(_acceptWord('como') || _acceptWord('es'))) {
      throw _error("Se esperaba 'Como' y un tipo, por ejemplo: Definir ${names.first} Como Entero.");
    }
    final typeToken = _current;
    final type = typeToken.type == TokenType.word ? _types[typeToken.norm] : null;
    if (type == null) {
      final suggestion = typeToken.type == TokenType.word ? closestMatch(typeToken.lexeme, _typeNames) : null;
      throw _error(
        '${typeToken.describe()} no es un tipo de dato válido.',
        hint: suggestion != null
            ? "¿Quisiste decir '$suggestion'?"
            : 'Los tipos son Entero, Real, Logico, Caracter y Texto.',
      );
    }
    _advance();
    return DefineStmt(names, type, start.line, start.column);
  }

  Stmt _parseDimension() {
    final start = _advance();
    final arrays = <ArrayDecl>[];
    do {
      final name = _expectIdentifier('de arreglo');
      if (!_isSymbol('[')) {
        throw _error("Se esperaba '[' con el tamaño del arreglo, por ejemplo: Dimension ${name.lexeme}[10].");
      }
      arrays.add(ArrayDecl(name.lexeme, _parseIndices(), name.line, name.column));
      _arrays.add(name.norm);
    } while (_acceptSymbol(','));
    return DimensionStmt(arrays, start.line, start.column);
  }

  bool _acceptNoNewline() {
    if (_isWord('sin') && (_isWord('saltar', 1) || _isWord('bajar', 1))) {
      _advance();
      _advance();
      return true;
    }
    return _acceptWord('sinsaltar') || _acceptWord('sinbajar');
  }

  Stmt _parseWrite() {
    final start = _advance();
    var newline = !_acceptNoNewline();
    final values = <Expr>[];
    if (!_isSeparator() && !_isWord('sin')) {
      do {
        values.add(_parseExpression());
      } while (_acceptSymbol(','));
    }
    if (_acceptNoNewline()) newline = false;
    // Escribir Hola mundo: a text without quotes reads as loose variables.
    if (values.isNotEmpty && values.last is VarRef && _current.type == TokenType.word && !_isSeparator()) {
      final words = [(values.last as VarRef).name];
      for (var i = 0; !_isSeparator(i) && _lookahead(i).type == TokenType.word; i++) {
        words.add(_lookahead(i).lexeme);
      }
      throw _error(
        'Parece un texto sin comillas.',
        hint: 'Los textos van entre comillas: Escribir "${words.join(' ')}"',
      );
    }
    return WriteStmt(values, start.line, start.column, newline: newline);
  }

  Stmt _parseRead() {
    final start = _advance();
    final targets = <Expr>[];
    do {
      targets.add(_parseTarget());
    } while (_acceptSymbol(','));
    return ReadStmt(targets, start.line, start.column);
  }

  Stmt _parseIf() {
    final start = _advance();
    final condition = _parseExpression();
    _acceptWord('entonces');
    final thenBody = _parseBlock(open: start, endDisplay: 'FinSi', isTerminator: () => _isWord('sino') || _isEnd('si'));
    List<Stmt>? elseBody;
    int? elseLine;
    if (_isWord('sino')) {
      elseLine = _advance().line;
      elseBody = _parseBlock(open: start, endDisplay: 'FinSi', isTerminator: () => _isEnd('si'));
    }
    _consumeEnd();
    final statement = IfStmt(condition, thenBody, elseBody, start.line, start.column);
    if (elseLine != null) _spans.setElse(statement, elseLine);
    return statement;
  }

  Stmt _parseSwitch() {
    final start = _advance();
    final subject = _parseExpression();
    _acceptWord('hacer');
    final cases = <SwitchCase>[];
    final caseLines = <int>[];
    List<Stmt>? otherwise;
    int? otherwiseLine;
    while (true) {
      _skipSeparators();
      if (_current.type == TokenType.eof) throw _missingEnd(start, 'FinSegun');
      if (_isEnd('segun')) break;
      if (_isOtherwise()) {
        otherwiseLine = _current.line;
        _advance();
        _advance();
        _advance();
        _acceptSymbol(':');
        otherwise = _parseCaseBody(start);
        continue;
      }
      caseLines.add(_current.line);
      final values = _tryCaseLabel();
      if (values == null) {
        throw _error(
          "Dentro de 'Segun' cada opción empieza con un valor seguido de ':'.",
          hint: 'Por ejemplo:  1: Escribir "uno"',
        );
      }
      cases.add(SwitchCase(values, _parseCaseBody(start)));
    }
    _consumeEnd();
    final statement = SwitchStmt(subject, cases, otherwise, start.line, start.column);
    for (var i = 0; i < cases.length; i++) {
      _spans.setCase(cases[i], caseLines[i]);
    }
    if (otherwiseLine != null) _spans.setOtherwise(statement, otherwiseLine);
    return statement;
  }

  /// Parses `valor, valor:` if that is what follows; otherwise restores the
  /// position and returns null.
  List<Expr>? _tryCaseLabel() {
    final savedPos = _pos;
    final savedCalls = _calls.length;
    try {
      if ((_isWord('caso') || _isWord('opcion')) && !_isSymbol('<-', 1)) _advance();
      final values = [_parseExpression()];
      while (_acceptSymbol(',')) {
        values.add(_parseExpression());
      }
      if (_acceptSymbol(':')) return values;
    } on JaguarError {
      // Not a label.
    }
    _pos = savedPos;
    _calls.length = savedCalls;
    return null;
  }

  List<Stmt> _parseCaseBody(Token open) {
    final statements = <Stmt>[];
    while (true) {
      _skipSeparators();
      if (_current.type == TokenType.eof) throw _missingEnd(open, 'FinSegun');
      if (_isEnd('segun') || _isOtherwise()) return statements;
      final savedPos = _pos;
      final savedCalls = _calls.length;
      final isLabel = _tryCaseLabel() != null;
      _pos = savedPos;
      _calls.length = savedCalls;
      if (isLabel) return statements;
      if (_isStrayCloser()) {
        throw _error(
          "Encontré ${_current.describe()}, pero antes falta 'FinSegun' para cerrar "
          "el '${open.lexeme}' de la línea ${open.line}.",
        );
      }
      statements.add(_parseStatement());
    }
  }

  Stmt _parseWhile() {
    final start = _advance();
    final condition = _parseExpression();
    _acceptWord('hacer');
    final body = _parseBlock(open: start, endDisplay: 'FinMientras', isTerminator: () => _isEnd('mientras'));
    _consumeEnd();
    return WhileStmt(condition, body, start.line, start.column);
  }

  Stmt _parseRepeat() {
    final start = _advance();
    final body = _parseBlock(
      open: start,
      endDisplay: 'Hasta Que',
      isTerminator: () => (_isWord('hasta') || _isWord('mientras')) && _isWord('que', 1),
    );
    final untilTrue = _isWord('hasta');
    _advance();
    _advance();
    final condition = _parseExpression();
    return RepeatStmt(body, condition, start.line, start.column, untilTrue: untilTrue);
  }

  Stmt _parseFor() {
    final start = _advance();
    final variable = _expectIdentifier('para la variable del ciclo');
    if (!_acceptAssign()) {
      throw _error(
        "Se esperaba '<-' después de '${variable.lexeme}'.",
        hint: 'Por ejemplo: Para ${variable.lexeme} <- 1 Hasta 10 Hacer',
      );
    }
    final from = _parseExpression();
    _expectWord('hasta', 'Hasta', 'en el ciclo Para');
    final to = _parseExpression();
    Expr? step;
    if (_acceptWord('con')) {
      _expectWord('paso', 'Paso', "después de 'Con'");
      step = _parseExpression();
    }
    _acceptWord('hacer');
    final body = _parseBlock(open: start, endDisplay: 'FinPara', isTerminator: () => _isEnd('para'));
    _consumeEnd();
    return ForStmt(variable.lexeme, from, to, step, body, start.line, start.column);
  }

  Stmt _parseForEach() {
    final start = _advance();
    _advance(); // cada
    final variable = _expectIdentifier('para la variable del ciclo');
    _expectWord('de', 'De', 'en el ciclo Para Cada');
    final array = _expectIdentifier('de arreglo');
    _acceptWord('hacer');
    final body = _parseBlock(open: start, endDisplay: 'FinPara', isTerminator: () => _isEnd('para'));
    _consumeEnd();
    return ForEachStmt(variable.lexeme, array.lexeme, body, start.line, start.column);
  }

  Stmt _parseWait() {
    final start = _advance();
    if (_acceptWord('tecla')) return WaitStmt(null, start.line, start.column);
    final amount = _parseExpression();
    var millis = false;
    if (_acceptWord('milisegundo') || _acceptWord('milisegundos')) {
      millis = true;
    } else if (!(_acceptWord('segundo') || _acceptWord('segundos'))) {
      throw _error("Se esperaba 'Segundos' o 'Milisegundos', por ejemplo: Esperar 2 Segundos.");
    }
    return WaitStmt(amount, start.line, start.column, millis: millis);
  }

  Stmt _parseClear() {
    final start = _advance();
    _acceptWord('pantalla');
    return ClearStmt(start.line, start.column);
  }

  // -------------------------------------------------------------------------
  // Expressions, from lowest to highest precedence

  Expr _parseExpression() => _parseOr();

  // DFD writes the logical operators in English and has a few more. They
  // become the PSeInt ones, so the pseudocode always reads Y, O, NO:
  // a XOR b is a <> b, a XNOR b is a = b, a NAND b is NO (a Y b) and
  // a NOR b is NO (a O b).

  Expr _parseOr() {
    var left = _parseAnd();
    while (true) {
      final op = _current;
      if (_isWord('o') || _isWord('or') || _isSymbol('|') || _isSymbol('||')) {
        _advance();
        left = BinaryExpr('o', left, _parseAnd(), op.line, op.column);
      } else if (_isWord('xor') || _isWord('xnor')) {
        _advance();
        left = BinaryExpr(op.norm == 'xor' ? '<>' : '=', left, _parseAnd(), op.line, op.column);
      } else if (_isWord('nor')) {
        _advance();
        left = UnaryExpr('no', BinaryExpr('o', left, _parseAnd(), op.line, op.column), op.line, op.column);
      } else {
        return left;
      }
    }
  }

  Expr _parseAnd() {
    var left = _parseNot();
    while (true) {
      final op = _current;
      if (_isWord('y') || _isWord('and') || _isSymbol('&') || _isSymbol('&&')) {
        _advance();
        left = BinaryExpr('y', left, _parseNot(), op.line, op.column);
      } else if (_isWord('nand')) {
        _advance();
        left = UnaryExpr('no', BinaryExpr('y', left, _parseNot(), op.line, op.column), op.line, op.column);
      } else {
        return left;
      }
    }
  }

  Expr _parseNot() {
    if (_isWord('no') || _isWord('not') || _isSymbol('~') || _isSymbol('!')) {
      final op = _advance();
      return UnaryExpr('no', _parseNot(), op.line, op.column);
    }
    return _parseComparison();
  }

  Expr _parseComparison() {
    final left = _parseAdditive();
    final op = _current;
    final normalized = op.type == TokenType.symbol ? _comparisons[op.lexeme] : null;
    if (normalized == null) return left;
    _advance();
    return BinaryExpr(normalized, left, _parseAdditive(), op.line, op.column);
  }

  Expr _parseAdditive() {
    var left = _parseMultiplicative();
    while (_isSymbol('+') || _isSymbol('-')) {
      final op = _advance();
      left = BinaryExpr(op.lexeme, left, _parseMultiplicative(), op.line, op.column);
    }
    return left;
  }

  Expr _parseMultiplicative() {
    var left = _parseUnary();
    while (true) {
      final op = _current;
      final String name;
      if (_isSymbol('*') || _isSymbol('/')) {
        name = op.lexeme;
      } else if (_isSymbol('%') || _isWord('mod')) {
        name = 'mod';
      } else {
        return left;
      }
      _advance();
      left = BinaryExpr(name, left, _parseUnary(), op.line, op.column);
    }
  }

  Expr _parseUnary() {
    if (_isSymbol('-')) {
      final op = _advance();
      return UnaryExpr('-', _parseUnary(), op.line, op.column);
    }
    if (_acceptSymbol('+')) return _parseUnary();
    return _parsePower();
  }

  Expr _parsePower() {
    final base = _parsePrimary();
    if (_isSymbol('^')) {
      final op = _advance();
      return BinaryExpr('^', base, _parseUnary(), op.line, op.column);
    }
    return base;
  }

  Expr _parsePrimary() {
    final token = _current;
    switch (token.type) {
      case TokenType.number:
        _advance();
        return NumberLit(token.value! as num, token.line, token.column);
      case TokenType.string:
        _advance();
        return StringLit(token.value! as String, token.line, token.column);
      case TokenType.symbol when token.lexeme == '(':
        _advance();
        final inner = _parseExpression();
        _expectSymbol(')', 'para cerrar el paréntesis');
        return inner;
      case TokenType.word:
        if (token.norm == 'verdadero' || token.norm == 'falso') {
          _advance();
          return BoolLit(token.norm == 'verdadero', token.line, token.column);
        }
        if (_reserved.contains(token.norm)) {
          throw _error(
            "Se esperaba un valor, pero encontré la palabra '${token.lexeme}'.",
            hint: token.norm == 'entonces' || token.norm == 'hacer'
                ? "Parece que falta la condición antes de '${token.lexeme}'."
                : null,
          );
        }
        if (_isArrayParen(1)) {
          _advance();
          return IndexExpr(token.lexeme, _parseParenIndices(), token.line, token.column);
        }
        _advance();
        if (_acceptSymbol('(')) {
          final call = _parseCall(token);
          final dfd = _dfdFunction(call);
          if (dfd != null) return dfd;
          _calls.add((call, false));
          return call;
        }
        if (_isSymbol('[')) return IndexExpr(token.lexeme, _parseIndices(), token.line, token.column);
        return VarRef(token.lexeme, token.line, token.column);
      case TokenType.newline || TokenType.eof:
        throw _error('Falta un valor: la instrucción termina antes de tiempo.');
      default:
        throw _error('Se esperaba un valor, pero encontré ${token.describe()}.');
    }
  }

  /// Parses the arguments after `nombre(`.
  CallExpr _parseCall(Token name) {
    final args = <Expr>[];
    if (!_isSymbol(')')) {
      do {
        args.add(_parseExpression());
      } while (_acceptSymbol(','));
    }
    _expectSymbol(')', 'para cerrar la llamada a ${name.lexeme}');
    return CallExpr(name.lexeme, args, name.line, name.column);
  }

  /// DFD's functions, in English, written as PSeInt's so the pseudocode
  /// runs in PSeInt too. The ones PSeInt lacks become their formula.
  Expr? _dfdFunction(CallExpr call) {
    final args = call.args;
    final (line, column) = (call.line, call.column);
    CallExpr f(String name, List<Expr> a) => CallExpr(name, a, line, column);
    Expr bin(String op, Expr l, Expr r) => BinaryExpr(op, l, r, line, column);
    Expr minus(Expr e) => UnaryExpr('-', e, line, column);
    final renamed = const {
      'sqrt': 'Raiz', 'abs': 'Abs', 'len': 'Longitud', 'round': 'Redon', 'trunc': 'Trunc', 'ln': 'Ln', //
      'exp': 'Exp', 'sin': 'Sen', 'cos': 'Cos', 'tan': 'Tan', 'asin': 'ASen', 'acos': 'ACos', 'atan': 'ATan',
      'random': 'Azar',
    }[normalize(call.name)];
    if (renamed != null) return args.length == 1 ? f(renamed, args) : null;
    switch ((normalize(call.name), args.length)) {
      case ('log', 1):
        return bin('/', f('Ln', args), f('Ln', [NumberLit(10, line, column)]));
      case ('sinh', 1):
        return bin('/', bin('-', f('Exp', args), f('Exp', [minus(args[0])])), NumberLit(2, line, column));
      case ('cosh', 1):
        return bin('/', bin('+', f('Exp', args), f('Exp', [minus(args[0])])), NumberLit(2, line, column));
      case ('tanh', 1):
        return bin(
          '/',
          bin('-', f('Exp', args), f('Exp', [minus(args[0])])),
          bin('+', f('Exp', args), f('Exp', [minus(args[0])])),
        );
      case ('substring', 3):
        // SUBSTRING(texto, inicio, cuantos) takes a count; Subcadena, an end.
        final end = bin('-', bin('+', args[1], args[2]), NumberLit(1, line, column));
        return f('Subcadena', [args[0], args[1], end]);
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // Validation

  void _validateCalls(Map<String, Subprogram> functions) {
    for (final (call, isStatement) in _calls) {
      final key = normalize(call.name);
      final function = functions[key];
      final builtin = builtins[key];
      JaguarError fail(String message, {String? hint}) =>
          JaguarError.syntax(message, line: call.line, column: call.column, hint: hint);

      if (function != null) {
        if (call.args.length != function.params.length) {
          throw fail(
            "'${function.name}' recibe ${_count(function.params.length)}, "
            'pero se le dieron ${call.args.length}.',
          );
        }
        if (!isStatement && function.returnVar == null) {
          throw fail(
            "'${function.name}' no devuelve ningún valor, así que no puede usarse dentro de una expresión.",
            hint: "Para que devuelva un valor defínela como 'Funcion resultado <- ${function.name}(...)'.",
          );
        }
      } else if (builtin != null) {
        if (call.args.length != builtin.arity) {
          throw fail("'${builtin.name}' recibe ${_count(builtin.arity)}, pero se le dieron ${call.args.length}.");
        }
      } else {
        final suggestion = closestMatch(call.name, [
          ...functions.values.map((f) => f.name),
          ...builtinNames,
          if (isStatement) ..._statementKeywords,
        ]);
        throw fail(
          isStatement
              ? "No entiendo la instrucción '${call.name}'."
              : "No existe ninguna función llamada '${call.name}'.",
          hint: suggestion != null ? "¿Quisiste decir '$suggestion'?" : null,
        );
      }
    }
  }

  String _count(int n) => n == 1 ? '1 valor' : '$n valores';
}
