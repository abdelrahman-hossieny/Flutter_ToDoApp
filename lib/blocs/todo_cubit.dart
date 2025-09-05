import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/models/TodoModel.dart';
import '../services/storage_service.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final String userEmail;

  TodoCubit(this.userEmail) : super(TodoState.initial) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    emit(state.copyWith(status: TodoStatus.loading));

    try {
      final todos = await StorageService.loadTodos(userEmail);
      emit(state.success(todos));
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        error: 'Failed to load todos',
      ));
    }
  }

  void searchTodos(String query) {
    final trimmedQuery = query.trim().toLowerCase();

    if (trimmedQuery.isEmpty) {
      // If search query is empty, show all todos
      emit(state.copyWith(
        searchQuery: '',
        filteredTodos: null,
      ));
    } else {
      // Filter todos based on title and description
      final filteredTodos = state.todos.where((todo) {
        final titleMatch = todo.title.toLowerCase().contains(trimmedQuery);
        final descriptionMatch = todo.description?.toLowerCase().contains(trimmedQuery) ?? false;
        return titleMatch || descriptionMatch;
      }).toList();

      emit(state.copyWith(
        searchQuery: trimmedQuery,
        filteredTodos: filteredTodos,
      ));
    }
  }

  void clearSearch() {
    emit(state.copyWith(
      searchQuery: '',
      filteredTodos: null,
    ));
  }

  Future<void> addTodo(String title, {String? description, DateTime? deadline}) async {
    if (title.trim().isEmpty) {
      emit(state.copyWith(
        error: 'You cant add empty Todo!',
        status: TodoStatus.error,
      ));
      return;
    }

    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description?.trim(),
      deadline: deadline,
    );

    final currentTodos = _getCurrentTodos();
    final updatedTodos = [...currentTodos, newTodo];

    try {
      await StorageService.saveTodos(userEmail, updatedTodos);
      final newState = state.success(updatedTodos);
      emit(newState);

      // Re-apply search if there's an active search
      if (state.searchQuery.isNotEmpty) {
        searchTodos(state.searchQuery);
      }
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        error: 'Failed to add todo',
      ));
    }
  }

  Future<void> updateTodo(String id, {String? title, String? description, DateTime? deadline}) async {
    final currentTodos = _getCurrentTodos();
    final updatedTodos = currentTodos.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(
          title: title ?? todo.title,
          description: description,
          deadline: deadline,
        );
      }
      return todo;
    }).toList();

    try {
      await StorageService.saveTodos(userEmail, updatedTodos);
      emit(state.success(updatedTodos));

      // Re-apply search if there's an active search
      if (state.searchQuery.isNotEmpty) {
        searchTodos(state.searchQuery);
      }
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        error: 'Failed to update todo',
      ));
    }
  }

  Future<void> deleteTodo(String id) async {
    final currentTodos = _getCurrentTodos();
    final updatedTodos = currentTodos.where((todo) => todo.id != id).toList();

    try {
      await StorageService.saveTodos(userEmail, updatedTodos);
      emit(state.copyWith(
        todos: updatedTodos,
        status: TodoStatus.success,
        error: null,
      ));

      // Re-apply search if there's an active search
      if (state.searchQuery.isNotEmpty) {
        searchTodos(state.searchQuery);
      }
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        error: 'Failed to delete todo',
      ));
    }
  }

  Future<void> toggleTodo(String id) async {
    final currentTodos = _getCurrentTodos();
    final updatedTodos = currentTodos.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();

    try {
      await StorageService.saveTodos(userEmail, updatedTodos);
      emit(state.copyWith(
        status: TodoStatus.success,
        error: null,
        todos: updatedTodos,
      ));

      // Re-apply search if there's an active search
      if (state.searchQuery.isNotEmpty) {
        searchTodos(state.searchQuery);
      }
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        error: 'Failed to update todo',
      ));
    }
  }

  List<Todo> _getCurrentTodos() {
    return state.todos;
  }
}