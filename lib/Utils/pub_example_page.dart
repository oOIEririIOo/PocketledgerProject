import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart'; // 导入 Math.tex 所在的库

class MathTexTestPage extends StatelessWidget {
  const MathTexTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math.tex 测试页面'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '以下是使用 Math.tex 渲染的数学公式示例：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- 示例 1: 简单的行内公式 ---
            // 修正：标题字符串前添加 'r'，使其成为原始字符串，避免 Dart 解析器对 $ 进行变量解析
            _buildSectionTitle(r'1. 简单的行内公式 ($x^2 + y^2 = z^2$)'),
            Row(
              children: [
                const Text('著名的勾股定理: '),
                // 注意这里使用 `r''` 原始字符串，避免反斜杠转义问题
                Math.tex(
                  r'x^2 + y^2 = z^2',
                  mathStyle: MathStyle.text, // 行内样式
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueGrey,
                  ),
                  onErrorFallback: (error) =>
                      _buildErrorWidget('行内公式渲染失败', error),
                ),
              ],
            ),
            const Divider(),

            // --- 示例 2: 块级公式 (导数定义) - 修正后的 LaTeX 语法 ---
            _buildSectionTitle(r'2. 块级公式 (导数定义)'),
            Center(
              child: Math.tex(
                // 修正：将 f''(x) 改为更标准的 LaTeX 语法 f^{\prime\prime}(x)
                // 或者，如果你只想要单撇号，用 f'(x)
                // 我们这里使用 f^{\prime\prime}(x) 来表示二阶导数
                r'f^{\prime\prime}(x) = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}',
                mathStyle: MathStyle.display, // 显示样式
                textStyle: const TextStyle(
                  fontSize: 22,
                  color: Colors.deepPurple,
                ),
                onErrorFallback: (error) =>
                    _buildErrorWidget('块级公式渲染失败', error),
              ),
            ),
            const Divider(),

            // --- 示例 3: 包含文本和单位的公式 ---
            // 修正：标题字符串前添加 'r'
            _buildSectionTitle(r'3. 包含文本和单位的公式 ($E = mc^2$)'),
            Row(
              children: [
                const Text('爱因斯坦质能方程: '),
                Math.tex(
                  r'E = mc^2 \quad \text{其中 } c \text{ 是光速}', // \quad 用于添加间距，\text{} 用于显示普通文本
                  mathStyle: MathStyle.text,
                  textStyle: const TextStyle(fontSize: 20, color: Colors.green),
                  onErrorFallback: (error) =>
                      _buildErrorWidget('文本公式渲染失败', error),
                ),
              ],
            ),
            const Divider(),

            // --- 示例 4: 故意引入错误的公式 (测试 onErrorFallback) ---
            _buildSectionTitle('4. 故意错误的公式 (测试错误处理)'),
            Center(
              child: Math.tex(
                r'\frac{这是一段错误语', // 故意缺少结束大括号，预期会触发错误
                mathStyle: MathStyle.display,
                textStyle: const TextStyle(fontSize: 20),
                onErrorFallback: (error) => _buildErrorWidget('错误公式被捕获', error),
              ),
            ),
            const Divider(),

            // --- 示例 5: 字体大小和颜色调整 ---
            _buildSectionTitle('5. 不同字体大小和颜色'),
            Math.tex(
              r'\int_a^b f(x) \, dx',
              textStyle: const TextStyle(fontSize: 30, color: Colors.orange),
              onErrorFallback: (error) => _buildErrorWidget('自定义样式渲染失败', error),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  // 辅助方法：构建标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 辅助方法：构建错误提示 Widget 并打印详细错误到控制台
  Widget _buildErrorWidget(String message, Object error) {
    // 打印详细错误信息到控制台，这对于调试至关重要
    debugPrint('Math.tex 渲染错误 ($message): $error');
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.red.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$message: ',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            error.toString(), // 显示错误对象的字符串表示
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
