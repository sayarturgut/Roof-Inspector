import 'package:flutter/material.dart';
import 'package:roffinspection/constants/coctext_extension.dart';

ThemeData appTheme(BuildContext context) {
  return ThemeData.dark().copyWith(
    cardTheme: const CardTheme(
      elevation: 3,
    ),
    brightness: Brightness.dark,
    ///////////////////////////
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStatePropertyAll(5),
        splashFactory: InkSplash.splashFactory,
        animationDuration: Duration(milliseconds: 250),
      ),
    ),
    ///////////////////////////
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      hoverColor: const Color.fromARGB(255, 43, 38, 38),
      elevation: 5,
      focusElevation: 7,
      splashColor: const Color.fromARGB(255, 255, 204, 51).withOpacity(0.4),
    ),
    ///////////////////////////
    dialogTheme: const DialogTheme(
      backgroundColor: Color.fromARGB(255, 43, 38, 38),
      contentTextStyle: TextStyle(color: Colors.white),
      elevation: 400,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.black,
    ),
    ///////////////////////////
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.black,
      unselectedLabelStyle: TextStyle(fontSize: 10),
      unselectedLabelColor: Color.fromARGB(255, 131, 99, 4),
      indicatorColor: Colors.black,
      indicatorSize: TabBarIndicatorSize.label,
      tabAlignment: TabAlignment.center,
      dividerColor: Color.fromARGB(255, 255, 204, 51),
    ),
    ///////////////////////////
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      preferBelow: false,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 10,
      ),
    ),
    ///////////////////////////
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: Color.fromARGB(255, 255, 204, 51),
      ),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      width: context.customWidthValue(0.375),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(strokeAlign: 15, color: Colors.black),
      ),
    ),
    splashFactory: InkRipple.splashFactory,
  );
}
