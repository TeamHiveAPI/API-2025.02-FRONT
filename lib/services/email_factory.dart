import 'package:sistema_almox/services/email_service.dart';

/// Tipos de mensagem de e-mail suportados para dispatch.
enum EmailMessageType { resetPassword, notification }

/// Contrato base para uma mensagem de e-mail fabricada.
abstract class EmailMessage {
  EmailMessageType get type;
}

/// Mensagem de recuperação de senha usando fluxo nativo Supabase Auth.
class ResetPasswordEmail implements EmailMessage {
  final String email;
  final String? redirectTo;
  ResetPasswordEmail({required this.email, this.redirectTo});
  @override
  EmailMessageType get type => EmailMessageType.resetPassword;
}

/// Mensagem de notificação genérica com template.
class NotificationEmail implements EmailMessage {
  final String toEmail;
  final String templateKey;
  final Map<String, dynamic> payload;
  final DateTime? scheduleAt;
  NotificationEmail({
    required this.toEmail,
    required this.templateKey,
    this.payload = const {},
    this.scheduleAt,
  });
  @override
  EmailMessageType get type => EmailMessageType.notification;
}

/// Fábrica de mensagens: centraliza criação de diferentes e-mails.
class EmailFactory {
  /// Cria mensagem de reset.
  static ResetPasswordEmail resetPassword(String email, {String? redirectTo}) {
    return ResetPasswordEmail(email: email, redirectTo: redirectTo);
  }

  /// Notificação simples com dias parametrizados.
  static NotificationEmail prazoDias({
    required String toEmail,
    required int dias,
    DateTime? scheduleAt,
    String templateKey = 'notificacao_prazo',
    String? assunto,
    String? mensagemRaw,
  }) {
    return NotificationEmail(
      toEmail: toEmail,
      templateKey: templateKey,
      scheduleAt: scheduleAt,
      payload: {
        'dias': dias,
        if (assunto != null) 'assunto': assunto,
        if (mensagemRaw != null) 'mensagem_raw': mensagemRaw,
      },
    );
  }
}

/// Helper para enviar uma EmailMessage.
extension EmailMessageDispatch on EmailService {
  Future<void> dispatch(EmailMessage message) async {
    switch (message.type) {
      case EmailMessageType.resetPassword:
        final m = message as ResetPasswordEmail;
        await sendPasswordReset(email: m.email, redirectTo: m.redirectTo);
        break;
      case EmailMessageType.notification:
        final m = message as NotificationEmail;
        await enqueueNotificationEmail(
          toEmail: m.toEmail,
          templateKey: m.templateKey,
          payload: m.payload,
          scheduleAt: m.scheduleAt,
        );
        break;
    }
  }
}
