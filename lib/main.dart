import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketledger/pages/expense_chat_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: ExpenseChatPage()),
    );
  }
}
