import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketledger/Services/ai_service.dart';
import 'package:pocketledger/models/message.dart';

class MyChatController extends GetxController with WidgetsBindingObserver {
  RxList<Message> messages = RxList<Message>();
  final ScrollController scrollController = ScrollController();
  final AIService aiService = AIService();
  final RxBool showNewMessageButton = false.obs;
  final isLongPressing = false.obs;
  RxBool keyboardMode = true.obs;
  final focusNode = FocusNode();
  final String userID = 'user';
  final String AIID = 'AI';
  final RxBool isLoading = false.obs;
  final bool isValid = false;

  // 用于跟踪键盘是否已经打开过一次的标志
  bool _hasKeyboardOpenedOnce = false;

  // 使用 RxBool 来表示键盘是否打开的状态
  final RxBool isKeyboardOpen = false.obs;
  _initData() async {
    update(["chat"]);
  }

  @override
  void onInit() {
    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addObserver(this);
    _initData();
    super.onInit();
  }

  void pressSend(String text) async {
    if (text == '') {
      return;
    }
    var msg = TextMessage(
      senderID: 'user',
      text: text,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    addMessage(msg);
    var isValid = aiService.getIsValid(text);
    asyncAddTextMessageByAI(text, await isValid);
    await streamAddTextMessageByAI(text, await isValid);
  }

  void addMessage(Message message) async {
    messages.add(message);
    scrollToBottom(force: true);
  }

  RxList<Message> getAllMessages() {
    return messages;
  }

  String getUserID() {
    return userID;
  }

  ///流式响应 用于文本输出
  Future<void> streamAddTextMessageByAI(
    String userMessage,
    bool isValid,
  ) async {
    final aiMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    final aiPlaceholderMessage = TextMessage(
      senderID: AIID,
      text: '', // 初始为空字符串
      id: aiMessageId,
    );
    addMessage(aiPlaceholderMessage); // 将占位符消息添加到列表

    String fullResponseContent = ''; // 用于累积 AI 的完整响应

    try {
      await for (final chunk in aiService.getAiStreamResponse(
        userMessage,
        isValid,
      )) {
        fullResponseContent += chunk; // 累积文本片段
        aiPlaceholderMessage.text.value =
            fullResponseContent; // 直接更新 RxString 的值

        scrollToBottom();
      }
    } catch (e) {
      print('接收 AI 流式响应出错: $e');
      aiPlaceholderMessage.text.value = 'AI 响应出错: $e';
    } finally {}
  }

  ///异步响应 用于记账卡片
  void asyncAddTextMessageByAI(String userMessage, bool isValid) async {
    if (!isValid) {
      return;
    }

    final aiMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    final aiPlaceholderMessage = TextMessage(
      senderID: AIID,
      text: '正在记账中',
      id: aiMessageId,
    );
    addMessage(aiPlaceholderMessage);
    final int thinkMessageIndex = messages.indexOf(aiPlaceholderMessage);
    scrollToBottom(force: true);

    try {
      final String? aiResponse = await aiService.getAiAsyncResponse(
        userMessage,
        isValid,
      );

      if (aiResponse != null) {
        aiPlaceholderMessage.text.value = aiResponse; // 更新 RxString 的值
        var consumeMessage = formatJsonToConsumeMessage(aiResponse);
        if (consumeMessage != null) {
          messages[thinkMessageIndex] = consumeMessage;
        } else {
          aiPlaceholderMessage.text.value = 'AI 回复: $aiResponse (未识别为记账卡片)';
        }
      } else {
        aiPlaceholderMessage.text.value = '未能获取 AI 回复。';
      }
    } catch (e) {
      print('获取 AI 异步回复出错: $e');
      aiPlaceholderMessage.text.value = 'AI 响应出错: $e';
    } finally {
      // 确保滚动到最新消息，无论成功与否
      scrollToBottom(force: true);
    }
  }

  ///将返回字符串结构化为ConsumeMessage
  ConsumeMessage? formatJsonToConsumeMessage(String fullString) {
    const String prefix = "```json\n";
    const String suffix = "\n```";
    print('原始文本: ${fullString}');
    // 检查是否以正确的格式开始和结束
    if (!fullString.startsWith(prefix) || !fullString.endsWith(suffix)) {
      print('文本格式错误');
      print('原始文本: ${fullString}');
      print('期望前缀: "$prefix"');
      print('期望后缀: "$suffix"');
      return null;
    }

    // 提取纯 JSON 字符串
    // 移除前缀和后缀
    String jsonPart = fullString.substring(
      prefix.length,
      fullString.length - suffix.length,
    );

    // 解析 JSON 部分
    try {
      Map<String, dynamic> jsonMap = json.decode(jsonPart);

      jsonMap['senderID'] = 'user';
      jsonMap['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      ConsumeMessage consumeMessage = ConsumeMessage.fromJson(jsonMap);
      return consumeMessage;
    } catch (e) {
      print('JSON 解析错误！请检查提取出的字符串是否为有效的 JSON。错误信息: $e');
      return null;
    }
  }

  // 滚动到列表底部
  void scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        if (force ||
            scrollController.position.pixels >=
                scrollController.position.maxScrollExtent - 10) {
          scrollController
              .animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500), // 滚动动画时长
                curve: Curves.easeOut, // 滚动动画曲线
              )
              .then((_) {
                scrollController.jumpTo(
                  scrollController.position.maxScrollExtent,
                );
              });
        }
      }
    });
  }

  /// 滚动监听器，用于判断用户是否在底部
  void _scrollListener() {
    // 检查用户是否接近列表底部
    // _scrollThreshold 可以根据需要调整，例如留出底部 100 像素的距离
    final double _scrollThreshold = 100.0;
    if (scrollController.hasClients &&
        scrollController.position.pixels <
            scrollController.position.maxScrollExtent - _scrollThreshold) {
      // 用户不在底部，显示按钮（如果还没有显示）
      if (!showNewMessageButton.value) {
        showNewMessageButton.value = true;
      }
    } else {
      // 用户在底部或非常接近底部，隐藏按钮
      if (showNewMessageButton.value) {
        showNewMessageButton.value = false;
      }
    }
  }

  @override
  void didChangeMetrics() {
    // 获取当前视图的 MediaQueryData
    final view = ui.PlatformDispatcher.instance.views.firstOrNull;
    if (view != null) {
      final keyboardHeight = view.viewInsets.bottom;
      final newIsKeyboardOpen = keyboardHeight > 0.0;

      if (isKeyboardOpen.value != newIsKeyboardOpen) {
        isKeyboardOpen.value = newIsKeyboardOpen;
      }

      // 判断键盘是否打开，并且只执行一次
      if (isKeyboardOpen.value && !_hasKeyboardOpenedOnce) {
        _hasKeyboardOpenedOnce = true;
        scrollToBottom(force: true);
      } else if (!isKeyboardOpen.value) {
        // 重置标志，以便下次键盘打开时再次执行
        _hasKeyboardOpenedOnce = false;
      }
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    focusNode.dispose();
    super.onClose();
  }
}
