class StackItemModel {
  final OpenState openState;
  final ClosedState closedState;
  final String ctaText;
  bool isExpanded;

  StackItemModel({
    required this.openState,
    required this.closedState,
    required this.ctaText,
    this.isExpanded = false,
  });

  factory StackItemModel.fromJson(Map<String, dynamic> json) {
    return StackItemModel(
      openState: OpenState.fromJson(json['open_state']),
      closedState: ClosedState.fromJson(json['closed_state']),
      ctaText: json['cta_text'],
    );
  }
}

class OpenState {
  final OpenStateBody body;

  OpenState({required this.body});

  factory OpenState.fromJson(Map<String, dynamic> json) {
    return OpenState(
      body: OpenStateBody.fromJson(json['body']),
    );
  }
}

class OpenStateBody {
  final String? title;
  final String? subtitle;

  OpenStateBody({
    this.title,
    this.subtitle,
  });

  factory OpenStateBody.fromJson(Map<String, dynamic> json) {
    return OpenStateBody(
      title: json['title'],
      subtitle: json['subtitle'],
    );
  }
}

class ClosedState {
  final String? title;
  final String? subtitle;

  ClosedState({required this.title,required this.subtitle});

  factory ClosedState.fromJson(Map<String, dynamic> json) {
    return ClosedState(
       title: json['title'],
      subtitle: json['subtitle'],
    );
  }
}
