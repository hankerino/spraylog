import 'package:flutter_test/flutter_test.dart';
import 'package:spraylog/core/sync/outbox_service.dart';

void main() {
  test('backoff doubles from 5s base', () {
    expect(OutboxService.backoffFor(0), const Duration(seconds: 5));
    expect(OutboxService.backoffFor(1), const Duration(seconds: 10));
    expect(OutboxService.backoffFor(2), const Duration(seconds: 20));
    expect(OutboxService.backoffFor(3), const Duration(seconds: 40));
  });

  test('backoff is capped at 900s', () {
    expect(OutboxService.backoffFor(8), const Duration(seconds: 900));
    expect(OutboxService.backoffFor(20), const Duration(seconds: 900));
    expect(OutboxService.backoffFor(100), const Duration(seconds: 900));
  });
}
