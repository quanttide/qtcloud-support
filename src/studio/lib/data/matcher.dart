import 'models.dart';

/// 第一级自动应答的检索匹配（实验室原型逻辑的 Dart 移植）。
/// 原则：升级是安全方向——宁可转人工，不乱答。
class AnswerResult {
  const AnswerResult.hit(this.solution)
      : escalatedReason = null,
        noHit = false;
  const AnswerResult.escalated(this.solution, this.escalatedReason)
      : noHit = false;
  const AnswerResult.noHit()
      : solution = null,
        escalatedReason = null,
        noHit = true;

  final Solution? solution;
  final String? escalatedReason;
  final bool noHit;

  bool get isHit => solution != null && escalatedReason == null && !noHit;
}

final RegExp _splitRe = RegExp(r'[\s，。？、,.?!：:；;（）()【】\[\]“”‘’\-—/]+');

List<String> _splitWords(String q) => q
    .toLowerCase()
    .split(_splitRe)
    .where((w) => w.length >= 2)
    .toList();

int _score(String q, Solution s) {
  final ql = q.toLowerCase();
  var sc = 0;
  final body =
      (s.title + s.scene + s.answer + s.escalate.join(' ') + s.trigger.join(' '))
          .toLowerCase();
  for (final k in s.trigger) {
    if (ql.contains(k.toLowerCase())) sc += 3;
  }
  for (final w in _splitWords(q)) {
    if (body.contains(w)) sc += 1;
  }
  // 子串级匹配：中文长问句不靠分词，靠连续 2-4 字子串命中
  for (var i = 0; i < ql.length - 1; i++) {
    for (var len = 2; len <= 4 && i + len <= ql.length; len++) {
      if (body.contains(ql.substring(i, i + len))) sc += 1;
    }
  }
  return sc;
}

String? _escalateHit(String q, Solution s) {
  final ql = q.toLowerCase();
  for (final k in s.escalate) {
    final kl = k.toLowerCase();
    if (ql.contains(kl)) return k;
    // 宽松：判据短语的任一 2-gram 命中即转人工
    for (var i = 0; i < kl.length - 1; i++) {
      if (ql.contains(kl.substring(i, i + 2))) return k;
    }
  }
  return null;
}

AnswerResult answer(String q, List<Solution> solutions) {
  final ranked = solutions.toList()
    ..sort((a, b) => _score(q, b).compareTo(_score(q, a)));
  if (ranked.isEmpty) return const AnswerResult.noHit();
  final top = ranked.first;
  if (_score(q, top) < 2) return const AnswerResult.noHit();
  final esc = _escalateHit(q, top);
  if (esc != null) return AnswerResult.escalated(top, esc);
  top.reuse += 1;
  return AnswerResult.hit(top);
}
