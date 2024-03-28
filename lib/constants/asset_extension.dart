extension ImagePathExtension on String {
  String get toPng => 'assets/images/png/$this.png';
  String get toSvg => 'assets/images/svg/$this.svg';
}
