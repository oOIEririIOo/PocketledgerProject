import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketledger/components/consume_card.dart';
import 'package:pocketledger/controllers/chat_controller.dart';
import 'package:pocketledger/components/text_bubble.dart';
import 'package:pocketledger/models/message.dart';

class ExpenseChatPage extends GetView<MyChatController> {
  ExpenseChatPage({super.key});

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyChatController>(
      init: MyChatController(),
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(child: _buildPage()),
        );
      },
    );
  }

  Widget _buildPage() {
    return Stack(
      children: [
        Expanded(child: _buildMessageList()),

        _buildInputArea(),

        _buildArrow(),
      ],
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      final messages = this.controller.getAllMessages();
      return ListView.builder(
        padding: EdgeInsets.only(bottom: 100),
        controller: this.controller.scrollController,
        itemCount: messages.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final message = messages[index];
          if (message is TextMessage) {
            return TextBubble(key: ValueKey(message.id), message: message);
          } else if (message is ConsumeMessage) {
            return Align(
              alignment: Alignment.centerLeft,
              child: ConsumeCard(consumeMessage: message),
            );
          }
        },
      );
    });
  }

  Widget _buildInputArea() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 17.0, sigmaY: 17.0), // 模糊程度
                  child: Container(
                    // 背景颜色和装饰
                    decoration: BoxDecoration(color: Colors.white10),
                    width: double.infinity,
                    height: 70.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: '输入消息...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          filled: true, // 启用填充背景
                          fillColor: const Color.fromARGB(110, 227, 213, 233),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                        onSubmitted: (_) => onPressSend(),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      onPressed: () => onPressSend(),
                      icon: const Icon(Icons.send, color: Colors.grey),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Obx(
      () => controller.showNewMessageButton.value
          ? Positioned(
              right: 16,
              bottom: 80,
              child: IconButton(
                onPressed: () => controller.scrollToBottom(force: true),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.arrow_downward, color: Colors.white),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  void onPressSend() {
    this.controller.pressSend(_messageController.text);
    _messageController.clear();
  }
}
