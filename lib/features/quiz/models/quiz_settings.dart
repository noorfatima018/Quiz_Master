class QuizSettings {
  final int questionCount;
  final int timePerQuestion; // in seconds
  final bool allowBack;
  final String? topic;
  final String? filePath;

  QuizSettings({
    this.questionCount = 10,
    this.timePerQuestion = 30,
    this.allowBack = true,
    this.topic,
    this.filePath,
  });

  QuizSettings copyWith({
    int? questionCount,
    int? timePerQuestion,
    bool? allowBack,
    String? topic,
    String? filePath,
  }) {
    return QuizSettings(
      questionCount: questionCount ?? this.questionCount,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      allowBack: allowBack ?? this.allowBack,
      topic: topic ?? this.topic,
      filePath: filePath ?? this.filePath,
    );
  }
}
