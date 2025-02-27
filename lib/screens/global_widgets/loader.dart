import 'package:flutter/material.dart';
import 'package:t_wear/core/utils/get_theme_state.dart';

class AppWideLoading extends StatelessWidget {
  final String message;
  const AppWideLoading({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    final themeMode = getThemeMode(context);
    return Container(
      color: themeMode.backgroundColor?.withValues(alpha:0.8), 
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    themeMode.primTextColor?.withValues(alpha:0.3) ?? Colors.red,
                    themeMode.primTextColor?.withValues(alpha:0.1) ?? Colors.red,
                    Colors.transparent,
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 6.0,
              ),
            ),
            const SizedBox(height: 20),

            
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeMode.primTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
