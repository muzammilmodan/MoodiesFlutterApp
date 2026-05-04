// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:moodiesapp/utils/navigation_service.dart';
import '../paints_widget/build_Logo.dart';
import '../paints_widget/build_bottom_landscape.dart';
import '../paints_widget/build_flower.dart';
import '../paints_widget/build_kids_avatar_widget.dart';
import '../paints_widget/build_tree.dart';
import '../paints_widget/landscape_painter.dart';
import '../paints_widget/rainbow_painter.dart';
import '../paints_widget/sky_painter.dart';
import '../services/firebase_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_enum.dart';
import '../utils/app_utils.dart';
import '../utils/common_snackbar.dart';
import '../utils/session_manager.dart';
import '../widgets/common_widgets.dart';
import 'abc_game/utils/app_theme.dart';
import 'abc_game/utils/appcolor.dart';
import 'signup_screen.dart';
import 'parent/home_parent_screen.dart';
import 'childs/home_kids_screen.dart';
import 'parent/code_for_kids_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  UserType _selectedUser = UserType.parent;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _svc = FirebaseService();


  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  // ── validation ─────────────────────────────────────────────────────────
  bool _validate() {
    if (_emailController.text.trim().isEmpty) {
      _snack('Please enter your email address');
      return false;
    }
    if (!isValidEmail(_emailController.text.trim())) {
      _snack('Please enter a valid email');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _snack('Please enter your password');
      return false;
    }
    return true;
  }

  // ── login ───────────────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await _svc.login(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      CommonSnackbar.showSuccessSnackbar(context: context,message:"Login successfully! 🎉");
      if (user.role == UserType.parent.name) {
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
      if (mounted) setState(() => _isLoading = false);
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F4FD),
                  Color(0xFFF0FAF5),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Sky & cloud decorations (top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: CustomPaint(painter: SkyPainter()),
          ),

          // Bottom landscape illustration
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: buildBottomLandscape(),
          ),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),

                            // ── Logo ──
                            buildLogo(),

                            const SizedBox(height: 4),

                            // Subtitle
                            Text(
                              'Sign in to your account',
                              style: TextStyle(
                                fontFamily: FontName.ChocoCooky,
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Kids illustration ──
                            BuildKidsAvatarWidget(),

                            const SizedBox(height: 20),

                            // ── Who are you? ──
                            _buildUserTypeSelector(),

                            const SizedBox(height: 20),

                            // ── Email field ──
                            _buildEmailField(),

                            const SizedBox(height: 14),

                            // ── Password field ──
                            _buildPasswordField(),

                            const SizedBox(height: 8),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontFamily: FontName.ChocoCooky,
                                    color: Color(0xFF4ECDC4),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Login button ──
                            _buildLoginButton(),

                            const SizedBox(height: 16),

                            // Sign up row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontFamily: FontName.ChocoCooky,
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    NavigationService().push(const SignUpScreen());
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontFamily: FontName.ChocoCooky,
                                      color: Color(0xFF4ECDC4),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Space for bottom landscape
                            const SizedBox(height: 130),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  USER TYPE SELECTOR
  // ──────────────────────────────────────────────
  Widget _buildUserTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Who are you?',
          style: TextStyle(
            fontFamily: FontName.ChocoCooky,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildUserTypeCard(
                type: UserType.parent,
                label: 'Parent',
                icon: Icons.supervisor_account_rounded,
                iconColor: const Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUserTypeCard(
                type: UserType.kides,
                label: 'Kids',
                icon: Icons.child_care_rounded,
                iconColor: const Color(0xFFFF6B9D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required UserType type,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedUser == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedUser = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? iconColor : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: iconColor.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? iconColor.withOpacity(0.12)
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: FontName.ChocoCooky,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? iconColor : const Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  FORM FIELDS
  // ──────────────────────────────────────────────
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your email';
        if (!v.contains('@')) return 'Please enter a valid email';
        return null;
      },
      decoration: AppUtils.inputDecoration(
        hint: 'Email Address',
        prefix: const Icon(
          Icons.mail_outline_rounded,
          color: Color(0xFFAAAAAA),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your password';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
      decoration: AppUtils.inputDecoration(
        hint: 'Password',
        prefix: const Icon(
          Icons.lock_outline_rounded,
          color: Color(0xFFAAAAAA),
          size: 20,
        ),
        suffix: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFFAAAAAA),
            size: 20,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  LOGIN BUTTON
  // ──────────────────────────────────────────────
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECDC4),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF4ECDC4).withOpacity(0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
                (states) => Colors.white.withOpacity(0.15),
          ),
        ),
        child: _isLoading
            ?  SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColor.progressColors,
          ),
        )
            : const Text(
          'Login',
          style: TextStyle(
            fontFamily: FontName.ChocoCooky,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

}



