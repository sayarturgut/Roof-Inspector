import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
}

extension MediaQueryExtension on BuildContext {
  double get height => mediaQuery.size.height;

  double get width => mediaQuery.size.width;

  double get lowHeightValue => height * 0.1;

  double get lowWidthValue => width * 0.1;

  double get normalHightValue => height * 0.2;

  double get normalWidthValue => height * 0.2;

  double get highHeightValue => height * 0.4;

  double get highWidthValue => width * 0.4;

  double customHeigthValue(double size) => height * size;

  double customWidthValue(double size) => width * size;
}

extension PaddingExtension on BuildContext {
  EdgeInsets get paddingUltraLowSymetric => EdgeInsets.symmetric(
      horizontal: lowWidthValue / 2, vertical: lowHeightValue / 2);

  EdgeInsets get paddingUltraULowSymetric => EdgeInsets.symmetric(
      horizontal: lowWidthValue / 4, vertical: lowHeightValue / 3);

  EdgeInsets get paddingLowWthTop => EdgeInsets.only(
        left: lowWidthValue / 2,
        right: lowWidthValue / 2,
        bottom: lowHeightValue / 2,
        top: lowHeightValue / 20,
      );

  EdgeInsets get paddingLowSymetric => EdgeInsets.symmetric(
      horizontal: lowWidthValue, vertical: customHeigthValue(0.03));

  EdgeInsets get paddingLowBottom =>
      EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom * 0.5);
}
