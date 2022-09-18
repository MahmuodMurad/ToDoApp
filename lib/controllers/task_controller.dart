import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/db/db_helper.dart';

import '../models/task.dart';

class TaskController extends GetxController {
  final RxList<Task> taskList = <Task>[].obs;

  Future<int> addTask({required Task task}) {
    return DBHelper.insert(task);
  }

  getTasks()async {
    final List<Map<String,dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((element) => Task.fromJson(element)).toList());

  }

  deleteTask(Task task)async {
    await DBHelper.delete(task);
    getTasks();
  }
  deleteAllTasks()async {
    await DBHelper.deleteAll();
    getTasks();
  }


  markAsCompleted(int id)async {
    await DBHelper.update(id);
    getTasks();
  }
}
