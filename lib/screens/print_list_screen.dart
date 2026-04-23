// lib/screens/print_list_screen.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../utils/common_snackbar.dart';
import '../widgets/common_widgets.dart';

class PrintListScreen extends StatefulWidget {
  const PrintListScreen({super.key});

  @override
  State<PrintListScreen> createState() => _PrintListScreenState();
}

class _PrintListScreenState extends State<PrintListScreen> {
  final _days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  late final Map<String, TextEditingController> _ctrl;

  final _svc = FirebaseService();

  @override
  void initState() {
    super.initState();
    _ctrl = {for (final d in _days) d: TextEditingController()};

    _findWeeklyPrintReviewData();
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) c.dispose();
    super.dispose();
  }

  WeeklyPrintReviewModel? _weeklyData;

  Future<void> _findWeeklyPrintReviewData() async {
    final data = await _svc.getWeeklyPrintReview();

    if (data == null) return;

    _weeklyData = data;

    _ctrl['Sunday']!.text = data.sunday;
    _ctrl['Monday']!.text = data.monday;
    _ctrl['Tuesday']!.text = data.tuesday;
    _ctrl['Wednesday']!.text = data.wednesday;
    _ctrl['Thursday']!.text = data.thursday;
    _ctrl['Friday']!.text = data.friday;
    _ctrl['Saturday']!.text = data.saturday;

    if (mounted) setState(() {});
  }


  Future<void> _addSubmitEvent() async {

    LoadingDialog.show(context);
    try {
      await _svc.addWeeklyPrintReview(
        sunday: _ctrl['Sunday']!.text.trim(),
        monday: _ctrl['Monday']!.text.trim(),
        tuesday: _ctrl['Tuesday']!.text.trim(),
        wednesday: _ctrl['Wednesday']!.text.trim(),
        thursday: _ctrl['Thursday']!.text.trim(),
        friday: _ctrl['Friday']!.text.trim(),
        saturday: _ctrl['Saturday']!.text.trim(),
      );

      if (!mounted) return;
      LoadingDialog.hide(context);

      CommonSnackbar.showSuccessSnackbar(context: context,
          message: 'Weekly review saved! 🖨️');

      Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        CommonSnackbar.showSuccessSnackbar(context: context,message: 'Failed. Try again.'); }
    }
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
            AppButton(label: '🖨️  Save & Print', onTap: _addSubmitEvent),
          ],
        ),
      ),
    );
  }
}
