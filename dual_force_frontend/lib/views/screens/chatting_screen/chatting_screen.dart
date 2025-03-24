import 'package:dual_force/models/expert_system.dart';
import 'package:dual_force/models/message.dart';
import 'package:dual_force/views/widgets/typing_animation.dart';
import 'package:flutter/material.dart';
import 'package:dual_force/res/app_colors.dart';
import 'package:dual_force/res/app_text_style.dart';
import 'package:dual_force/viewmodels/chat_viewmodel.dart';
import 'package:dual_force/views/widgets/app_widgets/custom_textfield.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final ExpertSystem expertSystem;

  ChatScreen({super.key, required this.expertSystem});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<ChatViewModel>(context, listen: false);
      viewModel.clearMessageList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(builder: (context, viewModel, child) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.expertSystem.name,
            style: AppTextStyle.titleTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textColor),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    // Add your edit document logic here
                    break;
                  case 'delete':
                    // Add your delete bot logic here
                    break;
                  case 'details':
                    // Add your view details logic here
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.textColor),
                      SizedBox(width: 8),
                      Text(
                        'Change Document',
                        style: AppTextStyle.mediumTextStyleDark,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.textColor),
                      SizedBox(width: 8),
                      Text(
                        'View Details',
                        style: AppTextStyle.mediumTextStyleDark,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Delete Bot',
                        style: AppTextStyle.mediumTextStyle
                            .copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          forceMaterialTransparency: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textColor,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: // Change this in your ChatScreen build method:
              Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final message = viewModel.messages[index];
                    return MessageCard(
                        message: message,
                        onSelect: () => viewModel.selectMessage(index),
                        onRetry: null);
                  },
                ),
              ),
              // Move the typing indicator here, just before the input
              if (viewModel.isLoading) TypingIndicator(isTyping: true),
              _messageInput(viewModel, context),
            ],
          ),
        ),
      );
    });
  }

  Widget _messageInput(ChatViewModel viewmodel, BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 150,
              ),
              child: CustomTextField(
                hintText: 'ask a query',
                controller: viewmodel.userQueryController,
                maxLines: null,
              ),
            ),
          ),
          SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: AppColors.primaryYellow,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: AppColors.themeColors2[0],
                ),
                onPressed: () {
                  if (viewmodel.userQueryController.text.trim().isNotEmpty) {
                    viewmodel.sendMessage(
                        viewmodel.userQueryController.text.trim(),
                        widget.expertSystem.id);
                    viewmodel.userQueryController.clear();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback onSelect;
  final VoidCallback? onRetry;

  const MessageCard({
    Key? key,
    required this.message,
    required this.onSelect,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primaryYellow
                    : AppColors.themeColors1[1],
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: onSelect,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isUser)
                        Text(
                          message.content,
                          style: AppTextStyle.mediumTextStyle.copyWith(
                            color: AppColors.themeColors2[0],
                          ),
                        )
                      else
                        // Fixed Markdown widget with specific height constraints and proper styling
                        SizedBox(
                          width: double.infinity,
                          child: MarkdownBody(
                            data: message.content,
                            styleSheet: MarkdownStyleSheet(
                              p: AppTextStyle.mediumTextStyleBlack,
                              h1: AppTextStyle.mediumTextStyleBlack.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              h2: AppTextStyle.mediumTextStyleBlack.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              a: AppTextStyle.mediumTextStyle.copyWith(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Text(
                          //   _formatTime(message.timestamp),
                          //   style: AppTextStyle.smallTextStyle.copyWith(
                          //     color: isUser
                          //         ? AppColors.themeColors2[0].withOpacity(0.7)
                          //         : AppColors.textColor.withOpacity(0.7),
                          //   ),
                          // ),
                          if (onRetry != null) ...[
                            SizedBox(width: 8),
                            InkWell(
                              onTap: onRetry,
                              child: Icon(
                                Icons.refresh,
                                size: 16,
                                color: isUser
                                    ? AppColors.themeColors2[0]
                                    : AppColors.textColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // String _formatTime(DateTime time) {
  //   return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  // }
}
