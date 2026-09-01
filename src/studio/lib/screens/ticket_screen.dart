import 'package:flutter/material.dart';

import '../data/models.dart';

/// 工单（Ticket）：已解决案例流，标注蒸馏映射（journal 案例 → profile 条目）。
class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key, required this.cases, required this.solutions});

  final List<SupportCase> cases;
  final List<Solution> solutions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _TicketCard(
        c: cases[i],
        mappedTitle: solutions
            .where((s) => s.id == cases[i].mapped)
            .map((s) => s.title)
            .firstOrNull,
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.c, required this.mappedTitle});

  final SupportCase c;
  final String? mappedTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${c.no} · ${c.title}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(c.status, style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('客户：${c.customer}', style: theme.textTheme.bodySmall),
            const SizedBox(height: 10),
            Text('问题：${c.q}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('解答：${c.a}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('沉淀：${c.distill}', style: theme.textTheme.bodySmall),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '已蒸馏 → ${mappedTitle ?? c.mapped}',
                style: TextStyle(fontSize: 12, color: Colors.purple.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
