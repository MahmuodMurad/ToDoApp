import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/theme.dart';

class InputField extends StatelessWidget {
  const InputField(
      {Key? key,
      required this.title,
      required this.note,
      this.controller,
      this.widget})
      : super(key: key);
  final String title;
  final String note;
  final TextEditingController? controller;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle,
        ),
        Container(
          width: SizeConfig.screenWidth,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  autofocus: false,
                  readOnly: widget != null? true:false,
                  style: subTitleStyle,
                  cursorColor: Get.isDarkMode?Colors.grey[100]:Colors.grey[700],
                  decoration: InputDecoration(
                    hintText: note,
                    hintStyle: subTitleStyle,

                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: context.theme.backgroundColor,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: context.theme.backgroundColor,
                      ),
                    ),
                  ),
                ),
              ),
              widget ?? Container(),
            ],
          ),
        ),
      ],
    );
  }
}
