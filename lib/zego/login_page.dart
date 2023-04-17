import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import 'create_account_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 20.0),
            Column(
              children: [
                const Icon(
                  Icons.clear_all,
                  size: 25.0,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  "LOGIN",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            TextField(
              decoration: const InputDecoration(labelText: "Email"),
              controller: _emailController,
            ),
            const SizedBox(height: 10.0),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
              controller: _passwordController,
            ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateAccountPage()));
                  },
                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                  child: const Text("Create Account"),
                ),
                TextButton(
                  onPressed: () {
                    _emailController.clear();
                    _passwordController.clear();
                  },
                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                  child: const Text("Clear"),
                ),
                ElevatedButton(
                  onPressed: () => _onLoginTap(context),
                  style: ElevatedButton.styleFrom(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text("Login"),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: () => _onLoginWithGoogleTap(context),
              style: ElevatedButton.styleFrom(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text("Google Sign in"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLoginTap(BuildContext context) async {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      var success = await FirebaseService.login(email: _emailController.text, password: _passwordController.text);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Icon(Icons.warning_amber),
                ),
                Expanded(
                  child: Text(
                    "Login failed",
                  ),
                )
              ],
            ),
          ),
        );
      }
    }
  }

  void _onLoginWithGoogleTap(BuildContext context) async {
    var sucsess = await FirebaseService.loginWithGoogle();
    if (!sucsess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Row(
            children: const [
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Icon(Icons.warning_amber),
              ),
              Expanded(
                child: Text(
                  "Google Login failed",
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
