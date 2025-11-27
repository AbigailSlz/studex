import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PerfilService {
  //Endpoint para obtener la información del perfil
  static const String _perfil = 'https://www.abigailslz.com/apiStudex/api/profile';

  //Creamos el objeto _secure que es el almacenamiento
  //del telefono para obtener el token que guardamos en el login
  static const _secure = FlutterSecureStorage();

  //Creamos la función para hacer la petición al endpoint
  static Future<Map<String, dynamic>?> getPerfil() async {
    //1. Obtenmos el token guardado
    final token = await _secure.read(key: 'studex_token');
    if(token == null) return null;

    //2. Realizamos la petición
    final resultado = await http.get(
      Uri.parse(_perfil),
      headers: {
        "Authorization": 'Bearer $token',
      }
    );

    //3. validamos la respuesta
    if(resultado.statusCode <200 || resultado.statusCode >=300) return null;

    //4. Obtenemos la información del body
    final Map<String,dynamic> json = jsonDecode(resultado.body);

    //5. Validamos el json
    if(json["ok"] == true && json["user"] != null) {
      return json["user"];
    } 

    return null;
  }
}