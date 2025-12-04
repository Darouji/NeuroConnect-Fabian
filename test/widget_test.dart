// Importamos las librerías necesarias para pruebas y Material Design.
import 'package:flutter_test/flutter_test.dart';

// Importamos el punto de entrada de nuestra aplicación.
import 'package:neuro_conecta/main.dart';

void main() {
  // Defino la prueba de "humo" (smoke test) para verificar la carga inicial.
  testWidgets('Verificar carga de pantalla de bienvenida', (
    WidgetTester tester,
  ) async {
    // Construyo el widget principal de la aplicación.
    // Utilizo NeuroconectaApp que es la clase definida en main.dart.
    await tester.pumpWidget(const NeuroconectaApp());

    // Verifico que el título principal aparezca en la pantalla.
    // Esto confirma que WelcomeScreen se ha renderizado.
    expect(find.text('Neuroconecta'), findsOneWidget);

    // Verifico que el botón de acción principal esté visible.
    expect(find.text('Comenzar'), findsOneWidget);
  });
}
