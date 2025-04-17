import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/pages/management/management_page.dart';
import 'package:frontend/providers/presentation_providers.dart';

import 'presentation/pages/add_book/add_book_page.dart';
import 'presentation/pages/home/home_page.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  try{
    // Load environment variables from .env file
    await dotenv.load(fileName: ".env");
    print('.env file loaded successfully');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  runApp(
      ProviderScope(
          child: const MyApp()
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '読書管理アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainAppScaffold(),
    );
  }
}

class MainAppScaffold extends ConsumerWidget {
  const MainAppScaffold({super.key});

  final List<Widget> _screens = const [
    HomePage(),
    AddBookPage(),
    ManagementPage()
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('読書管理アプリ'),
      ),
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '登録',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '管理',
          ),
        ],
      ),
    );
  }
}
