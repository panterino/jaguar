import 'ast.dart';
import 'values.dart' show formatValue;

/// Translates a program to Python, to read it side by side with the
/// pseudocode. It is a reading aid, not a second interpreter: the program
/// still runs in Jaguar. The result is meant to be real, runnable Python for
/// the programs a student writes; the few things Python does differently
/// (reading a number, passing by reference) are chosen as the closest idiom.
String toPython(Program program) => _Translator(program).translate();

const _pythonWords = {
  'False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue', //
  'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in',
  'is', 'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield',
  'print', 'input', 'len', 'int', 'float', 'str', 'range', 'abs', 'round', 'math', 'random', 'time',
};

/// Binding strength, the same as the pseudocode's (and Python's).
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

class _Translator {
  _Translator(this.program);

  final Program program;
  final _imports = <String>{};

  /// Names the program uses as numbers, to choose int() or float() on Leer.
  final _numeric = <String>{};
  final _text = <String>{};

  /// Variables compared with <, >, <= or >= against something that is not
  /// text: with nothing else said, a value read to find the greater is a number.
  final _ordered = <String>{};

  /// `x <- y` between two variables: they hold the same kind of value.
  final _copies = <(String, String)>[];

  /// Numbers that must be whole: positions, remainders, loop bounds.
  final _whole = <String>{};

  String translate() {
    _inferTypes(program.main.body);
    for (final sub in program.functions.values) {
      _inferTypes(sub.body);
    }
    // A value copied from or to a number that is compared is a number too.
    for (var changed = true; changed;) {
      changed = false;
      for (final (to, from) in _copies) {
        final numberTo = _numeric.contains(to) || _ordered.contains(to);
        final numberFrom = _numeric.contains(from) || _ordered.contains(from);
        if (numberTo && !numberFrom && !_text.contains(from)) {
          _ordered.add(from);
          changed = true;
        } else if (numberFrom && !numberTo && !_text.contains(to)) {
          _ordered.add(to);
          changed = true;
        }
      }
    }
    final body = StringBuffer();
    for (final sub in program.functions.values) {
      _function(body, sub);
      body.writeln();
    }
    body.writeln('# Algoritmo ${program.main.name}');
    _statements(body, program.main.body, 0);
    final header = [for (final name in _imports.toList()..sort()) 'import $name'];
    final text = [if (header.isNotEmpty) '${header.join('\n')}\n', body.toString().trimRight()].join('\n');
    return '$text\n';
  }

  /// The variable or array a plain reference stands for, in lowercase.
  String? _nameOf(Expr e) => switch (e) {
    VarRef(:final name) => name.toLowerCase(),
    IndexExpr(:final name) => name.toLowerCase(),
    _ => null,
  };

  // Types --------------------------------------------------------------------

  /// Marks which variables are numbers and which are text, from how they are
  /// used and from Definir.
  void _inferTypes(List<Stmt> statements) {
    void number(Expr e) {
      if (e is VarRef) _numeric.add(e.name.toLowerCase());
      if (e is IndexExpr) _numeric.add(e.name.toLowerCase());
    }

    void whole(Expr e) {
      if (e is VarRef) {
        _numeric.add(e.name.toLowerCase());
        _whole.add(e.name.toLowerCase());
      }
    }

    void text(Expr e) {
      if (e is VarRef) _text.add(e.name.toLowerCase());
    }

    void expr(Expr e) {
      switch (e) {
        case BinaryExpr(:final op, :final left, :final right):
          if (const {'-', '*', '/', '^', 'mod'}.contains(op)) {
            number(left);
            number(right);
            if (op == 'mod') {
              whole(left);
              whole(right);
            }
          } else if (const {'<', '>', '<=', '>=', '=', '<>', '+'}.contains(op)) {
            if (left is NumberLit) number(right);
            if (right is NumberLit) number(left);
            if (left is StringLit) text(right);
            if (right is StringLit) text(left);
            if (const {'<', '>', '<=', '>='}.contains(op) && left is! StringLit && right is! StringLit) {
              for (final side in [left, right]) {
                final name = _nameOf(side);
                if (name != null) _ordered.add(name);
              }
            }
            // Two values added with nothing that says text: they are numbers.
            if (op == '+' && left is! StringLit && right is! StringLit) {
              bool textual(Expr x) =>
                  x is CallExpr &&
                  const {
                    'mayusculas',
                    'minusculas',
                    'subcadena',
                    'concatenar',
                    'convertiratexto',
                  }.contains(x.name.toLowerCase());
              if (!textual(left) && !textual(right)) {
                number(left);
                number(right);
              }
            }
          }
          expr(left);
          expr(right);
        case UnaryExpr(:final operand):
          if (e.op == '-') number(operand);
          expr(operand);
        case CallExpr(:final name, :final args):
          final key = name.toLowerCase();
          if (const {'raiz', 'rc', 'abs', 'ln', 'exp', 'sen', 'cos', 'tan', 'trunc', 'redon', 'azar'}.contains(key)) {
            args.forEach(number);
          }
          if (const {'longitud', 'mayusculas', 'minusculas', 'convertiranumero'}.contains(key) && args.isNotEmpty) {
            text(args.first);
          }
          args.forEach(expr);
        case IndexExpr(:final indices):
          indices.forEach(whole);
          indices.forEach(expr);
        default:
      }
    }

    for (final s in statements) {
      switch (s) {
        case DefineStmt(:final names, :final type):
          for (final name in names) {
            (type == JType.texto ? _text : _numeric).add(name.toLowerCase());
            if (type == JType.entero) _whole.add(name.toLowerCase());
          }
        case AssignStmt(:final target, :final value):
          expr(target);
          expr(value);
          if (value is StringLit && target is VarRef) _text.add(target.name.toLowerCase());
          if (value is NumberLit && target is VarRef) _numeric.add(target.name.toLowerCase());
          final to = _nameOf(target);
          final from = _nameOf(value);
          if (to != null && from != null) _copies.add((to, from));
        case WriteStmt(:final values):
          values.forEach(expr);
        case IfStmt(:final condition, :final thenBody, :final elseBody):
          expr(condition);
          _inferTypes(thenBody);
          if (elseBody != null) _inferTypes(elseBody);
        case WhileStmt(:final condition, :final body):
          expr(condition);
          _inferTypes(body);
        case RepeatStmt(:final condition, :final body):
          expr(condition);
          _inferTypes(body);
        case ForStmt(:final variable, :final from, :final to, :final step, :final body):
          _numeric.add(variable.toLowerCase());
          _whole.add(variable.toLowerCase());
          whole(from);
          whole(to);
          expr(from);
          expr(to);
          if (step != null) expr(step);
          _inferTypes(body);
        case ForEachStmt(:final body):
          _inferTypes(body);
        case SwitchStmt(:final subject, :final cases, :final otherwise):
          expr(subject);
          for (final c in cases) {
            _inferTypes(c.body);
            for (final v in c.values) {
              if (v is NumberLit) number(subject);
              if (v is StringLit) text(subject);
            }
          }
          if (otherwise != null) _inferTypes(otherwise);
        case CallStmt(:final call):
          expr(call);
        default:
      }
    }
  }

  // Statements ---------------------------------------------------------------

  void _function(StringBuffer out, Subprogram sub) {
    final params = sub.params.map((p) => _name(p.name)).join(', ');
    out.writeln('def ${_name(sub.name)}($params):');
    if (sub.params.any((p) => p.byRef)) {
      out.writeln('    # Por Referencia: en Python los números y textos no se cambian desde la función;');
      out.writeln('    # se devuelven y se asignan al llamarla.');
    }
    final body = StringBuffer();
    _statements(body, sub.body, 1);
    out.write(body);
    final result = sub.returnVar;
    if (result != null) {
      out.writeln('    return ${_name(result)}');
    } else if (sub.body.isEmpty) {
      out.writeln('    pass');
    }
  }

  String _name(String name) => _pythonWords.contains(name) ? '${name}_' : name;

  String _indent(int level) => '    ' * level;

  void _line(StringBuffer out, int level, String text) => out.writeln('${_indent(level)}$text');

  void _statements(StringBuffer out, List<Stmt> body, int level) {
    if (body.isEmpty) {
      _line(out, level, 'pass');
      return;
    }
    for (final stmt in body) {
      _statement(out, stmt, level);
    }
  }

  void _statement(StringBuffer out, Stmt stmt, int level) {
    switch (stmt) {
      case DefineStmt(:final names, :final type):
        final initial = switch (type) {
          JType.entero => '0',
          JType.real => '0.0',
          JType.logico => 'False',
          JType.texto => '""',
        };
        for (final name in names) {
          _line(out, level, '${_name(name)} = $initial');
        }
      case DimensionStmt(:final arrays):
        for (final array in arrays) {
          final sizes = array.sizes.map(_expr).toList();
          if (sizes.length == 1) {
            _line(out, level, '${_name(array.name)} = [0] * ${sizes.first}');
          } else {
            _line(out, level, '${_name(array.name)} = [[0] * ${sizes.last} for _ in range(${sizes.first})]');
          }
        }
      case AssignStmt(:final target, :final value):
        _line(out, level, '${_expr(target)} = ${_expr(value)}');
      case WriteStmt(:final values, :final newline):
        final args = values.map(_expr).toList();
        final extra = [if (values.length > 1) 'sep=""', if (!newline) 'end=""'];
        _line(out, level, 'print(${[...args, ...extra].join(', ')})');
      case ReadStmt(:final targets):
        for (final target in targets) {
          _line(out, level, '${_expr(target)} = ${_read(target)}');
        }
      case IfStmt():
        _if(out, stmt, level, 'if');
      case WhileStmt(:final condition, :final body):
        _line(out, level, 'while ${_expr(condition)}:');
        _statements(out, body, level + 1);
      case RepeatStmt(:final condition, :final body, :final untilTrue):
        _line(out, level, 'while True:');
        _statements(out, body, level + 1);
        final test = untilTrue ? _expr(condition) : 'not (${_expr(condition)})';
        _line(out, level + 1, 'if $test:');
        _line(out, level + 2, 'break');
      case ForStmt(:final variable, :final from, :final to, :final step, :final body):
        _line(out, level, 'for ${_name(variable)} in ${_range(from, to, step)}:');
        _statements(out, body, level + 1);
      case ForEachStmt(:final variable, :final arrayName, :final body):
        _line(out, level, 'for ${_name(variable)} in ${_name(arrayName)}:');
        _statements(out, body, level + 1);
      case SwitchStmt(:final subject, :final cases, :final otherwise):
        final value = _expr(subject);
        for (final (i, c) in cases.indexed) {
          final test = c.values.length == 1
              ? '$value == ${_expr(c.values.first)}'
              : '$value in (${c.values.map(_expr).join(', ')})';
          _line(out, level, '${i == 0 ? 'if' : 'elif'} $test:');
          _statements(out, c.body, level + 1);
        }
        if (otherwise != null) {
          if (cases.isEmpty) {
            _statements(out, otherwise, level);
          } else {
            _line(out, level, 'else:');
            _statements(out, otherwise, level + 1);
          }
        }
      case CallStmt(:final call):
        _line(out, level, _expr(call));
      case WaitStmt(:final amount, :final millis):
        if (amount == null) {
          _line(out, level, 'input("Presiona Enter para continuar")');
        } else {
          _imports.add('time');
          _line(out, level, 'time.sleep(${_expr(amount)}${millis ? ' / 1000' : ''})');
        }
      case ClearStmt():
        _line(out, level, 'print("\\033c", end="")  # limpia la pantalla');
    }
  }

  void _if(StringBuffer out, IfStmt stmt, int level, String keyword) {
    _line(out, level, '$keyword ${_expr(stmt.condition)}:');
    _statements(out, stmt.thenBody, level + 1);
    final other = stmt.elseBody;
    if (other == null) return;
    if (other.length == 1 && other.first is IfStmt) {
      _if(out, other.first as IfStmt, level, 'elif');
    } else {
      _line(out, level, 'else:');
      _statements(out, other, level + 1);
    }
  }

  String _range(Expr from, Expr to, Expr? step) {
    num? literal(Expr e) => switch (e) {
      NumberLit(:final value) => value,
      UnaryExpr(op: '-', operand: NumberLit(:final value)) => -value,
      _ => null,
    };
    final a = literal(from);
    final b = literal(to);
    final s = step == null ? null : literal(step);
    final down = (s != null && s < 0) || (step == null && a != null && b != null && a > b);
    final start = _expr(from);
    final end = _plusOne(to, down ? -1 : 1);
    if (step == null) return down ? 'range($start, $end, -1)' : 'range($start, $end)';
    return 'range($start, $end, ${_expr(step)})';
  }

  /// `to + 1` (or `- 1`), folded when [to] is a number.
  String _plusOne(Expr to, int delta) {
    if (to is NumberLit && to.value == to.value.truncate()) return formatValue(to.value + delta);
    return '${_wrap(to, 5)} ${delta > 0 ? '+' : '-'} 1';
  }

  /// What reads one value of [target] from the keyboard.
  String _read(Expr target) {
    final name = switch (target) {
      VarRef(:final name) => name.toLowerCase(),
      IndexExpr(:final name) => name.toLowerCase(),
      _ => '',
    };
    if (_text.contains(name) && !_numeric.contains(name)) return 'input()';
    if (_numeric.contains(name)) return _whole.contains(name) ? 'int(input())' : 'float(input())';
    if (_ordered.contains(name) && !_text.contains(name)) return 'float(input())';
    return 'input()';
  }

  // Expressions --------------------------------------------------------------

  bool _isText(Expr e) => switch (e) {
    StringLit() => true,
    VarRef(:final name) => _text.contains(name.toLowerCase()) && !_numeric.contains(name.toLowerCase()),
    CallExpr(:final name) => const {
      'mayusculas',
      'minusculas',
      'subcadena',
      'concatenar',
      'convertiratexto',
    }.contains(name.toLowerCase()),
    BinaryExpr(op: '+', :final left, :final right) => _isText(left) || _isText(right),
    _ => false,
  };

  String _wrap(Expr e, int minimum) => _precedence(e) < minimum ? '(${_expr(e)})' : _expr(e);

  String _index(Expr index) {
    if (index is NumberLit && index.value == index.value.truncate()) return formatValue(index.value - 1);
    return '${_wrap(index, 5)} - 1';
  }

  String _expr(Expr expr) {
    switch (expr) {
      case NumberLit(:final value):
        return formatValue(value);
      case StringLit(:final value):
        return '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\n', r'\n')}"';
      case BoolLit(:final value):
        return value ? 'True' : 'False';
      case VarRef(:final name):
        if (name.toLowerCase() == 'pi') {
          _imports.add('math');
          return 'math.pi';
        }
        return _name(name);
      case IndexExpr(:final name, :final indices):
        return '${_name(name)}${indices.map((i) => '[${_index(i)}]').join()}';
      case UnaryExpr(op: 'no', :final operand):
        return 'not ${_wrap(operand, 3)}';
      case UnaryExpr(:final operand):
        return '-${_wrap(operand, 7)}';
      case BinaryExpr(op: '^', :final left, :final right):
        return '${_wrap(left, 9)} ** ${_wrap(right, 7)}';
      case BinaryExpr(op: '+', :final left, :final right) when _isText(left) != _isText(right):
        // Python does not join text and numbers: the number goes through str().
        String part(Expr e) => _isText(e) ? _wrap(e, 5) : 'str(${_expr(e)})';
        return '${part(left)} + ${part(right)}';
      case BinaryExpr(:final op, :final left, :final right):
        final precedence = _precedence(expr);
        final leftMin = precedence == 4 ? 5 : precedence;
        const names = {'o': 'or', 'y': 'and', 'mod': '%', '=': '==', '<>': '!='};
        return '${_wrap(left, leftMin)} ${names[op] ?? op} ${_wrap(right, precedence + 1)}';
      case CallExpr():
        return _call(expr);
    }
  }

  String _call(CallExpr call) {
    final args = call.args.map(_expr).toList();
    final key = call.name.toLowerCase();
    String math(String fn) {
      _imports.add('math');
      return 'math.$fn(${args.join(', ')})';
    }

    switch (key) {
      case 'raiz' || 'rc':
        return math('sqrt');
      case 'ln':
        return math('log');
      case 'exp' || 'sen' || 'cos' || 'tan':
        return math(key == 'sen' ? 'sin' : key);
      case 'asen':
        return math('asin');
      case 'acos' || 'atan':
        return math(key);
      case 'abs':
        return 'abs(${args.join(', ')})';
      case 'trunc':
        return 'int(${args.join(', ')})';
      case 'redon':
        return 'round(${args.join(', ')})';
      case 'azar':
        _imports.add('random');
        return 'random.randrange(${args.join(', ')})';
      case 'aleatorio':
        _imports.add('random');
        return 'random.randint(${args.join(', ')})';
      case 'longitud':
        return 'len(${args.join(', ')})';
      case 'mayusculas':
        return '${_wrap(call.args.first, 9)}.upper()';
      case 'minusculas':
        return '${_wrap(call.args.first, 9)}.lower()';
      case 'subcadena' when call.args.length == 3:
        final text = _wrap(call.args[0], 9);
        return '$text[${_index(call.args[1])}:${_expr(call.args[2])}]';
      case 'concatenar':
        return args.map((a) => a).join(' + ');
      case 'convertiranumero':
        return 'float(${args.join(', ')})';
      case 'convertiratexto':
        return 'str(${args.join(', ')})';
    }
    return '${_name(call.name)}(${args.join(', ')})';
  }
}
