package com.example.wanderlust;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import java.util.Collections;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MyFirebaseMessagingService extends FirebaseMessagingService {

    private static final String TAG = "FCMService";
    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

    private static final OkHttpClient client = new OkHttpClient.Builder()
        .connectTimeout(5, TimeUnit.SECONDS)
        .writeTimeout(5, TimeUnit.SECONDS)
        .readTimeout(5, TimeUnit.SECONDS)
        .build();

    private static final Set<String> processedMessageIds =
        Collections.newSetFromMap(new ConcurrentHashMap<String, Boolean>());

    @Override
    public void handleIntent(Intent intent) {
        if (intent != null && intent.getExtras() != null) {
            Bundle extras = intent.getExtras();
            String chatId = extras.getString("chatId");
            String messageId = extras.getString("messageId");

            if (chatId != null && messageId != null) {
                sendDeliveryStatus(chatId, messageId);
            }
        }

        super.handleIntent(intent);
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.d(TAG, "Message received");
    }

    private void sendDeliveryStatus(String chatId, String messageId) {
        if (chatId == null || messageId == null) return;

        if (!processedMessageIds.add(messageId)) {
            Log.d(TAG, "Delivery status already sent for messageId: " + messageId);
            return;
        }

        try {
            String json = "{\"chatId\":\"" + chatId + "\",\"messageId\":\"" + messageId + "\"}";
            RequestBody body = RequestBody.create(json, JSON);
            Request request = new Request.Builder()
                .url("https://wanderlust-api.navainnovation.com/updateDeliveryStatus")
                .post(body)
                .build();

            Response response = client.newCall(request).execute();
            Log.d(TAG, "Delivery status sent: " + response.code());
        } catch (Exception e) {
            Log.e(TAG, "Failed to send delivery status", e);
        }
    }
}
