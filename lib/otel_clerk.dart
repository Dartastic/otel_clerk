// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

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
