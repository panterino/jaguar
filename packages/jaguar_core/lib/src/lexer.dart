import 'errors.dart';
import 'text.dart';
import 'token.dart';

final _letter = RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ_]');
final _digit = RegExp(r'[0-9]');

// Longest first, so `<-` wins over `<`.
const _symbols = [
  '<-', '<=', '>=', '<>', '==', '!=', ':=', '&&', '||', //
  '+', '-', '*', '/', '^', '%', '(', ')', '[', ']', ',', ';', ':', '=', '<',
  '>', '&', '|', '~', '!',
];

/// Symbols from DFD and math notation, read as their PSeInt equivalent.
const _symbolAliases = {'←': '<-', '≠': '<>', '≤': '<=', '≥': '>='};

/// DFD's logical constants `.V.` and `.F.`.
final _dfdBool = RegExp(r'\.([VvFf])\.');

// Students often paste code from Word or WhatsApp, which turns quotes curly.
const _doubleQuotes = {'"', '“', '”'};

class Lexer {
  Lexer(this.source);

  final String source;
  final List<Token> _tokens = [];
  int _pos = 0;
  int _line = 1;
  int _column = 1;

  List<Token> tokenize() {
    while (_pos < source.length) {
      final char = source[_pos];
      if (char == '\n') {
        _tokens.add(Token(TokenType.newline, '\n', _line, _column));
        _advance();
      } else if (char == ' ' || char == '\t' || char == '\r' || char == '﻿') {
        _advance();
      } else if (source.startsWith('//', _pos)) {
        while (_pos < source.length && source[_pos] != '\n') {
          _advance();
        }
      } else if (char == '.' && _dfdBool.matchAsPrefix(source, _pos) != null) {
        _dfdConstant();
      } else if (_digit.hasMatch(char) || (char == '.' && _digit.hasMatch(_peek(1)))) {
        _number();
      } else if (_doubleQuotes.contains(char) || char == "'") {
        _string();
      } else if (_letter.hasMatch(char)) {
        _word();
      } else {
        _symbol();
      }
    }
    _tokens.add(Token(TokenType.eof, '', _line, _column));
    return _tokens;
  }

  String _peek(int offset) {
    final index = _pos + offset;
    return index < source.length ? source[index] : '';
  }

  void _advance() {
    if (source[_pos] == '\n') {
      _line++;
      _column = 1;
    } else {
      _column++;
    }
    _pos++;
  }

  void _number() {
    final line = _line, column = _column, start = _pos;
    while (_pos < source.length && _digit.hasMatch(source[_pos])) {
      _advance();
    }
    if (_peek(0) == '.' && _digit.hasMatch(_peek(1))) {
      _advance();
      while (_pos < source.length && _digit.hasMatch(source[_pos])) {
        _advance();
      }
    }
    final text = source.substring(start, _pos);
    _tokens.add(Token(TokenType.number, text, line, column, value: num.parse(text)));
  }

  void _string() {
    final line = _line, column = _column, start = _pos;
    final opening = source[_pos];
    final closing = opening == "'" ? {"'"} : _doubleQuotes;
    _advance();
    while (_pos < source.length && !closing.contains(source[_pos])) {
      if (source[_pos] == '\n') break;
      _advance();
    }
    if (_pos >= source.length || source[_pos] == '\n') {
      throw JaguarError.syntax(
        'Falta la comilla que cierra este texto.',
        line: line,
        column: column,
        hint: 'Cierra el texto con $opening en la misma línea.',
      );
    }
    final content = source.substring(start + 1, _pos);
    _advance();
    _tokens.add(Token(TokenType.string, source.substring(start, _pos), line, column, value: content));
  }

  void _word() {
    final line = _line, column = _column, start = _pos;
    while (_pos < source.length && (_letter.hasMatch(source[_pos]) || _digit.hasMatch(source[_pos]))) {
      _advance();
    }
    final text = source.substring(start, _pos);
    _tokens.add(Token(TokenType.word, text, line, column, norm: normalize(text)));
  }

  void _dfdConstant() {
    final line = _line, column = _column;
    final text = source.substring(_pos, _pos + 3);
    for (var i = 0; i < 3; i++) {
      _advance();
    }
    final word = text[1].toLowerCase() == 'v' ? 'verdadero' : 'falso';
    _tokens.add(Token(TokenType.word, text, line, column, norm: word));
  }

  void _symbol() {
    final line = _line, column = _column;
    final alias = _symbolAliases[source[_pos]];
    if (alias != null) {
      _advance();
      _tokens.add(Token(TokenType.symbol, alias, line, column));
      return;
    }
    for (final symbol in _symbols) {
      if (source.startsWith(symbol, _pos)) {
        for (var i = 0; i < symbol.length; i++) {
          _advance();
        }
        _tokens.add(Token(TokenType.symbol, symbol, line, column));
        return;
      }
    }
    throw JaguarError.syntax("No reconozco el carácter '${source[_pos]}'.", line: line, column: column);
  }
}
