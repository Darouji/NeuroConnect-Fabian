// Archivo: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';
import '../widgets/category_card.dart'; // Ahora debería funcionar porque renombraste la carpeta
import 'form_screen.dart';
import 'auth/login_screen.dart';
import 'category_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isAdmin = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Terapias Clínicas',
      'desc': 'Fonoaudiología y Terapia Ocupacional',
      'icon': Icons.medical_services,
      'color': AppColors.catTerapias,
    },
    {
      'title': 'Salud Mental',
      'desc': 'Psicología y Psiquiatría',
      'icon': Icons.psychology,
      'color': AppColors.catSaludMental,
    },
    {
      'title': 'Contención Emocional',
      'desc': 'Estrategias de regulación',
      'icon': Icons.favorite,
      'color': AppColors.catContencion,
    },
    {
      'title': 'Área Especial',
      'desc': 'Educación Diferencial',
      'icon': Icons.star,
      'color': AppColors.catAreaEspecial,
    },
    {
      'title': 'MyFunner',
      'desc': 'Actividades recreativas',
      'icon': Icons.sentiment_satisfied_alt,
      'color': AppColors.catMyFunner,
    },
    {
      'title': 'General',
      'desc': 'Información variada',
      'icon': Icons.info,
      'color': AppColors.catGeneral,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRole());
  }

  void _checkRole() {
    final User? user = _firebaseService.getCurrentUser();
    if (user != null && user.email != null) {
      if (user.email!.trim().toLowerCase() ==
          AppConstants.adminEmail.trim().toLowerCase()) {
        if (mounted) setState(() => _isAdmin = true);
      }
    }
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sugerencias'),
        content: TextField(
          controller: feedbackCtrl,
          decoration: const InputDecoration(
            hintText: 'Escribe tu sugerencia aquí...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (feedbackCtrl.text.isNotEmpty) {
                // Guardamos referencia a los datos antes de cerrar
                final text = feedbackCtrl.text;
                final email = _firebaseService.getCurrentUser()?.email;

                _firebaseService.sendFeedback(text, email);
                Navigator.pop(context);

                // Verificamos mounted antes de usar ScaffoldMessenger
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gracias por tu aporte')),
                  );
                }
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroConecta'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: _showFeedbackDialog,
            tooltip: 'Feedback',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _firebaseService.signOut();
              // Verificación de seguridad (Async gap)
              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Selecciona una categoría",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final cat = _categories[index];

                  return CategoryCard(
                    title: cat['title'],
                    description: cat['desc'],
                    icon: cat['icon'],
                    categoryColor: cat['color'],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CategoryListScreen(
                            categoryName: cat['title'],
                            categoryColor: cat['color'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FormScreen()),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
