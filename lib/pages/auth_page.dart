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
      final response = await supabaseProvider.signUp(
          _emailController.text, _passwordController.text);
      if (context.mounted) {
        showTopSnackBar(context, response, SnackBarType.success);
      }
    } catch (e) {
      if (context.mounted) {
        showTopSnackBar(context, e.toString(), SnackBarType.failure);
      }
    }
  }

  Future<void> _signIn() async {
    try {
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      final response = await supabaseProvider.signIn(
          _emailController.text, _passwordController.text);
      if (context.mounted) {
        showTopSnackBar(context, response, SnackBarType.success);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) {
        showTopSnackBar(context, e.toString(), SnackBarType.failure);
      }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('註冊'),
                ),
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('登入'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guestSignIn,
              child: Text('訪客登入'),
            ),
          ],
        ),
      ),
    );
  }
}
