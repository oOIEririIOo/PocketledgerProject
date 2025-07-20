import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as m;

// 自定义 LaTeX 标签
const _latexTag = 'latex';

// 将自定义标签与 SpanNodeGeneratorWithTag 关联
SpanNodeGeneratorWithTag latexGenerator = SpanNodeGeneratorWithTag(
  tag: _latexTag,
  generator: (e, config, visitor) =>
      LatexNode(e.attributes, e.textContent, config),
);

// 自定义语法，用于匹配 LaTeX 内容
// 顺序很重要：更具体的、可能包含特殊字符的模式在前
class LatexSyntax extends m.InlineSyntax {
  LatexSyntax()
    : super(
        // $$...$$ (块级)
        r'(\$\$[\s\S]+?\$\$)|' +
            // \[...\] (通常为显示样式)
            r'\\\[[\s\S]+?\\\]|' +
            // \(...\) (行内)
            r'\\\(.+?\\\)|' +
            // $...$ (行内)
            r'(\$.+?\$)',
      );

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final input = match.input;
    final matchValue = input.substring(match.start, match.end);
    String content = '';
    bool isInline = true;

    // 优先匹配块级公式 $$...$$
    if (matchValue.startsWith('\$\$') &&
        matchValue.endsWith('\$\$') &&
        matchValue.length > 4) {
      content = matchValue.substring(2, matchValue.length - 2);
      isInline = false;
    }
    // 其次匹配 \[...\]
    else if (matchValue.startsWith('\\[') &&
        matchValue.endsWith('\\]') &&
        matchValue.length > 4) {
      content = matchValue.substring(2, matchValue.length - 2);
      isInline = false; // \[...\] 通常被视为显示样式
    }
    // 再次匹配行内公式 \(...)\
    else if (matchValue.startsWith('\\(') &&
        matchValue.endsWith('\\)') &&
        matchValue.length > 4) {
      content = matchValue.substring(2, matchValue.length - 2);
      isInline = true;
    }
    // 最后匹配 $...$
    else if (matchValue.startsWith('\$') &&
        matchValue.endsWith('\$') &&
        matchValue.length > 2) {
      content = matchValue.substring(1, matchValue.length - 1);
      isInline = true;
    } else {
      debugPrint('LatexSyntax: No valid LaTeX match found for: $matchValue');
      return false; // 如果没有正确匹配，则不添加节点
    }

    m.Element el = m.Element.text(_latexTag, matchValue);
    el.attributes['content'] = content;
    el.attributes['isInline'] = '$isInline';
    parser.addNode(el);
    return true;
  }
}

// 自定义 SpanNode，用于渲染 LaTeX 内容
class LatexNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  LatexNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    final content = attributes['content'] ?? '';
    final isInline = attributes['isInline'] == 'true';
    final style = parentStyle ?? config.p.textStyle;

    // 如果 content 为空，则返回原始文本
    if (content.isEmpty) {
      debugPrint('LatexNode: content is empty for textContent: $textContent');
      return TextSpan(style: style, text: textContent);
    }

    final latex = Math.tex(
      content,
      mathStyle: isInline
          ? MathStyle.text
          : MathStyle.display, // 根据 isInline 设置样式
      textStyle: style.copyWith(
        color: style.color ?? Colors.black, // 确保文本颜色不为 null，默认黑色
      ),
      textScaleFactor: 1, // 可以根据需要调整缩放因子
      onErrorFallback: (error) {
        // 当渲染失败时，打印详细错误并显示原始文本
        debugPrint('flutter_math_fork rendering error for "$content": $error');
        return Text(
          textContent, // 显示原始 LaTeX 文本
          style: style.copyWith(color: Colors.red), // 错误时显示红色
        );
      },
    );

    if (isInline) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: latex, // 行内公式
      );
    } else {
      // **为块级公式添加水平滚动以防止溢出**
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle, // 块级公式的对齐方式
        child: Container(
          width: double.infinity, // 确保占据可用宽度
          margin: const EdgeInsets.symmetric(vertical: 16), // 块级公式的垂直边距
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 允许水平滚动
            padding: EdgeInsets.zero, // 移除额外的内边距
            child: Center(
              // 尝试居中内容，如果内容很长，居中效果可能不明显
              child: latex,
            ),
          ),
        ),
      );
    }
  }
}
