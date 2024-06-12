import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart';
import '../providers/supabase_provider.dart';
import '../snack_bar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      await supabaseProvider.signIn(
          _emailController.text, _passwordController.text);
    } catch (e) {
      final String msg;
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
      showTopSnackBar(context, msg, SnackBarType.failure);
    }
  }

  void _guestSignIn() {
    final supabaseProvider =
        Provider.of<SupabaseProvider>(context, listen: false);
    supabaseProvider.guestSignIn();
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _guestSignIn,
                  child: const Text('訪客登入'),
                ),
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('登入'),
                ),
              ],
            ),
            const SizedBox(height: 20),
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

class SignUpDialog extends StatefulWidget {
  const SignUpDialog({super.key});

  @override
  SignUpDialogState createState() => SignUpDialogState();
}

class SignUpDialogState extends State<SignUpDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      showTopSnackBar(context, '密碼不一致', SnackBarType.failure);
      return;
    }
    try {
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      await supabaseProvider.signUp(
          _emailController.text, _passwordController.text);
      if (!mounted) return;
      showTopSnackBar(context, '註冊成功', SnackBarType.success);
      Navigator.of(context).pop();
    } catch (e) {
      final String msg;
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
            TextField(
              controller: _emailController,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
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
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _signUp,
          child: const Text('註冊'),
        ),
      ],
    );
  }
}
