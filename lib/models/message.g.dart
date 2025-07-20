// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  senderID: json['senderID'] as String,
  messageType: $enumDecodeNullable(_$MessageTypeEnumMap, json['messageType']),
  id: json['id'] as String,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'senderID': instance.senderID,
  'messageType': _$MessageTypeEnumMap[instance.messageType],
  'id': instance.id,
};

const _$MessageTypeEnumMap = {
  MessageType.consume: 'card',
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.audio: 'audio',
};

ConsumeMessage _$ConsumeMessageFromJson(Map<String, dynamic> json) =>
    ConsumeMessage(
      senderID: json['senderID'] as String,
      id: json['id'] as String,
      activityType: $enumDecode(_$ActivityTypeEnumMap, json['activityType']),
      price: (json['price'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      describe: json['describe'] as String,
      isPositive: json['isPositive'] as bool,
    );

Map<String, dynamic> _$ConsumeMessageToJson(ConsumeMessage instance) =>
    <String, dynamic>{
      'senderID': instance.senderID,
      'id': instance.id,
      'activityType': _$ActivityTypeEnumMap[instance.activityType]!,
      'price': instance.price,
      'date': instance.date.toIso8601String(),
      'describe': instance.describe,
      'isPositive': instance.isPositive,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.travel: 'travel',
  ActivityType.entertainment: 'entertainment',
  ActivityType.food: 'food',
  ActivityType.study: 'study',
  ActivityType.exercise: 'exercise',
  ActivityType.work: 'work',
  ActivityType.shopping: 'shopping',
  ActivityType.leisure: 'leisure',
  ActivityType.other: 'other',
};
