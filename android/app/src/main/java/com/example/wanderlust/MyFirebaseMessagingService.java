package com.example.wanderlust;
import android.util.Log;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MyFirebaseMessagingService extends FirebaseMessagingService {

    private static final String TAG = "FCMService";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.d(TAG, "Message received");

        if (remoteMessage.getData().containsKey("chatId")) {
            String chatId = remoteMessage.getData().get("chatId");
            String messageId = remoteMessage.getData().get("messageId");

            sendDeliveryStatus(chatId, messageId);
        }
    }

    private void sendDeliveryStatus(String chatId, String messageId) {
        try {
            OkHttpClient client = new OkHttpClient();

            MediaType JSON = MediaType.get("application/json; charset=utf-8");
            String json = "{\"chatId\":\"" + chatId + "\",\"messageId\":\"" + messageId + "\"}";

            RequestBody body = RequestBody.create(json, JSON);
            Request request = new Request.Builder()
                .url("https://fcm-server-gct0.onrender.com/updateDeliveryStatus")
                .post(body)
                .build();

            Response response = client.newCall(request).execute();
            Log.d(TAG, "Delivery status sent: " + response.code());
        } catch (Exception e) {
            Log.e(TAG, "Failed to send delivery status", e);
        }
    }
}
