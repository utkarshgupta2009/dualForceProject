import 'package:flutter/material.dart';
import 'package:dual_force/res/app_colors.dart';
import 'package:dual_force/res/app_text_style.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatCard extends StatelessWidget {
  final String botName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final IconData botIcon;
  final Color iconColor;
  final VoidCallback onTap;

  const ChatCard({
    Key? key,
    required this.botName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.botIcon,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.themeColors2[0],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.2),
              child: Icon(
                botIcon,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          botName,
                          style: AppTextStyle.titleSmallTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeago.format(lastMessageTime),
                        style: AppTextStyle.subtitleTextStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: AppTextStyle.subtitleTextStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

