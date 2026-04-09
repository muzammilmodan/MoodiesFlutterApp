// lib/screens/planner_list_screen.dart

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'kids_mood_tracker_list_screen.dart';

class PlannerListScreen extends StatefulWidget {
  const PlannerListScreen({super.key});

  @override
  State<PlannerListScreen> createState() => _PlannerListScreenState();
}

class _PlannerListScreenState extends State<PlannerListScreen> {
  final _svc = FirebaseService();
  bool   _showForm   = false;
  String _selDate    = '';
  DateTime _focused  = DateTime.now();
  List<EventModel> _events = [];

  final _titleCtrl    = TextEditingController();
  final _typeCtrl     = TextEditingController();
  final _reminderCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selDate = _fmt(DateTime.now());
    _fetch(_selDate);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _fetch(String date) async {
    try {
      final list = await _svc.getEventsByDate(date);
      if (mounted) setState(() => _events = list);
    } catch (_) {}
  }

  Future<void> _addEvent() async {
    if (_titleCtrl.text.trim().isEmpty) {
      showSnack(context, 'Please enter event title'); return;
    }
    LoadingDialog.show(context);
    try {
      await _svc.addEvent(
        title:     _titleCtrl.text.trim(),
        type:      _typeCtrl.text.trim(),
        eventDate: _selDate,
        reminder:  _reminderCtrl.text.trim(),
        notes:     _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      LoadingDialog.hide(context);
      showSnack(context, 'Event added!');
      _titleCtrl.clear(); _typeCtrl.clear();
      _reminderCtrl.clear(); _notesCtrl.clear();
      setState(() => _showForm = false);
      _fetch(_selDate);
    } catch (e) {
      if (mounted) { LoadingDialog.hide(context); showSnack(context, 'Failed. Try again.'); }
    }
  }

  void _navTracker(String tab) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => KidsMoodTrackerListScreen(tab: tab)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Planner'),
          actions: [
            if (!_showForm)
              IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _showForm = true))
          ],
        ),
        body: _showForm ? _addForm() : _plannerView(),
      );

  Widget _plannerView() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _calendar(),
            const SizedBox(height: 16),
            // Events for selected date
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.event, color: kAppBg),
                      const SizedBox(width: 8),
                      Text(_selDate,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ]),
                    const Divider(height: 20),
                    if (_events.isEmpty)
                      const Text('No events for this date',
                          style: TextStyle(color: Colors.grey))
                    else
                      ..._events.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                if (e.type.isNotEmpty)
                                  Text('Type: ${e.type}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                if (e.reminder.isNotEmpty)
                                  Text('Reminder: ${e.reminder}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                if (e.notes.isNotEmpty)
                                  Text('Notes: ${e.notes}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Mood Tracker',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _quickTile('Mood Tracker', Icons.track_changes, () => _navTracker('Tracker')),
            _quickTile('Therapy Session', Icons.local_hospital, () => _navTracker('Therapy')),
            _quickTile('Reminders', Icons.alarm, () => _navTracker('Reminder')),
            _quickTile('Notes', Icons.note, () => _navTracker('Notes')),
          ],
        ),
      );

  Widget _addForm() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add Event',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Date picker button
            GestureDetector(
              onTap: () async {
                final p = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030));
                if (p != null) setState(() => _selDate = _fmt(p));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selDate.isEmpty ? 'Select Date' : _selDate),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _titleCtrl, hint: 'Event Title'),
            const SizedBox(height: 12),
            AppTextField(controller: _typeCtrl, hint: 'Event Type'),
            const SizedBox(height: 12),
            AppTextField(controller: _reminderCtrl, hint: 'Reminder'),
            const SizedBox(height: 12),
            AppTextField(controller: _notesCtrl, hint: 'Notes', maxLines: 3),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: AppButton(label: 'Cancel', color: Colors.grey,
                  onTap: () => setState(() => _showForm = false))),
              const SizedBox(width: 12),
              Expanded(child: AppButton(label: 'Add to Calendar', onTap: _addEvent)),
            ]),
          ],
        ),
      );

  Widget _calendar() {
    final now = DateTime.now();
    final first = DateTime(_focused.year, _focused.month, 1);
    final days  = DateTime(_focused.year, _focused.month + 1, 0).day;
    final start = first.weekday % 7;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() =>
                _focused = DateTime(_focused.year, _focused.month - 1))),
        Text('${_mName(_focused.month)} ${_focused.year}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() =>
                _focused = DateTime(_focused.year, _focused.month + 1))),
      ]),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, childAspectRatio: 1),
        itemCount: start + days,
        itemBuilder: (_, idx) {
          if (idx < start) return const SizedBox();
          final day  = idx - start + 1;
          final date = DateTime(_focused.year, _focused.month, day);
          final ds   = _fmt(date);
          final isSel = ds == _selDate;
          final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
          return GestureDetector(
            onTap: () { setState(() => _selDate = ds); _fetch(ds); },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSel ? kAppBg : isToday ? kAppBg.withOpacity(0.18) : null,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$day',
                    style: TextStyle(
                        color: isSel ? Colors.white : Colors.black87,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13)),
              ),
            ),
          );
        },
      ),
    ]);
  }

  Widget _quickTile(String label, IconData icon, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(icon, color: kAppBg),
          title: Text(label),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: onTap,
        ),
      );

  String _mName(int m) =>
      ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];

  @override
  void dispose() {
    _titleCtrl.dispose(); _typeCtrl.dispose();
    _reminderCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }
}
