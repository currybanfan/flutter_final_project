import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Future<void> _signUp() async {
    try {
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      await supabaseProvider.signUp(
          _emailController.text, _passwordController.text);
      if (!mounted) return;
      showTopSnackBar(context, '註冊成功', SnackBarType.success);
    } catch (e) {
      print('e message: $e');
      showTopSnackBar(context, e.toString(), SnackBarType.failure);
    }
  }

  Future<void> _signIn() async {
    try {
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      await supabaseProvider.signIn(
          _emailController.text, _passwordController.text);
      if (!mounted) return;
      showTopSnackBar(context, '登入成功', SnackBarType.success);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      showTopSnackBar(context, e.toString(), SnackBarType.failure);
    }
  }

  Future<void> _resetPassword() async {
    try {
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      await supabaseProvider.resetPassword(_emailController.text);
      if (!mounted) return;
      showTopSnackBar(context, '重置密碼的郵件已發送', SnackBarType.success);
    } catch (e) {
      showTopSnackBar(context, e.toString(), SnackBarType.failure);
    }
  }

  void _guestSignIn() {
    if (context.mounted) {
      showTopSnackBar(context, '成功以訪客身份登入', SnackBarType.success);
      Navigator.pushReplacementNamed(context, '/home');
    }
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
                  onPressed: _signUp,
                  child: const Text('註冊'),
                ),
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('登入'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guestSignIn,
              child: const Text('訪客登入'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('忘記密碼'),
            ),
          ],
        ),
      ),
    );
  }
}
