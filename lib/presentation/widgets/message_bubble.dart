import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/message_model.dart';

/// Message bubble widget for chat
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: isSender ? AppColors.primaryGradient : null,
          color: isSender
              ? null
              : (isDark ? AppColors.receiverBubbleDark : AppColors.receiverBubbleLight),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isSender ? 18 : 4),
            bottomRight: Radius.circular(isSender ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isSender
                    ? AppColors.white
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatBubbleTime(message.timestamp),
              style: TextStyle(
                color: isSender
                    ? AppColors.white.withOpacity(0.7)
                    : AppColors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
