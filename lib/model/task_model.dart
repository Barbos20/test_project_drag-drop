import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class Task extends Equatable {
  final int id;
  final int? parentId;
  final String name;
  final int order;

  const Task({
    required this.id,
    required this.parentId,
    required this.name,
    required this.order,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['indicator_to_mo_id'] as int,
      parentId: json['parent_id'] != null ? json['parent_id'] as int : null,
      name: json['name'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() => _$TaskToJson(this);

  @override
  List<Object> get props => [id, parentId ?? 0, name, order];
}

@JsonSerializable()
class ApiResponse extends Equatable {
  final List<Task> rows;

  const ApiResponse({required this.rows});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['rows'] as List;
    List<Task> taskList = list.map((i) => Task.fromJson(i)).toList();
    return ApiResponse(rows: taskList);
  }

  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);

  @override
  List<Object> get props => [rows];
}
