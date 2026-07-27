class OutboxItemModel {
  const OutboxItemModel({
    required this.id,
    required this.entity,
    required this.operation,
    required this.payload,
    required this.attempts,
    required this.nextAttemptAt,
  });

  final String id;
  final String entity;
  final String operation;
  final String payload;
  final int attempts;
  final DateTime nextAttemptAt;
}

