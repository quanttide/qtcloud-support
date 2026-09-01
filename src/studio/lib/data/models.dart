/// 领域模型：Solution（解决方案，蒸馏自已解决 Ticket）× Ticket（工单案例）。
/// 数据形状对齐 data/profile 与 data/journal 的 JSON 快照（assets/data）。
class Solution {
  Solution({
    required this.id,
    required this.biz,
    required this.type,
    required this.title,
    required this.scene,
    required this.answer,
    required this.src,
    required this.escalate,
    required this.trigger,
    this.reuse = 0,
  });

  final String id;
  final String biz;
  final String type;
  final String title;
  final String scene;
  final String answer;
  final String src;
  final List<String> escalate;
  final List<String> trigger;
  int reuse;

  factory Solution.fromJson(Map<String, dynamic> json) => Solution(
        id: json['id'] as String,
        biz: json['biz'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        scene: json['scene'] as String,
        answer: json['answer'] as String,
        src: json['src'] as String,
        escalate: (json['escalate'] as List<dynamic>).cast<String>(),
        trigger: (json['trigger'] as List<dynamic>).cast<String>(),
        reuse: (json['reuse'] as num?)?.toInt() ?? 0,
      );
}

/// 工单：一次客户问题的提出与解答（对齐 GitHub Issue 的评论流语义）。
/// 案例快照来自 data/journal。
class SupportCase {
  const SupportCase({
    required this.no,
    required this.title,
    required this.customer,
    required this.q,
    required this.a,
    required this.status,
    required this.distill,
    required this.mapped,
  });

  final String no;
  final String title;
  final String customer;
  final String q;
  final String a;
  final String status;
  final String distill;

  /// 已蒸馏到的 Solution id（journal「沉淀」字段的种子）。
  final String mapped;

  factory SupportCase.fromJson(Map<String, dynamic> json) => SupportCase(
        no: json['no'] as String,
        title: json['title'] as String,
        customer: json['customer'] as String,
        q: json['q'] as String,
        a: json['a'] as String,
        status: json['status'] as String,
        distill: json['distill'] as String,
        mapped: json['mapped'] as String,
      );
}
