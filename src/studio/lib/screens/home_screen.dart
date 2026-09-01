import 'package:flutter/material.dart';

import '../data/models.dart';
import 'knowledge_screen.dart';
import 'qa_screen.dart';
import 'ticket_screen.dart';

/// 主界面：左侧导航（问答 / 工单 / 知识库）+ 三个页面。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.solutions, required this.cases});

  final List<Solution> solutions;
  final List<SupportCase> cases;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('量潮客户支持云 · Studio'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('问答'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: Text('工单'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: Text('知识库'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                QaScreen(solutions: widget.solutions),
                TicketScreen(cases: widget.cases, solutions: widget.solutions),
                KnowledgeScreen(solutions: widget.solutions),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
