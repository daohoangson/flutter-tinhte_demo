package com.daohoangson.flutter_ttdemo;

import android.app.NotificationManager;
import android.service.notification.StatusBarNotification;
import android.util.Log;

import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class FcmService extends FlutterFirebaseMessagingService {
    public static final String TAG = "FcmService";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);

        final Map<String, String> data = remoteMessage.getData();
        if (data.size() == 0) {
            return;
        }

        if (data.containsKey("read_notification_id")) {
            onNotificationRead(data.get("read_notification_id"));
        }
    }

    private void onNotificationRead(final String which) {
        final String tagPrefix = "notificationId=" + ("all".equals(which) ? "" : which);
        final int dismissed = dismissByTagPrefix(tagPrefix);
        Log.i(TAG, String.format("onNotificationRead(which=%s): dismissed=%d", which, dismissed));
    }

    private int dismissByTagPrefix(final String tagPrefix) {
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {
            Log.d(TAG, "dismissByTagPrefix: API level 23 is required");
            return 0;
        }

        final NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        final StatusBarNotification[] sbnList = nm.getActiveNotifications();
        if (sbnList == null) {
            return 0;
        }

        int count = 0;
        for (final StatusBarNotification sbn : sbnList) {
            final String tag = sbn.getTag();
            if (tag == null || !tag.startsWith(tagPrefix)) {
                continue;
            }

            nm.cancel(tag, sbn.getId());
            count++;
        }

        return count;
    }
}
