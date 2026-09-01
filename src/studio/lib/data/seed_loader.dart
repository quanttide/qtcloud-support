import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'models.dart';

/// 种子数据加载器：单一事实源在 data/profile 与 data/journal 仓库，
/// 本目录 assets/data 是原型快照。
class SeedLoader {
  const SeedLoader._();

  static Future<List<Solution>> loadSolutions() async {
    final raw = await rootBundle.loadString('assets/data/solutions.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Solution.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<SupportCase>> loadCases() async {
    final raw = await rootBundle.loadString('assets/data/cases.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SupportCase.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
