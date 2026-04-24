// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:moodiesapp/utils/navigation_service.dart';
import '../services/firebase_service.dart';
import '../utils/app_constants.dart';
import '../utils/common_snackbar.dart';
import '../utils/session_manager.dart';
import '../widgets/common_widgets.dart';
import 'signup_screen.dart';
import 'parent/home_parent_screen.dart';
import 'childs/home_kids_screen.dart';
import 'parent/code_for_kids_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _svc = FirebaseService();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  String _role = '';
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  // ── validation ─────────────────────────────────────────────────────────
  bool _validate() {
    if (_emailCtrl.text.trim().isEmpty) {
      _snack('Please enter your email address');
      return false;
    }
    if (!isValidEmail(_emailCtrl.text.trim())) {
      _snack('Please enter a valid email');
      return false;
    }
    if (_pwCtrl.text.isEmpty) {
      _snack('Please enter your password');
      return false;
    }
    return true;
  }

  // ── login ───────────────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _svc.login(_emailCtrl.text.trim(), _pwCtrl.text);
      if (!mounted) return;
      CommonSnackbar.showSuccessSnackbar(context: context,message:"Login successfully! 🎉");
      if (user.role == AppConstants.roleParent) {
        final done = await SessionManager.getIsSelectCode();
        NavigationService().pushAndRemoveAll(done ? const HomeParentScreen() : const CodeForKidsScreen());
      } else {
        NavigationService().pushAndRemoveAll(const HomeKidsScreen());
      }
    } on FirebaseAuthException catch (e) {
      _snack(_authError(e.code));
    } catch (e) {
      _snack('Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── forgot password ─────────────────────────────────────────────────────
  void _forgotPw() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot Password'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Enter your email'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final email = ctrl.text.trim();
              if (email.isEmpty || !isValidEmail(email)) {
                _snack('Please enter a valid email');
                return;
              }
              Navigator.pop(ctx);
              try {
                await _svc.forgotPassword(email);
                _snack('Password reset email sent! Check your inbox.');
              } catch (_) {
                _snack('Email not found. Please check and try again.');
              }
            },
            child: const Text('Send Reset Email'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  void _snack(String msg) => CommonSnackbar.showErrorSnackbar(context: context,
      message:msg);

  String _authError(String code) => switch (code) {
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-credential' => 'Invalid email or password.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        'user-disabled' => 'This account has been disabled.',
        _ => 'Login failed. Please try again.',
      };

  // ── UI ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Logo
              const Center(
                child: Text(
                  'Moodies',
                  style: TextStyle(
                    fontFamily: 'ChocoCooky',
                    fontSize: 40,
                    color: kAppBg,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Sign in to your account',
                    style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 36),

              // Role selector
              const Text('Select your role',
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
                    label: 'Kids',
                    isSelected: _role == AppConstants.roleKids,
                    onTap: () async {
                      setState(() => _role = AppConstants.roleKids);
                      await SessionManager.setSelectRole(AppConstants.roleKids);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Email
              AppTextField(
                controller: _emailCtrl,
                hint: 'Email Address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Password
              PasswordField(controller: _pwCtrl, hint: 'Password'),
              const SizedBox(height: 4),

              // Forgot
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPw,
                  child: const Text('Forgot Password?',
                      style: TextStyle(color: kAppBg)),
                ),
              ),
              const SizedBox(height: 8),

              // Login button
              _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: kAppBg))
                  : AppButton(label: 'Login', onTap: _login),
              const SizedBox(height: 28),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () =>NavigationService().pushReplacement(const SignUpScreen()),
                    child: const Text('Sign Up',
                        style: TextStyle(
                            color: kAppBg, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              // ElevatedButton(
              //   onPressed: openNativeScreen,
              //   child: const Text("Open Native Screen"),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
