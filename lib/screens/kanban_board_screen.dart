import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_project/bloc/task_bloc.dart';
import 'package:test_project/model/task_model.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  List<Task> _tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Board'),
      ),
      body: BlocBuilder<TaskBloc, TaskBlocState>(
        builder: (context, state) {
          if (state is TaskInitial) {
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
            _tasks = state.tasks; // Инициализация _tasks при загрузке задач
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildColumns(),
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

  List<Widget> _buildColumns() {
    // Создаем пустую карту для группировки задач по их parentId
    final groupedTasks = <int, List<Task>>{};

    // Проходимся по всем задачам
    for (var task in _tasks) {
      // Если в карте еще нет записи с текущим parentId задачи, создаем ее
      if (!groupedTasks.containsKey(task.parentId)) {
        // Используем parentId задачи или 0, если parentId равен null
        groupedTasks[task.parentId ?? 0] = [];
      }
      // Добавляем текущую задачу в список задач с соответствующим parentId
      groupedTasks[task.parentId ?? 0]!.add(task);
    }

    // Преобразуем записи карты в список виджетов
    return groupedTasks.entries.map((entry) {
      // Получаем parentId и список задач для текущей записи
      final parentId = entry.key;
      final tasks = entry.value;

      // Создаем виджет колонки для текущего parentId и списка задач
      return _buildColumn(parentId, tasks);
    }).toList();
  }

// Метод для построения колонки с задачами
  Widget _buildColumn(int parentId, List<Task> tasks) {
    // Возвращает контейнер
    return Container(
      // Устанавливаем ширину контейнера в 300 пикселей
      width: 300,
      // Устанавливаем отступы со всех сторон в 8 пикселей
      margin: const EdgeInsets.all(8),
      // Оформляем контейнер: цвет фона и закругленные углы
      decoration: BoxDecoration(
        color: Colors.grey[200], // Цвет фона контейнера
        borderRadius: BorderRadius.circular(8), // Закругленные углы контейнера
      ),
      // Внутри контейнера создаем колонку
      child: Column(
        // Выравниваем содержимое колонки по левому краю
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Внутренний контейнер для заголовка колонки
          Container(
            // Устанавливаем отступы внутри контейнера в 8 пикселей
            padding: const EdgeInsets.all(8),
            // Оформляем контейнер: цвет фона и закругленные верхние углы
            decoration: const BoxDecoration(
              color: Colors.blue, // Цвет фона контейнера
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8)), // Закругленные верхние углы
            ),
            // Внутри контейнера создаем текстовый виджет
            child: Text(
              // Текст заголовка с идентификатором родителя
              'Parent ID: $parentId',
              // Оформление текста: белый цвет
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Метод для создания списка задач
          _buildTasksList(tasks),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    // Возвращает ReorderableListView для списка задач
    return ReorderableListView(
      // Устанавливает симметричные отступы по вертикали
      padding: const EdgeInsets.symmetric(vertical: 8),
      // Указывает, что высота списка будет определяться его содержимым
      shrinkWrap: true,
      // Запрещает прокрутку списка
      physics: const NeverScrollableScrollPhysics(),
      // Создает список виджетов для каждой задачи с помощью метода _buildTaskItem
      children: tasks.map((task) => _buildTaskItem(task)).toList(),
      // Обработчик изменения порядка элементов в списке
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex--;
          }
          // Создаем копию списка задач для конкретного parentId
          final List<Task> updatedTasks = List.from(tasks);
          // Удаляем задачу из старой позиции и вставляем в новую
          final task = updatedTasks.removeAt(oldIndex);
          updatedTasks.insert(newIndex, task);
          // Обновляем состояние с новой копией списка задач
          BlocProvider.of<TaskBloc>(context).add(ReorderTasks(
            oldIndex,
            newIndex,
            task.parentId ?? 0,
          ));
        });
      },
    );
  }

// Создает виджет для элемента задачи
  Widget _buildTaskItem(Task task) {
    // Возвращает элемент списка (ListTile)
    return ListTile(
      // Задает уникальный ключ для элемента, основанный на ID задачи (важно для ReorderableListView)
      key: Key(task.id.toString()),
      // Основной заголовок элемента списка
      title: Container(
        // Ограничивает максимальную ширину контейнера до 300 пикселей
        constraints: const BoxConstraints(maxWidth: 300),
        // Отображает имя задачи
        child: Text(task.name),
      ),
      // Подзаголовок элемента списка
      subtitle: Container(
        // Ограничивает максимальную ширину контейнера до 300 пикселей
        constraints: const BoxConstraints(maxWidth: 300),
        // Отображает порядок задачи
        child: Text('Order: ${task.order}'),
      ),
    );
  }
}
