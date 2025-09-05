package com.Lutasubin.freeVpn;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;

import java.util.Map;

import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

/**
 * Custom Native Ad Factory để tạo layout tùy chỉnh cho native ads
 * Tạo layout giống như trong design mẫu với background tối và button cam
 */
public class CustomNativeAdFactory implements GoogleMobileAdsPlugin.NativeAdFactory {

    private final Context context;

    public CustomNativeAdFactory(Context context) {
        this.context = context;
    }

    @Override
    public NativeAdView createNativeAd(NativeAd nativeAd, Map<String, Object> customOptions) {
        // Tạo NativeAdView container
        NativeAdView adView = new NativeAdView(context);

        // Tạo main container với background tối
        LinearLayout mainContainer = new LinearLayout(context);
        mainContainer.setOrientation(LinearLayout.VERTICAL);
        mainContainer.setLayoutParams(new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ));

        // Set background tối với border radius và border
        GradientDrawable background = new GradientDrawable();
        background.setColor(Color.parseColor("#172032")); // Đổi màu nền như yêu cầu
        background.setCornerRadius(dpToPx(8)); // Đổi corner radius thành 8
        background.setStroke(dpToPx(1), Color.argb(13, 255, 255, 255)); // Thêm border trắng với opacity 0.05 (13/255)
        mainContainer.setBackground(background);
        mainContainer.setPadding(dpToPx(8), dpToPx(8), dpToPx(8), dpToPx(8));

        // Tạo header container (icon + text info)
        LinearLayout headerContainer = new LinearLayout(context);
        headerContainer.setOrientation(LinearLayout.HORIZONTAL);
        headerContainer.setLayoutParams(new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ));

        // Tạo app icon
        ImageView iconView = new ImageView(context);
        LinearLayout.LayoutParams iconParams = new LinearLayout.LayoutParams(
            dpToPx(40), dpToPx(40)
        );
        iconView.setLayoutParams(iconParams);

        // Set icon background
        GradientDrawable iconBg = new GradientDrawable();
        iconBg.setColor(Color.parseColor("#E0E0E0"));
        iconBg.setCornerRadius(dpToPx(8));
        iconView.setBackground(iconBg);
        iconView.setScaleType(ImageView.ScaleType.CENTER);

        // Tạo text container (title + description)
        LinearLayout textContainer = new LinearLayout(context);
        textContainer.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams textParams = new LinearLayout.LayoutParams(
            0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.0f
        );
        textParams.setMarginStart(dpToPx(8));
        textContainer.setLayoutParams(textParams);

        // Tạo title text
        TextView titleView = new TextView(context);
        titleView.setLayoutParams(new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ));
        titleView.setTextColor(Color.WHITE);
        titleView.setTextSize(14);
        titleView.setTypeface(null, android.graphics.Typeface.BOLD);
        titleView.setSingleLine(true);
        titleView.setText("Title ads");

        // Tạo description container (AD badge + text)
        LinearLayout descContainer = new LinearLayout(context);
        descContainer.setOrientation(LinearLayout.HORIZONTAL);
        descContainer.setLayoutParams(new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ));
        LinearLayout.LayoutParams descContainerParams = (LinearLayout.LayoutParams) descContainer.getLayoutParams();
        descContainerParams.setMargins(0, dpToPx(2), 0, 0);

        // Tạo AD badge
        TextView adBadge = new TextView(context);
        LinearLayout.LayoutParams badgeParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        adBadge.setLayoutParams(badgeParams);

        // Style AD badge
        GradientDrawable badgeBg = new GradientDrawable();
        badgeBg.setColor(Color.parseColor("#4CAF50")); // Green
        badgeBg.setCornerRadius(dpToPx(4));
        adBadge.setBackground(badgeBg);
        adBadge.setPadding(dpToPx(6), dpToPx(2), dpToPx(6), dpToPx(2));
        adBadge.setTextColor(Color.WHITE);
        adBadge.setTextSize(10);
        adBadge.setTypeface(null, android.graphics.Typeface.BOLD);
        adBadge.setText("AD");

        // Tạo description text
        TextView descView = new TextView(context);
        LinearLayout.LayoutParams descParams = new LinearLayout.LayoutParams(
            0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.0f
        );
        descParams.setMarginStart(dpToPx(8));
        descView.setLayoutParams(descParams);
        descView.setTextColor(Color.GRAY);
        descView.setTextSize(12);
        descView.setSingleLine(true);
        descView.setText("Install video maker app for free!");

        // Add views to description container
        descContainer.addView(adBadge);
        descContainer.addView(descView);

        // Add views to text container
        textContainer.addView(titleView);
        textContainer.addView(descContainer);

        // Add views to header container
        headerContainer.addView(iconView);
        headerContainer.addView(textContainer);

        // Tạo button container để center button
        LinearLayout buttonContainer = new LinearLayout(context);
        buttonContainer.setOrientation(LinearLayout.HORIZONTAL);
        buttonContainer.setGravity(Gravity.CENTER);
        LinearLayout.LayoutParams buttonContainerParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        buttonContainerParams.setMargins(0, dpToPx(6), 0, 0);
        buttonContainer.setLayoutParams(buttonContainerParams);

        // Tạo install button với width nhỏ hơn
        Button installButton = new Button(context);
        LinearLayout.LayoutParams buttonParams = new LinearLayout.LayoutParams(
            dpToPx(120), // Width cố định 120dp
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        installButton.setLayoutParams(buttonParams);

        // Style install button
        GradientDrawable buttonBg = new GradientDrawable();
        buttonBg.setColor(Color.parseColor("#F15E24")); // Orange
        buttonBg.setCornerRadius(dpToPx(6));
        installButton.setBackground(buttonBg);
        installButton.setTextColor(Color.WHITE);
        installButton.setTextSize(12);
        installButton.setTypeface(null, android.graphics.Typeface.BOLD);
        installButton.setText("INSTALL");
        installButton.setAllCaps(true);
        installButton.setPadding(0, dpToPx(8), 0, dpToPx(8));

        // Add button to container
        buttonContainer.addView(installButton);

        // Add views to main container
        mainContainer.addView(headerContainer);
        mainContainer.addView(buttonContainer);

        // Add container to ad view
        adView.addView(mainContainer);

        // Set native ad data
        if (nativeAd.getIcon() != null) {
            iconView.setImageDrawable(nativeAd.getIcon().getDrawable());
        }
        
        if (nativeAd.getHeadline() != null) {
            titleView.setText(nativeAd.getHeadline());
        }
        
        if (nativeAd.getBody() != null) {
            descView.setText(nativeAd.getBody());
        }
        
        if (nativeAd.getCallToAction() != null) {
            installButton.setText(nativeAd.getCallToAction().toUpperCase());
        }

        // Register views with NativeAdView
        adView.setIconView(iconView);
        adView.setHeadlineView(titleView);
        adView.setBodyView(descView);
        adView.setCallToActionView(installButton);

        // Set the native ad
        adView.setNativeAd(nativeAd);

        return adView;
    }

    private int dpToPx(int dp) {
        float density = context.getResources().getDisplayMetrics().density;
        return Math.round(dp * density);
    }
}