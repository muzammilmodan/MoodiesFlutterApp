import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppUtils {
  static bool _isDialogOpen = false;

  static Future<bool> showExitDialog(BuildContext context) async {
    if (_isDialogOpen) return false; // 🚫 prevent double trigger

    _isDialogOpen = true;

    final result = await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => _exitDialogUI(context),
    );

    _isDialogOpen = false;

    return result ?? false;
  }

  static Widget _exitDialogUI(BuildContext context) {
    return Dialog(
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
              'Exit App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3D2FA0),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Are you sure you want to close Moodies app?',
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
                onPressed: () async {
                  Navigator.of(context).pop(true);
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
                      'Yes',
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
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  backgroundColor: const Color(0xFFF3F1FF),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                child: const Text(
                  'No',
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
    );
  }
}

// class AppUtils{
//
//   static Future<bool> showExitDialog(BuildContext context) async {
//    return await showDialog(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.3),
//       builder: (_) =>
//       Dialog(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         child: Container(
//           padding: const EdgeInsets.all(28),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(28),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Icon bubble
//               Container(
//                 width: 64,
//                 height: 64,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFFD5D0F8), Color(0xFFB0A8F0)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Center(
//                   child: Text('👋', style: TextStyle(fontSize: 28)),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Title
//               const Text(
//                 'Exit App',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF3D2FA0),
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               // Subtitle
//               const Text(
//                 'Are you sure you want to close Moodies app?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 28),
//
//               // Logout button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async{
//                     Navigator.of(context).pop(true);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: const StadiumBorder(),
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                   ).copyWith(
//                     backgroundColor: WidgetStateProperty.all(Colors.transparent),
//                   ),
//                   child: Ink(
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF7B6EF6), Color(0xFF9B8FF8)],
//                         begin: Alignment.centerLeft,
//                         end: Alignment.centerRight,
//                       ),
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: Container(
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       child: const Text(
//                         'Yes',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//
//               // Cancel button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () =>  Navigator.of(context).pop(false),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: const StadiumBorder(),
//                     backgroundColor: const Color(0xFFF3F1FF),
//                     shadowColor: Colors.transparent,
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'No',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF7B6EF6),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ) ?? false;
//   }
// }
