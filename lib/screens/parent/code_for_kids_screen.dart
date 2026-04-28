// lib/screens/code_for_kids_screen.dart

import 'package:flutter/material.dart';
import 'package:moodiesapp/screens/login_screen.dart';
import 'package:moodiesapp/utils/common_snackbar.dart';
import '../../services/firebase_service.dart';
import '../../utils/navigation_service.dart';
import '../../utils/session_manager.dart';
import '../../widgets/common_widgets.dart';
import 'home_parent_screen.dart';

class CodeForKidsScreen extends StatefulWidget {
  const CodeForKidsScreen({super.key});

  @override
  State<CodeForKidsScreen> createState() => _CodeForKidsScreenState();
}

class _CodeForKidsScreenState extends State<CodeForKidsScreen> {
  final _svc      = FirebaseService();
  final _codeCtrl = TextEditingController();
  bool  _loading  = false;

  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) { _snack('Please enter the 6-character code'); return; }

    setState(() => _loading = true);
    try {
      final child = await _svc.getChildByCode(code);
      if (!mounted) return;
      if (child == null) {
        _snack('No child found with that code. Please check and try again.');
        return;
      }
      await _svc.linkChildToParent(child.uid);
      await SessionManager.setIsSelectCode(true);

      CommonSnackbar.showSuccessSnackbar(context: context,
          message:("Connected to ${child.name}'s account! 🎉"));

      NavigationService().pushAndRemoveAll(const HomeParentScreen());
    } catch (e) {
      if (mounted) _snack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _svc.logout();
    if (!mounted) return;
    NavigationService().pushAndRemoveAll( const LoginScreen());
  }


  void _snack(String m) => CommonSnackbar.showErrorSnackbar(context: context, message:m);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect with Your Child'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.link, size: 64, color: kAppBg),
            const SizedBox(height: 20),
            const Text(
              'Enter Your Child\'s Code',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your child received a 6-character code when they registered. Enter it here to link your accounts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 36),

            // Code input — large and centered
            TextField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8),
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'ABC123',
                hintStyle: const TextStyle(
                    letterSpacing: 8, color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                counterText: '',
              ),
            ),
            const SizedBox(height: 28),

            _loading
                ? const Center(child: CircularProgressIndicator(color: kAppBg))
                : AppButton(label: 'Connect', onTap: _submit),
            const SizedBox(height: 30),
            AppButton(label: 'Logout', onTap: _logout)
          ],
        ),
      ),
    );
  }
}
