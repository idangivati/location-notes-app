import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime date;
  final GeoPoint location;
  final String? imageUrl;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.date,
    required this.location,
    this.imageUrl,
  });

  // Copy with method for easy updates
  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    DateTime? date,
    GeoPoint? location,
    String? imageUrl,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'date': Timestamp.fromDate(date),
      'location': location,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  // Create from Firestore document
  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] as GeoPoint,
      imageUrl: data['imageUrl'],
    );
  }
}