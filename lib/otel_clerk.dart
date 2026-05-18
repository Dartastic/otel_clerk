// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

/// OpenTelemetry instrumentation for Clerk authentication operations.
///
/// Single helper `tracedClerk(...)` wraps any Clerk auth call
/// (`signIn`, `signUp`, `signOut`, `createSession`, `verifyToken`,
/// ...) in a CLIENT span carrying `clerk.*` attributes plus optional
/// `user.id` propagation.
library;

export 'src/clerk_semantics.dart';
export 'src/otel_clerk.dart';
export 'src/otel_clerk_suppression.dart';
