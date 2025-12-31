import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NutritionDashboard extends StatelessWidget {
  const NutritionDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Giriş yapmalısınız'));

    final today = DateTime.now().toIso8601String().split('T')[0];

    return Scaffold(
      appBar: AppBar(title: const Text('Beslenme Paneli')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('analyses')
            .where('date', isEqualTo: today)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          double totalAccCalories = 0;
          double totalProtein = 0;
          double totalCarbs = 0;
          double totalFat = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalAccCalories += (data['calories'] ?? 0);
            totalProtein += (data['protein'] ?? 0);
            totalCarbs += (data['carbs'] ?? 0);
            totalFat += (data['fat'] ?? 0);
          }

          final pCal = totalProtein * 4;
          final cCal = totalCarbs * 4;
          final fCal = totalFat * 9;
          final totalMacroCal = pCal + cCal + fCal;

          if (totalMacroCal <= 0) {
             return const Center(child: Text('Bugün henüz yemek girmediniz.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Günlük Makro Dağılımı', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(color: Colors.blue, value: pCal, title: '${(pCal/totalMacroCal*100).round()}%', radius: 60, showTitle: true),
                        PieChartSectionData(color: Colors.green, value: cCal, title: '${(cCal/totalMacroCal*100).round()}%', radius: 60, showTitle: true),
                        PieChartSectionData(color: Colors.red, value: fCal, title: '${(fCal/totalMacroCal*100).round()}%', radius: 60, showTitle: true),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text('Toplam: ${totalAccCalories.round()} kcal', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                     _macroCard('Protein', '${totalProtein.round()}g', Colors.blue),
                     _macroCard('Karb', '${totalCarbs.round()}g', Colors.green),
                     _macroCard('Yağ', '${totalFat.round()}g', Colors.red),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 12, height: 12, color: Colors.blue), const Text(' Prot '),
                    Container(width: 12, height: 12, color: Colors.green), const Text(' Karb '),
                    Container(width: 12, height: 12, color: Colors.red), const Text(' Yağ '),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _macroCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
