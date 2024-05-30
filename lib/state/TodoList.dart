import 'package:equatable/equatable.dart';

import '../models/todo.dart';

class TodoList extends Equatable {
  final List<Todo> todos;

  const TodoList({this.todos = const []});

  @override
  List<Object?> get props => [todos];
}
