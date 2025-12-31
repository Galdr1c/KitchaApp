import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class FeedbackHandler {
  static final FeedbackHandler _instance = FeedbackHandler._internal();
  factory FeedbackHandler() => _instance;
  FeedbackHandler._internal();

  /// Trigger light haptic feedback
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Trigger medium haptic feedback
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Trigger success haptic feedback
  static void success() {
    HapticFeedback.vibrate();
  }

  /// Show a success Lottie overlay
  static void showSuccessDialog(BuildContext context, {String message = 'İşlem Başarılı!'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Lottie.network(
                      'https://assets9.lottiefiles.com/packages/lf20_kq5r8mw7.json',
                      width: 150,
                      height: 150,
                      repeat: false,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build a confetti widget for celebrations
  static Widget buildConfetti(ConfettiController controller) {
    return ConfettiWidget(
      confettiController: controller,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      colors: const [
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.orange,
        Colors.purple
      ],
    );
  }
}
