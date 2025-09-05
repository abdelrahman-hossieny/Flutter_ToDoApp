import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/todo_cubit.dart';
import '../blocs/todo_state.dart';
import 'add_todo_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // Controller for the search input field that allows us to read and manipulate the text entered by the user.
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    context.read<TodoCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        // Dynamic title: either a search field or the app title based on the search state
        title: _isSearching ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search todos...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
          ),
          onChanged: (query) {
            context.read<TodoCubit>().searchTodos(query);
          },
        )
            : const Text(
          'My Todos',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: _stopSearch,
        )
            : null,
        actions: _isSearching
            ? [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.black54),
            onPressed: () {
              _searchController.clear();
              context.read<TodoCubit>().clearSearch();
            },
          ),
        ]
            : [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: _startSearch,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthCubit>().logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {

          if (state.status == TodoStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == TodoStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.error ?? 'Something went wrong',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TodoCubit>().loadTodos(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final todos = state.displayTodos;
          if (todos.isEmpty) {
            // No todos found "search" < or > no todos yet
            if (state.isSearching) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No todos found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey[600],),),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No todos yet!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey,),),
                  ],
                ),
              );
            }
          }

          return Column(
            children: [
              // Search result info
              if (state.isSearching)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue[50],
                  child: Text(
                    '${todos.length} result${todos.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // Todo list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    final isOverdue = todo.deadline != null &&
                        todo.deadline!.isBefore(DateTime.now()) &&
                        !todo.isCompleted;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (_) {
                            context.read<TodoCubit>().toggleTodo(todo.id);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: Colors.green,
                        ),
                        title: _buildHighlightedText(
                          todo.title,
                          state.searchQuery,
                          TextStyle(
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? Colors.grey
                                : (isOverdue ? Colors.red[700] : Colors.black87),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (todo.description != null) ...[
                              const SizedBox(height: 4),
                              _buildHighlightedText(
                                todo.description!,
                                state.searchQuery,
                                TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                              ),
                            ],
                            if (todo.deadline != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: isOverdue ? Colors.red : Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${todo.deadline!.month.toString().padLeft(2, '0')}/${todo.deadline!.day.toString().padLeft(2, '0')}/${todo.deadline!.year}',
                                    style: TextStyle(
                                      color: isOverdue ? Colors.red : Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                  if (isOverdue) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Overdue',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red[400],
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: const Text('Delete Todo'),
                                  content: Text('Are you sure you want to delete "${todo.title}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
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
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final todoCubit = context.read<TodoCubit>();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider<TodoCubit>.value(
                value: todoCubit,
                child: const AddTodoScreen(),
              ),
            ),
          );
        },
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHighlightedText(
      String text,
      String query,
      TextStyle style, {
        int? maxLines,
      }) {
    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int start = 0;
    int indexOfHighlight = lowerText.indexOf(lowerQuery);

    while (indexOfHighlight >= 0) {
      // Add text before the match
      if (indexOfHighlight > start) {
        spans.add(TextSpan(
          text: text.substring(start, indexOfHighlight),
          style: style,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, indexOfHighlight + query.length),
        style: style.copyWith(
          backgroundColor: Colors.yellow[300],
          fontWeight: FontWeight.bold,
        ),
      ));

      start = indexOfHighlight + query.length;
      indexOfHighlight = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
    );
  }
}