import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  runApp(PomoFocusApp(storageService: storageService));
}

class PomoFocusApp extends StatelessWidget {
  final StorageService storageService;

  const PomoFocusApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PomoFocus Pro',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(storageService: storageService),
    );
  }
}
