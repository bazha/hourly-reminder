import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/notification_service.dart';

class TestNotificationButton extends StatelessWidget {
  const TestNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ElevatedButton.icon(
      onPressed: () async {
        await NotificationService.showHourlyNotification();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Тестовое уведомление отправлено'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.startColor,
            ),
          );
        }
      },
      icon: const Icon(Icons.notifications_outlined, size: 20),
      label: const Text('Тест уведомления'),
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.appBarFg,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 1,
      ),
    );
  }
}
