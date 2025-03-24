import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dual_force/res/app_colors.dart';
import 'package:dual_force/res/app_text_style.dart';

class MessageCard extends StatelessWidget {
  final String text;
  final bool isUser;
  final VoidCallback onSelect;
  final VoidCallback? onRetry;

  const MessageCard({
    Key? key,
    required this.text,
    required this.isUser,
    required this.onSelect,
     this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onLongPressStart: (details) => _showMessageOptions(context, details.globalPosition),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.75, // Limits width to 80% of screen
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUser ? AppColors.themeColors1[2] : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(text, style: TextStyle(color: isUser ? Colors.white : Colors.black)),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, Offset tapPosition) {
    final screenSize = MediaQuery.of(context).size;
    final adjustedY = tapPosition.dy > screenSize.height - 100 ? tapPosition.dy - 100 : tapPosition.dy+10;

    showMenu(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      
      context: context,
      position: RelativeRect.fromLTRB(tapPosition.dx, adjustedY, screenSize.width - tapPosition.dx, 0),
      items: [
         PopupMenuItem(
          value: 'Select',
          onTap: onSelect,
          child: Text('Select',
                        style: AppTextStyle.mediumTextStyleDark,),
        ),
        PopupMenuItem(
          value: 'Copy',
          child: Text('Copy',
                        style: AppTextStyle.mediumTextStyleDark,),
          onTap: () {
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied to clipboard")));
          },
        ),
        if(onRetry!=null) PopupMenuItem(
          value: 'Retry Message',
          onTap: onRetry,
          child: Text('Retry Message',
                        style: AppTextStyle.mediumTextStyleDark,),
        ),
       
      ],
    );
  }
}
