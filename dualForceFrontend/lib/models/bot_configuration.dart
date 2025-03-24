class BotConfiguration {
  final double temperature;
  final String model;
  final int maxTokens;

  BotConfiguration({
    required this.temperature,
    required this.model,
    required this.maxTokens,
  });

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'model': model,
      'maxTokens': maxTokens,
    };
  }

  factory BotConfiguration.fromMap(Map<String, dynamic> map) {
    return BotConfiguration(
      temperature: map['temperature']?.toDouble() ?? 0.7,
      model: map['model'] ?? 'gpt-3.5-turbo',
      maxTokens: map['maxTokens'] ?? 2000,
    );
  }
}
