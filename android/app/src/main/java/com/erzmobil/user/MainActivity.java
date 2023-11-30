package com.erzmobil.user;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import android.net.Uri;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import java.util.Map;
import java.io.*;
import android.util.Log;

import static android.content.Intent.ACTION_VIEW;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "erzmobil.native/share";
    private static final String TAG = "MainActivity";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        Log.d(TAG,"configureFlutterEngine");
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    Log.d(TAG, "call.method: "+call.method);
                    if (call.method.equals("shareLocation")) {
                        expectMapArguments(call);
                        _shareLocation((String) call.argument("lat"), (String) call.argument("lng"));
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }

    private void expectMapArguments(MethodCall call) throws IllegalArgumentException {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
    }

    void _shareLocation(String latitude, String longitude) {
        if (null == latitude || null == longitude) {
            return;
        }

        String mapsUri = "http://maps.google.com/maps?";

        mapsUri += "&daddr=" + latitude + "," + longitude;
        mapsUri += "&dirflg=w";

        Intent intent = new Intent(ACTION_VIEW, Uri.parse(mapsUri));
        startActivity(intent);
    }

    void _requestPushPermission() {
        
    }
}
