import 'package:firstproject/events/todo/add_todo_event.dart';
import 'package:firstproject/events/todo/remove_todo_event.dart';
import 'package:firstproject/events/todo/update_todo_event.dart';
import 'package:firstproject/events/todo_event.dart';
import 'package:firstproject/state/todo_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoBloc extends Bloc<TodoEvent, TodoList> {
  TodoBloc() : super(const TodoList()) {
    on<AddTodoEvent>((event, emit) {
      final newTodoList = TodoList(todos: [...state.todos, event.todo]);
      emit(newTodoList);
    });
    on<RemoveTodoEvent>((event, emit) {
      final newTodoListItemns = TodoList(
          todos: state.todos.where((todo) => todo != event.todo).toList());
      ;
      emit(newTodoListItemns);
    });
    on<UpdateTodoEvent>((event, emit) {
      final updatedTodo = event.todo.copyWith(
          completed: event.completed,
          title: event.title,
          deadLine: event.deadLine,
          description: event.description);
      final newTodoList = TodoList(
          todos: state.todos
              .map((todo) => todo == event.todo ? updatedTodo : todo)
              .toList());
      emit(newTodoList);
    });
  }
}
