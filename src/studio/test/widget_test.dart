import 'package:flutter_test/flutter_test.dart';
import 'package:qtcloud_support_studio/main.dart';

void main() {
  testWidgets('app boots and shows nav rail', (tester) async {
    await tester.pumpWidget(const SupportStudioApp());
    await tester.pumpAndSettle();
    expect(find.text('量潮客户支持云 · Studio'), findsOneWidget);
    expect(find.text('问答'), findsOneWidget);
    expect(find.text('工单'), findsOneWidget);
    expect(find.text('知识库'), findsOneWidget);
  });
}

// 注：种子数据加载测试依赖真实 assets，保留在集成层验证；
// 这里仅验证匹配逻辑与页面骨架。
