part of 'task_bloc.dart';

sealed class TaskBlocEvent extends Equatable {
  const TaskBlocEvent();

  @override
  List<Object> get props => [];
}

// Событие загрузки задач
class LoadTasks extends TaskBlocEvent {}

// Событие обновления задачи
class UpdateTask extends TaskBlocEvent {
  final int taskId;
  final int newParentId;
  final int newOrder;

  const UpdateTask(this.taskId, this.newParentId, this.newOrder);

  @override
  List<Object> get props => [taskId, newParentId, newOrder];
}

// Событие изменения порядка задач
class ReorderTasks extends TaskBlocEvent {
  final int oldIndex;
  final int newIndex;
  final int parentId;

  const ReorderTasks(this.oldIndex, this.newIndex, this.parentId);

  @override
  List<Object> get props => [oldIndex, newIndex, parentId];
}
