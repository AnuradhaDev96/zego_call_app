import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import 'login_page.dart';

class CreateAccountPage extends StatelessWidget {
  CreateAccountPage({Key? key}) : super(key: key);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

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
                  "CREATE ACCOUNT",
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
            const SizedBox(height: 10.0),
            TextField(
              decoration: const InputDecoration(labelText: "Full name"),
              controller: _nameController,
            ),
            const SizedBox(height: 10.0),
            TextField(
              decoration: const InputDecoration(labelText: "Username"),
              controller: _usernameController,
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                  child: const Text("Already have an account?"),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        _emailController.clear();
                        _passwordController.clear();
                        _usernameController.clear();
                        _nameController.clear();
                      },
                      style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                      child: const Text("Clear"),
                    ),
                    ElevatedButton(
                      onPressed: () => _onSignUpTap(context),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSignUpTap(BuildContext context) async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty) {
      var success = await FirebaseService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        name: _nameController.text,
      );
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
                    "Create account failed",
                  ),
                )
              ],
            ),
          ),
        );
      }
    }
  }
}
