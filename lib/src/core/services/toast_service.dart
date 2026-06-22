import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class ToastService {
  ToastService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static OverlayState? get _overlay => navigatorKey.currentState?.overlay;

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void success(String message) {
    _show(message: message, background: AppColors.success);
  }

  static void error(String message) {
    _show(message: message, background: AppColors.danger);
  }

  static void info(String message) {
    _show(message: message, background: AppColors.textPrimary);
  }

  static void _show({
    required String message,
    required Color background,
  }) {
    final overlay = _overlay;
    if (overlay == null) return;

    _timer?.cancel();
    _entry?.remove();

    _entry = OverlayEntry(
      builder: (context) {
        final bottomInset = MediaQuery.of(context).padding.bottom;
        return Positioned(
          left: 12,
          right: 12,
          bottom: 12 + bottomInset + 72,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);
    _timer = Timer(const Duration(seconds: 3), () {
      _entry?.remove();
      _entry = null;
    });
  }
}

