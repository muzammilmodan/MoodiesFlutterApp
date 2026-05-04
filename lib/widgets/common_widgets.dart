// lib/widgets/common_widgets.dart

import 'package:flutter/material.dart';
import '../screens/abc_game/utils/app_theme.dart';
import '../utils/app_constants.dart';

const Color kAppBg = Color(AppConstants.appBgColorValue);
const Color kWhite = Colors.white;

// ── Loading overlay ────────────────────────────────────────────────────────
class LoadingDialog {
  static bool _showing = false;

  static void show(BuildContext context) {
    if (_showing) return;
    _showing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: kAppBg),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (_showing) {
      _showing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}


// ── Primary button ─────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color ?? kAppBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor ?? kWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: FontName.ChocoCooky,
            ),
          ),
        ),
      );
}

// ── Role selector pill ─────────────────────────────────────────────────────
class RoleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? kAppBg : Colors.white,
              border: Border.all(color: kAppBg),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : kAppBg,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
}

// ── Password field with show/hide ──────────────────────────────────────────
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const PasswordField({super.key, required this.controller, required this.hint});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hide = true;

  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        obscureText: _hide,
        decoration: InputDecoration(
          hintText: widget.hint,
          suffixIcon: IconButton(
            icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _hide = !_hide),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );
}

// ── Standard text field ────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );
}

// ── Standard text field ────────────────────────────────────────────────────
class AppTextWithCalenderField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final VoidCallback? onTap;          // ✅ add this
  final bool readOnly;

  const AppTextWithCalenderField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onTap,                       // ✅ add this
    this.readOnly = false,            // ✅ add this
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    readOnly: readOnly,           // ✅ prevents keyboard from opening
    onTap: onTap,
    decoration: InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: const Icon(Icons.calendar_today),
    ),
  );
}




// ── Logout dialog ──────────────────────────────────────────────────────────
Future<void> showLogoutDialog(
    BuildContext context, VoidCallback onConfirm) async {
  await showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon bubble
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD5D0F8), Color(0xFFB0A8F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👋', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Leaving so soon?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3D2FA0),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Are you sure you want to logout from Moodies?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ).copyWith(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B6EF6), Color(0xFF9B8FF8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: const Text(
                      'Yes, Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  backgroundColor: const Color(0xFFF3F1FF),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7B6EF6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Email validation ───────────────────────────────────────────────────────
bool isValidEmail(String e) =>
    RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e);
