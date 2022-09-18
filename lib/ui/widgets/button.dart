import 'package:flutter/material.dart';
import '../theme.dart';

class MyButton extends StatelessWidget {
  const MyButton({Key? key, required this.onTap, required this.label})
      : super(key: key);

  final String label;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        alignment: Alignment.center,
        width: 100,
        height: 45,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: primaryClr),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
