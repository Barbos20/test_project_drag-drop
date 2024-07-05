part of 'task_bloc.dart';

sealed class TaskBlocState extends Equatable {
  const TaskBlocState();

  @override
  List<Object> get props => [];
}

// Начальное состояние задач
class TaskInitial extends TaskBlocState {}

// Состояние загрузки задач
class TaskLoading extends TaskBlocState {}

// Состояние, когда задачи загружены
class TaskLoaded extends TaskBlocState {
  final List<Task> tasks;

  const TaskLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

// Состояние ошибки при загрузке задач
class TaskError extends TaskBlocState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

final class TaskBlocInitial extends TaskBlocState {}
