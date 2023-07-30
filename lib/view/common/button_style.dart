import 'package:flutter/material.dart';

ButtonStyle appOutlineButtonStyle() {
  return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
}

ButtonStyle appTitleButtonStyle() {
  return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
}
