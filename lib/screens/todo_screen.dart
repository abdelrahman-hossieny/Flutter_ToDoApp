import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../blocs/todo_cubit.dart';
import '../blocs/todo_state.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTodo() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      context.read<TodoCubit>().addTodo(text);
      _textController.clear();
      FocusScope.of(context).unfocus(); // Hide keyboard after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TodoCubit, TodoState>(
          builder: (context, state) {
            final todoCount = state.todos.length;
            return Text('Todo App ($todoCount)', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2,),);
          },
        ),
        backgroundColor: Color(0xFF6C63FF),
        elevation: 4,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Text field for adding new todos
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Enter a new todo...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.add_task),
                        ),
                        onSubmitted: (_) => _addTodo(),
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _addTodo,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stats row
            BlocBuilder<TodoCubit, TodoState>(
              builder: (context, state) {

                // 1. calculate stats
                final totalCount = state.todos.length;
                final completedCount = state.todos.where((todo) => todo.isCompleted).length;
                final pendingCount = totalCount - completedCount;

                // 2. if no todos, don't show stats row
                if (totalCount == 0) return const SizedBox.shrink();

                // 3. show stats row
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12),),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Stat items: Total, Pending, Completed
                      // Use a helper method to avoid repetition
                      _buildStatItem(context, 'Total', totalCount.toString(), Icons.list, Colors.blue,),
                      _buildStatItem(context, 'Pending', pendingCount.toString(), Icons.pending_actions, Colors.orange,),
                      _buildStatItem(context, 'Completed', completedCount.toString(), Icons.check_circle, Colors.green,),

                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Todos list + BlocConsumer +
            // enum status: loading, error, success
            // Fluttertoast: as snackbar alternative
            Expanded(
              child: BlocConsumer<TodoCubit, TodoState>(
                // we have to things : listener + builder

                // 1. listener: show error toast if error occurs
                listener: (context, state) {
                  if (state.status == TodoStatus.error && state.error != null) {
                    Fluttertoast.showToast(
                      msg: state.error!,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },

                // 2. builder: build UI based on state
                builder: (context, state) {
                  final todos = state.todos;
                  // Handle empty list state
                  if (todos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.grey.shade400,),
                          const SizedBox(height: 16),
                          Text('No todos yet!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey.shade600,),),
                          const SizedBox(height: 8),
                          Text('Add one above to get started.', style: TextStyle(fontSize: 16, color: Colors.grey.shade500,),),
                        ],
                      ),
                    );
                  }

                  // Show list of todos
                  return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,

                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (_) {
                              context.read<TodoCubit>().toggleTodo(todo.id);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isCompleted
                                  ? Colors.grey.shade600
                                  : null,
                              fontSize: 16,
                              fontWeight: todo.isCompleted
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red.shade400,
                            onPressed: () {
                              // Show confirmation dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Delete Todo'),
                                    content: Text('Are you sure you want to delete "${todo.title}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.read<TodoCubit>().deleteTodo(todo.id);
                                          Navigator.of(dialogContext).pop();
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            tooltip: 'Delete todo',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String count, IconData icon, Color color,) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}