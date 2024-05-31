import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'supabase_provider.dart';

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

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('註冊成功')));
      }
    } catch (e) {
      print(e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('註冊失敗 : $e')));
      }
    }
  }

  Future<void> _signIn() async {
    try {
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);
      await supabaseProvider.signIn(
          _emailController.text, _passwordController.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('登入成功')));
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) {
        print(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('登入失敗 : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('註冊和登入'),
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
          ],
        ),
      ),
    );
  }
}
