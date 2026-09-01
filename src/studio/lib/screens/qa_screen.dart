import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../data/matcher.dart';
import '../data/models.dart';

/// 问答台：第一级自动应答。命中 Solution → AI 应答；命中升级判据或未命中 → 转人工。
class QaScreen extends StatefulWidget {
  const QaScreen({super.key, required this.solutions});

  final List<Solution> solutions;

  @override
  State<QaScreen> createState() => _QaScreenState();
}

enum _MsgKind { user, ai, human, sys }

class _Msg {
  const _Msg(this.kind, this.content, {this.extra});

  final _MsgKind kind;
  final String content;
  final String? extra;
}

class _QaScreenState extends State<QaScreen> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [
    const _Msg(
      _MsgKind.sys,
      '当日基线（journal 观察）：全部提问由人工接力应答，AI 参与率 0%。'
      '在这个台子上用真实 Solution 数据验证第一级自动应答。',
    ),
  ];
  int _asked = 0;
  int _ai = 0;
  int _human = 0;

  static const _examples = [
    '代金券怎么用？',
    '课题申请发到哪个邮箱？',
    '怎么了解公司的商务信息？',
    '职级 -2 是什么意思？',
    '链接打不开，说没有权限',
    '想定制合同，批量采购',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask(String raw) {
    final q = raw.trim();
    if (q.isEmpty) return;
    setState(() {
      _asked += 1;
      _messages.add(_Msg(_MsgKind.user, q));
      final r = answer(q, widget.solutions);
      if (r.isHit) {
        _ai += 1;
        final s = r.solution!;
        _messages.add(_Msg(
          _MsgKind.ai,
          s.answer,
          extra: '来源：${s.src} · 命中复用次数 ${s.reuse}',
        ));
      } else if (r.noHit) {
        _human += 1;
        _messages.add(const _Msg(_MsgKind.human, '未命中任何 Solution 条目，等待支持人员应答。'));
      } else {
        _human += 1;
        _messages.add(_Msg(_MsgKind.human, '命中升级判据「${r.escalatedReason}」，等待支持人员应答。'));
        _messages.add(_Msg(_MsgKind.sys, '已引用候选 Solution ${r.solution!.id} 作为人工应答的上下文。'));
      }
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, i) => _Bubble(msg: _messages[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '输入问题，回车提问…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: _ask,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _ask(_controller.text),
                child: const Text('提问'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _examples.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => ActionChip(
              label: Text(_examples[i]),
              onPressed: () => _ask(_examples[i]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _Stat(label: '累计提问', value: '$_asked'),
              const SizedBox(width: 24),
              _Stat(label: 'AI 直接应答', value: '$_ai'),
              const SizedBox(width: 24),
              _Stat(label: '升级人工', value: '$_human'),
              const SizedBox(width: 24),
              _Stat(
                label: '无需人参与比例',
                value: _asked == 0 ? '0%' : '${(_ai / _asked * 100).round()}%',
                highlight: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: highlight ? Colors.green.shade700 : null,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});

  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final align = msg.kind == _MsgKind.user ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    Color? bg;
    Color? fg;
    String? roleTag;
    switch (msg.kind) {
      case _MsgKind.user:
        bg = theme.colorScheme.primary;
        fg = theme.colorScheme.onPrimary;
      case _MsgKind.ai:
        bg = theme.colorScheme.surfaceContainerHighest;
        roleTag = 'AI · Solution 命中';
      case _MsgKind.human:
        bg = Colors.amber.shade50;
        roleTag = '升级人工';
      case _MsgKind.sys:
        bg = Colors.transparent;
        roleTag = '系统';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (roleTag != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                roleTag,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: msg.kind == _MsgKind.human ? Colors.orange.shade800 : theme.colorScheme.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Container(
            constraints: const BoxConstraints(maxWidth: 640),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: msg.kind == _MsgKind.sys
                  ? Border.all(color: theme.colorScheme.outlineVariant)
                  : null,
            ),
            child: msg.kind == _MsgKind.ai
                ? MarkdownBody(
                    data: msg.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  )
                : Text(
                    msg.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: msg.kind == _MsgKind.user ? fg : null,
                    ),
                  ),
          ),
          if (msg.extra != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(msg.extra!, style: theme.textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
