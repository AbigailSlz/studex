import 'package:go_router/go_router.dart';
import 'package:studex/features/auth/presentation/screens/login_screen.dart';
import 'package:studex/features/auth/presentation/screens/register_screen.dart';
import 'package:studex/features/modules/presentation/screens/perfil_screen.dart';
import 'package:studex/features/modules/presentation/screens/students_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    //Rutas para autenticación
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen()
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen()
    ) ,
    GoRoute(
      path: '/perfil',
      builder: (context, state) => const PerfilScreen()
    ),
    GoRoute(
      path: '/grupo',
      builder: (context,state) => const StudentsScreen()
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen()
    ) 
  ]
);