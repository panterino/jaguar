/// Intérprete de pseudocódigo compatible con PSeInt (perfil flexible).
library;

export 'src/ast.dart';
export 'src/desk_check.dart';
export 'src/builtins.dart' show builtinNames;
export 'src/editing.dart';
export 'src/errors.dart';
export 'src/exercise.dart';
export 'src/flowchart.dart';
export 'src/flowchart_svg.dart' show flowchartSvg;
export 'src/format.dart' show Notation, assignArrow, formatExpr, formatSimpleStmt;
export 'src/interpreter.dart' show BufferedIO, Interpreter, JaguarIO, RunOptions, StepHook;
export 'src/parser.dart' show parse;
export 'src/plan.dart';
export 'src/python.dart' show toPython;
export 'src/runner.dart';
export 'src/test_generator.dart' show suggestTests;
export 'src/text.dart' show normalize;
export 'src/values.dart' show debugValue, formatValue;
