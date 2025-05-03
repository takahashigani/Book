// 画面の状態を表すEnum
import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entities/book.dart';

enum ManagementStatus {
  initial,
  loading,
  Success,
  failure,
}

// 管理画面の状態を表すクラス
class ManagementState extends Equatable {
  final ManagementStatus status; // 画面の状態
  final List<Book> books; // 本のリスト
  final ReadingStatus selectedStatus; // 選択された本の状態
  final String? errorMessage; // エラーメッセージ

  const ManagementState({
   this.status = ManagementStatus.initial,
    this.books = const [],
    this.selectedStatus = ReadingStatus.completed,
    this.errorMessage,
  });

  ManagementState copyWith({
    ManagementStatus? status,
    List<Book>? books,
    ReadingStatus? selectedStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
}) {
    return ManagementState(
      status: status ?? this.status,
      books: books ?? this.books,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    books,
    selectedStatus,
    errorMessage,
  ];
}
