import 'package:flutter/material.dart';

import 'data/models.dart';
import 'data/seed_loader.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SupportStudioApp());
}

class SupportStudioApp extends StatelessWidget {
  const SupportStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '量潮客户支持云 Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0969DA)),
        useMaterial3: true,
      ),
      home: const _Bootstrap(),
    );
  }
}

/// 加载种子数据（assets/data），完成后进入主界面。
class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Seed>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('种子数据加载失败：${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final seed = snapshot.data!;
        return HomeScreen(solutions: seed.solutions, cases: seed.cases);
      },
    );
  }
}

class _Seed {
  const _Seed({required this.solutions, required this.cases});

  final List<Solution> solutions;
  final List<SupportCase> cases;
}

Future<_Seed> _load() async {
  final solutions = await SeedLoader.loadSolutions();
  final cases = await SeedLoader.loadCases();
  return _Seed(solutions: solutions, cases: cases);
}
