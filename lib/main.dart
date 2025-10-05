import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/theme_manager.dart';
import 'core/services/service_locator.dart';
import 'features/ambient/presentation/pages/ambient_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize service locator
  await ServiceLocator.setup();

  runApp(const GeoffWidgetsApp());
}

class GeoffWidgetsApp extends StatelessWidget {
  const GeoffWidgetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Geoff Widgets',
            debugShowCheckedModeBanner: false,
            theme: themeManager.currentTheme,
            home: const AmbientPage(),
          );
        },
      ),
    );
  }
}
