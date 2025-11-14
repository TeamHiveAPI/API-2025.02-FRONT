import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EmailService {
  EmailService._();
  static final EmailService instance = EmailService._();
  final _client = Supabase.instance.client;

  String _defaultRedirect() {
    // Em dev web: http://localhost:62183/reset-password
    final origin = Uri.base.origin;
    return '$origin/reset-password';
  }

  Future<void> sendPasswordReset({required String email, String? redirectTo}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo ?? _defaultRedirect(),
    );
  }

  Future<void> enqueueNotificationEmail({
    required String toEmail,
    required String templateKey,
    Map<String, dynamic> payload = const {},
    DateTime? scheduleAt,
  }) async {
    final insertPayload = {
      'to_email': toEmail,
      'template_key': templateKey,
      'payload': payload,
      'schedule_at': (scheduleAt ?? DateTime.now()).toUtc().toIso8601String(),
    };
    await _client.from('email_queue').insert(insertPayload);
  }
}