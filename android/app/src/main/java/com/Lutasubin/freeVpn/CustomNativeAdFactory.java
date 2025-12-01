package com.Lutasubin.freeVpn;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;

import java.util.Map;

import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class CustomNativeAdFactory implements GoogleMobileAdsPlugin.NativeAdFactory {

    private final Context context;

    public CustomNativeAdFactory(Context context) {
        this.context = context;
    }

    @Override
    public NativeAdView createNativeAd(NativeAd nativeAd, Map<String, Object> customOptions) {
        NativeAdView adView = new NativeAdView(context);

        // ================= MAIN CONTAINER =================
        LinearLayout mainContainer = new LinearLayout(context);
        mainContainer.setOrientation(LinearLayout.HORIZONTAL);
        mainContainer.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
        ));

        GradientDrawable background = new GradientDrawable();
        background.setColor(Color.parseColor("#1A2332")); // nền xanh đậm
        background.setCornerRadius(dpToPx(12));
        mainContainer.setBackground(background);
        mainContainer.setPadding(dpToPx(10), dpToPx(10), dpToPx(10), dpToPx(10));

        // ================= LEFT SIDE (info + button) =================
        LinearLayout leftContainer = new LinearLayout(context);
        leftContainer.setOrientation(LinearLayout.VERTICAL);
        leftContainer.setLayoutParams(new LinearLayout.LayoutParams(
                0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.0f
        ));

        // Row AD label + Icon + Text
        LinearLayout headerRow = new LinearLayout(context);
        headerRow.setOrientation(LinearLayout.HORIZONTAL);
        headerRow.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
        ));
        headerRow.setGravity(Gravity.CENTER_VERTICAL);

        // Label "AD"
        TextView adLabel = new TextView(context);
        LinearLayout.LayoutParams adLabelParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
        );
        adLabelParams.setMarginEnd(dpToPx(6));
        adLabel.setLayoutParams(adLabelParams);

        GradientDrawable adBg = new GradientDrawable();
        adBg.setColor(Color.parseColor("#4CAF50")); // xanh lá
        adBg.setCornerRadius(dpToPx(4));
        adLabel.setBackground(adBg);

        adLabel.setText("AD");
        adLabel.setTextColor(Color.WHITE);
        adLabel.setTextSize(10);
        adLabel.setPadding(dpToPx(4), dpToPx(2), dpToPx(4), dpToPx(2));

        // Icon
        ImageView iconView = new ImageView(context);
        LinearLayout.LayoutParams iconParams = new LinearLayout.LayoutParams(
                dpToPx(20), dpToPx(20)
        );
        iconParams.setMarginEnd(dpToPx(8));
        iconView.setLayoutParams(iconParams);
        iconView.setScaleType(ImageView.ScaleType.CENTER_CROP);

        // Text container
        LinearLayout textContainer = new LinearLayout(context);
        textContainer.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams textParams = new LinearLayout.LayoutParams(
                0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.0f
        );
        textParams.setMargins(0, 0, dpToPx(8), 0);
        textContainer.setLayoutParams(textParams);

        TextView titleView = new TextView(context);
        titleView.setTextColor(Color.WHITE);
        titleView.setTextSize(14);
        titleView.setTypeface(null, android.graphics.Typeface.BOLD);
        titleView.setSingleLine(true);

        TextView descView = new TextView(context);
        descView.setTextColor(Color.parseColor("#8A94A6"));
        descView.setTextSize(11);
        descView.setSingleLine(true);
        descView.setPadding(0, dpToPx(2), 0, 0);

        textContainer.addView(titleView);
        textContainer.addView(descView);

        headerRow.addView(adLabel);
        headerRow.addView(iconView);
        headerRow.addView(textContainer);

        // Button Install
        Button installButton = new Button(context);
        LinearLayout.LayoutParams buttonParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(40)
        );
        buttonParams.topMargin = dpToPx(8);
        installButton.setLayoutParams(buttonParams);

        GradientDrawable buttonBg = new GradientDrawable();
        buttonBg.setColor(Color.parseColor("#4A9EFF"));
        buttonBg.setCornerRadius(dpToPx(8));
        installButton.setBackground(buttonBg);
        installButton.setTextColor(Color.WHITE);
        installButton.setTextSize(14);
        installButton.setTypeface(null, android.graphics.Typeface.BOLD);
        installButton.setAllCaps(true);
        installButton.setText("INSTALL");

        leftContainer.addView(headerRow);
        leftContainer.addView(installButton);

        // ================= RIGHT SIDE (media view) =================
        com.google.android.gms.ads.nativead.MediaView mediaView =
                new com.google.android.gms.ads.nativead.MediaView(context);
        LinearLayout.LayoutParams mediaParams = new LinearLayout.LayoutParams(
                0, dpToPx(120), 1.0f
        );
        mediaView.setLayoutParams(mediaParams);

      

        // ================= ADD TO MAIN =================
        mainContainer.addView(leftContainer);
        mainContainer.addView(mediaView);
        adView.addView(mainContainer);

        // ================= GÁN DỮ LIỆU =================
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

        adView.setIconView(iconView);
        adView.setHeadlineView(titleView);
        adView.setBodyView(descView);
        adView.setCallToActionView(installButton);
        adView.setMediaView(mediaView);

        adView.setNativeAd(nativeAd);

        return adView;
    }

    private int dpToPx(int dp) {
        float density = context.getResources().getDisplayMetrics().density;
        return Math.round(dp * density);
    }
}
