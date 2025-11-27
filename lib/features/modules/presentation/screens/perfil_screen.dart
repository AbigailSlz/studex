import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:studex/features/shared/menu_nav.dart';
import 'package:studex/services/perfil_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState(); 

}

class _PerfilScreenState extends State<PerfilScreen> {
  //Definimos el tab (opción del menú)
  int _tabActual = 0;

  //Definimos el controlador/objeto para el modelo 3D
  final Flutter3DController _avatarCtrl = Flutter3DController();

  //Definimos la ruta donde se encuentra el avatar
  final String avatarGlb = 'assets/avatar/avatar_abigail.glb';

  //Definimos un timer (tiempo) de animación
  Timer? _finalTimer;

  //DEFINIMOS VARIABLES PARA EL MANEJO DE LOS DATOS DEL USUARIO
  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _error;


  @override
  //Creamos el método initState para manejar el estado de la pantalla
  //y cargar el modelo en 3d
  void initState(){
    super.initState();

    //LLAMAMOS AL MÉTODO PARA CARGAR LOS DATOS DEL PERFIL
    _loadPerfil();


    //Configuramos que el avatar se ejecute en automático junto con su animación
    try {
      _avatarCtrl.onModelLoaded.addListener(() {
        //Cuando "escuchemos" que el modelo se carga validamos recibirlo y si tiene animación la ejecutamos
        if(_avatarCtrl.onModelLoaded.value == true) {
          //Ejecuto el método para "play"
          _playAnimacion();
        }
      });

    }catch(_) {
      //Si no existe el modelo no muestra nada
    }

    //Ponemos un tiempo para ejecutar el play de la animación
    _finalTimer = Timer(const Duration(milliseconds: 700), _playAnimacion);

  }

      //TODO: CARGAR INFORMACIÓN DE PERFIL DE USUARIO
    Future<void> _loadPerfil() async {
      try {

        //1. Llamos al servicio para ejecutar el método de cargar perfil
        final datos = await PerfilService.getPerfil();
        //2. Validamos que esté la pantalla montada
        if(!mounted) return;
        //3. Actualizamos la interfaz con los nuevos valores
        setState(() {
          _user = datos;
          _loading = false;
          if(datos == null) {
            _error = "No se pudo obtener el perfil";
          }
        });

      } catch(error) {
        //Validamos que esté "montada" la pantalla
        if(!mounted) return;
        //Si está la pantalla actualizamos el estado de la app y mostramos el error
        setState(() {
          _error = 'Error: $error';
          _loading = false;
        });
      }
    }


  //Creamos el método para ejecutar la animación
  void _playAnimacion() {
    try {

      _avatarCtrl.playAnimation();
      _avatarCtrl.startRotation(rotationSpeed: 12);
      _avatarCtrl.setCameraOrbit(0, 80, 190);

    } catch(error) {
      debugPrint('Error al ejecutar animación $error');
    }
  }

  //Método para detener el timer
  @override
  void detener() {
    _finalTimer?.cancel();
    super.dispose();
  }

  //Méodo para construir la vista
  @override
    Widget build(BuildContext context) {

      //TODO: OBTENER LA INFORMACIÓN DEL USUARIO

      //1. MANEJAR LA PANTALLA DE CARGA
      if(_loading) {
        //Si la pantalla está cargando
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: CircularProgressIndicator()
            ) 
          ),
        );
      }

      //2. MANEJAMOS LOS ERRORES
      //Si hubo un error, muestra mensaje
      if(_error != null) {
        return Scaffold(
          body: SafeArea(
            child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14), //El signo ! indica que lo use como String
                  ),
                ),
              )
            ),
        );
      }  


      //================= CARGAR DATOS DEL USUARIO ==================
      final u = _user ?? {}; //Si _user viene vacío ENTONCES tomalo como un json vacío {}, ?? = "entonces".

      //Declaramos todos los campos recibidos y los validamos
      final nombre = (u["nombre"] ?? '') as String;
      final apellidoPaterno = (u["apellido_paterno"] ?? '') as String;
      final apellidoMaterno = (u["apellido_materno"] ?? '') as String;
      final apodo = (u["apodo"] ?? '') as String;
      final nombreGrupo = (u["nombre_grupo"] ?? '') as String;
      final nombreGrupoAbr = (u["grupo_abreviatura"] ?? '') as String;
      final nombreCarrera = (u["nombre_carrera"] ?? '') as String;
      final fechaNacimiento = (u["fecha_nacimiento"] ?? '').toString();
      final cuatrimestre = int.tryParse(u["cuatrimestre"]?.toString() ?? '') ?? 1;


      //Validamos el cuatrimestre para ser usado en la barra de progreso
      final progreso = cuatrimestre / 10.0;
      
      //Validamos que el cuatrimestre se ponga en pantalla como 01,02...
      final cuatrimestreLabel = cuatrimestre.toString().padLeft(2,'0');



      return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
            slivers: [
              //CABECERA
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      //ENCABEZADO PERFIL
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
                        child: Text('Perfil', style: TextStyle(fontWeight: FontWeight.w600)),
                      )
                    ],
                  ),
                )
              ),

              //NOMBRE Y MODELO EN 3D
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$nombre $apellidoPaterno $apellidoMaterno',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                        ),
                      ),
                      //espacio
                      SizedBox(height: 8),
                      //avatar
                      SizedBox(
                        height: 260,
                        child:  Flutter3DViewer(
                          src: avatarGlb,
                          controller: _avatarCtrl),
                      )
                    ],
                  )
              )
            ),
            
            //CUATRIMESTRE + PROGRESO
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          cuatrimestreLabel,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          )
                        ),
                        //Espacio
                        SizedBox(height: 2),
                        Text(
                          'cuatrimestre',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 15
                          ),
                        )
                      ],
                    ),
                    //Espacio horizontal
                    SizedBox(width: 18),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: progreso,
                            minHeight: 8,
                            backgroundColor: Colors.grey,
                            valueColor: AlwaysStoppedAnimation(Colors.green),
                        ),
                      )
                    )
                  ],
                )
              ),
            ),

            //DATOS PERSONALES
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24,22,24,6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(3)
                          ),
                        )
                      ),
                      SizedBox(width: 16),
                      Column(
                        children: [
                          Text(
                            'DATOS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                            'PERSONALES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600
                              ),
                            )
                        ],
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(3)
                          ),
                        )
                      )
                    ],
                  ),
                ),
              ),

              //DATOS DEL PERFIL 
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 24, vertical: 6),
                  child: Column(
                    children: [
                      _InformacionFila(label: 'Nombre', value: '$nombre $apellidoPaterno $apellidoMaterno'),
                      _InformacionFila(label: 'Carrera', value:  nombreCarrera),
                      _InformacionFila(label: 'Grupo', value: nombreGrupoAbr),
                      _InformacionFila(label: 'Cumpleaños', value: fechaNacimiento)
                    ],
                  ),
                ),
              )
            ],
          )        
        ),

        //MENÚ
        /*onDestinationSelected 
          Se ejecuta cuando el usuario toca una pestaña
          i = es el número del botón (0,1,2...)
          setState = Actualiza el estado de la aplicación y 
          marca la nueva pestaña como seleccionada
        */
        bottomNavigationBar: MenuNav(
          tabActual: _tabActual, 
          onTap: (i) {
            setState(() => _tabActual = i );
            //Validamos cada opción del menú
            if(i == 0) return; //Ya estamos en la opción de perfil
            if(i == 1) context.go('/grupo'); 
          }
        ),
      );
    }
}

//WIDGET PERSONALIZADO PARA PINTAR INFORMACIÓN DEL PERFIL
class _InformacionFila extends StatelessWidget {
  //Declaramos los parámetros obligatorios a recibir
  const _InformacionFila({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
      return Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 86,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14
                ),
              )
            )
          ],
        ),
      );
  }
}


 