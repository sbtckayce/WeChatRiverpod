import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

enum Type { text, image }

class MessageModel {
  
  final String fromId;
  final String msg;
  final DateTime read;
  final DateTime sent;
  final String toId;
  final Type type;
  MessageModel({
   
    required this.fromId,
    required this.msg,
    required this.read,
    required this.sent,
    required this.toId,
    required this.type,
  });

  MessageModel copyWith({
    
    String? fromId,
    String? msg,
    DateTime? read,
    DateTime? sent,
    String? toId,
    Type? type,
  }) {
    return MessageModel(
     
      fromId: fromId ?? this.fromId,
      msg: msg ?? this.msg,
      read: read ?? this.read,
      sent: sent ?? this.sent,
      toId: toId ?? this.toId,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
     
      'fromId': fromId,
      'msg': msg,
      'read': read,
      'sent': sent,
      'toId': toId,
      'type': type.name,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
    
      fromId: map['fromId'] ?? '',
      msg: map['msg'] ?? '',
      read: (map['read']as Timestamp).toDate() ,
      sent: (map['sent']as Timestamp).toDate() ,
      toId: map['toId'] ?? '',
      type: map['type'] == Type.text.name ? Type.text : Type.image,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MessageModel( fromId: $fromId, msg: $msg, read: $read, sent: $sent, toId: $toId, type: $type)';
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;

    return 
        other.fromId == fromId &&
        other.msg == msg &&
        other.read == read &&
        other.sent == sent &&
        other.toId == toId &&
        other.type == type;
  }

  @override
  int get hashCode {
    return 
        fromId.hashCode ^
        msg.hashCode ^
        read.hashCode ^
        sent.hashCode ^
        toId.hashCode ^
        type.hashCode;
  }
}
