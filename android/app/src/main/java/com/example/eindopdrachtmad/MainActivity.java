package com.example.eindopdrachtmad;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import java.util.concurrent.CountDownLatch;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.eindopdrachtmad/sentiment";
    private SentimentPredictor sentimentPredictor;
    private final CountDownLatch latch = new CountDownLatch(1);

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Initialize in a background thread to avoid blocking the UI thread
        new Thread(() -> {
            try {
                android.util.Log.d("MainActivity", "Starting sentiment predictor initialization...");
                File modelDir = new File(getContext().getCacheDir(), "model");
                if (!modelDir.exists()) {
                    android.util.Log.d("MainActivity", "Creating model directory: " + modelDir.getAbsolutePath());
                    modelDir.mkdirs();
                    if (!modelDir.exists()) {
                        android.util.Log.e("MainActivity", "Failed to create model directory: " + modelDir.getAbsolutePath());
                        throw new IOException("Failed to create model directory: " + modelDir.getAbsolutePath());
                    }
                    android.util.Log.d("MainActivity", "Model directory created successfully.");
                }
                
                android.util.Log.d("MainActivity", "Copying model.onnx...");
                copyAsset("assets/sentiment/model.onnx", new File(modelDir, "model.onnx"));
                
                android.util.Log.d("MainActivity", "Copying tokenizer.json...");
                copyAsset("assets/sentiment/tokenizer.json", new File(modelDir, "tokenizer.json"));
                
                android.util.Log.d("MainActivity", "Creating SentimentPredictor instance...");
                sentimentPredictor = new SentimentPredictor(modelDir);
                
                android.util.Log.d("MainActivity", "Sentiment predictor initialized successfully!");
                latch.countDown(); // Signal that initialization is complete
            } catch (Exception e) {
                // Log the exception with more detail
                android.util.Log.e("MainActivity", "Failed to initialize sentiment predictor", e);
                latch.countDown(); // Release the latch even on error
            }
        }).start();


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("predictSentiment")) {
                                // Run prediction on a background thread
                                new Thread(() -> {
                                    try {
                                        android.util.Log.d("MainActivity", "Waiting for sentiment predictor initialization...");
                                        latch.await(); // Wait for initialization to complete
                                        android.util.Log.d("MainActivity", "Sentiment predictor initialization completed.");
                                    } catch (InterruptedException e) {
                                        android.util.Log.e("MainActivity", "Thread interrupted", e);
                                        Thread.currentThread().interrupt();
                                        runOnUiThread(() -> result.error("UNAVAILABLE", "Thread interrupted during sentiment predictor initialization.", e.toString()));
                                        return;
                                    }

                                    if (sentimentPredictor == null) {
                                        android.util.Log.e("MainActivity", "Sentiment predictor is null after initialization");
                                        runOnUiThread(() -> result.error("UNAVAILABLE", "Sentiment predictor not initialized.", "The model might be loading or failed to load. Check Logcat for errors."));
                                        return;
                                    }
                                    String text = call.argument("text");
                                    android.util.Log.d("MainActivity", "Predicting sentiment for text: " + text);
                                    try {
                                        String prediction = sentimentPredictor.predict(text);
                                        android.util.Log.d("MainActivity", "Prediction result: " + prediction);
                                        runOnUiThread(() -> result.success(prediction));
                                    } catch (Exception e) {
                                        android.util.Log.e("MainActivity", "Prediction failed", e);
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
