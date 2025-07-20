import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketledger/models/activity_type.dart';
import 'package:pocketledger/models/message.dart';

class ConsumeCard extends StatelessWidget {
  final ConsumeMessage consumeMessage;

  const ConsumeCard({super.key, required this.consumeMessage});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'yyyy-MM-dd',
    ).format(consumeMessage.date);
    final String formattedPrice = consumeMessage.isPositive
        ? '+¥' + consumeMessage.price.toStringAsFixed(2)
        : '-¥' + consumeMessage.price.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: 270,
        height: 180,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(169, 158, 158, 158), // 阴影颜色及透明度
              spreadRadius: 2, // 阴影扩散的程度
              blurRadius: 5, // 阴影的模糊程度
              offset: Offset(0, 3), // 阴影的偏移量 (x, y)
            ),
          ],
          color: const Color.fromARGB(255, 241, 241, 241),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            //顶部信息栏
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '已记账',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            //分割线
            Container(
              width: 235,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            //中间详细信息
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 221, 236, 243),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(Icons.book, color: Colors.blueAccent),
                      ),

                      SizedBox(width: 5),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            consumeMessage.activityType.toLocalizedString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color: Colors.grey[800],
                            ),
                          ),
                          Container(
                            width: 100,
                            child: Text(
                              consumeMessage.describe,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 50,
                      maxWidth: 80,
                    ), // 设置最小宽度
                    child: IntrinsicWidth(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            // 模拟凹陷效果
                            BoxShadow(
                              color: const Color.fromARGB(120, 255, 255, 255),
                              offset: const Offset(2, 2),
                              blurRadius: 2,
                              spreadRadius: 0,
                              blurStyle: BlurStyle.inner,
                            ),

                            BoxShadow(
                              color: const Color.fromARGB(64, 0, 0, 0),
                              offset: const Offset(-1.5, -1.5),
                              blurRadius: 2,
                              spreadRadius: 0,
                              blurStyle: BlurStyle.inner,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            formattedPrice,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //底部按钮
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 45,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 221, 236, 243),
                        ),
                        child: Icon(
                          Icons.edit_note,
                          color: Colors.blueAccent[100],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 45,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 255, 175, 167),
                        ),
                        child: Icon(
                          Icons.delete_sharp,
                          color: Colors.redAccent[200],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
