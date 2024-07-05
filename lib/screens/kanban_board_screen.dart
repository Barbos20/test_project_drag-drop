import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_project/bloc/task_bloc.dart';
import 'package:test_project/model/task_model.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Board'),
      ),
      body: BlocBuilder<TaskBloc, TaskBlocState>(
        builder: (context, state) {
          if (state is TaskInitial) {
            // Начальное состояние, показывает кнопку для загрузки задач
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  BlocProvider.of<TaskBloc>(context).add(LoadTasks());
                },
                child: const Text('Load Tasks'),
              ),
            );
          } else if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildColumns(state.tasks),
              ),
            );
          } else if (state is TaskError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Container(color: Colors.red);
          }
        },
      ),
    );
  }

  List<Widget> _buildColumns(List<Task> tasks) {
    final groupedTasks = <int, List<Task>>{};
    for (var task in tasks) {
      if (!groupedTasks.containsKey(task.parentId)) {
        groupedTasks[task.parentId ?? 0] = [];
      }
      groupedTasks[task.parentId ?? 0]!.add(task);
    }

    return groupedTasks.entries.map((entry) {
      final parentId = entry.key;
      final tasks = entry.value;

      return Container(
        width: 300, // Ограничиваем ширину колонки
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Text(
                'Parent ID: $parentId',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ...tasks.map((task) {
              return ListTile(
                title: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(task.name),
                ),
                subtitle: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text('Order: ${task.order}'),
                ),
              );
            }),
          ],
        ),
      );
    }).toList();
  }
}
