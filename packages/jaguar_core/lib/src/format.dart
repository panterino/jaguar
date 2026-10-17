import 'ast.dart';
import 'values.dart';

/// How expressions are written: as in PSeInt (`x <- a Y b`, `"hola"`) or as
/// in DFD (`x ← a AND b`, `'hola'`). The pseudocode is always PSeInt; a
/// flowchart can use either, so a class that learned with DFD sees what it
/// knows.
enum Notation { pseint, dfd }

/// Writes an expression back as text, with only the parentheses it needs:
/// `(a + b) * 2`, never `((a + b) * 2)`.
String formatExpr(Expr expr, {Notation notation = Notation.pseint}) => _Printer(notation).expr(expr);

/// The text a flowchart block shows for a simple statement.
String formatSimpleStmt(Stmt stmt, {Notation notation = Notation.pseint}) => _Printer(notation).simple(stmt);

/// The assignment arrow of each notation.
String assignArrow(Notation notation) => notation == Notation.dfd ? '←' : '<-';

/// Binding strength, as in the parser: `o` < `y` < `no` < comparisons <
/// `+ -` < `* / mod` < unary minus < `^`.
int _precedence(Expr expr) => switch (expr) {
  BinaryExpr(op: 'o') => 1,
  BinaryExpr(op: 'y') => 2,
  UnaryExpr(op: 'no') => 3,
  BinaryExpr(op: '=' || '<>' || '<' || '>' || '<=' || '>=') => 4,
  BinaryExpr(op: '+' || '-') => 5,
  BinaryExpr(op: '*' || '/' || 'mod') => 6,
  UnaryExpr() => 7,
  BinaryExpr(op: '^') => 8,
  _ => 9,
};

const _pseintOps = {'o': 'O', 'y': 'Y', 'mod': 'MOD'};
const _dfdOps = {'o': 'OR', 'y': 'AND', 'mod': 'MOD', '<>': '!='};

/// PSeInt's functions by their DFD name, keyed by normalized PSeInt name.
const _dfdFunctions = {
  'raiz': 'SQRT', 'rc': 'SQRT', 'abs': 'ABS', 'longitud': 'LEN', 'redon': 'ROUND', 'trunc': 'TRUNC', //
  'ln': 'LN', 'exp': 'EXP', 'sen': 'SIN', 'cos': 'COS', 'tan': 'TAN', 'asen': 'ASIN', 'acos': 'ACOS',
  'atan': 'ATAN', 'azar': 'RANDOM',
};

class _Printer {
  _Printer(this.notation);

  final Notation notation;

  bool get _dfd => notation == Notation.dfd;

  String expr(Expr expr) => switch (expr) {
    NumberLit(:final value) => formatValue(value),
    // DFD has no way to write a ' inside a text; those keep double quotes.
    StringLit(:final value) => _dfd && !value.contains("'") ? "'$value'" : '"$value"',
    BoolLit(:final value) => _dfd ? (value ? '.V.' : '.F.') : (value ? 'Verdadero' : 'Falso'),
    VarRef(:final name) => name,
    IndexExpr(:final name, :final indices) =>
      _dfd ? '$name(${indices.map(this.expr).join(', ')})' : '$name[${indices.map(this.expr).join(', ')}]',
    CallExpr() => _call(expr),
    UnaryExpr(op: 'no', :final operand) => '${_dfd ? 'NOT' : 'NO'} ${_wrap(operand, 3)}',
    UnaryExpr(:final op, :final operand) => '$op${_wrap(operand, 7)}',
    BinaryExpr(op: '^', :final left, :final right) => '${_wrap(left, 9)}^${_wrap(right, 7)}',
    BinaryExpr(:final op, :final left, :final right) => _binary(op, left, right, _precedence(expr)),
  };

  String _call(CallExpr call) {
    final key = call.name.toLowerCase();
    if (_dfd && (key == 'subcadena') && call.args.length == 3) {
      // Subcadena(t, desde, hasta) is SUBSTRING(t, desde, cuantos).
      final [text, from, to] = call.args;
      final count = BinaryExpr('+', BinaryExpr('-', to, from, 0, 0), NumberLit(1, 0, 0), 0, 0);
      return 'SUBSTRING(${expr(text)}, ${expr(from)}, ${expr(count)})';
    }
    final name = _dfd ? (_dfdFunctions[key] ?? call.name) : call.name;
    return '$name(${call.args.map(expr).join(', ')})';
  }

  String _binary(String op, Expr left, Expr right, int precedence) {
    // Comparisons don't chain; every other operator groups to the left.
    final leftMin = precedence == 4 ? 5 : precedence;
    final text = (_dfd ? _dfdOps[op] : _pseintOps[op]) ?? op;
    return '${_wrap(left, leftMin)} $text ${_wrap(right, precedence + 1)}';
  }

  /// Parenthesizes [e] when it binds weaker than [minimum].
  String _wrap(Expr e, int minimum) => _precedence(e) < minimum ? '(${expr(e)})' : expr(e);

  String _list(List<Expr> values) => values.map(expr).join(', ');

  /// In DFD the symbol says what a block does, so Leer and Escribir blocks
  /// show only their variables or values, as DFD's objects do.
  String simple(Stmt stmt) => switch (stmt) {
    DefineStmt(:final names, :final type) => 'Definir ${names.join(', ')} Como ${type.label}',
    DimensionStmt(:final arrays) =>
      'Dimension ${arrays.map((a) => '${a.name}${_dfd ? '(' : '['}${_list(a.sizes)}${_dfd ? ')' : ']'}').join(', ')}',
    AssignStmt(:final target, :final value) => '${expr(target)} ${assignArrow(notation)} ${expr(value)}',
    WriteStmt(:final values, :final newline) =>
      _dfd ? _list(values) : 'Escribir${newline ? '' : ' Sin Saltar'} ${_list(values)}',
    ReadStmt(:final targets) => _dfd ? _list(targets) : 'Leer ${_list(targets)}',
    CallStmt(:final call) => expr(call),
    WaitStmt(amount: null) => 'Esperar Tecla',
    WaitStmt(:final amount?, :final millis) => 'Esperar ${expr(amount)} ${millis ? 'Milisegundos' : 'Segundos'}',
    ClearStmt() => 'Borrar Pantalla',
    // Blocks are drawn by their own shapes.
    IfStmt() || SwitchStmt() || WhileStmt() || RepeatStmt() || ForStmt() || ForEachStmt() => '',
  };
}
