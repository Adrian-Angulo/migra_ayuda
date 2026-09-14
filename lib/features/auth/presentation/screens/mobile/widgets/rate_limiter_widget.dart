import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/login_rate_limiter_provider.dart';

class RateLimiterWidget extends StatelessWidget {
  const RateLimiterWidget({
    super.key,
    required this.rateLimiter,
  });

  final RateLimiterState rateLimiter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, color: Colors.red.shade700, size: 18),
          const SizedBox(width: 8),
          Text(
            'Demasiados intentos. Espera ${rateLimiter.cooldownSeconds}s',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
