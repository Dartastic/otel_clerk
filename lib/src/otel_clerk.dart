// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'clerk_semantics.dart';
import 'otel_clerk_suppression.dart';

const _tracerName = 'dartastic_otel_libs_clerk';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

/// Wraps a Clerk Authentication call in a CLIENT span.
///
/// Works with `clerk_flutter`, raw HTTP, or any Clerk SDK — pass your
/// call inside [invoke]. Span name `clerk <operation>` (e.g.
/// `clerk signIn`).
///
/// ```dart
/// final session = await tracedClerk<Session>(
///   operation: 'signIn',
///   strategy: 'password',
///   email: email,
///   invoke: () => clerk.signIn.create(
///     identifier: email,
///     password: password,
///   ),
///   onSuccessUserId: (s) => s.userId,
///   onSuccessSessionId: (s) => s.id,
/// );
/// ```
Future<T> tracedClerk<T>({
  required String operation,
  required Future<T> Function() invoke,
  String? strategy,
  String? email,
  String? userId,
  String? sessionId,
  String? organizationId,
  String? Function(T)? onSuccessUserId,
  String? Function(T)? onSuccessSessionId,
}) async {
  if (clerkInstrumentationSuppressed()) return invoke();

  final m = <String, Object>{
    ClerkBridgeSemantics.operation.key: operation,
  };
  if (strategy != null) m[ClerkBridgeSemantics.strategy.key] = strategy;
  if (email != null) m[User.userEmail.key] = email;
  if (userId != null) m[User.userId.key] = userId;
  if (sessionId != null) m[ClerkBridgeSemantics.sessionId.key] = sessionId;
  if (organizationId != null) {
    m[ClerkBridgeSemantics.organizationId.key] = organizationId;
  }

  final span = _tracer().startSpan(
    'clerk $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final result = await invoke();
    final extra = <Attribute<Object>>[];
    final uid = onSuccessUserId?.call(result);
    if (uid != null) {
      extra.add(OTel.attributeString(User.userId.key, uid));
    }
    final sid = onSuccessSessionId?.call(result);
    if (sid != null) {
      extra.add(OTel.attributeString(ClerkBridgeSemantics.sessionId.key, sid));
    }
    if (extra.isNotEmpty) span.addAttributes(OTel.attributes(extra));
    return result;
  } catch (e, st) {
    span.addAttributes(
      OTel.attributes([
        OTel.attributeString(
          ErrorResource.errorType.key,
          e.runtimeType.toString(),
        ),
      ]),
    );
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
