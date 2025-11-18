package com.example.eindopdrachtmad;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
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
    private volatile Exception initializationError;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        initializePredictorAsync();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("predictSentiment")) {
                                predictSentimentAsync(call, result);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private void initializePredictorAsync() {
        new Thread(() -> {
            try {
                File modelDir = prepareModelDirectory();
                copyAsset("assets/sentiment/model.onnx", new File(modelDir, "model.onnx"));
                copyAsset("assets/sentiment/tokenizer.json", new File(modelDir, "tokenizer.json"));
                sentimentPredictor = new SentimentPredictor(modelDir);
            } catch (Exception e) {
                initializationError = e;
            } finally {
                latch.countDown();
            }
        }).start();
    }

    private void predictSentimentAsync(MethodCall call, MethodChannel.Result result) {
        new Thread(() -> {
            try {
                latch.await();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                runOnUiThread(() -> result.error(
                        "UNAVAILABLE",
                        "Sentiment predictor initialization was interrupted.",
                        e.toString()
                ));
                return;
            }

            if (sentimentPredictor == null) {
                String detail = initializationError != null ? initializationError.toString() : "Predictor not yet available.";
                runOnUiThread(() -> result.error(
                        "UNAVAILABLE",
                        "Sentiment predictor not initialized.",
                        detail
                ));
                return;
            }

            String text = call.argument("text");
            if (text == null || text.trim().isEmpty()) {
                runOnUiThread(() -> result.error(
                        "INVALID_INPUT",
                        "Text to analyse cannot be empty.",
                        null
                ));
                return;
            }

            try {
                String prediction = sentimentPredictor.predict(text);
                runOnUiThread(() -> result.success(prediction));
            } catch (Exception e) {
                runOnUiThread(() -> result.error("ERROR", "Prediction failed", e.toString()));
            }
        }).start();
    }

    private File prepareModelDirectory() throws IOException {
        File modelDir = new File(getContext().getCacheDir(), "model");
        if (!modelDir.exists() && !modelDir.mkdirs() && !modelDir.exists()) {
            throw new IOException("Failed to create model directory: " + modelDir.getAbsolutePath());
        }
        return modelDir;
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
