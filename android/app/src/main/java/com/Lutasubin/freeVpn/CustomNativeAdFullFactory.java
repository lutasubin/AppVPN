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
 * Custom Native Ad Full Factory để tạo layout native lớn giống fullscreen card
 * Layout: Badge AD + Media lớn, Headline, Body, CTA full width bo góc theo style app
 */
public class CustomNativeAdFullFactory implements GoogleMobileAdsPlugin.NativeAdFactory {

    private final Context context;

    public CustomNativeAdFullFactory(Context context) {
        this.context = context;
    }

    @Override
    public NativeAdView createNativeAd(NativeAd nativeAd, Map<String, Object> customOptions) {
        NativeAdView adView = new NativeAdView(context);

        LinearLayout mainContainer = new LinearLayout(context);
        mainContainer.setOrientation(LinearLayout.VERTICAL);
        mainContainer.setLayoutParams(new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.MATCH_PARENT
        ));

        // Nền đen toàn bộ
        GradientDrawable background = new GradientDrawable();
         background.setColor(Color.parseColor("#172032")); // Đổi màu nền như yêu cầu
        background.setCornerRadius(0);
         background.setStroke(dpToPx(1), Color.argb(13, 255, 255, 255)); // Thêm border trắng với opacity 0.05 (13/255)
        mainContainer.setBackground(background);
        mainContainer.setPadding(dpToPx(12), dpToPx(12), dpToPx(12), dpToPx(12));

        // Container nội dung có weight đẩy CTA xuống đáy
        LinearLayout contentContainer = new LinearLayout(context);
        contentContainer.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams contentParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            0,
            1f
        );
        contentContainer.setLayoutParams(contentParams);

        // AD badge
        TextView adBadge = new TextView(context);
        LinearLayout.LayoutParams badgeParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        badgeParams.setMargins(0, 0, 0, dpToPx(8));
        adBadge.setLayoutParams(badgeParams);
        GradientDrawable badgeBg = new GradientDrawable();
        badgeBg.setColor(Color.parseColor("#4CAF50"));
        badgeBg.setCornerRadius(dpToPx(4));
        adBadge.setBackground(badgeBg);
        adBadge.setPadding(dpToPx(6), dpToPx(2), dpToPx(6), dpToPx(2));
        adBadge.setTextColor(Color.WHITE);
        adBadge.setTextSize(10);
        adBadge.setTypeface(null, android.graphics.Typeface.BOLD);
        adBadge.setText("AD");

        // Media lớn (cao hơn medium)
        ImageView mediaView = new ImageView(context);
        LinearLayout.LayoutParams mediaParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            dpToPx(340)
        );
        mediaParams.setMargins(0, 0, 0, dpToPx(12));
        mediaView.setLayoutParams(mediaParams);
        GradientDrawable mediaBg = new GradientDrawable();
        mediaBg.setColor(Color.parseColor("#121212")); // dark placeholder
        mediaBg.setCornerRadius(dpToPx(8));
        mediaView.setBackground(mediaBg);
        mediaView.setScaleType(ImageView.ScaleType.CENTER_CROP);

        // Headline
        TextView titleView = new TextView(context);
        LinearLayout.LayoutParams titleParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        titleParams.setMargins(0, 0, 0, dpToPx(6));
        titleView.setLayoutParams(titleParams);
        titleView.setTextColor(Color.WHITE);
        titleView.setTextSize(18);
        titleView.setTypeface(null, android.graphics.Typeface.BOLD);
        titleView.setMaxLines(2);
        titleView.setText("Title ads");

        // Body
        TextView descView = new TextView(context);
        LinearLayout.LayoutParams descParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        descParams.setMargins(0, 0, 0, dpToPx(14));
        descView.setLayoutParams(descParams);
        descView.setTextColor(Color.parseColor("#B3B3B3"));
        descView.setTextSize(13);
        descView.setMaxLines(3);
        descView.setText("Install app for free!");

        // CTA button full width cố định ở đáy, màu cam
        Button ctaButton = new Button(context);
        LinearLayout.LayoutParams buttonParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        buttonParams.setMargins(dpToPx(8), dpToPx(8), dpToPx(8), dpToPx(8));
        ctaButton.setLayoutParams(buttonParams);
        GradientDrawable buttonBg = new GradientDrawable();
        buttonBg.setColor(Color.parseColor("#F15E24")); // Orange
        buttonBg.setCornerRadius(dpToPx(24));
        ctaButton.setBackground(buttonBg);
        ctaButton.setTextColor(Color.WHITE);
        ctaButton.setTextSize(14);
        ctaButton.setTypeface(null, android.graphics.Typeface.BOLD);
        ctaButton.setAllCaps(true);
        ctaButton.setPadding(0, dpToPx(12), 0, dpToPx(12));
        ctaButton.setText("INSTALL");

        // Add vào container: badge, media, texts trong content, CTA ở đáy
        contentContainer.addView(adBadge);
        contentContainer.addView(mediaView);
        contentContainer.addView(titleView);
        contentContainer.addView(descView);

        mainContainer.addView(contentContainer);
        mainContainer.addView(ctaButton);

        adView.addView(mainContainer);

        // Bind data thực tế
        if (nativeAd.getMediaContent() != null) {
            com.google.android.gms.ads.nativead.MediaView nativeMediaView =
                new com.google.android.gms.ads.nativead.MediaView(context);
            nativeMediaView.setLayoutParams(mediaParams);
            nativeMediaView.setMediaContent(nativeAd.getMediaContent());
            contentContainer.removeView(mediaView);
            contentContainer.addView(nativeMediaView, 1);
            adView.setMediaView(nativeMediaView);
        } else if (nativeAd.getImages() != null && !nativeAd.getImages().isEmpty()) {
            mediaView.setImageDrawable(nativeAd.getImages().get(0).getDrawable());
            adView.setImageView(mediaView);
        }

        if (nativeAd.getHeadline() != null) titleView.setText(nativeAd.getHeadline());
        if (nativeAd.getBody() != null) descView.setText(nativeAd.getBody());
        if (nativeAd.getCallToAction() != null) ctaButton.setText(nativeAd.getCallToAction().toUpperCase());

        adView.setHeadlineView(titleView);
        adView.setBodyView(descView);
        adView.setCallToActionView(ctaButton);

        adView.setNativeAd(nativeAd);
        return adView;
    }

    private int dpToPx(int dp) {
        float density = context.getResources().getDisplayMetrics().density;
        return Math.round(dp * density);
    }
}


