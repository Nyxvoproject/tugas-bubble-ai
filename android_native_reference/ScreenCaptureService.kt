package com.example.tugas_bubble_ai

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.util.DisplayMetrics
import android.view.WindowManager
import java.io.ByteArrayOutputStream

/**
 * Tempel file ini ke android/app/src/main/kotlin/.../ScreenCaptureService.kt
 * (satu folder dengan MainActivity.kt), lalu daftarkan sebagai foreground
 * service di AndroidManifest.xml (lihat README).
 *
 * Alur: MainActivity minta izin MediaProjection sekali -> hasilnya dipakai
 * di sini untuk bikin VirtualDisplay + ImageReader -> setiap captureOnce()
 * dipanggil, ambil 1 frame terbaru, encode ke JPEG, kirim balik ke Dart.
 */
object ScreenCaptureService {
    private var mediaProjection: MediaProjection? = null
    private var imageReader: ImageReader? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var appContext: Context? = null

    fun init(context: Context, resultCode: Int, data: Intent) {
        appContext = context.applicationContext
        val mpm = context.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        mediaProjection = mpm.getMediaProjection(resultCode, data)

        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val metrics = DisplayMetrics()
        @Suppress("DEPRECATION")
        wm.defaultDisplay.getRealMetrics(metrics)
        val width = metrics.widthPixels
        val height = metrics.heightPixels
        val density = metrics.densityDpi

        imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
        virtualDisplay = mediaProjection?.createVirtualDisplay(
            "TugasBubbleAI-Capture", width, height, density,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            imageReader?.surface, null, null
        )
    }

    /** Ambil satu frame & kirim sebagai JPEG ByteArray lewat callback. */
    fun captureOnce(context: Context, callback: (ByteArray?) -> Unit) {
        val reader = imageReader
        if (reader == null || mediaProjection == null) {
            callback(null)
            return
        }
        try {
            val image = reader.acquireLatestImage()
            if (image == null) {
                callback(null)
                return
            }
            val planes = image.planes
            val buffer = planes[0].buffer
            val pixelStride = planes[0].pixelStride
            val rowStride = planes[0].rowStride
            val rowPadding = rowStride - pixelStride * image.width

            val bitmap = Bitmap.createBitmap(
                image.width + rowPadding / pixelStride, image.height, Bitmap.Config.ARGB_8888
            )
            bitmap.copyPixelsFromBuffer(buffer)
            image.close()

            val cropped = Bitmap.createBitmap(bitmap, 0, 0, image.width, image.height)
            val stream = ByteArrayOutputStream()
            cropped.compress(Bitmap.CompressFormat.JPEG, 85, stream)
            callback(stream.toByteArray())
        } catch (e: Exception) {
            callback(null)
        }
    }

    fun stop() {
        virtualDisplay?.release()
        imageReader?.close()
        mediaProjection?.stop()
        virtualDisplay = null
        imageReader = null
        mediaProjection = null
    }
}
