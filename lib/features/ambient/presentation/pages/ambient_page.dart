import 'package:flutter/material.dart';
import '../widgets/ambient_dashboard.dart';
import '../widgets/physics_ambient_dashboard.dart';
import '../../../../examples/drag_behavior_test.dart';
import '../../../../examples/enlarge_test.dart';

class AmbientPage extends StatefulWidget {
  const AmbientPage({super.key});

  @override
  State<AmbientPage> createState() => _AmbientPageState();
}

class _AmbientPageState extends State<AmbientPage> {
  bool _usePhysics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            _usePhysics
                ? const PhysicsAmbientDashboard()
                : const AmbientDashboard(),

            // Toggle button
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    onPressed: () {
                      setState(() {
                        _usePhysics = !_usePhysics;
                      });
                    },
                    backgroundColor: _usePhysics ? Colors.blue : Colors.grey,
                    child: Icon(
                      _usePhysics ? Icons.science : Icons.grid_view,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DragBehaviorTest(),
                        ),
                      );
                    },
                    backgroundColor: Colors.orange,
                    child: const Icon(
                      Icons.science,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EnlargeTest(),
                        ),
                      );
                    },
                    backgroundColor: Colors.purple,
                    child: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
