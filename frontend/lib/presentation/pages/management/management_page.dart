import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagementPage extends ConsumerWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('本管理')),
      body: const Center(
        child: Text('本管理画面')
      ),
    );
  }
}