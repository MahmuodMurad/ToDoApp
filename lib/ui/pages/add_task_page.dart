import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '/ui/widgets/button.dart';
import '/ui/theme.dart';
import '/ui/widgets/input_field.dart';
import '/controllers/task_controller.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();
  int _selectedRemind = 5;

  List<int> remindList = [1,5, 10, 15, 20, 25, 30, 45, 60];
  String _selectedRepeat = 'None';
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Add Task',
                  style: headingStyle,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              InputField(
                title: 'Title',
                note: 'Enter Title Here',
                controller: _titleController,
              ),
              const SizedBox(
                height: 18,
              ),
              InputField(
                title: 'Note',
                note: 'Enter Note Here',
                controller: _noteController,
              ),
              const SizedBox(
                height: 18,
              ),
              InputField(
                title: 'Date',
                note: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  onPressed: () => _getDateFromUser(),
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      title: 'Start Time',
                      note: _startTime,
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: true),
                        icon: const Icon(
                          Icons.alarm,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InputField(
                      title: 'End Time',
                      note: _endTime,
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: false),
                        icon: const Icon(
                          Icons.alarm,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              InputField(
                title: 'Remind',
                note: '$_selectedRemind minutes early',
                widget: DropdownButton(
                  menuMaxHeight: 200,
                  dropdownColor: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(15),
                  items: remindList
                      .map<DropdownMenuItem<String>>(
                        (int value) => DropdownMenuItem<String>(
                          value: value.toString(),
                          child: Text(
                            '$value',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 5,
                  underline: Container(
                    height: 0,
                  ),
                  style: subTitleStyle,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRemind = int.parse(newValue!);
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              InputField(
                title: 'Repeat',
                note: _selectedRepeat,
                widget: DropdownButton(
                  menuMaxHeight: 200,
                  dropdownColor: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(15),
                  items: repeatList
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 5,
                  underline: Container(
                    height: 0,
                  ),
                  style: subTitleStyle,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRepeat = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color',
                        style: titleStyle,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        children: List.generate(
                          3,
                          (index) => InkWell(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              child: CircleAvatar(
                                radius: 16,
                                child: _selectedColor == index
                                    ? const Icon(Icons.done)
                                    : null,
                                backgroundColor: index == 0
                                    ? primaryClr
                                    : index == 1
                                        ? pinkClr
                                        : orangeClr,
                              ),
                              padding: const EdgeInsets.only(right: 8),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedColor = index;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  MyButton(
                      onTap: () {
                        _validate();
                      },
                      label: 'Create Task')
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getDateFromUser() async {
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2080),
    );
    if (_pickedDate != null) {
      setState(() {
        _selectedDate = _pickedDate;
      });
    } else {
      print('choose null');
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? _pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(
              DateTime.now().add(const Duration(minutes: 30))),
    );
    String _formattedTime = _pickedTime!.format(context);
    if (isStartTime) {
      setState(() {
        _startTime = _formattedTime;
      });
    } else if (!isStartTime) {
      setState(() {
        _endTime = _formattedTime;
      });
    } else {
      print('null value');
    }
  }

  _validate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTasksToDb();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar(
        'Required',
        'All Fields Are Required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: pinkClr,
        icon: const Icon(
          Icons.warning_amber_sharp,
          color: Colors.red,
        ),
      );
    } else {
      print('error');
    }
  }

  _addTasksToDb() async {
    try {
      int value = await _taskController.addTask(
        task: Task(
          title: _titleController.text,
          note: _noteController.text,
          isCompleted: 0,
          date: DateFormat.yMd().format(_selectedDate),
          color: _selectedColor,
          endTime: _endTime,
          remind: _selectedRemind,
          repeat: _selectedRepeat,
          startTime: _startTime,
        ),
      );
    }catch(e){
      print('error');
    }
  }

  AppBar _appBar() => AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Get.isDarkMode ? Colors.white : primaryClr,
          ),
        ),
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage('images/person.png'),
            radius: 24,
          ),
          SizedBox(
            width: 20,
          ),
        ],
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        centerTitle: true,
      );
}
