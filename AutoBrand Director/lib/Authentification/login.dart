import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  //sign in function
  void signIn() async {
    formKey.currentState!.validate();
    setState(() {
      loading = true;
    });
    try {
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email.text.trim(),
            password: password.text.trim(),
          );
      if (!mounted) return;
      if (credentials.user != null) {
        context.go('/Home');
      }
      setState(() {
        loading = false;
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Form(
          key: formKey,
          child: Column(
            spacing: 20,
            children: [
              const Center(child: Text('Login Page')),
              TextFormField(
                controller: email,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: password,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              loading
                  ? const SizedBox()
                  : ElevatedButton(onPressed: signIn, child: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}
