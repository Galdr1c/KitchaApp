import 'package:flutter/material.dart';

/// Theme color for the app.
const Color kThemeColor = Color(0xFFFF6347);

/// Twitter-style verified badge for premium users.
class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool isLifetime;

  const VerifiedBadge({
    super.key,
    this.size = 20,
    this.isLifetime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isLifetime ? const Color(0xFFFFD700) : kThemeColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.7,
      ),
    );
  }
}

/// Inline verified badge with text (for lists/cards).
class VerifiedBadgeInline extends StatelessWidget {
  final bool isLifetime;

  const VerifiedBadgeInline({super.key, this.isLifetime = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VerifiedBadge(size: 16, isLifetime: isLifetime),
        const SizedBox(width: 4),
        Text(
          isLifetime ? 'Lifetime' : 'Premium',
          style: TextStyle(
            color: isLifetime ? const Color(0xFFFFD700) : kThemeColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Username with verified badge (like Twitter).
class VerifiedUsername extends StatelessWidget {
  final String username;
  final bool isPremium;
  final bool isLifetime;
  final double fontSize;
  final FontWeight fontWeight;

  const VerifiedUsername({
    super.key,
    required this.username,
    this.isPremium = false,
    this.isLifetime = false,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          username,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
        if (isPremium || isLifetime) ...[
          const SizedBox(width: 6),
          VerifiedBadge(size: fontSize * 0.9, isLifetime: isLifetime),
        ],
      ],
    );
  }
}

/// Premium recipe lock overlay.
class PremiumRecipeLock extends StatelessWidget {
  final VoidCallback? onTap;

  const PremiumRecipeLock({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kThemeColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 12),
              const Text(
                'Premium Tarif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kilidi açmak için tıklayın',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// User avatar with verified badge.
class VerifiedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String displayName;
  final double radius;
  final bool isPremium;
  final bool isLifetime;

  const VerifiedAvatar({
    super.key,
    this.imageUrl,
    required this.displayName,
    this.radius = 24,
    this.isPremium = false,
    this.isLifetime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: kThemeColor.withOpacity(0.2),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: radius * 0.8,
                    fontWeight: FontWeight.bold,
                    color: kThemeColor,
                  ),
                )
              : null,
        ),
        if (isPremium || isLifetime)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: VerifiedBadge(
                isLifetime: isLifetime,
                size: radius * 0.45,
              ),
            ),
          ),
      ],
    );
  }
}

// Backward compatibility aliases
typedef PremiumBadge = VerifiedBadge;
typedef PremiumBadgeInline = VerifiedBadgeInline;
typedef PremiumAvatar = VerifiedAvatar;
