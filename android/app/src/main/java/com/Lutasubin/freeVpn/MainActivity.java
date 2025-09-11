package com.Lutasubin.freeVpn;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.VpnService;
import android.os.Bundle;
import android.os.Handler;
import android.os.RemoteException;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.multidex.MultiDex;

import org.json.JSONObject;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;

import de.blinkt.openvpn.VpnProfile;
import de.blinkt.openvpn.core.ConfigParser;
import de.blinkt.openvpn.core.OpenVPNService;
import de.blinkt.openvpn.core.OpenVPNThread;
import de.blinkt.openvpn.core.ProfileManager;
import de.blinkt.openvpn.core.VPNLaunchHelper;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

// UMP SDK
import com.google.android.ump.ConsentForm;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.UserMessagingPlatform;

// Google Mobile Ads
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

import androidx.core.view.WindowCompat;

// StunnelEngine import
import com.Lutasubin.freeVpn.StunnelEngine;


public class MainActivity extends FlutterActivity {
    private MethodChannel vpnControlMethod;
    private EventChannel vpnControlEvent;
    private EventChannel vpnStatusEvent;
    private EventChannel.EventSink vpnStageSink;
    private EventChannel.EventSink vpnStatusSink;

    private static final String EVENT_CHANNEL_VPN_STAGE = "vpnStage";
    private static final String EVENT_CHANNEL_VPN_STATUS = "vpnStatus";
    private static final String METHOD_CHANNEL_VPN_CONTROL = "vpnControl";
    private static final int VPN_REQUEST_ID = 1;
    private static final int VPN_REQUEST_ID_WG = 1001;
    private static final String TAG = "VPN";

    private VpnProfile vpnProfile;
    private String config = "", username = "", password = "", name = "";
    private String dns1 = VpnProfile.DEFAULT_DNS1, dns2 = VpnProfile.DEFAULT_DNS2;
    private ArrayList<String> bypassPackages;
    private boolean attached = true;
    private JSONObject localJson;

    private String pendingWgName = null;
    private String pendingWgConfig = null;
    private boolean pendingWireGuard = false;
    private MethodChannel.Result pendingWireGuardResult = null;

    private Handler mainHandler = new Handler();

    @Override
    public void finish() {
        vpnControlEvent.setStreamHandler(null);
        vpnControlMethod.setMethodCallHandler(null);
        vpnStatusEvent.setStreamHandler(null);
        super.finish();
    }

    @Override
    protected void attachBaseContext(Context newBase) {
        super.attachBaseContext(newBase);
        MultiDex.install(this);
    }

    @Override
    public void onDetachedFromWindow() {
        attached = false;
        super.onDetachedFromWindow();
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        }

        NativeLibInitializer.initializeNativeLibs(this);

        LocalBroadcastManager.getInstance(this).registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String stage = intent.getStringExtra("state");
                if (stage != null) setStage(stage);

                if (vpnStatusSink != null) {
                    try {
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("duration", intent.getStringExtra("duration") != null ? intent.getStringExtra("duration") : "00:00:00");
                        jsonObject.put("last_packet_receive", intent.getStringExtra("lastPacketReceive") != null ? intent.getStringExtra("lastPacketReceive") : "0");
                        jsonObject.put("byte_in", intent.getStringExtra("byteIn") != null ? intent.getStringExtra("byteIn") : " ");
                        jsonObject.put("byte_out", intent.getStringExtra("byteOut") != null ? intent.getStringExtra("byteOut") : " ");
                        localJson = jsonObject;

                        if (attached) vpnStatusSink.success(jsonObject.toString());
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }, new IntentFilter("connectionState"));

        super.onCreate(savedInstanceState);

        ConsentRequestParameters params = new ConsentRequestParameters.Builder()
            .setTagForUnderAgeOfConsent(false)
            .build();

        ConsentInformation consentInformation = UserMessagingPlatform.getConsentInformation(this);

        consentInformation.requestConsentInfoUpdate(
            this,
            params,
            () -> {
                if (consentInformation.isConsentFormAvailable()) {
                    UserMessagingPlatform.loadAndShowConsentFormIfRequired(
                        this,
                        formError -> {
                            if (formError != null) {
                                Log.w(TAG, "Consent form error: " + formError.getMessage());
                            }
                        }
                    );
                }
            },
            formError -> {
                if (formError != null) {
                    Log.w(TAG, "Consent info update error: " + formError.getMessage());
                }
            }
        );
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Đăng ký StunnelEngine plugin
        flutterEngine.getPlugins().add(new StunnelEngine());

        // Đăng ký Custom Native Ad Factories
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "customNativeAd",
            new CustomNativeAdFactory(this)
        );

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "customNativeAdMedium",
            new CustomNativeAdMediumFactory(this)
        );

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "customNativeAdFull",
            new CustomNativeAdFullFactory(this)
        );

        vpnControlEvent = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL_VPN_STAGE);
        vpnControlEvent.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                vpnStageSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                vpnStageSink.endOfStream();
            }
        });

        vpnStatusEvent = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL_VPN_STATUS);
        vpnStatusEvent.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                vpnStatusSink = events;
            }

            @Override
            public void onCancel(Object arguments) {}
        });

        vpnControlMethod = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL_VPN_CONTROL);
        vpnControlMethod.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "stop":
                    stopAllVPNs();
                    break;
                case "start":
                    config = call.argument("config");
                    name = call.argument("country");
                    username = call.argument("username");
                    password = call.argument("password");
                    dns1 = call.argument("dns1") != null ? call.argument("dns1") : dns1;
                    dns2 = call.argument("dns2") != null ? call.argument("dns2") : dns2;
                    bypassPackages = call.argument("bypass_packages");

                    if (config == null || name == null) {
                        Log.e(TAG, "Config not valid!");
                        return;
                    }

                    if (isWireGuardConnected()) {
                        WireGuardEngine.getInstance(this).stopTunnel();
                        mainHandler.postDelayed(this::prepareVPN, 2000);
                    } else {
                        prepareVPN();
                    }
                    break;
                case "refresh":
                    updateVPNStages();
                    break;
                case "refresh_status":
                    updateVPNStatus();
                    break;
                case "stage":
                    result.success(OpenVPNService.getStatus());
                    break;
                case "kill_switch":
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                        Intent intent = new Intent(Settings.ACTION_VPN_SETTINGS);
                        startActivity(intent);
                    }
                    break;
                case "startWireGuard": {
                    String wgName = call.argument("name");
                    String wgConfig = call.argument("config");

                    if (isOpenVPNConnected()) {
                        OpenVPNThread.stop();
                        mainHandler.postDelayed(() -> startWireGuardProcess(wgName, wgConfig, result), 2000);
                    } else {
                        startWireGuardProcess(wgName, wgConfig, result);
                    }
                    break;
                }
                case "stopWireGuard": {
                    boolean stopped = WireGuardEngine.getInstance(this).stopTunnel();
                    result.success(stopped);
                    if (stopped) setStage("DISCONNECTED");
                    break;
                }
                case "getWireGuardState": {
                    String state = WireGuardEngine.getInstance(this).getTunnelState();
                    result.success(state);
                    break;
                }
            }
        });
    }

    private void startWireGuardProcess(String wgName, String wgConfig, MethodChannel.Result result) {
        Intent vpnIntent = VpnService.prepare(this);
        if (vpnIntent != null) {
            pendingWgName = wgName;
            pendingWgConfig = wgConfig;
            pendingWireGuard = true;
            pendingWireGuardResult = result;
            startActivityForResult(vpnIntent, VPN_REQUEST_ID_WG);
        } else {
            setStage("CONNECTING");
            new Thread(() -> {
                try {
                    boolean started = WireGuardEngine.getInstance(this).startTunnel(wgName, wgConfig);
                    runOnUiThread(() -> {
                        result.success(started);
                        setStage(started ? "CONNECTED" : "DISCONNECTED");
                    });
                } catch (Exception e) {
                    runOnUiThread(() -> {
                        result.success(false);
                        setStage("DISCONNECTED");
                        Toast.makeText(this, "WireGuard failed: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                    });
                }
            }).start();
        }
    }

    private void prepareVPN() {
        if (isConnected()) {
            setStage("prepare");
            try {
                ConfigParser parser = new ConfigParser();
                parser.parseConfig(new StringReader(config));
                vpnProfile = parser.convertProfile();
            } catch (IOException | ConfigParser.ConfigParseError e) {
                e.printStackTrace();
            }

            Intent vpnIntent = VpnService.prepare(this);
            if (vpnIntent != null) {
                startActivityForResult(vpnIntent, VPN_REQUEST_ID);
            } else {
                startVPN();
            }
        } else {
            setStage("nonetwork");
        }
    }

    private void startVPN() {
        try {
            setStage("connecting");

            if (vpnProfile.checkProfile(this) != de.blinkt.openvpn.R.string.no_error_found) {
                throw new RemoteException(getString(vpnProfile.checkProfile(this)));
            }

            vpnProfile.mName = name;
            vpnProfile.mProfileCreator = getPackageName();
            vpnProfile.mUsername = username;
            vpnProfile.mPassword = password;
            vpnProfile.mDNS1 = dns1;
            vpnProfile.mDNS2 = dns2;
            vpnProfile.mOverrideDNS = dns1 != null && dns2 != null;

            if (bypassPackages != null && !bypassPackages.isEmpty()) {
                vpnProfile.mAllowedAppsVpn.addAll(bypassPackages);
                vpnProfile.mAllowAppVpnBypass = true;
            }

            ProfileManager.setTemporaryProfile(this, vpnProfile);
            VPNLaunchHelper.startOpenVpn(vpnProfile, this);
        } catch (Exception e) {
            Log.e(TAG, "Error: " + e.getMessage(), e);
            setStage("disconnected");
            Toast.makeText(this, "Failed to start VPN: " + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    private void stopAllVPNs() {
        if (isOpenVPNConnected()) OpenVPNThread.stop();
        if (isWireGuardConnected()) WireGuardEngine.getInstance(this).stopTunnel();
        setStage("disconnected");
    }

    private boolean isOpenVPNConnected() {
        String status = OpenVPNService.getStatus();
        return status != null && (status.equals("CONNECTED") || status.equals("LEVEL_CONNECTED"));
    }

    private boolean isWireGuardConnected() {
        try {
            String state = WireGuardEngine.getInstance(this).getTunnelState();
            return "UP".equals(state);
        } catch (Exception e) {
            return false;
        }
    }

    private void updateVPNStages() {
        setStage(OpenVPNService.getStatus());
    }

    private void updateVPNStatus() {
        if (attached && localJson != null) {
            vpnStatusSink.success(localJson.toString());
        }
    }

    private boolean isConnected() {
        ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo info = cm.getActiveNetworkInfo();
        return info != null && info.isConnectedOrConnecting();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == VPN_REQUEST_ID && resultCode == RESULT_OK) startVPN();
        else if (requestCode == VPN_REQUEST_ID) {
            setStage("disconnected");
            Toast.makeText(this, "Permission is denied! VPN disconnected.", Toast.LENGTH_SHORT).show();
        }

        if (requestCode == VPN_REQUEST_ID_WG && resultCode == RESULT_OK && pendingWireGuard) {
            setStage("CONNECTING");
            new Thread(() -> {
                try {
                    boolean started = WireGuardEngine.getInstance(this).startTunnel(pendingWgName, pendingWgConfig);
                    runOnUiThread(() -> {
                        if (pendingWireGuardResult != null) pendingWireGuardResult.success(started);
                        setStage(started ? "CONNECTED" : "DISCONNECTED");
                        resetPendingWireGuard();
                    });
                } catch (Exception e) {
                    runOnUiThread(() -> {
                        if (pendingWireGuardResult != null) pendingWireGuardResult.success(false);
                        setStage("DISCONNECTED");
                        Toast.makeText(this, "WireGuard failed to start: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                        resetPendingWireGuard();
                    });
                }
            }).start();
        } else if (requestCode == VPN_REQUEST_ID_WG && pendingWireGuardResult != null) {
            pendingWireGuardResult.success(false);
            setStage("DISCONNECTED");
            Toast.makeText(this, "Permission is denied! WireGuard VPN disconnected.", Toast.LENGTH_SHORT).show();
            resetPendingWireGuard();
        }
    }

    private void resetPendingWireGuard() {
        pendingWireGuard = false;
        pendingWgName = null;
        pendingWgConfig = null;
        pendingWireGuardResult = null;
    }

    private void setStage(String stage) {
        if (vpnStageSink == null || !attached) return;
        switch (stage.toUpperCase()) {
            case "CONNECTED": vpnStageSink.success("connected"); break;
            case "DISCONNECTED": vpnStageSink.success("disconnected"); break;
            case "WAIT": vpnStageSink.success("wait_connection"); break;
            case "AUTH": vpnStageSink.success("authenticating"); break;
            case "RECONNECTING": vpnStageSink.success("reconnect"); break;
            case "NONETWORK": vpnStageSink.success("no_connection"); break;
            case "CONNECTING": vpnStageSink.success("connecting"); break;
            case "PREPARE": vpnStageSink.success("prepare"); break;
            case "DENIED": vpnStageSink.success("denied"); break;
        }
    }
}
