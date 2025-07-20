import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:pocketledger/Utils/latex_span_node.dart';

import '../models/message.dart';

class TextBubble extends StatefulWidget {
  final TextMessage message;

  const TextBubble({required Key key, required this.message}) : super(key: key);

  @override
  State<TextBubble> createState() => _TextBubbleState();
}

class _TextBubbleState extends State<TextBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget messageContent;

    final bool isCurrentUser = widget.message.senderID == 'user';

    final Color bubbleColor = isCurrentUser
        ? const Color.fromARGB(255, 60, 131, 255)
        : Colors.grey[200]!;
    final BubbleNip bubbleNip = isCurrentUser
        ? BubbleNip.rightBottom
        : BubbleNip.leftBottom;
    final Alignment bubbleAlignment = isCurrentUser
        ? Alignment.topRight
        : Alignment.topLeft;
    final Color generalTextColor = isCurrentUser
        ? Colors.white
        : Colors.black87;

    messageContent = Obx(
      () => MarkdownBlock(
        data: widget.message.content,
        config: MarkdownConfig(
          configs: [
            PConfig(
              textStyle: TextStyle(
                color: generalTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            PreConfig(
              builder: (code, language) {
                // 顶部 UI (语言标签和复制按钮)
                final Color headerBgColor =
                    a11yLightTheme['root']?.backgroundColor ??
                    const Color.fromARGB(255, 214, 214, 214);
                final Color bodyBgColor =
                    a11yLightTheme['root']?.backgroundColor ??
                    const Color.fromARGB(255, 214, 214, 214);
                final Color headerTextColor = Colors.grey;
                final Color bodyTextColor = Colors.black87;
                final TextStyle codeTextStyle = const TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                );

                final bool containsLatex = language == 'latex';
                Widget codeContentWidget;

                if (containsLatex) {
                  //包含 LaTeX 的代码块 (牺牲语法高亮)
                  // 在这里使用嵌套的 MarkdownBlock 来解析代码内容，允许 LaTeX 渲染
                  codeContentWidget = MarkdownBlock(
                    data: code, // 将原始代码作为新的 Markdown 内容传递
                    config: MarkdownConfig(
                      configs: [
                        PConfig(
                          textStyle: codeTextStyle.copyWith(
                            color: bodyTextColor,
                          ),
                        ),
                        // 注意：这里不再包含 PreConfig，防止无限递归
                      ],
                    ),
                    generator: MarkdownGenerator(
                      generators: [latexGenerator],
                      inlineSyntaxList: [LatexSyntax()],
                    ),
                  );
                } else {
                  // 纯代码块 (使用 flutter_highlight 进行语法高亮)
                  codeContentWidget = ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 400),
                        child: HighlightView(
                          code,
                          language: language,
                          theme: a11yLightTheme,
                          padding: const EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 代码块头部 UI
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            height: 50,
                            decoration: BoxDecoration(
                              color: headerBgColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    language.isNotEmpty
                                        ? language
                                        : 'Natural Language',
                                    style: TextStyle(
                                      color: headerTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  size: 20,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: code));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copy That✅')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 代码内容区域
                    Container(
                      decoration: BoxDecoration(
                        color: bodyBgColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      width: double.infinity,
                      child: codeContentWidget, // 根据判断结果显示内容 Widget
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        generator: MarkdownGenerator(
          generators: [latexGenerator],
          inlineSyntaxList: [LatexSyntax()],
        ),
      ),
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: bubbleAlignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          child: Bubble(
            padding: const BubbleEdges.all(15),
            alignment: bubbleAlignment,
            color: bubbleColor,
            nip: bubbleNip,
            child: messageContent,
          ),
        ),
      ),
    );
  }
}
