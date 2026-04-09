// lib/screens/print_list_screen.dart

import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class PrintListScreen extends StatefulWidget {
  const PrintListScreen({super.key});

  @override
  State<PrintListScreen> createState() => _PrintListScreenState();
}

class _PrintListScreenState extends State<PrintListScreen> {
  final _days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  late final Map<String, TextEditingController> _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = {for (final d in _days) d: TextEditingController()};
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) c.dispose();
    super.dispose();
  }

  void _submit() {
    showSnack(context, 'Weekly review saved! 🖨️');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Print Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Mood Review',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Write how you felt each day this week',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ..._days.map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kAppBg.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(day,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: kAppBg)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _ctrl[day],
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'How was $day?',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 10),
            AppButton(label: '🖨️  Save & Print', onTap: _submit),
          ],
        ),
      ),
    );
  }
}
