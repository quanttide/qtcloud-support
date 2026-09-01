import 'package:flutter_test/flutter_test.dart';
import 'package:qtcloud_support_studio/data/matcher.dart';
import 'package:qtcloud_support_studio/data/models.dart';

Solution _s(String id, List<String> trigger, List<String> escalate,
        {String answer = ''}) =>
    Solution(
      id: id,
      biz: 'qtclass',
      type: 'FAQ',
      title: id,
      scene: '',
      answer: answer,
      src: 'journal/test#案例一',
      trigger: trigger,
      escalate: escalate,
    );

void main() {
  final solutions = [
    _s('voucher-usage', ['代金券', '券', '一对一'], ['定制合同', '兑换纠纷', '过期争议'],
        answer: '群内沟通不消耗代金券——群内提问免费'),
    _s('rank-progress', ['职级', '晋升', '定档'], ['结果有异议', '人事']),
    _s('business-info', ['商务', '渠道'], ['报价', '合同']),
  ];

  group('第一级自动应答', () {
    test('触发词命中直接应答', () {
      final r = answer('代金券怎么用？', solutions);
      expect(r.isHit, isTrue);
      expect(r.solution!.id, 'voucher-usage');
    });

    test('升级判据短语命中转人工', () {
      final r = answer('想定制合同，批量采购', solutions);
      expect(r.isHit, isFalse);
      expect(r.escalatedReason, isNotNull);
      expect(r.solution!.id, 'voucher-usage');
    });

    test('升级判据 2-gram 宽松命中（中间隔字）', () {
      final r = answer('代金券兑换有纠纷', solutions);
      expect(r.isHit, isFalse);
      expect(r.escalatedReason, isNotNull);
    });

    test('无关问题未命中', () {
      final r = answer('今天天气怎么样', solutions);
      expect(r.noHit, isTrue);
    });

    test('FAQ 高频词（定档）不误触升级', () {
      final r = answer('收到定档通知 -1 是啥', solutions);
      expect(r.isHit, isTrue);
      expect(r.solution!.id, 'rank-progress');
    });

    test('升级判据（结果有异议）命中', () {
      final r = answer('对定档结果有异议怎么申诉', solutions);
      expect(r.isHit, isFalse);
      expect(r.solution!.id, 'rank-progress');
    });

    test('中文长问句子串匹配', () {
      final r = answer('群内沟通免费吗？', solutions);
      expect(r.isHit, isTrue);
      expect(r.solution!.id, 'voucher-usage');
    });

    test('命中复用次数递增', () {
      final before = solutions.first.reuse;
      answer('代金券怎么用？', solutions);
      expect(solutions.first.reuse, before + 1);
    });
  });
}
