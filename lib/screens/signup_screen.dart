// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../utils/app_constants.dart';
import '../utils/session_manager.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'childs/home_kids_screen.dart';
import 'childs/create_character_screen.dart';
import 'parent/code_for_kids_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _svc           = FirebaseService();
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _pwCtrl        = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  final _parentCtrl    = TextEditingController();
  String _role         = '';
  bool   _loading      = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _pwCtrl.dispose();
    _confirmCtrl.dispose(); _parentCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_nameCtrl.text.trim().isEmpty) { _snack('Please enter your full name'); return false; }
    if (_emailCtrl.text.trim().isEmpty) { _snack('Please enter your email'); return false; }
    if (!isValidEmail(_emailCtrl.text.trim())) { _snack('Please enter a valid email'); return false; }
    if (_pwCtrl.text.isEmpty) { _snack('Please enter a password'); return false; }
    if (_pwCtrl.text.length < 6) { _snack('Password must be at least 6 characters'); return false; }
    if (_confirmCtrl.text != _pwCtrl.text) { _snack('Passwords do not match'); return false; }
    if (_role.isEmpty) { _snack('Please select a role'); return false; }
    if (_role == AppConstants.roleKids && _parentCtrl.text.trim().isEmpty) {
      _snack('Please enter your parent\'s email'); return false;
    }
    return true;
  }

  Future<void> _signUp() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _svc.register(
        name:        _nameCtrl.text.trim(),
        email:       _emailCtrl.text.trim(),
        password:    _pwCtrl.text,
        parentEmail: _parentCtrl.text.trim(),
        role:        _role,
      );
      if (!mounted) return;
      _snack('Account created successfully! 🎉');
      if (user.isChild == AppConstants.isChildKids) {
        _go(const CreateCharacterScreen());
      } else {
        _go(const CodeForKidsScreen());
      }
    } on FirebaseAuthException catch (e) {
      _snack(_authError(e.code));
    } catch (e) {
      _snack('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _go(Widget s) => Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => s), (_) => false);

  void _snack(String m) => showSnack(context, m);

  String _authError(String code) => switch (code) {
    'email-already-in-use' => 'This email is already registered.',
    'weak-password'        => 'Password is too weak.',
    'invalid-email'        => 'Invalid email format.',
    _                      => 'Registration failed. Try again.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                      fontFamily: 'ChocoCooky',
                      fontSize: 34,
                      color: kAppBg),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                  child: Text('Sign up to get started',
                      style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 30),

              // Role selector
              const Text('I am a...',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  RoleButton(
                    label: 'Parent',
                    isSelected: _role == AppConstants.roleParent,
                    onTap: () async {
                      setState(() => _role = AppConstants.roleParent);
                      await SessionManager.setSelectRole(
                          AppConstants.roleParent);
                    },
                  ),
                  const SizedBox(width: 12),
                  RoleButton(
                    label: 'Child',
                    isSelected: _role == AppConstants.roleKids,
                    onTap: () async {
                      setState(() => _role = AppConstants.roleKids);
                      await SessionManager.setSelectRole(AppConstants.roleKids);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(controller: _nameCtrl, hint: 'Full Name'),
              const SizedBox(height: 12),
              AppTextField(
                  controller: _emailCtrl,
                  hint: 'Email Address',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              PasswordField(controller: _pwCtrl, hint: 'Password'),
              const SizedBox(height: 12),
              PasswordField(
                  controller: _confirmCtrl, hint: 'Confirm Password'),

              // Parent email — shown only when role = kids
              if (_role == AppConstants.roleKids) ...[
                const SizedBox(height: 12),
                AppTextField(
                  controller: _parentCtrl,
                  hint: "Parent's Email Address",
                  keyboardType: TextInputType.emailAddress,
                ),
              ],

              const SizedBox(height: 24),
              _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: kAppBg))
                  : AppButton(label: 'Create Account', onTap: _signUp),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen())),
                    child: const Text('Login',
                        style: TextStyle(
                            color: kAppBg, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
