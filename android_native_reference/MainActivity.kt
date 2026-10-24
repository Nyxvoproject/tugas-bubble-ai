package com.example.tugas_bubble_ai

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Tempel potongan ini ke MainActivity.kt hasil `flutter create` kamu
 * (file ada di android/app/src/main/kotlin/.../MainActivity.kt).
 * Ganti package di baris paling atas sesuai applicationId project kamu.
 */
class MainActivity : FlutterActivity() {
    private val CHANNEL = "tugas_bubble_ai/screen_capture"
    private val REQUEST_CODE = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    pendingResult = result
                    val mpm = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
                    startActivityForResult(mpm.createScreenCaptureIntent(), REQUEST_CODE)
                }
                "captureOnce" -> {
                    // Delegasikan ke ScreenCaptureService (lihat ScreenCaptureService.kt)
                    ScreenCaptureService.captureOnce(this) { bytes ->
                        result.success(bytes)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                ScreenCaptureService.init(applicationContext, resultCode, data)
                pendingResult?.success(true)
            } else {
                pendingResult?.success(false)
            }
            pendingResult = null
        }
    }
}
