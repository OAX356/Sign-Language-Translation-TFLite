package com.example.flutter_application_0


import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mediapipe_hand_landmarks"

    private var handLandmarker: HandLandmarker? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        setupHandLandmarker()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "detectHandLandmarks" -> {
                    val imageBytes = call.argument<ByteArray>("imageBytes")

                    if (imageBytes == null) {
                        result.error("NO_IMAGE", "No image bytes received", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val landmarks = detectHandLandmarks(imageBytes)

                        if (landmarks == null) {
                            result.success(
                                mapOf(
                                    "landmarks" to null
                                )
                            )
                        } else {
                            result.success(
                                mapOf(
                                    "landmarks" to landmarks
                                )
                            )
                        }
                    } catch (e: Exception) {
                        result.error(
                            "MEDIAPIPE_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun setupHandLandmarker() {
        val baseOptions = BaseOptions.builder()
            .setModelAssetPath("hand_landmarker.task")
            .build()

        val options = HandLandmarker.HandLandmarkerOptions.builder()
            .setBaseOptions(baseOptions)
            .setRunningMode(RunningMode.IMAGE)
            .setNumHands(1)
            .setMinHandDetectionConfidence(0.5f)
            .setMinHandPresenceConfidence(0.5f)
            .setMinTrackingConfidence(0.5f)
            .build()

        handLandmarker = HandLandmarker.createFromOptions(this, options)
    }

    private fun detectHandLandmarks(imageBytes: ByteArray): List<Double>? {
        val bitmap = BitmapFactory.decodeByteArray(
            imageBytes,
            0,
            imageBytes.size
        ) ?: return null

        val argbBitmap = bitmap.copy(Bitmap.Config.ARGB_8888, false)

        val mpImage = BitmapImageBuilder(argbBitmap).build()

        val result = handLandmarker?.detect(mpImage) ?: return null

        if (result.landmarks().isEmpty()) {
            return null
        }

        val firstHandLandmarks = result.landmarks()[0]

        val output = mutableListOf<Double>()

        for (landmark in firstHandLandmarks) {
            output.add(landmark.x().toDouble())
            output.add(landmark.y().toDouble())
            output.add(landmark.z().toDouble())
        }

        // Should be 21 landmarks * 3 values = 63
        return output
    }

    override fun onDestroy() {
        handLandmarker?.close()
        handLandmarker = null
        super.onDestroy()
    }
}