/// Resolves `{{ t(key) }}` and `{{ meta(path) }}` template literals
/// embedded in server-returned component labels and placeholders.
///
/// `{{ t(signin:forms.credentials.title) }}` is resolved via the i18n
/// translations returned by GET /flow/meta. Colon-separated namespaces
/// map to the first path segment in the translations map.
///
/// `{{ meta(application.name) }}` is resolved via a dot-path lookup on
/// the FlowMeta map returned by GET /flow/meta.
///
/// Any unrecognised expression is left unchanged.
class FlowTemplateResolver {
  static final RegExp _regex = RegExp(r'\{\{\s*(.*?)\s*\}\}');

  final Map<String, dynamic> _meta;

  const FlowTemplateResolver(this._meta);

  String resolve(String? text) {
    if (text == null || text.isEmpty) return '';
    if (!text.contains('{{')) return text;
    return text.replaceAllMapped(_regex, _replace);
  }

  String _replace(Match match) {
    final content = match.group(1)?.trim() ?? '';

    if (content.startsWith('t(') && content.endsWith(')')) {
      return _resolveTranslation(content.substring(2, content.length - 1));
    }

    if (content.startsWith('meta(') && content.endsWith(')')) {
      return _resolveMeta(content.substring(5, content.length - 1));
    }

    return match.group(0)!;
  }

  String _resolveTranslation(String key) {
    // key: "signin:forms.credentials.title" → namespace="signin", dotKey="forms.credentials.title"
    final colonIdx = key.indexOf(':');
    if (colonIdx == -1) return '';

    final namespace = key.substring(0, colonIdx);
    final dotKey = key.substring(colonIdx + 1);

    final translations = (_meta['i18n'] as Map?)?['translations'];
    if (translations is! Map) return '';

    final nsMap = translations[namespace];
    if (nsMap is! Map) return '';

    final value = nsMap[dotKey];
    return value is String ? value : '';
  }

  String _resolveMeta(String path) {
    // path: "application.logoUrl" → dot-path lookup on _meta
    dynamic current = _meta;
    for (final part in path.split('.')) {
      if (current is Map) {
        current = current[part];
      } else {
        return '';
      }
    }
    return current is String ? current : (current?.toString() ?? '');
  }
}
