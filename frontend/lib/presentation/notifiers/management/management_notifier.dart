import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/entities/book.dart';
import 'package:frontend/presentation/notifiers/management/management_state.dart';
import 'package:frontend/providers/domain_providers.dart';

class ManagementNotifier extends Notifier<ManagementState>{

  @override
  ManagementState build() {
    final initialState = ManagementState(
      status: ManagementStatus.loading,
      selectedStatus: ReadingStatus.completed,
      books: [],
    );
    Future.microtask( () => _initialFetch(initialState.selectedStatus));
    return initialState;
  }

  Future<void> _initialFetch(ReadingStatus initialStatus) async {
    await fetchBooks(initialStatus);
  }

  Future<void> fetchBooks(ReadingStatus status) async {
    state = state.copyWith(
        status: ManagementStatus.loading,
        selectedStatus: status,
        clearErrorMessage: true
    );

    try {
      final getBooksByStatus = ref.read(getBooksByStatusUseCaseProvider);
      final books = await getBooksByStatus(status);
      state = state.copyWith(
        status: ManagementStatus.Success,
        books: books,
        selectedStatus: status,
      );
    } catch(e){
      state = state.copyWith(
        status: ManagementStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> changeStatus(int bookId, ReadingStatus newStatus) async {
    try{
      final updateBookStatus = ref.read(updateBookStatusProvider);
      await updateBookStatus(bookId, newStatus);
      await fetchBooks(state.selectedStatus);
    } catch (e) {
      print('ステータス更新エラー: $e');
      throw Exception('ステータス更新に失敗しました');
      state = state.copyWith(
        status: ManagementStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }
}