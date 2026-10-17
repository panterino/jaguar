enum JType {
  entero('Entero'),
  real('Real'),
  logico('Lógico'),
  texto('Texto');

  const JType(this.label);

  final String label;
}

sealed class Node {
  const Node(this.line, this.column);

  final int line;
  final int column;
}

// ---------------------------------------------------------------------------
// Expressions

sealed class Expr extends Node {
  const Expr(super.line, super.column);
}

final class NumberLit extends Expr {
  const NumberLit(this.value, super.line, super.column);

  final num value;
}

final class StringLit extends Expr {
  const StringLit(this.value, super.line, super.column);

  final String value;
}

final class BoolLit extends Expr {
  const BoolLit(this.value, super.line, super.column);

  final bool value;
}

final class VarRef extends Expr {
  const VarRef(this.name, super.line, super.column);

  final String name;
}

/// `a[i]` or `m[i, j]`.
final class IndexExpr extends Expr {
  const IndexExpr(this.name, this.indices, super.line, super.column);

  final String name;
  final List<Expr> indices;
}

/// [op] is `-` or `no`.
final class UnaryExpr extends Expr {
  const UnaryExpr(this.op, this.operand, super.line, super.column);

  final String op;
  final Expr operand;
}

/// [op] is normalized: `+ - * / ^ mod = <> < > <= >= y o`.
final class BinaryExpr extends Expr {
  const BinaryExpr(this.op, this.left, this.right, super.line, super.column);

  final String op;
  final Expr left;
  final Expr right;
}

final class CallExpr extends Expr {
  const CallExpr(this.name, this.args, super.line, super.column);

  final String name;
  final List<Expr> args;
}

// ---------------------------------------------------------------------------
// Statements

sealed class Stmt extends Node {
  const Stmt(super.line, super.column);
}

final class DefineStmt extends Stmt {
  const DefineStmt(this.names, this.type, super.line, super.column);

  final List<String> names;
  final JType type;
}

final class ArrayDecl extends Node {
  const ArrayDecl(this.name, this.sizes, super.line, super.column);

  final String name;
  final List<Expr> sizes;
}

final class DimensionStmt extends Stmt {
  const DimensionStmt(this.arrays, super.line, super.column);

  final List<ArrayDecl> arrays;
}

final class AssignStmt extends Stmt {
  const AssignStmt(this.target, this.value, super.line, super.column);

  /// A [VarRef] or an [IndexExpr].
  final Expr target;
  final Expr value;
}

final class WriteStmt extends Stmt {
  const WriteStmt(this.values, super.line, super.column, {this.newline = true});

  final List<Expr> values;
  final bool newline;
}

final class ReadStmt extends Stmt {
  const ReadStmt(this.targets, super.line, super.column);

  final List<Expr> targets;
}

final class IfStmt extends Stmt {
  const IfStmt(this.condition, this.thenBody, this.elseBody, super.line, super.column);

  final Expr condition;
  final List<Stmt> thenBody;
  final List<Stmt>? elseBody;
}

final class SwitchCase {
  const SwitchCase(this.values, this.body);

  final List<Expr> values;
  final List<Stmt> body;
}

final class SwitchStmt extends Stmt {
  const SwitchStmt(this.subject, this.cases, this.otherwise, super.line, super.column);

  final Expr subject;
  final List<SwitchCase> cases;
  final List<Stmt>? otherwise;
}

final class WhileStmt extends Stmt {
  const WhileStmt(this.condition, this.body, super.line, super.column);

  final Expr condition;
  final List<Stmt> body;
}

/// `Repetir ... Hasta Que cond` ([untilTrue]) or `Repetir ... Mientras Que cond`.
final class RepeatStmt extends Stmt {
  const RepeatStmt(this.body, this.condition, super.line, super.column, {required this.untilTrue});

  final List<Stmt> body;
  final Expr condition;
  final bool untilTrue;
}

final class ForStmt extends Stmt {
  const ForStmt(this.variable, this.from, this.to, this.step, this.body, super.line, super.column);

  final String variable;
  final Expr from;
  final Expr to;
  final Expr? step;
  final List<Stmt> body;
}

final class ForEachStmt extends Stmt {
  const ForEachStmt(this.variable, this.arrayName, this.body, super.line, super.column);

  final String variable;
  final String arrayName;
  final List<Stmt> body;
}

final class CallStmt extends Stmt {
  const CallStmt(this.call, super.line, super.column);

  final CallExpr call;
}

/// `Esperar Tecla` when [amount] is null, otherwise `Esperar n Segundos`.
final class WaitStmt extends Stmt {
  const WaitStmt(this.amount, super.line, super.column, {this.millis = false});

  final Expr? amount;
  final bool millis;
}

final class ClearStmt extends Stmt {
  const ClearStmt(super.line, super.column);
}

// ---------------------------------------------------------------------------
// Program

final class Param {
  const Param(this.name, {this.byRef = false});

  final String name;
  final bool byRef;
}

final class Subprogram {
  const Subprogram({
    required this.name,
    required this.params,
    required this.returnVar,
    required this.body,
    required this.line,
    required this.isMain,
  });

  final String name;
  final List<Param> params;

  /// Name of the variable holding the result (`Funcion r <- f(x)`), or null
  /// for a SubProceso that returns nothing.
  final String? returnVar;
  final List<Stmt> body;
  final int line;
  final bool isMain;
}

final class Program {
  const Program(this.main, this.functions, {this.spans});

  final Subprogram main;

  /// Keyed by normalized name.
  final Map<String, Subprogram> functions;

  /// Where things are in the source, for editing from the flowchart.
  final SourceSpans? spans;
}

/// Lines the AST nodes don't keep themselves: where each statement ends
/// (its `FinSi`, `FinMientras`…), where `SiNo` and each `Según` case are.
/// Keyed by identity.
final class SourceSpans {
  final Map<Stmt, int> _ends = Map.identity();
  final Map<IfStmt, int> _elses = Map.identity();
  final Map<SwitchCase, int> _cases = Map.identity();
  final Map<SwitchStmt, int> _otherwise = Map.identity();
  final Map<Subprogram, int> _subprogramEnds = Map.identity();

  /// The last line of [stmt]: its closing word for blocks.
  int endLine(Stmt stmt) => _ends[stmt] ?? stmt.line;
  int? elseLine(IfStmt stmt) => _elses[stmt];
  int? caseLine(SwitchCase c) => _cases[c];
  int? otherwiseLine(SwitchStmt stmt) => _otherwise[stmt];
  int? subprogramEnd(Subprogram sub) => _subprogramEnds[sub];

  void setEnd(Stmt stmt, int line) => _ends[stmt] = line;
  void setElse(IfStmt stmt, int line) => _elses[stmt] = line;
  void setCase(SwitchCase c, int line) => _cases[c] = line;
  void setOtherwise(SwitchStmt stmt, int line) => _otherwise[stmt] = line;
  void setSubprogramEnd(Subprogram sub, int line) => _subprogramEnds[sub] = line;
}
