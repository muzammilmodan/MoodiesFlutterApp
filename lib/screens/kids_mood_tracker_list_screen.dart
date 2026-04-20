// lib/screens/kids_mood_tracker_list_screen.dart

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class KidsMoodTrackerListScreen extends StatefulWidget {
  final String tab; // 'Tracker' | 'Therapy' | 'Reminder' | 'Notes'
  const KidsMoodTrackerListScreen({super.key, required this.tab});

  @override
  State<KidsMoodTrackerListScreen> createState() =>
      _KidsMoodTrackerListScreenState();
}

class _KidsMoodTrackerListScreenState
    extends State<KidsMoodTrackerListScreen> {
  final _svc = FirebaseService();

  bool _loading  = true;
  bool _showForm = false;
  bool _saving   = false;

  List<MoodModel>     _moods     = [];
  List<ReminderModel> _reminders = [];
  List<TherapyModel>  _therapies = [];

  final _f1 = TextEditingController(); // main field
  final _f2 = TextEditingController(); // datetime field

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      switch (widget.tab) {
        case 'Tracker':
          _moods = await _svc.getMoods();
          break;
        case 'Reminder':
          _reminders = await _svc.getReminders();
          break;
        case 'Therapy':
          _therapies = await _svc.getTherapySessions();
          break;
        case 'Notes':
          _reminders = await _svc.getReminders();
          break;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_f1.text.trim().isEmpty) {
      showSnack(context, 'Please fill in the required field');
      return;
    }
    setState(() => _saving = true);
    try {
      switch (widget.tab) {
        case 'Reminder':
        case 'Notes':
          await _svc.addReminder(_f1.text.trim(), _f2.text.trim());
          break;
        case 'Therapy':
          await _svc.addTherapy(_f1.text.trim(), _f2.text.trim());
          break;
      }
      if (!mounted) return;
      showSnack(context, 'Saved successfully!');
      _f1.clear();
      _f2.clear();
      setState(() => _showForm = false);
      _fetch();
    } catch (e) {
      if (mounted) showSnack(context, 'Failed. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── mood color helpers ─────────────────────────────────────────────────
  Color _moodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'excited':
      case 'loved':
        return Colors.green;
      case 'sad':
      case 'scared':
      case 'worried':
        return Colors.blue;
      case 'mad':
        return Colors.red;
      case 'tired':
        return Colors.orange;
      case 'comfortable':
      case 'safe':
        return Colors.teal;
      default:
        return kAppBg;
    }
  }

  IconData _moodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':   return Icons.sentiment_very_satisfied;
      case 'sad':     return Icons.sentiment_dissatisfied;
      case 'mad':     return Icons.sentiment_very_dissatisfied;
      case 'excited': return Icons.celebration;
      case 'scared':  return Icons.warning_amber;
      case 'tired':   return Icons.bedtime;
      case 'loved':   return Icons.favorite;
      case 'smart':   return Icons.lightbulb;
      default:        return Icons.mood;
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitle()),
        actions: [
          if (widget.tab != 'Tracker')
            IconButton(
              icon: Icon(_showForm ? Icons.close : Icons.add),
              onPressed: () => setState(() => _showForm = !_showForm),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAppBg))
          : Column(
              children: [
                if (_showForm) _buildForm(),
                Expanded(child: _buildList()),
                SizedBox(height: 10,)
              ],
            ),
    );
  }

  String _tabTitle() {
    switch (widget.tab) {
      case 'Tracker':  return 'Mood History';
      case 'Reminder': return 'Reminders';
      case 'Therapy':  return 'Therapy Sessions';
      case 'Notes':    return 'Notes';
      default:         return widget.tab;
    }
  }

  Widget _buildForm() => Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add ${_tabTitle()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              AppTextField(
                controller: _f1,
                hint: widget.tab == 'Reminder'
                    ? 'Reminder Text'
                    : widget.tab == 'Therapy'
                        ? 'Therapist Name'
                        : 'Note',
                maxLines: widget.tab == 'Notes' ? 3 : 1,
              ),
              if (widget.tab != 'Notes') ...[
                const SizedBox(height: 12),

                AppTextWithCalenderField(
                  controller: _f2,
                  hint: 'Date & Time (e.g. 2024-12-01 10:00)',
                  keyboardType: TextInputType.datetime,
                  readOnly: true,                     // ✅ no keyboard
                  onTap: () => _pickDateTime(context),
                ),
              ],
              const SizedBox(height: 16),
              _saving
                  ? const Center(
                      child: CircularProgressIndicator(color: kAppBg))
                  : AppButton(label: 'Save', onTap: _save),
            ],
          ),
        ),
      );

  Future<void> _pickDateTime(BuildContext context) async {
    // Step 1 — Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return; // user cancelled

    // Step 2 — Pick Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return; // user cancelled

    // Step 3 — Combine and format
    final DateTime combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Format: 2024-12-01 10:00
    final String formatted =
        '${combined.year}-'
        '${combined.month.toString().padLeft(2, '0')}-'
        '${combined.day.toString().padLeft(2, '0')} '
        '${combined.hour.toString().padLeft(2, '0')}:'
        '${combined.minute.toString().padLeft(2, '0')}';

    _f2.text = formatted;
  }

  Widget _buildList() {
    switch (widget.tab) {
      case 'Tracker':
        if (_moods.isEmpty) return _empty('No mood records yet');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _moods.length,
          itemBuilder: (_, i) {
            final m = _moods[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _moodColor(m.mood),
                  child: Icon(_moodIcon(m.mood), color: Colors.white),
                ),
                title: Text(m.mood,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(m.formattedDate,
                    style: const TextStyle(color: Colors.grey)),
              ),
            );
          },
        );

      case 'Reminder':
      case 'Notes':
        if (_reminders.isEmpty) return _empty('Nothing added yet');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _reminders.length,
          itemBuilder: (_, i) {
            final r = _reminders[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kAppBg,
                  child: Icon(
                    widget.tab == 'Notes' ? Icons.note : Icons.alarm,
                    color: Colors.white,
                  ),
                ),
                title: Text(r.reminder),
                subtitle: r.reminderDatetime.isNotEmpty
                    ? Text(r.reminderDatetime,
                        style: const TextStyle(color: Colors.grey))
                    : null,
              ),
            );
          },
        );

      case 'Therapy':
        if (_therapies.isEmpty) return _empty('No therapy sessions yet');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _therapies.length,
          itemBuilder: (_, i) {
            final t = _therapies[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.local_hospital, color: Colors.white),
                ),
                title: Text(t.therapist,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: t.therapyDatetime.isNotEmpty
                    ? Text(t.therapyDatetime,
                        style: const TextStyle(color: Colors.grey))
                    : null,
              ),
            );
          },
        );

      default:
        return _empty('Nothing here');
    }
  }

  Widget _empty(String msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(msg, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );

  @override
  void dispose() {
    _f1.dispose();
    _f2.dispose();
    super.dispose();
  }
}
