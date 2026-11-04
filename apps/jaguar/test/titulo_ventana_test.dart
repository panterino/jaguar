import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/workspace/rooms.dart';
import 'package:jaguar/src/workspace/workspace_screen.dart';

void main() {
  const source = 'Algoritmo mi_programa\nFinAlgoritmo\n';

  test('el título de la pestaña no arrastra el último programa fuera del Taller', () {
    expect(windowTitle(Room.home, source), 'Jaguar Code');
    expect(windowTitle(Room.route, source), 'Ruta — Jaguar Code');
    expect(windowTitle(Room.classes, source), 'Clases — Jaguar Code');
    expect(windowTitle(Room.workshop, source), 'mi_programa — Jaguar Code');
  });
}
