import '../models/user_data.dart';

/// ------------------------------------------------------------------------
/// 1) Minimal-payload vCard generator for QR:
///
///    Only includes:
///      • Full Name       (FN + N)
///      • All phoneNumbers
///      • All emails
///      • Job Title
///      • Organisation
///
///    This keeps the QR-string ≤ ~300 chars so scanners won't fail.
/// ------------------------------------------------------------------------
String generateMinimalVCardFromUserData(UserData data) {
  final buffer = StringBuffer();

  buffer.writeln('BEGIN:VCARD');
  buffer.writeln('VERSION:3.0');

  // 1. Name (N and FN)
  final name = data.name?.trim();
  final displayName = (name != null && name.isNotEmpty)
      ? name
      : (data.username);

  final parts = displayName.split(' ');
  if (parts.length >= 2) {
    final family = parts.removeLast();
    final given = parts.join(' ');
    buffer.writeln('N:$family;$given');
  } else {
    buffer.writeln('N:$displayName;$displayName');
  }
  buffer.writeln('FN:${_escapeValue(displayName)}');

  // 2. Organisation & Job Title
  if (data.organisation != null && data.organisation!.trim().isNotEmpty) {
    buffer.writeln('ORG:${_escapeValue(data.organisation!)}');
  }
  if (data.jobTitle != null && data.jobTitle!.trim().isNotEmpty) {
    buffer.writeln('TITLE:${_escapeValue(data.jobTitle!)}');
  }

  // 3. Phone Numbers (all of them, each as TYPE=CELL)
  for (final phone in data.phoneNumbers ?? <String>[]) {
    final p = phone.trim();
    if (p.isNotEmpty) {
      buffer.writeln('TEL;TYPE=CELL:${_escapeValue(p)}');
    }
  }

  // 4. Emails (all of them)
  for (final email in data.emails ?? <String>[]) {
    final e = email.trim();
    if (e.isNotEmpty) {
      buffer.writeln('EMAIL:${_escapeValue(e)}');
    }
  }

  buffer.writeln('END:VCARD');
  return buffer.toString();
}

/// ------------------------------------------------------------------------
/// 2) Utility: Escape special characters in vCard values.
/// ------------------------------------------------------------------------
String _escapeValue(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('\n', r'\n')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,');
}
