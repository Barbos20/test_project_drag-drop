import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/task_bloc.dart';
import 'repositories/task_repository.dart';
import 'screens/kanban_board_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Инициализация репозитория и BLoC
    final TaskRepository taskRepository = TaskRepository();

    return BlocProvider(
      create: (context) => TaskBloc(taskRepository: taskRepository),
      child: MaterialApp(
        title: 'Kanban Board',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const KanbanBoard(),
      ),
    );
  }
}
