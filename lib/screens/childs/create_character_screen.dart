// lib/screens/create_character_screen.dart

import 'package:flutter/material.dart';
import 'package:moodiesapp/utils/common_snackbar.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/session_manager.dart';
import '../../widgets/common_widgets.dart';
import 'home_kids_screen.dart';

enum _Step { gender, hair, skin }

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final _svc  = FirebaseService();
  _Step  _step   = _Step.gender;
  int    _gender = AppConstants.isMale;
  String _hair   = '';
  String _skin   = '';
  bool   _saving = false;

  String get _gStr => _gender == AppConstants.isMale ? 'boy' : 'girl';
  String get _genderApi => _gender == AppConstants.isMale ? 'male' : 'female';

  Future<void> _save() async {
    if (_hair.isEmpty) { _snack('Please select a hair colour'); return; }
    if (_skin.isEmpty) { _snack('Please select a skin tone'); return; }
    setState(() => _saving = true);
    try {
      await _svc.saveAvatar(gender: _genderApi, hairColor: _hair, skin: _skin);
      await SessionManager.setIsGender(_gender);
      await SessionManager.setHairColor(_hair);
      await SessionManager.setSkinColor(_skin);
      if (!mounted) return;
      CommonSnackbar.showSuccessSnackbar(context: context, message:'Character saved! 🎉');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeKidsScreen()),
          (_) => false);
    } catch (e) {
      if (mounted) _snack('Failed to save. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m) =>  CommonSnackbar.showErrorSnackbar(context: context, message: m);

  // ── gender preview image ─────────────────────────────────────────────────
  String _img(String mood, String g, String h) {
    final hairStr = h.isEmpty ? 'blonde' : h;
    if (hairStr == AppConstants.hairTan) {
      return 'assets/images/${mood}_${g}_tan_wz_black${g == 'girl' ? '_hair' : ''}.jpg';
    }
    return 'assets/images/${mood}_${g}_$hairStr.jpg';
  }

  Widget _avatar(String mood, String g, String h, {double size = 80}) =>
      Image.asset(
        _img(mood, g, h),
        width: size, height: size, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.person, size: size, color: Colors.grey),
      );


  // ── create character card ──────────────────────────────────────────────────────────
  Widget _createCharacterCard({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(12),
          transform: Matrix4.identity()
            ..translate(0.0, selected ? -10.0 : 0.0)
            ..scale(selected ? 1.05 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? kAppBg : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: kAppBg.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ IMPORTANT
            children: [
              Opacity(
                opacity: selected ? 1 : 0.7,
                child: child ?? const SizedBox(),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selected ? kAppBg : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ── option card ──────────────────────────────────────────────────────────
  Widget _card({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Widget? child,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? kAppBg.withOpacity(0.12) : Colors.white,
            border: Border.all(
                color: selected ? kAppBg : Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (child != null) child,
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? kAppBg : Colors.black87)),
            ],
          ),
        ),
      );

  // ── step: gender ─────────────────────────────────────────────────────────
  Widget _genderStep() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Choose Your Character',
              style: TextStyle(fontFamily: 'ChocoCooky',fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 70),
          Row(
            children: [
              _createCharacterCard(
                label: 'Boy',
                selected: _gender == AppConstants.isMale,
                onTap: () => setState(() => _gender = AppConstants.isMale),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(AppImages.icnMaleCharacter),
                ),
              ),
              _createCharacterCard(
                label: 'Girl',
                selected: _gender == AppConstants.isFemale,
                onTap: () => setState(() => _gender = AppConstants.isFemale),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(AppImages.icnGirlCharacter),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          AppButton(
              label: 'Next: Choose Hair Colour',
              onTap: () => setState(() => _step = _Step.hair)),
        ],
      );

  // ── step: hair ───────────────────────────────────────────────────────────
  Widget _hairStep() {
    final options = {
      'Blonde': AppConstants.hairBlonde,
      'Brown':  AppConstants.hairBrown,
      'Red':    AppConstants.hairRed,
      'Black':  AppConstants.hairTan,
    };
    return Column(
      children: [
        const Text('Choose Hair Colour',
            style: TextStyle(fontFamily: 'ChocoCooky', fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          children: options.entries
              .map((e) => _card(
                    label: e.key,
                    selected: _hair == e.value,
                    onTap: () {
                      setState(() => _hair = e.value);
                      SessionManager.setHairColor(e.value);
                    },
                    child: _avatar('confused', _gStr, e.value),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
              child: AppButton(
                  label: 'Back',
                  onTap: () => setState(() => _step = _Step.gender),
                  color: Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
              child: AppButton(
                  label: 'Next: Skin Tone',
                  onTap: () {
                    if (_hair.isEmpty) {
                      _snack('Please select a hair colour');
                      return;
                    }
                    setState(() => _step = _Step.skin);
                  }
              ),),
        ]),
      ],
    );
  }

  // ── step: skin ───────────────────────────────────────────────────────────
  Widget _skinStep() {
    final options = {
      'Light':  AppConstants.skinBlonde,
      'Medium': AppConstants.skinBrown,
      'Dark':   AppConstants.skinRed,
      'Tan':    AppConstants.skinTan,
    };
    final hair = _hair.isEmpty ? AppConstants.hairBlonde : _hair;
    return Column(
      children: [
        const Text('Choose Skin Tone',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          children: options.entries
              .map((e) => _card(
                    label: e.key,
                    selected: _skin == e.value,
                    onTap: () {
                      setState(() => _skin = e.value);
                      SessionManager.setSkinColor(e.value);
                    },
                    child: _avatar('happy', _gStr, hair),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
              child: AppButton(
                  label: 'Back',
                  onTap: () => setState(() => _step = _Step.hair),
                  color: Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
              child: _saving
                  ?  const Center(
                      child: CircularProgressIndicator(color: kAppBg))
                  : AppButton(
                label: 'Save My Character 🎉',
                onTap: () => (_skin.isEmpty) ? null : _save,
              )),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create My Character',style: TextStyle(fontFamily: 'ChocoCooky',),)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: () {
          switch (_step) {
            case _Step.gender: return _genderStep();
            case _Step.hair:   return _hairStep();
            case _Step.skin:   return _skinStep();
          }
        }(),
      ),
    );
  }
}
