
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿Ya tienes una cuenta?'),
              TextButton(
                onPressed: () => context.go('/login'), 
                child: Text(
                  'Inicia sesión',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              )
            ],
          ),
        )
      ),
    );
  }
}