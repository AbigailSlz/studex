import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:studex/features/shared/menu_nav.dart';
import 'package:studex/services/student_service.dart';

class StudentsScreen extends StatefulWidget {
  //super.key para ubicar cada elemento en pantalla
  const StudentsScreen({
    super.key
  });
  //Constructor de estado
  @override 
  State<StudentsScreen> createState() => _StudentsScreenState();
}

//Clase para la pantalla
class _StudentsScreenState extends State<StudentsScreen>{
  //1. Creamos el control para la búsqueda
  final TextEditingController _busquedaController = TextEditingController();
  //2.Creamos la variable para obtener los datos del almacenamiento
  static const _secure = FlutterSecureStorage();
  //3. Declaramos todas las variables necesarias para la pantalla
  List<String> _estudiantes = [];
  String filtro = "";
  bool _isLoading = false;
  String? _error;
  String? _nombreGrupo;
  //4. Declarar método que se carga en automático al mostrar la pantalla
  @override 
  void initState() {
    super.initState();
    //Mandamos a llamar al método para cargar alumnos
    _cargarAlumnos();
  } 
  //5. Declarar método para "disponer/eliminar" del campo de búsqueda
  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }
  //6. Creamos el método de cargar alumnos
  Future<void> _cargarAlumnos() async {
    //6.1 Llamamos al método setState para cambiar el estado de la pantalla y colocar la animación de carga
    setState(() {
      _isLoading = true;
      _error = null;
    });
    //6.2 try/catch
    try {
      //1. Obtenemos la información del usuario guardada en el almacenamiento
      final usuario = await _secure.read(key: 'studex_user');
      //2. Validamos recibir el usuario
      if(usuario != null) {
        final Map<String,dynamic> user = jsonDecode(usuario);
        final nombreGrupo = user["nombre_grupo"] ?? '';

        if(mounted) {
          setState(() {
            _nombreGrupo = nombreGrupo?.toString();
          });
        }
      }

      //3. Mandamos llamar el método del servicio para obtener los datos de los estudiantes
      final nombres = await StudentService.obtenerEstudiantesGrupo();
      //4. Realizamos validaciones
      if(nombres.isEmpty) {
        setState(() {
          _estudiantes = [];
          _error = "No hay estudiantes o no fue posible cargar la lista.";
        });
      } else {
        setState(() {
          _estudiantes = nombres;
        });
      }
    } catch(error) {
      setState(() {
        _error = "Error al conectar con el servidor";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //1. Convertimos a minúsculas los alumnos filtrados
    final estudiantesFiltrados = _estudiantes.where((estudiante) => estudiante.toLowerCase().contains(filtro.toLowerCase())).toList();
    //2. Retornamos la pantalla
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey
          ),
        child: Text(
          'Grupo $_nombreGrupo',
          style: TextStyle(color: Colors.black87),
        ),
        ),
      ),

      //BODY
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Buscar',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),

          //Campo de texto para la búsqueda
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _busquedaController,
              onChanged: (texto) => setState(() => filtro = texto),
              decoration: InputDecoration(
                hintText: 'Buscar alumno...',
                fillColor: Colors.grey,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
            ),
          ),

          //ESPACIO ENTRE EL CAMPO DE TEXTO Y LA LISTA
          SizedBox(height: 10),

          //LISTA Y VALIDACIONES
          Expanded(
            child: () {
              //Si la pantalla está cargando mostramos el widget de carga
              if(_isLoading) {
                return Center(
                  child: CircularProgressIndicator()
                );
              }
              
              //Si existe un error lo mostramos en pantalla
              if(_error != null) {
                return Center(
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                  )
                );
              }

              //Si no hay alumnos filtrados indicamos en pantalla
              if(estudiantesFiltrados.isEmpty) {
                return Center(
                  child: Text(
                    "No existen alumnos en este grupo",
                    style: TextStyle(color:Colors.black54),
                  )
                );
              }

              //Devolvemos la lista de estudiantes
              return ListView.builder(
                padding:  EdgeInsets.symmetric(horizontal: 20),
                itemCount: estudiantesFiltrados.length,
                itemBuilder: (_,i) => _EstudianteItem(nombre: estudiantesFiltrados[i]),
              );
            }(),
          )
        ],
      ),

      //Menú de navegación
      bottomNavigationBar: MenuNav(
        tabActual: 1, 
        onTap: (i) {
          if(i == 0) {
           context.go('/perfil');
          }
        }
      ),
    );
  }
}

//WIDGET PERSONALIZADO PARA CADA ESTUDIANTE
class _EstudianteItem extends StatelessWidget {
  //Declaramos las variables necesarias
  final String nombre;
  //Indicamos que la variable nombre es obligatoria
  const _EstudianteItem({required this.nombre});

  //Construimos el widget
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding:  EdgeInsets.all(12),
      decoration:  BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(16)
      ),
      child:  Row(
        children: [
          //Imagen por defecto
          ClipOval(
            child: Image.asset(
              'assets/images/logosx.jpg',
              width: 60,
              height: 60,
              fit: BoxFit.cover
            ),
          ),
          //Espacio horizontal
          SizedBox(width: 16),
          //Nombre del estudiante
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87
              ),
            ) 
          )
        ],
      ),
    );
  }
}