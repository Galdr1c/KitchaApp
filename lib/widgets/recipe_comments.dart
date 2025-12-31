import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeComments extends StatefulWidget {
  final String recipeId;
  const RecipeComments({super.key, required this.recipeId});

  @override
  State<RecipeComments> createState() => _RecipeCommentsState();
}

class _RecipeCommentsState extends State<RecipeComments> {
  final _ctrl = TextEditingController();

  Future<void> _post() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yorum yapmak için giriş yapın')));
      return;
    }
    if (_ctrl.text.trim().isEmpty) return;
    
    // Get user details for badge
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    int count = 0;
    if (userDoc.exists) count = userDoc.data()?['contributionCount'] ?? 0;
    
    await FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId).collection('comments').add({
       'text': _ctrl.text.trim(),
       'userId': user.uid,
       'userName': user.email?.split('@')[0] ?? 'Kullanıcı',
       'userContribution': count,
       'timestamp': FieldValue.serverTimestamp(),
    });
    
    // Increment local contribution
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
       'contributionCount': FieldValue.increment(1)
    }, SetOptions(merge: true));

    _ctrl.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _delete(String commentId) async {
     await FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId).collection('comments').doc(commentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Yorumlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId).collection('comments').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
               if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
               final docs = snapshot.data!.docs;
               if (docs.isEmpty) return const Text('Henüz yorum yok. İlk yorumu sen yap!');

               return ListView.separated(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: docs.length,
                 separatorBuilder: (_,__) => const Divider(),
                 itemBuilder: (context, index) {
                   final data = docs[index].data() as Map<String, dynamic>;
                   final isMe = user != null && data['userId'] == user.uid;
                   final contribution = data['userContribution'] ?? 0;
                   final isVerified = contribution > 10;

                   return ListTile(
                     contentPadding: EdgeInsets.zero,
                     leading: CircleAvatar(child: Text(((data['userName'] as String?) ?? 'A')[0].toUpperCase())),
                     title: Row(
                       children: [
                         Text(data['userName'] ?? 'Anonim', style: const TextStyle(fontWeight: FontWeight.bold)),
                         if (isVerified) ...[
                           const SizedBox(width: 4),
                           const Icon(Icons.verified, size: 16, color: Colors.blue, semanticLabel: 'Onaylı Şef'),
                         ]
                       ],
                     ),
                     subtitle: Text(data['text'] ?? ''),
                     trailing: isMe 
                       ? IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () => _delete(docs[index].id))
                       : null,
                   );
                 },
               );
            },
          ),
          
          const SizedBox(height: 20),
          if (user != null)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Yorum yaz...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.green), onPressed: _post),
              ],
            )
          else
             const Text('Yorum yapmak için giriş yapınız.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
