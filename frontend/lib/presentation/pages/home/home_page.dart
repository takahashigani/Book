import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/entities/book.dart';
import 'package:frontend/providers/presentation_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(managementProvider);

    // 読書状態のカウント
    final int completedCount = state.books
        .where((book) => book.readingStatus == ReadingStatus.completed)
        .length;
    final int wantToReadCount = state.books
        .where((book) => book.readingStatus == ReadingStatus.wantToRead)
        .length;
    final int readingCount = state.books
        .where((book) => book.readingStatus == ReadingStatus.reading)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child:
                  _buildStatusCard('読書中', readingCount, Colors.red),
                ),
                Expanded(child:
                  _buildStatusCard('読了', completedCount, Colors.green),
                ),
                Expanded(child:
                  _buildStatusCard('読みたい', wantToReadCount, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(navigationIndexProvider.notifier).state = 1;
              },
              child: const Text('本を探すページへ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(navigationIndexProvider.notifier).state = 2;
              },
              child: const Text('読書管理ページへ'),
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, int count, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count冊',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}