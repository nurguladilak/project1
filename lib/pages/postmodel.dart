import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String nickname;
  final String profileUrl;
  final String text;
  final String contentUrl;
  final String contentTypes;
  final int likes;
  final int comments;
  final List<dynamic> likedBy;
  final DateTime timestamp;
  final Map<String, dynamic>?
  dominantColor;

  PostModel({
    required this.postId,
    required this.userId,
    required this.nickname,
    required this.profileUrl,
    required this.text,
    required this.contentUrl,
    required this.contentTypes,
    required this.likes,
    required this.comments,
    required this.likedBy,
    required this.timestamp,
    this.dominantColor,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      nickname: map['nickname'] ?? '',
      profileUrl: map['profileUrl'] ?? '',
      text: map['text'] ?? '',
      contentUrl: map['contentUrl'] ?? '',
      contentTypes: map['contentTypes'] ?? 'text',
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      likedBy: map['likedBy'] ?? [],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dominantColor: map['dominantColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'nickname': nickname,
      'profileUrl': profileUrl,
      'text': text,
      'contentUrl': contentUrl,
      'contentTypes': contentTypes,
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
      'timestamp': timestamp,
      if (dominantColor != null) 'dominantColor': dominantColor,
    };
  }
}
