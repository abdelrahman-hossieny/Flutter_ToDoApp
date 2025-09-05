import 'package:todoapp/models/TodoModel.dart';

enum TodoStatus { initial, loading, error, success }

class TodoState {
  final List<Todo> todos;
  final TodoStatus status;
  final String? error;
  final String searchQuery;
  final List<Todo>? filteredTodos;

  const TodoState._({
    required this.todos,
    required this.status,
    this.error,
    this.searchQuery = '',
    this.filteredTodos,
  });

  static const TodoState initial = TodoState._(
    todos: [],
    status: TodoStatus.initial,
    error: null,
    searchQuery: '',
    filteredTodos: null,
  );

  // Get the todos to display (filtered or all)
  List<Todo> get displayTodos => filteredTodos ?? todos;

  // Check if search is active
  bool get isSearching => searchQuery.isNotEmpty;

  TodoState success(List<Todo> todos) => copyWith(
    status: TodoStatus.success,
    todos: todos,
    error: null,
  );

  TodoState loading() => copyWith(status: TodoStatus.loading);

  TodoState copyWith({
    TodoStatus? status,
    List<Todo>? todos,
    String? error,
    String? searchQuery,
    List<Todo>? filteredTodos,
  }) {
    return TodoState._(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredTodos: filteredTodos,
    );
  }
}