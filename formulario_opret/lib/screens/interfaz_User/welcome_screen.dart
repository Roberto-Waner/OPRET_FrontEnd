import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:formulario_opret/screens/interfaz_User/navbarUser/navbar_Empl.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class WelcomeScreen extends StatefulWidget {
  final TextEditingController filtrarUsuarioController;
  final TextEditingController filtrarEmailController;
  final TextEditingController filtrarId;

  const WelcomeScreen({
    super.key,
    required this.filtrarUsuarioController,
    required this.filtrarEmailController,
    required this.filtrarId,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletWidth = size.width > 600;
    final isTabletHeight = size.height > 800;
    return isTabletWidth && isTabletHeight;
  }

  Widget logoInsideLogin(bool isTabletDevice) {
    return Container(
      width: isTabletDevice ? 0.3.sw : 0.3.sw, // Ajuste del ancho basado en el tamaño de la pantalla (30% del ancho)
      height: isTabletDevice ? 0.2.sh : 0.2.sh, // Ajuste del alto basado en el tamaño de la pantalla (20% del alto)
      decoration: const BoxDecoration(
        shape: BoxShape.circle, // El logo estará dentro de un contenedor circular
        color: Color.fromRGBO(255, 255, 255, 1),
      ),
      child: Padding(
        padding: isTabletDevice ? const EdgeInsets.all(50.0) : const EdgeInsets.all(30.0), // Margen dentro del logo
        child: Image.asset(
          'assets/Logo/Logo_Metro_transparente.png',
          fit: BoxFit.contain, // El logo se ajustará manteniendo su aspecto original
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTabletDevice = isTablet(context);

    return PopScope(
      canPop: false,
      child: ScreenUtilInit(
        designSize: const Size(360, 740),
        builder: (context, child) => Scaffold(
          drawer: NavbarEmpl(
            filtrarUsuarioController: widget.filtrarUsuarioController,  
            filtrarEmailController: widget.filtrarEmailController,
            filtrarId: widget.filtrarId,
            // // filtrarCedula: widget.filtrarCedula,
          ),
        
          appBar: AppBar(
            title: const Text('Inicio', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
            backgroundColor: const Color.fromARGB(255, 1, 135, 76),
          ),
        
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 1, 135, 76), Color.fromARGB(255, 22, 218, 0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(height: isTabletDevice ? 80.h : 80.h),
                      logoInsideLogin(isTabletDevice),
                      const SizedBox(height: 20),
                      const Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        )
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Estamos felices de verte aquí.',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        // color: Colors.white,
                        decoration: BoxDecoration( 
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35), 
                          boxShadow: [ 
                            BoxShadow( 
                              color: Colors.black.withOpacity(0.1), 
                              blurRadius: 10, 
                              offset: const Offset(0, 5), 
                            ), 
                          ], 
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2000, 1, 1),
                          lastDay: DateTime.utc(2100, 1, 1),
                          focusedDay: DateTime.now(),
                          calendarFormat: CalendarFormat.month,
                          availableGestures: AvailableGestures.none, // Desactiva la selección y deslizamiento
                          headerStyle: const HeaderStyle(
                            titleTextStyle: TextStyle(color: Color.fromARGB(255, 30, 179, 10), fontSize: 35),
                            formatButtonVisible: false, // Oculta el botón de formato
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: const TextStyle(color: Color.fromARGB(255, 29, 143, 1), fontSize: 15),
                            weekendStyle: const TextStyle(color: Color.fromARGB(255, 0, 52, 208), fontSize: 15),
                            dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date)[0], // Mostrar solo la primera letra
                          ),
                          calendarStyle: const CalendarStyle(
                            defaultTextStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
                            weekendTextStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
                            holidayTextStyle: TextStyle(color: Colors.orange, fontSize: 20)
                          ),
                        ),
                      )
                    ]
                  )
                )
              ),
            )
          ),
        ),
      ),
    );
  }
}