import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd(context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  Widget _buildImage(IconData icon, Color color) {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 100,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0, 
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppTheme.backgroundDark,
      ),
      bodyTextStyle: const TextStyle(fontSize: 18.0),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Theme.of(context).scaffoldBackgroundColor,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      allowImplicitScrolling: true,
      pages: [
        PageViewModel(
          title: "Kitcha'ya Hoş Geldin",
          body: "Mutfakta en zeki yardımcın. Yemeklerini tanı, tarifler bul ve beslenmeni yönet.",
          image: _buildImage(Icons.restaurant, AppTheme.primaryColor),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Multi-Model Yapay Zeka",
          body: "GPT-4, Claude ve yerel modeller ile yemeklerini en ince ayrıntısına kadar analiz ediyoruz.",
          image: _buildImage(Icons.auto_awesome, AppTheme.accentAI),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Seni Öğrenen Mutfak",
          body: "Zamanla damak tadını ve alışkanlıklarını öğrenerek sana en uygun önerileri sunar.",
          image: _buildImage(Icons.psychology, Colors.purple),
          footer: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton(
              onPressed: () async {
                await [
                  Permission.camera,
                  Permission.notification,
                ].request();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("İzinleri Ayarla"),
            ),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text('Atla', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Başla', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: isDark ? Colors.white24 : Colors.grey.shade300,
        activeSize: const Size(22.0, 10.0),
        activeColor: AppTheme.primaryColor,
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
