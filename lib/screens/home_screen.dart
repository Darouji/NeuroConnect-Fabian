import 'package:flutter/material.dart';
// Importo las pantallas a las que puedo navegar desde el Home.
import 'form_screen.dart';
import 'detail_screen.dart';

// Widget para la pantalla principal después del login.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Neuroconecta'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        // Agrego un botón de "Cerrar Sesión" en la AppBar.
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            // La lógica real de cerrar sesión debe ir aquí.
            onPressed: () {
              // Simulación: Navegar de vuelta al Login después de cerrar sesión.
              // Navigator.of(context).pushReplacementNamed('/login');
              // Por ahora, solo muestro un mensaje.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión cerrada (simulación)')),
              );
            },
          ),
        ],
      ),
      // Muestro el contenido en una vista que permite desplazamiento.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Alineo los widgets al inicio de la columna.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Título de bienvenida con el nombre del usuario (simulado).
            const Text(
              '¡Hola, Usuario!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Encuentra tus recursos psicopedagógicos y de contención emocional.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 32),

            // GRID: Uso un GridView para mostrar las Cards principales de forma ordenada.
            GridView.count(
              // Deshabilito el propio scroll del GridView.
              physics: const NeverScrollableScrollPhysics(),
              // Hace que el GridView tome solo el espacio necesario (importante dentro de SingleChildScrollView).
              shrinkWrap: true,
              // Dos columnas.
              crossAxisCount: 2,
              // Espaciado entre las cards.
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              // Lista de las cards funcionales.
              children: <Widget>[
                // Card 1: Acceso al Formulario (CRUD).
                _buildFeatureCard(
                  context,
                  title: 'Mis Recursos (CRUD)',
                  icon: Icons.edit_note,
                  color: Colors.deepOrangeAccent,
                  // Navego a la pantalla de Formulario/CRUD.
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FormScreen(),
                      ),
                    );
                  },
                ),

                // Card 2: Acceso a la Pantalla de Detalle (Simulación).
                _buildFeatureCard(
                  context,
                  title: 'Detalles de Actividad',
                  icon: Icons.insights,
                  color: Colors.teal,
                  // Navego a la pantalla de Detalle.
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DetailScreen(itemId: '123'),
                      ),
                    );
                  },
                ),

                // Card 3: Otras funcionalidades de la aplicación.
                _buildFeatureCard(
                  context,
                  title: 'Orientación Profesional',
                  icon: Icons.record_voice_over,
                  color: Colors.purple,
                  onTap: () {
                    // Acción para orientación.
                  },
                ),

                // Card 4: Acceso a recursos de apoyo emocional.
                _buildFeatureCard(
                  context,
                  title: 'Apoyo Emocional',
                  icon: Icons.favorite_border,
                  color: Colors.pink,
                  onTap: () {
                    // Acción para apoyo emocional.
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget privado para construir una Card de funcionalidad reutilizable.
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // InkWell permite hacer un widget interactivo con efecto de toque (splash).
    return InkWell(
      onTap: onTap,
      child: Card(
        // Elevación para darle un efecto de profundidad.
        elevation: 4,
        // Forma con esquinas redondeadas.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Distribuyo los widgets verticalmente dentro de la card.
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // El ícono de la funcionalidad.
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              // El título de la funcionalidad.
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              // Pequeño indicador.
              const Text(
                'Acceder',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
