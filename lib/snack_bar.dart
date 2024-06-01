import 'package:flutter/material.dart';

enum SnackBarType { success, failure }

void showTopSnackBar(BuildContext context, String message, SnackBarType type) {
  final overlay = Overlay.of(context);
  final theme = Theme.of(context);

  Color backgroundColor;
  TextStyle textStyle;
  Icon icon;

  switch (type) {
    case SnackBarType.success:
      icon = Icon(Icons.done, color: theme.colorScheme.primary);
      backgroundColor = theme.colorScheme.surface;
      textStyle = theme.textTheme.bodyMedium!
          .copyWith(color: theme.colorScheme.primary);
      break;
    case SnackBarType.failure:
      icon = Icon(Icons.error, color: theme.colorScheme.error);
      backgroundColor = theme.colorScheme.surface;
      textStyle =
          theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.error);
      break;
  }

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 10.0,
      left: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.8,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: const Offset(0, 0),
        ).animate(CurvedAnimation(
          parent: AnimationController(
            duration: const Duration(milliseconds: 200),
            vsync: ScaffoldMessenger.of(context),
          )..forward(),
          curve: Curves.easeInOut,
        )),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 16),
                Expanded(
                  child: Text(message, style: textStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
