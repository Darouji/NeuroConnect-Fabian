import 'package:flutter/material.dart';
// Importo el servicio de Firebase para la lógica de CRUD.
// import '../services/firebase_service.dart';
// Importo el modelo para definir la estructura del objeto.
// import '../models/recurso_model.dart';

// Lo defino como StatefulWidget para manejar los campos del formulario y la validación.
class FormScreen extends StatefulWidget {
  // Opcional: Recibir un objeto existente para editarlo.
  // final RecursoModel? recursoToEdit;
  const FormScreen({super.key /*, this.recursoToEdit */});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // Clave global para identificar y validar el Formulario.
  final _formKey = GlobalKey<FormState>();
  // Controladores para obtener el texto de los campos de entrada.
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();

  // Función para manejar la acción de guardar/actualizar el recurso.
  void _saveRecurso() async {
    // Si la validación del formulario es exitosa, procedo.
    if (_formKey.currentState!.validate()) {
      // Muestro un indicador de carga.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Guardando Recurso...')));

      // SIMULACIÓN: Aquí iría la lógica de CRUD (Crear/Actualizar) a Firebase.
      // try {
      //   final recurso = RecursoModel(
      //     id: widget.recursoToEdit?.id, // Si estoy editando, uso el ID existente.
      //     titulo: _tituloController.text,
      //     descripcion: _descripcionController.text,
      //     autor: _autorController.text,
      //   );
      //   // await FirebaseService().saveRecurso(recurso);

      //   // Si la operación es exitosa:
      //   if (mounted) {
      //     Navigator.of(context).pop(); // Vuelvo a la pantalla anterior (Home).
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Recurso guardado con éxito!')),
      //     );
      //   }
      // } catch (e) {
      //   // Muestro un error en caso de fallo.
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Error al guardar: $e')),
      //   );
      // }

      // Simulación de guardado exitoso y regreso.
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recurso guardado con éxito (simulado)!'),
          ),
        );
      }
    }
  }

  @override
  // Se llama cuando el widget se inicializa (útil para precargar datos de edición).
  void initState() {
    super.initState();
    // Si recibí un objeto para editar (no nulo), lleno los campos.
    // if (widget.recursoToEdit != null) {
    //   _tituloController.text = widget.recursoToEdit!.titulo;
    //   _descripcionController.text = widget.recursoToEdit!.descripcion;
    //   _autorController.text = widget.recursoToEdit!.autor;
    // }
  }

  @override
  // Se llama cuando el widget se destruye (importante para liberar recursos).
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _autorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El título cambia si estoy creando o editando.
        title: const Text(
          'Crear/Editar Recurso',
        ), // widget.recursoToEdit == null ? 'Crear Recurso' : 'Editar Recurso',
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Form es el widget que permite la validación de los campos.
        child: Form(
          key: _formKey, // Asigno la clave global al formulario.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Campo de texto para el Título del recurso (obligatorio).
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del Recurso',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                // Función de validación: si el campo está vacío, muestro un error.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de texto para la Descripción (obligatorio y multilinea).
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4, // Permito varias líneas de texto.
                // Función de validación: si el campo está vacío, muestro un error.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción no puede estar vacía';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de texto para el Autor/Fuente.
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(
                  labelText: 'Autor/Fuente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 32),

              // Botón principal para Guardar o Actualizar.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveRecurso, // Llama a mi función para guardar.
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar Recurso',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),

              // SIMULACIÓN: Botón de ELIMINAR (solo si se está editando).
              // if (widget.recursoToEdit != null)
              //   const SizedBox(height: 16),
              //   SizedBox(
              //     width: double.infinity,
              //     child: OutlinedButton.icon(
              //       onPressed: () {
              //         // Aquí iría la lógica de DELETE a Firebase
              //         // FirebaseService().deleteRecurso(widget.recursoToEdit!.id);
              //       },
              //       icon: const Icon(Icons.delete, color: Colors.red),
              //       label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              //       style: OutlinedButton.styleFrom(
              //         padding: const EdgeInsets.symmetric(vertical: 15),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
