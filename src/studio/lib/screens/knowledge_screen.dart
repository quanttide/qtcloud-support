import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../data/models.dart';

/// 知识库（Solution）：左侧条目列表，右侧四段结构详情。
class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key, required this.solutions});

  final List<Solution> solutions;

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  Solution? _selected;

  @override
  Widget build(BuildContext context) {
    final list = widget.solutions;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 320,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = list[i];
              final active = identical(s, _selected);
              return InkWell(
                onTap: () => setState(() => _selected = s),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: active ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .4) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        '${s.id} · ${s.biz} · ${s.type} · 复用 ${s.reuse}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _selected == null
              ? const Center(
                  child: Text('点击左侧条目查看四段结构（适用场景 / 解答 / 升级判据 / 来源与复用）。'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _Detail(solution: _selected!),
                ),
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.solution});

  final Solution solution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(solution.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('${solution.id} · ${solution.type}', style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        _Section(title: '适用场景', child: MarkdownBody(data: solution.scene)),
        _Section(title: '解答', child: MarkdownBody(data: solution.answer)),
        _Section(
          title: '升级判据',
          child: Text(solution.escalate.join('；')),
        ),
        _Section(
          title: '来源与复用',
          child: Text('来源：${solution.src} · 复用：${solution.reuse}'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
