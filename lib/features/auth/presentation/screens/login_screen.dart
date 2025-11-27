
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studex/services/login_service.dart';

class LoginScreen extends StatelessWidget {

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    const double logoRadius = 66; //constante para el tamaño de la imagen

    //final: una variable que se le asigna un valor una sola vez.
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    
    //< > : estos simbolos en dart definen un tipo. Ej
    //formkey es de tipo FormState
    //FormState: me permite validar y resetear un formulario.
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          //SingleChildScrollView: Permite hacer scroll si el contenido no cabe por ejemplo cuando se abre el teclado.
          child: SingleChildScrollView(
                padding:  EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //==================LOGOTIPO================
                    CircleAvatar(
                      radius: logoRadius,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: logoRadius - 4,
                        backgroundImage: AssetImage('assets/images/logosx.jpg'), //Para que la imagen se visualice debe de estar declarada en pubspec.yaml
                      ),
                    ),
                    //Espacio vacío 
                    SizedBox(height: 16),

                    //==================NOMBRE==============
                    Text(
                      'StudeX',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    //============ FORMULARIO ============
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // ===== CAMPO DE CORREO ====
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            //_dec: es una función que realizaremos para especificar todo el estilo de nuestros campos de texto.
                            decoration: _dec(label: 'Correo',icon: Icons.person_outline),
                            //OPERADOR TERNARIO:
                            // (CONDICION) ? VALORSICUMPLE : VALORSINOCUMPLE
                            // '?' :Significa 'entonces'
                            //Mi campo de texto recibe un valor, si ese valor es null o NO contiene un @ entonces va a mostrar correo inválido, si el campo tiene valor no muestra nada.
                            validator: (valor) => (valor == null || !valor.contains('@') ? 'Correo inválido':null),
                          ),
                          
                          SizedBox(height: 14),

                          //=============== CAMPO DE CONTRASEÑA ====
                          //_PasswordField es un Widget creado por nosotros (personalizado), para el campo de contraseña.
                          //_ el guión bajo significa que es privado y no se podrà utilizar fuera de este archivo login_screen.dart
                          _PasswordField(
                            controller: passCtrl,
                            decoration: _dec(label: 'Contraseña', icon: Icons.lock_outline),
                          ),

                          SizedBox(height: 22),

                          //====== BOTÓN DE INGRESAR =========
                          SizedBox(
                            //Double.infinity significa que va a abarcar todo el ancho disponible.
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)
                                )
                              ),
                              //Método que se ejecuta al presionar el botón
                              onPressed: () async {
                                //FocusScope, quita el enfoque del campo que está activo (cierra el teclado)
                                FocusScope.of(context).unfocus();
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                try {

                                  //Mandamos llamar al servicio del login
                                  final login = await AuthApi.login(
                                    login: emailCtrl.text.trim(),
                                    password: passCtrl.text.trim(),
                                  );

                                  //Mostramos en consola que el login ya se realizó
                                  debugPrint('Login realizado $login');

                                    //Validamos que la interfaz este "montada"
                                  if(!context.mounted) return;

                                  //Si se obtuvo información (el login fue exitoso)
                                  //redireccionamos al la pantalla de perfil
                                  if(login) {
                                    context.go('/perfil');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Usuario o contraseña inválidos'))
                                    );

                                    //"Descongelamos" cualquier elemento que tengamos en pantalla
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                    });
                                  }
                                }catch(e,st){
                                  debugPrint('Excepción en login');
                                }
                                
                              }, 
                              child: Text(
                                  'Ingresar',
                                  style: TextStyle(fontWeight: FontWeight.w200),
                                )
                              ),
                          ),

                          SizedBox(height: 16),

                          //============== ENLACE PARA REGISTRARSE =======
                           Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('¿No tienes una cuenta?'),
                                TextButton(
                                  onPressed: () => context.push('/register'), 
                                  child: Text(
                                    'Regístrate',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  )
                                )
                              ],
                            ),
                        ],
                      ),
                    
                    )
                  ],
                ),
          ),
        )
      ),
    );
  }

  static InputDecoration _dec({required String label, required IconData icon}) {
    // return -> palabra reservada: retorna el valor de la función.
    return InputDecoration(
      // labelText -> texto de etiqueta (aparece como "placeholder").
      labelText: label,
      // prefixIcon -> ícono que aparece al inicio del campo de texto.
      prefixIcon: Icon(icon),
      // filled/fillColor -> pinta el fondo del campo.
      filled: true,
      fillColor: Colors.white,
      // contentPadding -> espacio interno del contenido (texto) respecto a los bordes.
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      // border/enabledBorder/focusedBorder -> definen apariencia del borde en distintos estados.
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        // BorderSide -> describe color/grosor de línea.
        borderSide: const BorderSide(color: Color(0xFFCDD1D5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black, width: 1.2),
      ),
    );
  }
}

//================== WIDGET PERSONALIZADO DE CONTRASEÑA ===============

class _PasswordField extends StatefulWidget {
  // const -> (constructor constante si todos los campos son const/inalterables).
  // {required ...} -> PARÁMETROS NOMBRADOS y OBLIGATORIOS (required).
  const _PasswordField({required this.controller, required this.decoration});

  // final -> palabra reservada: solo asignable una vez (inmutable después de construir el widget).
  final TextEditingController controller; // controla el texto del campo
  final InputDecoration decoration;       // decoración base reutilizable

  @override
  // createState -> método de StatefulWidget que debe devolver una instancia de State asociada.
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  // bool -> tipo lógico de Dart (true/false).
  // _obscure -> nombre de variable PRIVADA (por _). Controla si el campo oculta el texto.
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller, // "widget" -> referencia a los parámetros del StatefulWidget padre.
      // obscureText -> si true, oculta el texto (••••).
      obscureText: _obscure,
      // decoration -> usamos la decoración que llegó, pero modificamos solo "suffixIcon".
      // copyWith(...) -> Crea una COPIA del objeto con algunos cambios.
      //                  Mantiene lo demás igual.
      decoration: widget.decoration.copyWith(
        // suffixIcon -> ícono al final del campo (ojo para mostrar/ocultar).
        suffixIcon: IconButton(
          // onPressed -> al tocar el ícono, alternamos _obscure y redibujamos con setState.
          onPressed: () => setState(() => _obscure = !_obscure),
          // Icon(...) -> widget de ícono; elige visibilidad según estado.
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        ),
      ),
      // validator -> si está vacío, muestra error.
      validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
    );
  }
}


