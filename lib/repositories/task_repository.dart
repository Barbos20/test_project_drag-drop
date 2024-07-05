import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_project/model/task_model.dart';

class TaskRepository {
  static const String baseUrl =
      'https://development.kpi-drive.ru/_api/indicators';
  static const String token = '48ab34464a5573519725deb5865cc74c';

  // Получение списка задач с сервера
  Future<List<Task>> fetchTasks() async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_mo_indicators'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'period_start': '2024-05-01',
        'period_end': '2024-05-31',
        'period_key': 'month',
        'requested_mo_id': '478',
        'behaviour_key': 'task',
        'with_result': 'false',
        'response_fields': 'name,indicator_to_mo_id,parent_id,order',
        'auth_user_id': '2',
      },
    );

    // Проверка статуса ответа
    if (response.statusCode == 200) {
      // Исправляем кодировку здесь
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData['DATA'] != null && decodedData['DATA']['rows'] != null) {
        final apiResponse = ApiResponse.fromJson(decodedData['DATA']);
        return apiResponse.rows;
      } else {
        throw Exception('Data field is missing in the response');
      }
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Обновление поля задачи на сервере
  Future<void> updateTaskField(
      int taskId, String fieldName, String fieldValue) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save_indicator_instance_field'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'period_start': '2024-05-01',
        'period_end': '2024-05-31',
        'period_key': 'month',
        'indicator_to_mo_id': taskId.toString(),
        'field_name': fieldName,
        'field_value': fieldValue,
        'auth_user_id': '2',
      },
    );

    // Проверка статуса ответа
    if (response.statusCode != 200) {
      throw Exception('Failed to update task field');
    }
  }
}
