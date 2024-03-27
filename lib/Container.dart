import 'package:flutter/material.dart';

class ContainerCam extends StatelessWidget {
  final Widget singleElement;
  final double containerWidth;
  final double containerHeight;

  ContainerCam({
    required this.singleElement,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerWidth,
      height: containerHeight,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xFF333333),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurStyle: BlurStyle.inner,
            spreadRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 1.0),
        child: singleElement,
      ),
    );
  }
}
