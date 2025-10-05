import 'package:flutter/material.dart';
import '../widgets/physics_ambient_dashboard.dart';

class PhysicsAmbientPage extends StatelessWidget {
  const PhysicsAmbientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: const SafeArea(
        child: PhysicsAmbientDashboard(),
      ),
    );
  }
}
