package com.example.eindopdrachtmad;

import java.io.File;
import java.nio.LongBuffer;
import java.util.Map;

import ai.onnxruntime.OnnxTensor;
import ai.onnxruntime.OrtEnvironment;
import ai.onnxruntime.OrtSession;

/**
 * Very small helper that:
 *   1. Loads the ONNX model & tokenizer
 *   2. Tokenises an input string
 *   3. Runs inference
 *   4. Returns one of 5 sentiment labels.
 */
public class SentimentPredictor {

    /* =====================  Instance fields ===================== */
    private final OrtEnvironment env;            // ONNX Runtime environment (JNI handles)
    private final OrtSession session;           // The compiled model
    private final SimpleTokenizer tokenizer;  // Turns text → token‑ids

    // Human‑readable labels that match the 5‑class output of the model
    private static final String[] LABELS = {
            "Very Negative",
            "Negative",
            "Neutral",
            "Positive",
            "Very Positive"
    };

    /* =====================  Constructor ===================== */
    /**
     * Initialise from a folder that contains:
     *   - model.onnx
     *   - tokenizer.json
     *
     * @param modelDir Folder that holds the two files
     * @throws Exception If the files can’t be read or the model can’t be loaded
     */
    public SentimentPredictor(File modelDir) throws Exception {
        // Create the ONNX Runtime environment
        env = OrtEnvironment.getEnvironment();

        // Load the serialized ONNX file
        File onnxModelFile = new File(modelDir, "model.onnx");
        session = env.createSession(
                onnxModelFile.getAbsolutePath(),
                new OrtSession.SessionOptions()
        );

        // Load the tokenizer (the tokenizer.json that came with the model)
        File tokenizerFile = new File(modelDir, "tokenizer.json");
        tokenizer = new SimpleTokenizer(tokenizerFile);
    }

    /* =====================  Public API ===================== */
    /**
     * Predict the sentiment of a single sentence.
     *
     * @param text The raw UTF‑8 string (any language)
     * @return One of the 5 sentiment labels
     * @throws Exception If inference fails
     */
    public String predict(String text) throws Exception {
        /* Tokenise – we get two integer arrays:
         *  ids       → input_ids  (token IDs)
         *  attention → attention_mask (1 for real tokens, 0 for padding)
         */
        SimpleTokenizer.EncodedInput encoded = tokenizer.encode(text);
        long[] inputIds = encoded.getIds();
        long[] attentionMask = encoded.getAttentionMask();

        /* Build tensors that ONNXRuntime expects.
         * The shape must match what the model was trained on: [batch, seq_len].
         * We always run a batch of 1.
         */
        OnnxTensor inputIdsTensor = OnnxTensor.createTensor(
                env,
                LongBuffer.wrap(inputIds),
                new long[]{1, inputIds.length}
        );

        OnnxTensor attentionMaskTensor = OnnxTensor.createTensor(
                env,
                LongBuffer.wrap(attentionMask),
                new long[]{1, attentionMask.length}
        );

        /* Prepare the input map that the model understands.
         * The keys must match the ONNX graph input names (“input_ids”,
         * “attention_mask”, …).  For most PyTorch‑based transformer models
         * these are the two names used.
         */
        Map<String, OnnxTensor> inputs = Map.of(
                "input_ids", inputIdsTensor,
                "attention_mask", attentionMaskTensor
        );

        /* Run the model */
        try (OrtSession.Result results = session.run(inputs)) {
            /* The model outputs a single tensor of shape [1, 5] – the logits
             * for each class.  We pull it out as a Java array. */
            float[][] logits = (float[][]) results.get(0).getValue();

            /* Arg‑max over the 5 logits to pick the most probable
             * sentiment class. */
            int bestIdx = 0;
            float bestScore = Float.NEGATIVE_INFINITY;
            for (int i = 0; i < logits[0].length; i++) {
                if (logits[0][i] > bestScore) {
                    bestScore = logits[0][i];
                    bestIdx = i;
                }
            }
            return LABELS[bestIdx];
        }
    }
}
