import '../../models/todo.dart';
import '../todo_event.dart';

class UpdateTodoEvent extends TodoEvent {
  final Todo todo;
  final String? title;
  final String? description;
  final bool? completed;
  final DateTime? deadLine;

  const UpdateTodoEvent(this.todo,
      {this.title, this.description, this.completed, this.deadLine});

  @override
  List<Object?> get props => [todo, title, description, completed, deadLine];
}
