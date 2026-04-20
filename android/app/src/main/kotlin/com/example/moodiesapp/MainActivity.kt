package com.example.moodiesapp

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.moodiesapp.colorsPic.controller.main.MainColorPicActivity


class MainActivity : FlutterActivity() {

    // ── Channel name must match the string used on the Flutter/Dart side ──
    companion object {
        const val CHANNEL = "native_channel"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        actionBar?.hide()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // ── Invoked by Flutter to launch the coloring activity ──
                "openColorScreen" -> {
                    try {
                        val intent = Intent(this@MainActivity, MainColorPicActivity::class.java)

                        // Optional: pass data from Flutter to the Activity.
                        // The Dart side can supply arguments via invokeMethod("openColorScreen", {"theme": "forest"})
                        call.argument<String>("theme")?.let { theme ->
                            intent.putExtra("theme", theme)
                        }
                        call.argument<String>("imageUrl")?.let { url ->
                            intent.putExtra("imageUrl", url)
                        }

                        startActivity(intent)
                        result.success("Opened")       // ← returned to Flutter as a String
                    } catch (e: Exception) {
                        result.error(
                            "LAUNCH_ERROR",
                            "Could not open color screen: ${e.message}",
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
