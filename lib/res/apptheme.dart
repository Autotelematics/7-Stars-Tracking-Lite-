import 'package:autotelematic_new_app/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppTheme {
  static const String logoPath = 'assets/images/Splashsceen.png';

  static double loginTextFieldWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.85;

  }

  static InputDecoration textFieldInputDecoration(String labelText, Icon icon, {Widget? suffixIcon}) {
    return InputDecoration(

      isDense: true,
      prefixIcon: icon,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        fontSize: 14,
        color: Color(0xff000000),
      ),
      labelText: labelText,
      fillColor: AppColors.buttonColor,
      filled: true,
      border: OutlineInputBorder(borderSide:BorderSide.none,borderRadius: BorderRadius.circular(10)),
      disabledBorder: InputBorder.none,
    );
  }

  static TextStyle headTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
  static SpinKitCircle  loadingImage = SpinKitCircle(
    color: AppColors.primaryColor,
    size: 75.0,
  );
}
