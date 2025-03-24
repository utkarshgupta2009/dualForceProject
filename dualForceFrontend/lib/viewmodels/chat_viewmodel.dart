import 'dart:developer';

import 'package:dual_force/data/response/api_response.dart';
import 'package:dual_force/models/message.dart';
import 'package:dual_force/repository/chat_repository.dart';
import 'package:dual_force/utils/toast_message.dart';

import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  final List<Message> _messages = [];
  final TextEditingController userQueryController = TextEditingController();
  bool _isLoading = false;
  final ChatRepository _chatRepository = ChatRepository();
  int? _editingIndex;
  final TextEditingController editingController = TextEditingController();

  List<Message> get messages => _messages.reversed.toList();
  bool get isLoading => _isLoading;

  void clearMessageList() {
    _messages.clear();
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> sendMessage(String query, String experSystemId) async {
    if (query.trim().isEmpty) return;

  

    // Set loading state
    setLoading(true);
    print(_isLoading);
    final userMessage = Message(
      user: true,
      content: query,
    );
    _messages.add(userMessage);

    try {
      _chatRepository
          .sendMessage(
              expertSystemId: experSystemId,
              query: query,
              conversationMessages: _messages)
          .then((val) {
        if (val.status == Status.ERROR) {
          ToastUtils.showErrorToast("Error occured: ${val.message}");
          setLoading(false);
          return;
        }

        _messages.add(Message(user: false, content: val.data['response']));
        notifyListeners();
      });

      setLoading(false);
    } catch (e) {
      log(e.toString());
      // Handle error

      ToastUtils.showErrorToast("An error occured");
      setLoading(false);
    }
  }

  void selectMessage(int index) {
    _editingIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    userQueryController.dispose();
    editingController.dispose();
    super.dispose();
  }
}
