// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_clerk/otel_clerk.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_clerk-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('emits CLIENT span with clerk.* attrs + user.id propagation', () async {
    await tracedClerk<Map<String, String>>(
      operation: 'signIn',
      strategy: 'password',
      email: 'ada@example.com',
      organizationId: 'org_42',
      invoke: () async => {'userId': 'user_42', 'sessionId': 'sess_99'},
      onSuccessUserId: (r) => r['userId'],
      onSuccessSessionId: (r) => r['sessionId'],
    );
    final span = spans.findSpanByName('clerk signIn');
    expect(span, isNotNull);
    expect(span!.kind, SpanKind.client);
    final a = attrsOf(span);
    expect(a['clerk.operation'], 'signIn');
    expect(a['clerk.strategy'], 'password');
    expect(a['clerk.organization_id'], 'org_42');
    expect(a['user.email'], 'ada@example.com');
    expect(a['user.id'], 'user_42');
    expect(a['clerk.session_id'], 'sess_99');
  });

  test('records exception on throw', () async {
    await expectLater(
      tracedClerk<String>(
        operation: 'signIn',
        invoke: () async => throw StateError('clerk_session_not_found'),
      ),
      throwsA(isA<StateError>()),
    );
    final span = spans.findSpanByName('clerk signIn');
    expect(span!.status, SpanStatusCode.Error);
    expect(attrsOf(span)['error.type'], 'StateError');
  });

  test('signOut / createSession get distinct span names', () async {
    await tracedClerk<String>(
      operation: 'signOut',
      invoke: () async => 'ok',
    );
    await tracedClerk<String>(
      operation: 'createSession',
      invoke: () async => 'ok',
    );
    expect(spans.findSpanByName('clerk signOut'), isNotNull);
    expect(spans.findSpanByName('clerk createSession'), isNotNull);
  });

  test('suppression skips the span', () async {
    await runWithoutClerkInstrumentationAsync(() async {
      await tracedClerk<String>(
        operation: 'signIn',
        invoke: () async => 'ok',
      );
    });
    expect(spans.findSpansStartingWith('clerk '), isEmpty);
  });
}
