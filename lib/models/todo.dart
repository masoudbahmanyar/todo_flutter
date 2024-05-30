import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String title;
  final String description;
  final bool completed;
  final DateTime? deadLine;

  const Todo(
      {required this.title,
      required this.description,
      this.completed = false,
      this.deadLine});

  Todo copyWith({
    String? title,
    String? description,
    bool? completed,
    DateTime? deadLine,
  }) {
    return Todo(
        title: title ?? this.title,
        description: description ?? this.description,
        completed: completed ?? this.completed,
        deadLine: deadLine ?? this.deadLine);
  }

  @override
  List<Object?> get props => [title, description, completed, deadLine];
}
