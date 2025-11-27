import 'package:flutter/material.dart';

class MenuNav extends StatelessWidget {
  //1. Declaramos la variable para la tab seleccionada actual
  final int tabActual;
  //2. Declaramos la variable para la tab que se presiona
  final ValueChanged<int> onTap;

  //Inicializamos las variables
  const MenuNav({
    super.key,
    required this.tabActual,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: tabActual,
      onTap: onTap, // La opción que se tocó
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true, //Mostrar texto de las opciones no seleccionadas
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil' 
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          label: 'Mi grupo' 
        )
      ],
    );
  }
}