import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart';
import '../providers/supabase_provider.dart';
import '../snack_bar.dart';

// 定義 AuthPage 類，表示身份驗證頁面
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  // 控制輸入框的控制器
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 處理用戶登入邏輯
  Future<void> _signIn() async {
    try {
      // 獲取 SupabaseProvider 的實例
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      // 調用登入方法
      await supabaseProvider.signIn(
          _emailController.text, _passwordController.text);
    } catch (e) {
      final String msg;
      // 根據不同的錯誤狀態碼顯示不同的錯誤信息
      if (e is AuthException) {
        switch (e.statusCode) {
          case '400':
            msg = '帳號或密碼錯誤';
          default:
            msg = '登入失敗';
        }
      } else {
        msg = e.toString();
      }
      if (!mounted) return;
      // 顯示錯誤 Snackbar
      showTopSnackBar(context, msg, SnackBarType.failure);
    }
  }

  // 處理訪客登入邏輯
  void _guestSignIn() {
    // 獲取 SupabaseProvider 的實例並調用訪客登入方法
    final supabaseProvider =
        Provider.of<SupabaseProvider>(context, listen: false);
    supabaseProvider.guestSignIn();
  }

  // 顯示註冊對話框
  void _showSignUpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SignUpDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('註冊和登入', style: theme.textTheme.titleLarge),
        backgroundColor: theme.colorScheme.primary,
      ),
      // 使用 SingleChildScrollView 避免 overflow
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 輸入 email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            // 輸入密碼
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // 按鈕區域
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 訪客登入按鈕
                ElevatedButton(
                  onPressed: _guestSignIn,
                  child: const Text('訪客登入'),
                ),
                // 登入按鈕
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('登入'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 註冊按鈕
            ElevatedButton(
              onPressed: _showSignUpDialog,
              child: const Text('註冊'),
            ),
          ],
        ),
      ),
    );
  }
}

// 註冊對話框
class SignUpDialog extends StatefulWidget {
  const SignUpDialog({super.key});

  @override
  SignUpDialogState createState() => SignUpDialogState();
}

class SignUpDialogState extends State<SignUpDialog> {
  // 控制輸入框的控制器
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 處理用戶註冊邏輯
  Future<void> _signUp() async {
    // 檢查密碼是否一致
    if (_passwordController.text != _confirmPasswordController.text) {
      showTopSnackBar(context, '密碼不一致', SnackBarType.failure);
      return;
    }
    try {
      // 獲取 SupabaseProvider 的實例
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      // 調用註冊方法
      await supabaseProvider.signUp(
          _emailController.text, _passwordController.text);
      if (!mounted) return;
      // 顯示註冊成功提示
      showTopSnackBar(context, '註冊成功', SnackBarType.success);
      Navigator.of(context).pop();
    } catch (e) {
      final String msg;
      // 根據不同的錯誤狀態碼顯示不同的錯誤信息
      if (e is AuthException) {
        switch (e.statusCode) {
          case '400':
            msg = '輸入資訊錯誤';
          case '422':
            msg = '請輸入信箱或密碼';
          default:
            msg = '註冊失敗';
        }
      } else {
        msg = e.toString();
      }
      // 顯示錯誤 Snackbar
      showTopSnackBar(context, msg, SnackBarType.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Text('註冊', style: theme.textTheme.titleLarge),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 輸入 email
            TextField(
              controller: _emailController,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            // 輸入密碼
            TextField(
              controller: _passwordController,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            // 確認密碼
            TextField(
              controller: _confirmPasswordController,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        // 取消按鈕
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        // 註冊按鈕
        ElevatedButton(
          onPressed: _signUp,
          child: const Text('註冊'),
        ),
      ],
    );
  }
}
