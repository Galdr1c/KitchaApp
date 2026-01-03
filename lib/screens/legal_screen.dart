import 'package:flutter/material.dart';

/// Screen for displaying legal documents (Privacy Policy, Terms of Service).
class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({
    super.key,
    required this.title,
    required this.content,
  });

  /// Factory for Privacy Policy screen.
  factory LegalScreen.privacyPolicy() {
    return const LegalScreen(
      title: 'Gizlilik Politikası',
      content: _privacyPolicyContent,
    );
  }

  /// Factory for Terms of Service screen.
  factory LegalScreen.termsOfService() {
    return const LegalScreen(
      title: 'Kullanım Koşulları',
      content: _termsOfServiceContent,
    );
  }

  static const String _privacyPolicyContent = '''
KITCHA GİZLİLİK POLİTİKASI

Son Güncelleme: 3 Ocak 2026

1. TOPLANAN BİLGİLER
   • E-posta adresi (giriş yaparsanız)
   • Tarif görüntülemeleri ve favoriler
   • Kalori hesaplamaları
   • Cihaz bilgileri
   • Analitik veriler (Firebase üzerinden)

2. BİLGİLERİNİZİ NASIL KULLANIYORUZ
   • Uygulama işlevselliğini sağlamak
   • Kullanıcı deneyimini geliştirmek
   • Bildirim göndermek (izin verildiyse)
   • İçeriği kişiselleştirmek

3. ÜÇÜNCÜ TARAF HİZMETLER
   • Firebase (Analitik, Kimlik Doğrulama, Firestore)
   • Google AdMob (Reklamcılık)
   • RevenueCat (Ödeme işlemleri)

4. VERİ SAKLAMA
   • Hesap verileri: Hesabınızı silene kadar
   • Analitik veriler: 14 ay (Firebase varsayılanı)
   • Önbellek verileri: Sona erene kadar (7-30 gün)

5. HAKLARINIZ (KVKK/GDPR)
   • Verilerinize erişim
   • Verilerinizi dışa aktarma
   • Verilerinizi silme
   • Pazarlamadan çıkma

6. ÇOCUKLARIN GİZLİLİĞİ
   • Uygulamamız 13 yaş altındaki çocuklara yönelik değildir
   • Çocuklardan bilerek veri toplamıyoruz

7. İLETİŞİM
   E-posta: support@kitcha.app
   Web sitesi: www.kitcha.app/privacy
''';

  static const String _termsOfServiceContent = '''
KITCHA KULLANIM KOŞULLARI

Son Güncelleme: 3 Ocak 2026

1. KABUL
   Kitcha uygulamasını kullanarak bu koşulları kabul etmiş olursunuz.

2. HİZMET TANIMI
   Kitcha, tarif arama, kalori hesaplama ve beslenme takibi özellikleri sunan bir mobil uygulamadır.

3. KULLANICI HESABI
   • Hesap bilgilerinizin güvenliğinden siz sorumlusunuz
   • Hesabınızı başkalarıyla paylaşmayın
   • Hesabınızda yapılan tüm işlemlerden siz sorumlusunuz

4. ABONELİK VE ÖDEME
   • Aylık abonelikler otomatik olarak yenilenir
   • İptal etmek için dönem bitiminden 24 saat önce işlem yapmalısınız
   • Ömür boyu lisanslar tek seferlik ödemedir
   • İadeler App Store/Play Store politikalarına tabidir

5. İÇERİK KULLANIMI
   • Tarifler bilgilendirme amaçlıdır
   • Sağlık tavsiyesi değildir
   • Alerji ve beslenme ihtiyaçlarınızı göz önünde bulundurun

6. YASAKLI DAVRANIŞLAR
   • Uygulamayı kötüye kullanma
   • Başka kullanıcılara zarar verme
   • Sistemleri hackleme veya tersine mühendislik

7. SORUMLULUK REDDİ
   • Kalori hesaplamaları tahminidir
   • Tıbbi tavsiye yerine geçmez
   • Uygulama "olduğu gibi" sunulmaktadır

8. HİZMET DEĞİŞİKLİKLERİ
   • İstediğimiz zaman hizmeti değiştirme hakkımız saklıdır
   • Önemli değişiklikler için bildirim yapılacaktır

9. İLETİŞİM
   Sorularınız için: support@kitcha.app
''';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
