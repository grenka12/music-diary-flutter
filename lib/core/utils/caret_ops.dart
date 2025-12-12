import 'package:flutter/widgets.dart';

int getCaretOffset(TextEditingController controller) {
  final selection = controller.selection;
  if (!selection.isValid) {
    return controller.text.length;
  }
  return selection.start;
}

void setCaretToEnd(TextEditingController controller) {
  final length = controller.text.length;
  controller.selection = TextSelection.collapsed(offset: length);
}

void setCaretTo(TextEditingController controller, int offset) {
  final clamped = clampCaret(offset, controller.text);
  controller.selection = TextSelection.collapsed(offset: clamped);
}

int clampCaret(int offset, String text) {
  final length = text.length;
  if (offset < 0) {
    return 0;
  }
  if (offset > length) {
    return length;
  }
  return offset;
}
