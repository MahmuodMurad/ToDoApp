import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '/services/notification_services.dart';
import '/ui/widgets/task_tile.dart';
import '../../controllers/task_controller.dart';
import '../theme.dart';
import '/ui/pages/add_task_page.dart';
import '/ui/widgets/input_field.dart';
import '/services/theme_services.dart';
import '/ui/pages/notification_screen.dart';
import '/ui/size_config.dart';
import '/ui/widgets/button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    _taskController.getTasks();
  }

  DateTime _selectedDate = DateTime.now();
  final TaskController _taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(
            height: 8,
          ),
          _showTasks(),
        ],
      ),
    );
  }

  AppBar _appBar() => AppBar(
        leading: IconButton(
          onPressed: () {
            ThemeServices().switchTheme();
          },
          icon: Icon(
            Get.isDarkMode ? Icons.sunny : Icons.dark_mode,
            color: Get.isDarkMode ? Colors.white : primaryClr,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSnackBar(context),
            icon: Icon(
              Icons.clear,
              color: Get.isDarkMode ? Colors.white : primaryClr,
              size: 24,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          const CircleAvatar(
            backgroundImage: AssetImage('images/person.png'),
            radius: 24,
          ),
          const SizedBox(
            width: 20,
          ),
        ],
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        centerTitle: true,
      );

  _showSnackBar(BuildContext ctx) {
    final sBar = SnackBar(
      action: SnackBarAction(
        textColor: Colors.red,
        label: 'Delete',
        onPressed: () {
          notifyHelper.cancelAllNotification();
          _taskController.deleteAllTasks();
        },
      ),
      content: SizedBox(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight * 0.06,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_sharp,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'WARNING',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: pinkClr,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'All Tasks Will be Deleted',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
    ScaffoldMessenger.of(ctx).showSnackBar(sBar);
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'Today',
                style: headingStyle,
              ),
            ],
          ),
          MyButton(
            onTap: () async {
              await Get.to(() => const AddTaskPage());
              _taskController.getTasks();
            },
            label: '+ Add Task',
          ),
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(
        top: 8,
        left: 25,
      ),
      child: DatePicker(
        DateTime.now(),
        width: 70,
        height: 100,
        initialSelectedDate: DateTime.now(),
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  Future<void> _refresh() async {
    _taskController.getTasks();
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        if (_taskController.taskList.isEmpty) {
          return _noTaskMessage();
        } else {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              scrollDirection: SizeConfig.orientation == Orientation.landscape
                  ? Axis.horizontal
                  : Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                var task = _taskController.taskList[index];
                var date = DateFormat.jm().parse(task.startTime!);
                var myTime = DateFormat('HH:mm').format(date);
                notifyHelper.scheduledNotification(
                  int.parse(myTime.toString().split(':')[0]),
                  int.parse(myTime.toString().split(':')[1]),
                  task,
                );
                if (task.repeat == 'Daily' ||
                    task.date == DateFormat.yMd().format(_selectedDate) ||
                    (task.repeat == 'Weekly' &&
                        _selectedDate
                                    .difference(
                                        DateFormat.yMd().parse(task.date!))
                                    .inDays %
                                7 ==
                            0) ||
                    (task.repeat == 'Monthly' &&
                        _selectedDate.day ==
                            DateFormat.yMd().parse(task.date!).day)) {
                  return AnimationConfiguration.staggeredList(
                    duration: const Duration(seconds: 1),
                    position: index,
                    child: SlideAnimation(
                      horizontalOffset: 300,
                      child: FadeInAnimation(
                        child: InkWell(
                          onTap: () {
                            showBottomSheet(context, task);
                          },
                          child: TaskTile(task),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: _taskController.taskList.isEmpty
                        ? _noTaskMessage()
                        : Container(),
                  );
                }
              },
              itemCount: _taskController.taskList.length,
            ),
          );
        }
      }),
    );
  }

  showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 4),
          width: SizeConfig.screenWidth,
          height: (SizeConfig.orientation == Orientation.landscape)
              ? (task.isCompleted == 1
                  ? SizeConfig.screenHeight * 0.6
                  : SizeConfig.screenHeight * 0.8)
              : (task.isCompleted == 1
                  ? SizeConfig.screenHeight * 0.3
                  : SizeConfig.screenHeight * 0.4),
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
          child: Column(
            children: [
              Flexible(
                child: Container(
                  height: 6,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              task.isCompleted == 1
                  ? Container()
                  : _buildBottomSheet(
                      label: 'Task Completed',
                      onTap: () {
                        notifyHelper.cancelNotification(task);
                        _taskController.markAsCompleted(task.id!);
                        Get.back();
                      },
                      clr: primaryClr,
                    ),
              _buildBottomSheet(
                label: 'Delete Task',
                onTap: () {
                  notifyHelper.cancelNotification(task);
                  _taskController.deleteTask(task);
                  Get.back();
                },
                clr: Colors.red[400]!,
              ),
              Divider(
                color: Get.isDarkMode ? Colors.grey : darkGreyClr,
              ),
              _buildBottomSheet(
                label: 'Cancel',
                onTap: () {
                  Get.back();
                },
                clr: primaryClr,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildBottomSheet({
    required String label,
    required Function() onTap,
    required Color clr,
    bool isClose = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose
                ? Get.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[200]!
                : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  _noTaskMessage() {
    return Stack(
      children: [
        AnimatedPositioned(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 6,
                        )
                      : const SizedBox(
                          height: 220,
                        ),
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 90,
                    color: primaryClr.withOpacity(0.5),
                  ),
                  Text(
                    'You don\'t have any tasks!\nAdd some tasks to make your day more productive',
                    style: subTitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 6,
                        )
                      : const SizedBox(
                          height: 220,
                        ),
                ],
              ),
            ),
          ),
          duration: const Duration(seconds: 2),
        )
      ],
    );
  }
}
