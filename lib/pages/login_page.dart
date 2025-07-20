import 'package:flutter/material.dart';
import 'package:pocketledger/components/my_button.dart';
import 'package:pocketledger/components/my_text_filed.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  void login() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 50),

            //welcome back message
            Text(
              "欢迎使用",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            //email textfield
            MyTextField(hintText: '邮箱', controller: _emailController),

            const SizedBox(height: 10),

            //psw textfield
            MyTextField(
              hintText: '密码',
              obscureText: true,
              controller: _passwordController,
            ),

            const SizedBox(height: 25),

            //login button
            MyButton(text: '登录', onTap: login),

            const SizedBox(height: 15),

            //register button
            MyButton(text: '注册', onTap: login),
          ],
        ),
      ),
    );
  }
}
