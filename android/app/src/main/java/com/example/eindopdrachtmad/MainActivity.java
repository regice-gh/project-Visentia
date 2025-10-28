package com.example.eindopdrachtmad;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.MethodChannel;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.concurrent.CountDownLatch; // Added import

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.eindopdrachtmad/sentiment";
    private SentimentPredictor sentimentPredictor;
    private final CountDownLatch latch = new CountDownLatch(1); // Added CountDownLatch

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Initialize in a background thread to avoid blocking the UI thread
        new Thread(() -> {
            try {
                File modelDir = new File(getContext().getCacheDir(), "model");
                if (!modelDir.exists()) {
                    modelDir.mkdirs();
                }
                copyAsset("assets/sentiment/model.onnx", new File(modelDir, "model.onnx"));
                copyAsset("assets/sentiment/tokenizer.json", new File(modelDir, "tokenizer.json"));
                sentimentPredictor = new SentimentPredictor(modelDir);
                latch.countDown(); // Signal that initialization is complete
            } catch (Exception e) {
                // Log the exception
                e.printStackTrace();
            }
        }).start();


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("predictSentiment")) {
                                // Run prediction on a background thread
                                new Thread(() -> {
                                    try {
                                        latch.await(); // Wait for initialization to complete
                                    } catch (InterruptedException e) {
                                        Thread.currentThread().interrupt();
                                        runOnUiThread(() -> result.error("UNAVAILABLE", "Thread interrupted during sentiment predictor initialization.", e.toString()));
                                        return;
                                    }

                                    if (sentimentPredictor == null) {
                                        runOnUiThread(() -> result.error("UNAVAILABLE", "Sentiment predictor not initialized.", "The model might be loading or failed to load. Check Logcat for errors."));
                                        return;
                                    }
                                    String text = call.argument("text");
                                    try {
                                        String prediction = sentimentPredictor.predict(text);
                                        runOnUiThread(() -> result.success(prediction));
                                    } catch (Exception e) {
                                        runOnUiThread(() -> result.error("ERROR", "Prediction failed", e.toString()));
                                    }
                                }).start();
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private void copyAsset(String assetName, File destination) throws IOException {
        String assetKey = "flutter_assets/" + assetName;
        try (InputStream in = getAssets().open(assetKey); OutputStream out = new FileOutputStream(destination)) {
            byte[] buffer = new byte[1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
        }
    }
}
