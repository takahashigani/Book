import 'package:flutter_riverpod/flutter_riverpod.dart';

// 検索キーワードを保持するProvider
// 初期値は空文字列
final searchKeywordProvider = StateProvider<String>((ref) => '');

// 現在選択されているボトムナビゲーションのタブインデックスを管理するProvider
// 初期値は0
final navigationIndexProvider = StateProvider<int>((ref) => 0);
