import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/components/appBar.dart';
import '../../components/color.dart';

class TextDraftPage extends StatelessWidget {
  const TextDraftPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: AppColors.color24,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('drafts')
                .where('uid', isEqualTo: uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No text drafts found.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Trash',
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final text = data['text'] ?? '';

              return ListTile(
                title: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('Saved as draft'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await docs[index].reference.delete();
                  },
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
