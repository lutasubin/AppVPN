package com.Lutasubin.freeVpn;

import android.content.Context;
import android.util.Log;
import java.io.File;

public class NativeLibInitializer {
    private static final String TAG = "NativeLibInitializer";
    
    // Khởi tạo thư viện native
    public static void initializeNativeLibs(Context context) {
        try {
            Log.d(TAG, "Initializing native libraries...");
            
            // In ra đường dẫn thư viện để debug
            String libPath = context.getApplicationInfo().nativeLibraryDir;
            Log.d(TAG, "Native library path: " + libPath);
            
            // Kiểm tra xem thư viện có tồn tại không
            File jbcryptoFile = new File(libPath, "libjbcrypto.so");
            File openvpnFile = new File(libPath, "libopenvpn.so");
            File opvpnutilFile = new File(libPath, "libopvpnutil.so");
            File ovpnexecFile = new File(libPath, "libovpnexec.so");
            
            Log.d(TAG, "libjbcrypto.so exists: " + jbcryptoFile.exists());
            Log.d(TAG, "libopenvpn.so exists: " + openvpnFile.exists());
            Log.d(TAG, "libopvpnutil.so exists: " + opvpnutilFile.exists());
            Log.d(TAG, "libovpnexec.so exists: " + ovpnexecFile.exists());
            
            // Load các thư viện native OpenVPN
            System.loadLibrary("jbcrypto");
            System.loadLibrary("openvpn");
            System.loadLibrary("opvpnutil");
            System.loadLibrary("ovpnexec");
            
            Log.d(TAG, "Native libraries loaded successfully");
        } catch (UnsatisfiedLinkError e) {
            Log.e(TAG, "Failed to load native libraries: " + e.getMessage(), e);
        } catch (Exception e) {
            Log.e(TAG, "Exception initializing native libraries: " + e.getMessage(), e);
        }
    }
} 