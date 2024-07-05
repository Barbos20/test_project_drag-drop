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
}
