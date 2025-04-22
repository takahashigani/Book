import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/notifiers/management/management_notifier.dart';
import 'package:frontend/presentation/notifiers/management/management_state.dart';

// 検索キーワードを保持するProvider
// 初期値は空文字列
final searchKeywordProvider = StateProvider<String>((ref) => '');

// 現在選択されているボトムナビゲーションのタブインデックスを管理するProvider
// 初期値は0
final navigationIndexProvider = StateProvider<int>((ref) => 0);

final managementProvider = NotifierProvider<ManagementNotifier, ManagementState>(() {
  return ManagementNotifier();
});