import 'package:firstproject/events/todo/remove_todo_event.dart';
import 'package:firstproject/events/todo/update_todo_event.dart';
import 'package:firstproject/widgets/todo_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/todo_bloc.dart';
import '../models/todo.dart';
import '../state/todo_list.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  // void _editTodoItem(Todo todoToBeModified, String title, String description) {
  //   setState(() {
  //     todoToBeModified.title = title;
  //     todoToBeModified.description = description;
  //   });
  // }

  // void _toggleTodoCompletion(Todo todoToBeCompleted) {
  //   setState(() {
  //     todoToBeCompleted.completed = !todoToBeCompleted.completed;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final TodoBloc todoBloc = BlocProvider.of<TodoBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todo List'),
      ),
      body: BlocBuilder<TodoBloc, TodoList>(builder: (context, state) {
        int pendingCount = state.todos
            .where((todo) =>
                !todo.completed &&
                (todo.deadLine == null ||
                    todo.deadLine!.isAfter(DateTime.now())))
            .length;
        int delayedCount = state.todos
            .where((todo) =>
                !todo.completed &&
                todo.deadLine != null &&
                todo.deadLine!.isBefore(DateTime.now()))
            .length;
        int completedCount = state.todos.where((todo) => todo.completed).length;
        return Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.blueGrey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Pending', pendingCount, Colors.orange,
                    Icons.hourglass_empty),
                _buildSummaryItem(
                    'Delayed', delayedCount, Colors.red, Icons.error_outline),
                _buildSummaryItem('Completed', completedCount, Colors.green,
                    Icons.check_circle_outline),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: state.todos.map((Todo todo) {
                return Dismissible(
                    key: Key(todo.title),
                    background: Container(
                      color: Colors.red,
                      child: const Icon(Icons.delete),
                    ),
                    onDismissed: (direction) {
                      todoBloc.add(RemoveTodoEvent(todo));
                    },
                    child: ListTile(
                      onTap: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (dialogContext) {
                              return BlocProvider.value(
                                  value: BlocProvider.of<TodoBloc>(context),
                                  child: TodoFormWidget(
                                    existingTodo: todo,
                                  ));
                            });
                      },
                      title: Text(todo.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(todo.description),
                          if (todo.deadLine != null)
                            Text(
                              'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(todo.deadLine!)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              todoBloc.add(UpdateTodoEvent(todo,
                                  completed: !todo.completed));
                            },
                            icon: Icon(todo.completed
                                ? Icons.check_box
                                : Icons.check_box_outline_blank),
                          ),
                        ],
                      ),
                      tileColor: todo.completed
                          ? Colors.grey.withOpacity(0.5)
                          : todo.deadLine != null &&
                                  todo.deadLine!.isBefore(DateTime.now())
                              ? Colors.red.withOpacity(0.2)
                              : null,
                    ));
              }).toList(),
            ),
          )
        ]);
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return BlocProvider.value(
                value: BlocProvider.of<TodoBloc>(context),
                child: const TodoFormWidget(),
              );
            },
          );
        },
        tooltip: 'Add a new Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildSummaryItem(String label, int count, Color color, IconData icon) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        count.toString(),
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
