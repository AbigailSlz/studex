import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudentService {

  //1. Declaramos el endpoint
  static const String _listaEstudiantes = 'https://www.abigailslz.com/apiStudex/api/grupos';

  //2. Creamos una variable para acceder al almacenamiento local
  static const _secure = FlutterSecureStorage();

  //3. Creamos la funciòn para obtener la información
  static Future<List<String>> obtenerEstudiantesGrupo() async {
    //3.1 Obtenemos el token y la información de usuario guardadas en _secure
    final token = await _secure.read(key: 'studex_token');
    final usuario = await _secure.read(key: 'studex_user');
    //3.2 validamos que no estén vacíos
    if(token == null || usuario == null) return []; 
    //3.3 Decodificamos la información del usuario en json
    final Map<String, dynamic> user = jsonDecode(usuario);
    //3.4 Nos aseguramos que el id_grupo sea entero
    final int? idGrupo = int.tryParse(user["id_grupo"].toString()); 
    //3.5 Validamos recibir el id_grupo
    if(idGrupo == null) return [];
    //3.6 Realizamos la petición por http
    final resultado = await http.get(
      Uri.parse('$_listaEstudiantes/$idGrupo/usuarios'),
      headers: {
        'Accept':'application/json',
        'Content-Type':'application/json',
        'Authorization': 'Bearer $token'
      }
    );
    //3.7 Validamos las respuestas obtenidas
    if(resultado.statusCode <200 || resultado.statusCode >=300) return [];
    //3.8 Obtenemos el resultado y lo decodificamos a json
    final Map<String,dynamic> jsonResultado = jsonDecode(resultado.body);
    //3.9 Validamos el resultado y creamos la lista
    if(jsonResultado['ok'] == true && jsonResultado["data"] is List) {
      //Creamos una variable para la información
      final List datos = jsonResultado["data"];
      //Retornamos la información necesaria
      return datos.map((elemento) {
        final nombre = (elemento['nombre'] ?? '').toString();
        final apPaterno = (elemento['apellido_paterno'] ?? '').toString();
        final apMaterno = (elemento['apellido_materno'] ?? '').toString();
        return '$nombre $apPaterno $apMaterno'.trim();
      }).toList();
    }
    return [];
  }
}