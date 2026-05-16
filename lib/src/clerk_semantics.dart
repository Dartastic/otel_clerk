// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

/// Attribute keys for the Clerk → OTel bridge.
///
/// User identity uses the OTel `user.*` semconv directly. The
/// `clerk.*` keys cover Clerk-specific concepts (strategy, session
/// id, organization id).
enum ClerkBridgeSemantics implements OTelSemantic {
  /// `clerk.operation` — `signIn`, `signUp`, `signOut`,
  /// `createSession`, `verifyToken`, `getSessionList`, etc.
  operation('clerk.operation'),

  /// `clerk.strategy` — sign-in strategy: `password`,
  /// `email_code`, `phone_code`, `oauth_google`, `oauth_github`,
  /// `saml`, `web3`, etc.
  strategy('clerk.strategy'),

  /// `clerk.session_id` — Clerk session identifier (`sess_xxx`).
  sessionId('clerk.session_id'),

  /// `clerk.organization_id` — active organization (`org_xxx`).
  organizationId('clerk.organization_id');

  const ClerkBridgeSemantics(this.key);

  @override
  final String key;

  @override
  String toString() => key;
}
