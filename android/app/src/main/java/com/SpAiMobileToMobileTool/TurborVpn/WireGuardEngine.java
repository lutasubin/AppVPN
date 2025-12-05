package com.SpAiMobileToMobileTool.TurborVpn;

import android.content.Context;
import android.util.Log;

import com.wireguard.android.backend.GoBackend;
import com.wireguard.android.backend.Tunnel;
import com.wireguard.config.Config;

import java.io.StringReader;
import java.io.BufferedReader;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.Future;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.TimeoutException;

public class WireGuardEngine {
    private static final String TAG = "WireGuardEngine";
    private static final int OPERATION_TIMEOUT_SECONDS = 15;
    private static WireGuardEngine instance;

    private final GoBackend backend;
    private final Context context;
    private final ExecutorService executorService;
    private Tunnel tunnel;
    private String tunnelName;
    private volatile boolean isOperationInProgress = false;

    private WireGuardEngine(Context context) {
        this.context = context.getApplicationContext();
        this.backend = new GoBackend(this.context);
        this.executorService = Executors.newSingleThreadExecutor();
    }

    public static synchronized WireGuardEngine getInstance(Context context) {
        if (instance == null) {
            instance = new WireGuardEngine(context);
        }
        return instance;
    }

    public boolean startTunnel(String name, String configStr) {
        // Prevent concurrent operations
        if (isOperationInProgress) {
            Log.w(TAG, "[WARN] Operation already in progress, skipping startTunnel");
            return false;
        }

        try {
            isOperationInProgress = true;
            Log.d(TAG, "[DEBUG] startTunnel called with name: " + name);
            
            // Don't log full config for security (contains private keys)
            Log.d(TAG, "[DEBUG] Config received, length: " + configStr.length());

            // Stop existing tunnel first if any
            if (tunnel != null && !tunnelName.equals(name)) {
                Log.d(TAG, "[DEBUG] Stopping existing tunnel before starting new one");
                stopTunnelInternal();
            }

            // Parse config
            Config config = Config.parse(new BufferedReader(new StringReader(configStr)));
            tunnel = new SimpleTunnel(name);
            tunnelName = name;

            Log.d(TAG, "[DEBUG] backend.setState: UP");
            
            // Use executor with timeout to prevent hanging
            Future<Void> future = executorService.submit(() -> {
                try {
                    backend.setState(tunnel, Tunnel.State.UP, config);
                    return null;
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            });

            // Wait with timeout
            future.get(OPERATION_TIMEOUT_SECONDS, TimeUnit.SECONDS);

            // Verify tunnel is actually up
            Tunnel.State currentState = backend.getState(tunnel);
            if (currentState == Tunnel.State.UP) {
                Log.d(TAG, "[INFO] WireGuard tunnel started successfully: " + name);
                return true;
            } else {
                Log.e(TAG, "[ERROR] Tunnel state is not UP after start: " + currentState);
                return false;
            }

        } catch (TimeoutException e) {
            Log.e(TAG, "[ERROR] Timeout starting WireGuard tunnel", e);
            // Clean up on timeout
            cleanupTunnel();
            return false;
        } catch (Exception e) {
            Log.e(TAG, "[ERROR] Failed to start WireGuard tunnel", e);
            // Clean up on error
            cleanupTunnel();
            return false;
        } finally {
            isOperationInProgress = false;
        }
    }

    public boolean stopTunnel() {
        if (isOperationInProgress) {
            Log.w(TAG, "[WARN] Operation already in progress, skipping stopTunnel");
            return false;
        }

        try {
            isOperationInProgress = true;
            return stopTunnelInternal();
        } finally {
            isOperationInProgress = false;
        }
    }

    private boolean stopTunnelInternal() {
        try {
            Log.d(TAG, "[DEBUG] stopTunnel called");
            if (tunnel != null) {
                Log.d(TAG, "[DEBUG] backend.setState: DOWN");
                
                // Use executor with timeout
                Future<Void> future = executorService.submit(() -> {
                    try {
                        backend.setState(tunnel, Tunnel.State.DOWN, null);
                        return null;
                    } catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                });

                // Wait with timeout
                future.get(OPERATION_TIMEOUT_SECONDS, TimeUnit.SECONDS);
                
                Log.d(TAG, "[INFO] WireGuard tunnel stopped: " + tunnelName);
                cleanupTunnel();
            } else {
                Log.w(TAG, "[WARN] stopTunnel called but tunnel is null");
            }
            return true;
        } catch (TimeoutException e) {
            Log.e(TAG, "[ERROR] Timeout stopping WireGuard tunnel", e);
            // Force cleanup even on timeout
            cleanupTunnel();
            return true; // Return true since we cleaned up
        } catch (Exception e) {
            Log.e(TAG, "[ERROR] Failed to stop WireGuard tunnel", e);
            // Force cleanup even on error
            cleanupTunnel();
            return false;
        }
    }

    private void cleanupTunnel() {
        tunnel = null;
        tunnelName = null;
    }

    public String getTunnelState() {
        try {
            if (tunnel == null) {
                Log.d(TAG, "[DEBUG] getTunnelState: tunnel is null, returning DOWN");
                return "DOWN";
            }
            
            Tunnel.State state = backend.getState(tunnel);
            Log.d(TAG, "[DEBUG] getTunnelState: " + state.name());
            return state.name();
        } catch (Exception e) {
            Log.e(TAG, "[ERROR] Failed to get WireGuard tunnel state", e);
            return "ERROR";
        }
    }

    public String getTunnelName() {
        return tunnelName;
    }

    public boolean isOperationInProgress() {
        return isOperationInProgress;
    }

    // Force stop all operations (emergency cleanup)
    public void forceStop() {
        Log.w(TAG, "[WARN] Force stopping WireGuard engine");
        isOperationInProgress = false;
        cleanupTunnel();
        
        // Cancel any pending operations
        if (executorService != null && !executorService.isShutdown()) {
            executorService.shutdownNow();
        }
    }

    // Cleanup resources
    public void destroy() {
        Log.d(TAG, "[DEBUG] Destroying WireGuard engine");
        stopTunnel();
        
        if (executorService != null && !executorService.isShutdown()) {
            executorService.shutdown();
            try {
                if (!executorService.awaitTermination(5, TimeUnit.SECONDS)) {
                    executorService.shutdownNow();
                }
            } catch (InterruptedException e) {
                executorService.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
        
        instance = null;
    }

    // Simple implementation of Tunnel interface
    private static class SimpleTunnel implements Tunnel {
        private final String name;
        private volatile State state = State.DOWN;

        SimpleTunnel(String name) {
            this.name = name;
        }

        @Override
        public String getName() {
            return name;
        }

        @Override
        public void onStateChange(State newState) {
            Log.d(TAG, "[DEBUG] Tunnel state changed: " + state + " -> " + newState);
            this.state = newState;
        }

        public State getCurrentState() {
            return state;
        }
    }
}