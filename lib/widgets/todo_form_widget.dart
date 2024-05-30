import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../events/todo/add_todo_event.dart';
import '../events/todo/update_todo_event.dart';
import '../models/todo.dart';

class TodoFormWidget extends StatefulWidget {
  final Todo? existingTodo;

  const TodoFormWidget({super.key, this.existingTodo});

  @override
  _TodoFormWidgetState createState() => _TodoFormWidgetState();
}

class _TodoFormWidgetState extends State<TodoFormWidget> {
  late TextEditingController myTodoTitleFormController;
  late TextEditingController myTodoDescriptionFormController;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    myTodoTitleFormController =
        TextEditingController(text: widget.existingTodo?.title ?? '');
    myTodoDescriptionFormController =
        TextEditingController(text: widget.existingTodo?.description ?? '');
    selectedDate = widget.existingTodo?.deadLine;
    selectedTime = widget.existingTodo?.deadLine != null
        ? TimeOfDay.fromDateTime(widget.existingTodo!.deadLine!)
        : null;
  }

  @override
  void dispose() {
    myTodoTitleFormController.dispose();
    myTodoDescriptionFormController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTime ??= TimeOfDay.now();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        selectedDate ??= DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the TodoBloc from the context
    final TodoBloc todoBloc = BlocProvider.of<TodoBloc>(context);

    return AlertDialog(
      // Set the title based on whether it's an addition or an edit
      title: Text(widget.existingTodo == null ? 'Add a new todo' : 'Edit todo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: myTodoTitleFormController,
            decoration: const InputDecoration(labelText: 'Todo title'),
            autofocus: true,
          ),
          TextField(
            controller: myTodoDescriptionFormController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Todo description'),
          ),
          // Display the selected date and time
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Deadline', style: TextStyle(fontSize: 16)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Show the selected date or "not set"
              Text(
                selectedDate != null
                    ? 'Date: ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'
                    : 'Date: not set',
              ),
              // Buttons for date selection
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                  if (selectedDate != null)
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setState(() {
                              selectedTime = null;
                              selectedDate = null;
                            })),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Show the selected time or "not set"
              Text(
                selectedTime != null
                    ? 'Time: ${selectedTime!.format(context)}'
                    : 'Time: not set',
              ),
              // Buttons for time selection
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                  if (selectedTime != null)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() {
                        selectedTime = null;
                        selectedDate = null;
                      }),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Determine the deadline by combining selected date and time
            final DateTime? deadline = selectedDate != null
                ? (selectedTime != null
                    ? DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute)
                    : selectedDate)
                : null;
            // Add or update the todo
            if (widget.existingTodo != null) {
              todoBloc.add(UpdateTodoEvent(
                widget.existingTodo!,
                title: myTodoTitleFormController.text,
                description: myTodoDescriptionFormController.text,
                deadLine: deadline,
              ));
            } else {
              todoBloc.add(AddTodoEvent(Todo(
                  // Or UniqueKey().toString()
                  title: myTodoTitleFormController.text,
                  description: myTodoDescriptionFormController.text,
                  deadLine: deadline)));
            }
            Navigator.of(context).pop();
          },
          child: Text(widget.existingTodo == null ? 'Add' : 'Edit'),
        ),
      ],
    );
  }
}
