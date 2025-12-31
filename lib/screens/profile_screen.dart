import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _calorieGoalCtrl = TextEditingController(); 
  String? _gender;
  String _goal = 'Koru'; 

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _calorieGoalCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFromFirestore() async {
     setState(() => _isLoading = true);
     final user = FirebaseAuth.instance.currentUser;
     if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
           final data = doc.data()!;
           _ageCtrl.text = (data['age'] ?? '').toString();
           _weightCtrl.text = (data['weight'] ?? '').toString();
           _heightCtrl.text = (data['height'] ?? '').toString();
           if (data['gender'] != null) _gender = data['gender'];
           _goal = data['goal'] ?? 'Koru';
           _calorieGoalCtrl.text = (data['targetCalories'] ?? '').toString();
        }
     }
     setState(() => _isLoading = false);
  }

  int _calculateBMR() {
    final w = int.tryParse(_weightCtrl.text) ?? 0;
    final h = int.tryParse(_heightCtrl.text) ?? 0;
    final a = int.tryParse(_ageCtrl.text) ?? 0;
    if (w == 0 || h == 0 || a == 0) return 2000;

    // Mifflin-St Jeor Formula
    double bmr = (10 * w) + (6.25 * h) - (5 * a);
    bmr += (_gender == 'Kadın') ? -161 : 5;
    
    // Activity multiplier (Assuming Sedentary/Light: 1.2)
    double tdee = bmr * 1.2; 
    
    // Goal adjustment
    if (_goal == 'Kilo Ver') return (tdee - 500).round();
    if (_goal == 'Kilo Al') return (tdee + 500).round();
    return tdee.round();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oturum açın')));
      setState(() => _isLoading = false);
      return;
    }

    final target = _calculateBMR();
    _calorieGoalCtrl.text = target.toString(); 

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
         'age': int.parse(_ageCtrl.text),
         'weight': int.parse(_weightCtrl.text),
         'height': int.parse(_heightCtrl.text),
         'gender': _gender,
         'goal': _goal,
         'targetCalories': target,
         'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil güncellendi. Hedef: $target kcal')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Hedefler')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
             children: [
                _buildField(_ageCtrl, 'Yaş', Icons.calendar_today),
                _buildField(_weightCtrl, 'Kilo (kg)', Icons.monitor_weight),
                _buildField(_heightCtrl, 'Boy (cm)', Icons.height),
                DropdownButtonFormField<String>(
                   value: _gender,
                   decoration: const InputDecoration(labelText: 'Cinsiyet', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                   items: ['Erkek', 'Kadın'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                   onChanged: (v) => setState(() => _gender = v),
                   validator: (v) => v == null ? 'Seçiniz' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                   value: _goal,
                   decoration: const InputDecoration(labelText: 'Hedef', prefixIcon: Icon(Icons.flag), border: OutlineInputBorder()),
                   items: ['Kilo Ver', 'Kilo Al', 'Koru'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                   onChanged: (v) => setState(() => _goal = v!),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                   icon: const Icon(Icons.calculate),
                   label: const Text('Hesapla ve Kaydet'),
                   onPressed: _save,
                   style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
                const SizedBox(height: 24),
                if (_calorieGoalCtrl.text.isNotEmpty) 
                   Card(
                     color: Colors.amber.shade100,
                     child: Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Column(
                         children: [
                           const Text('Önerilen Günlük Kalori', style: TextStyle(fontWeight: FontWeight.bold)),
                           Text('${_calorieGoalCtrl.text} kcal', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                         ],
                       ),
                     ),
                   )
             ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        validator: (v) => v!.isEmpty ? 'Gerekli' : null,
      ),
    );
  }
}
