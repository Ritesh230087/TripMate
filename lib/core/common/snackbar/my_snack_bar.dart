import 'package:flutter/material.dart';

void showMySnackBar({
  required BuildContext context,
  required String message,
  Color? color,
}){
   ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message),
      backgroundColor: color ?? Colors.green,
        behavior: SnackBarBehavior.floating,
   ),
 );
}