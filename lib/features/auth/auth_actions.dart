import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: SakuColors.blue300,
          disabledBackgroundColor: SakuColors.neutral300,
          foregroundColor: SakuColors.white,
          disabledForegroundColor: SakuColors.neutral600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: SakuColors.neutral50,
          foregroundColor: SakuColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleBadge(),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthDividerLabel extends StatelessWidget {
  const AuthDividerLabel({super.key, this.label = 'Atau'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: SakuColors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 5,
            top: 1,
            child: Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 3,
            child: CircleAvatar(
              radius: 3,
              backgroundColor: Color(0xFF34A853),
            ),
          ),
          Positioned(
            right: 3,
            top: 4,
            child: CircleAvatar(
              radius: 3,
              backgroundColor: Color(0xFFEA4335),
            ),
          ),
          Positioned(
            left: 3,
            bottom: 3,
            child: CircleAvatar(
              radius: 3,
              backgroundColor: Color(0xFFFBBC05),
            ),
          ),
        ],
      ),
    );
  }
}
