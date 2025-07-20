import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketledger/models/activity_type.dart';
part 'message.g.dart';

/// 消息类型枚举
enum MessageType {
  @JsonValue('card')
  consume,
  text,
  image,
  audio,
}

/// 基础消息类
@JsonSerializable()
class Message {
  final String senderID;
  final MessageType? messageType;
  final DateTime timestamp;
  final String id;

  Message({required this.senderID, this.messageType, required this.id})
    : timestamp = DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

///文本消息类，继承自Message
class TextMessage extends Message {
  ///文字内容
  final RxString text;

  TextMessage({
    required String senderID,
    required String text,
    required String id,
  }) : text = text.obs, // 初始化RxString
       super(
         senderID: senderID,
         messageType: MessageType.text, // 文本消息类型固定为text
         id: id,
       );

  String get content => text.value; // 获取文本内容
}

///消费消息类，用于展示记账卡片，继承自Message
@JsonSerializable()
class ConsumeMessage extends Message {
  ///活动类型
  final ActivityType activityType;

  ///消费金额
  final double price;

  ///消费日期
  final DateTime date;

  //具体活动描述
  final String describe;

  //入账出账布尔 true为入账 false为出账
  final bool isPositive;

  ConsumeMessage({
    required String senderID,
    required String id,
    required this.activityType,
    required this.price,
    required this.date,
    required this.describe,
    required this.isPositive,
  }) : super(
         senderID: senderID,
         id: id,
         messageType: MessageType.consume, // 卡片消息通常用于消费或特定信息展示
       );

  factory ConsumeMessage.fromJson(Map<String, dynamic> json) =>
      _$ConsumeMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ConsumeMessageToJson(this);
}
