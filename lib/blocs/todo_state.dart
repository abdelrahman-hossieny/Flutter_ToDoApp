

import 'package:todoapp/models/TodoModel.dart';

enum TodoStatus { initial, loading, error, success }

class TodoState {
  final List<Todo> todos;
  final TodoStatus status;
  final String? error;

  const TodoState._({
    required this.todos,
    required this.status,
    this.error,
  });

  static const TodoState initial = TodoState._(
    todos: [],
    status: TodoStatus.initial,
    error: null,
  );

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
  }) {
    return TodoState._(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      error: error,
    );
  }
}