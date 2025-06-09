import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> ensureMetadataExists() async {
  final firestore = FirebaseFirestore.instance;
  final metadataRef = firestore.collection('metadata').doc('userCount');

  try {
    DocumentSnapshot snapshot = await metadataRef.get();
    if (!snapshot.exists) {
      await metadataRef.set({'count': 0});
      print("✅ Metadata created: count = 0");
    } else {
      print("✅ Metadata already exists.");
    }
  } catch (e) {
    print("❌Metadata check/creation error: $e");
  }
}
