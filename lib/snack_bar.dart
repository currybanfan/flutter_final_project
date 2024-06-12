import 'package:flutter/material.dart';

// 定義一個枚舉，用來表示 Snackbar 類型：成功或失敗
enum SnackBarType { success, failure }

// 顯示頂部 Snackbar 的方法
void showTopSnackBar(BuildContext context, String message, SnackBarType type) {
  // 獲取當前的 Overlay 和主題
  final overlay = Overlay.of(context);
  final theme = Theme.of(context);

  // 宣告背景顏色、文字樣式和圖標的變數
  Color backgroundColor;
  TextStyle textStyle;
  Icon icon;

  // 根據 Snackbar 的類型設置不同的樣式
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

  // 創建 OverlayEntry，用於顯示 Snackbar
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      // 設定 Snackbar 的位置
      top: 10.0,
      left: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.8,
      child: SlideTransition(
        // 設定位移動畫
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

  // 插入 OverlayEntry
  overlay.insert(overlayEntry);

  // 設置 Snackbar 顯示 2 秒後移除
  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
