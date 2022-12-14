import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DraggableItem extends StatelessWidget {
  final String value;
  final int index;
  final void Function()? onDragStarted;
  const DraggableItem({
    Key? key,
    required this.value,
    required this.index,
    this.onDragStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<Map<String, dynamic>>(
      onDragStarted: onDragStarted,
      data: {
        "value": value,
        "index": index,
      },
      feedback: SizedBox(
        width: (context.width - 32 - 16 - 12) / 3,
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: const SizedBox(),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
