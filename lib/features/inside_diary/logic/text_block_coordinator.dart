import 'package:flutter/material.dart';

import 'package:music_diary_new/core/models/diary_block.dart';
import 'package:music_diary_new/core/utils/caret_ops.dart';

/// Keeps text controllers and focus nodes in sync with diary text blocks.
class TextBlockCoordinator {
  TextBlockCoordinator({required ValueChanged<String?> onActiveChanged})
      : _onActiveChanged = onActiveChanged;

  final ValueChanged<String?> _onActiveChanged;

  /// Maps block IDs to their text editing controllers.
  final Map<String, TextEditingController> controllers = {};

  /// Maps block IDs to their focus nodes.
  final Map<String, FocusNode> focusNodes = {};

  /// The ID of the currently focused text block, if any.
  String? activeTextId;

  /// Updates controllers and focus nodes to match the provided blocks.
  void syncWithBlocks(List<TextBlock> blocks) {
    final ids = blocks.map((block) => block.id).toSet();

    final toRemove = controllers.keys.where((id) => !ids.contains(id)).toList();
    for (final id in toRemove) {
      controllers.remove(id)?.dispose();
      focusNodes.remove(id)?.dispose();
      if (activeTextId == id) {
        activeTextId = null;
        _onActiveChanged(null);
      }
    }

    for (final block in blocks) {
      final controller = controllers[block.id];
      if (controller == null) {
        controllers[block.id] = TextEditingController(text: block.text);
        final focusNode = FocusNode();
        focusNode.addListener(() {
          if (focusNode.hasFocus) {
            activeTextId = block.id;
            _onActiveChanged(block.id);
          } else if (activeTextId == block.id) {
            activeTextId = null;
            _onActiveChanged(null);
          }
        });
        focusNodes[block.id] = focusNode;
      } else if (controller.text != block.text) {
        controller
          ..text = block.text
          ..selection = TextSelection.collapsed(offset: block.text.length);
      }
    }
  }

  /// Returns the controller for the provided block ID.
  TextEditingController? controllerFor(String id) => controllers[id];

  /// Returns the focus node for the provided block ID.
  FocusNode? focusNodeFor(String id) => focusNodes[id];

  /// Returns the caret offset for the provided block, if available.
  int? caretOffset(String id) {
    final controller = controllers[id];
    if (controller == null) {
      return null;
    }
    return getCaretOffset(controller);
  }

  /// Focuses the provided text block and optionally moves the caret.
  void focus(String id, {int? offset}) {
    final controller = controllers[id];
    final node = focusNodes[id];
    if (controller == null || node == null) {
      return;
    }

    void applySelection() {
      if (offset != null) {
        setCaretTo(controller, offset);
      } else {
        setCaretToEnd(controller);
      }
    }

    void requestFocus() {
      if (!node.hasFocus) {
        node.requestFocus();
      }
      applySelection();
    }

    if (node.context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentNode = focusNodes[id];
        final currentController = controllers[id];
        if (currentNode != node || currentController != controller) {
          return;
        }
        requestFocus();
      });
    } else {
      requestFocus();
    }

    if (activeTextId != id) {
      activeTextId = id;
      _onActiveChanged(id);
    }
  }

  /// Disposes all managed controllers and focus nodes.
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    for (final node in focusNodes.values) {
      node.dispose();
    }
  }
}
