package com.example.eindopdrachtmad;

import org.json.JSONObject;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import android.util.Log;

/**
 * Simple tokenizer that reads a Hugging Face tokenizer.json and performs basic tokenization.
 */
public class SimpleTokenizer {
    private final Map<String, Integer> vocab;
    private final int maxLength;
    private final int padTokenId;
    private final int clsTokenId;
    private final int sepTokenId;

    public SimpleTokenizer(File tokenizerFile) throws Exception {
        StringBuilder jsonBuilder = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new FileReader(tokenizerFile))) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }
        }

        JSONObject root = new JSONObject(jsonBuilder.toString());
        JSONObject model = root.getJSONObject("model");
        JSONObject vocabObj = model.getJSONObject("vocab");

        vocab = new HashMap<>();
        for (java.util.Iterator<String> it = vocabObj.keys(); it.hasNext(); ) {
            String key = it.next();
            vocab.put(key, vocabObj.getInt(key));
        }

        // Default values
        this.maxLength = 512;
        this.padTokenId = vocab.getOrDefault("[PAD]", 0);
        this.clsTokenId = vocab.getOrDefault("[CLS]", 101);
        this.sepTokenId = vocab.getOrDefault("[SEP]", 102);
    }

    public EncodedInput encode(String text) {
        
        // Basic tokenization: split on spaces and punctuation
        List<String> tokens = basicTokenize(text);
        Log.d("SimpleTokenizer", "Basic Tokens: " + tokens.toString());
        
        // Convert tokens to IDs
        List<Integer> inputIds = new ArrayList<>();
        inputIds.add(clsTokenId); // Add [CLS] token at start
        Log.d("SimpleTokenizer", "[CLS] Token ID: " + clsTokenId);
        
        for (String token : tokens) {
            Integer id = vocab.get(token);
            if (id == null) {
                // Try wordpiece tokenization for unknown words
                List<String> subTokens = wordpieceTokenize(token);
                for (String subToken : subTokens) {
                    Integer subId = vocab.getOrDefault(subToken, vocab.getOrDefault("[UNK]", 100));
                    inputIds.add(subId);
                    Log.d("SimpleTokenizer", "Token: '" + subToken + "' -> ID: " + subId);
                }
            } else {
                inputIds.add(id);
                Log.d("SimpleTokenizer", "Token: '" + token + "' -> ID: " + id);
            }
        }
        
        inputIds.add(sepTokenId); // Add [SEP] token at end
        Log.d("SimpleTokenizer", "[SEP] Token ID: " + sepTokenId);
        Log.d("SimpleTokenizer", "Raw Input IDs (before truncation): " + inputIds.toString());
        
        // Truncate if too long
        if (inputIds.size() > maxLength) {
            inputIds = inputIds.subList(0, maxLength - 1);
            inputIds.add(sepTokenId);
            Log.d("SimpleTokenizer", "Input IDs after truncation: " + inputIds.toString());
        }
        
        // Create attention mask (all 1s for real tokens)
        long[] attentionMask = new long[inputIds.size()];
        for (int i = 0; i < attentionMask.length; i++) {
            attentionMask[i] = 1;
        }
        
        // Convert to long array
        long[] ids = new long[inputIds.size()];
        for (int i = 0; i < inputIds.size(); i++) {
            ids[i] = inputIds.get(i);
        }
        
        return new EncodedInput(ids, attentionMask);
    }

    private List<String> basicTokenize(String text) {
        List<String> tokens = new ArrayList<>();
        StringBuilder currentToken = new StringBuilder();
        
        for (char c : text.toCharArray()) {
            if (Character.isWhitespace(c)) {
                if (currentToken.length() > 0) {
                    tokens.add(currentToken.toString());
                    currentToken = new StringBuilder();
                }
            } else if (isPunctuation(c)) {
                if (currentToken.length() > 0) {
                    tokens.add(currentToken.toString());
                    currentToken = new StringBuilder();
                }
                tokens.add(String.valueOf(c));
            } else {
                currentToken.append(c);
            }
        }
        
        if (currentToken.length() > 0) {
            tokens.add(currentToken.toString());
        }
        
        return tokens;
    }

    private List<String> wordpieceTokenize(String word) {
        List<String> tokens = new ArrayList<>();
        int start = 0;
        
        while (start < word.length()) {
            int end = word.length();
            String curSubstr = null;
            
            while (start < end) {
                String substr = word.substring(start, end);
                if (start > 0) {
                    substr = "##" + substr;
                }
                
                if (vocab.containsKey(substr)) {
                    curSubstr = substr;
                    break;
                }
                end--;
            }
            
            if (curSubstr == null) {
                tokens.add("[UNK]");
                return tokens;
            }
            
            tokens.add(curSubstr);
            start = end;
        }

        return tokens;
    }

    private boolean isPunctuation(char c) {
        return c == '.' || c == ',' || c == '!' || c == '?' || c == ';' || c == ':' ||
               c == '\'' || c == '"' || c == '(' || c == ')' || c == '[' || c == ']' ||
               c == '{' || c == '}' || c == '-' || c == '/' || c == '\\' || c == '_';
    }

    public static class EncodedInput {
        private final long[] ids;
        private final long[] attentionMask;
        public EncodedInput(long[] ids, long[] attentionMask) {
            this.ids = ids;
            this.attentionMask = attentionMask;
        }

        public long[] getIds() {
            return ids;
        }

        public long[] getAttentionMask() {
            return attentionMask;
        }
    }
}