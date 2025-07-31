import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/notification/notificationController.dart';
import '../constants/contants.dart';

class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final double? size;
  final Color? badgeColor;
  final Color? textColor;

  const NotificationBadge({
    Key? key,
    this.onTap,
    this.size = 24,
    this.badgeColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: onTap ??
              () {
                // Navigate to notifications page
                Navigator.pushNamed(context, '/notifications');
              },
          child: Stack(
            children: [
              Icon(
                Icons.notifications,
                size: size,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
              if (controller.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      controller.unreadCount > 99
                          ? '99+'
                          : controller.unreadCount.toString(),
                      style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationBadgeWithLoading extends StatelessWidget {
  final VoidCallback? onTap;
  final double? size;
  final Color? badgeColor;
  final Color? textColor;

  const NotificationBadgeWithLoading({
    Key? key,
    this.onTap,
    this.size = 24,
    this.badgeColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: onTap ??
              () {
                // Navigate to notifications page
                Navigator.pushNamed(context, '/notifications');
              },
          child: Stack(
            children: [
              Icon(
                Icons.notifications,
                size: size,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
              if (controller.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      controller.unreadCount > 99
                          ? '99+'
                          : controller.unreadCount.toString(),
                      style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
