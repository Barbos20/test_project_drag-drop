import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_project/model/task_model.dart';
import 'package:test_project/repositories/task_repository.dart';

part 'task_bloc_event.dart';
part 'task_bloc_state.dart';

class TaskBloc extends Bloc<TaskBlocEvent, TaskBlocState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    // Определение реакций на события
    on<LoadTasks>(_onLoadTasks);
    on<UpdateTask>(_onUpdateTask);
    on<ReorderTasks>(_onReorderTasks);
  }
  // Обработка события загрузки задач
  Future<void> _onLoadTasks(
      LoadTasks event, Emitter<TaskBlocState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await taskRepository.fetchTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // Обработка события обновления задачи
  Future<void> _onUpdateTask(
      UpdateTask event, Emitter<TaskBlocState> emit) async {
    try {
      await taskRepository.updateTaskField(
          event.taskId, 'parent_id', event.newParentId.toString());
      await taskRepository.updateTaskField(
          event.taskId, 'order', event.newOrder.toString());
      add(LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // Обработка события изменения порядка задач
  void _onReorderTasks(ReorderTasks event, Emitter<TaskBlocState> emit) async {
    if (state is TaskLoaded) {
      final List<Task> updatedTasks = List.from((state as TaskLoaded).tasks);

      // Фильтруем задачи по parentId
      final List<Task> filteredTasks = updatedTasks
          .where((task) => task.parentId == event.parentId)
          .toList();

      // Изменяем порядок только для отфильтрованных задач
      final task = filteredTasks.removeAt(event.oldIndex);
      filteredTasks.insert(event.newIndex, task);

      // Обновляем исходный список задач с измененным порядком
      for (int i = 0; i < updatedTasks.length; i++) {
        if (updatedTasks[i].parentId == event.parentId) {
          updatedTasks[i] = filteredTasks.removeAt(0);
        }
      }

      // Устанавливаем order как index + 1 для задач с конкретным parentId
      for (int i = 0; i < updatedTasks.length; i++) {
        if (updatedTasks[i].parentId == event.parentId) {
          updatedTasks[i].order = i + 1;
        }
      }

      emit(TaskLoaded(updatedTasks));
      // Отправляем обновленные значения задач на сервер
      try {
        for (int i = 0; i < updatedTasks.length; i++) {
          if (updatedTasks[i].parentId == event.parentId) {
            await taskRepository.updateTaskField(
              updatedTasks[i].id,
              'order',
              updatedTasks[i].order.toString(),
            );
          }
        }
        emit(TaskLoaded(updatedTasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    }
  }
}
