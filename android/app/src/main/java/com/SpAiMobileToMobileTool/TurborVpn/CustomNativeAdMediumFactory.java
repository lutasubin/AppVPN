package com.SpAiMobileToMobileTool.TurborVpn;

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
 * Custom Native Ad Medium Factory để tạo layout tùy chỉnh cho medium native ads
 * Layout: Image lớn ở trên, title + description ở dưới, button install full width
 */
public class CustomNativeAdMediumFactory implements GoogleMobileAdsPlugin.NativeAdFactory {

    private final Context context;

    public CustomNativeAdMediumFactory(Context context) {
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
        mainContainer.setPadding(dpToPx(12), dpToPx(12), dpToPx(12), dpToPx(12));

        // Tạo AD badge ở góc trên trái
        TextView adBadge = new TextView(context);
        LinearLayout.LayoutParams badgeParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        badgeParams.setMargins(0, 0, 0, dpToPx(8));
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

        // Tạo main image (media view)
        ImageView mediaView = new ImageView(context);
        LinearLayout.LayoutParams mediaParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            dpToPx(180) // Chiều cao cố định cho image
        );
        mediaParams.setMargins(0, 0, 0, dpToPx(12));
        mediaView.setLayoutParams(mediaParams);
        
        // Set media background
        GradientDrawable mediaBg = new GradientDrawable();
        mediaBg.setColor(Color.parseColor("#E0E0E0")); // Light gray placeholder
        mediaBg.setCornerRadius(dpToPx(8));
        mediaView.setBackground(mediaBg);
        mediaView.setScaleType(ImageView.ScaleType.CENTER_CROP);

        // Tạo title text
        TextView titleView = new TextView(context);
        LinearLayout.LayoutParams titleParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        titleParams.setMargins(0, 0, 0, dpToPx(4));
        titleView.setLayoutParams(titleParams);
        titleView.setTextColor(Color.WHITE);
        titleView.setTextSize(16);
        titleView.setTypeface(null, android.graphics.Typeface.BOLD);
        titleView.setMaxLines(2);
        titleView.setText("Title ads");

        // Tạo description text
        TextView descView = new TextView(context);
        LinearLayout.LayoutParams descParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        descParams.setMargins(0, 0, 0, dpToPx(12));
        descView.setLayoutParams(descParams);
        descView.setTextColor(Color.GRAY);
        descView.setTextSize(12);
        descView.setMaxLines(2);
        descView.setText("Install video maker app for free!");

        // Tạo install button full width
        Button installButton = new Button(context);
        LinearLayout.LayoutParams buttonParams = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        );
        installButton.setLayoutParams(buttonParams);
        
        // Style install button
        GradientDrawable buttonBg = new GradientDrawable();
        buttonBg.setColor(Color.parseColor("#3FD8EF")); 
        buttonBg.setCornerRadius(dpToPx(8));
        installButton.setBackground(buttonBg);
        installButton.setTextColor(Color.WHITE);
        installButton.setTextSize(14);
        installButton.setTypeface(null, android.graphics.Typeface.BOLD);
        installButton.setText("INSTALL");
        installButton.setAllCaps(true);
        installButton.setPadding(0, dpToPx(12), 0, dpToPx(12));

        // Add views to main container
        mainContainer.addView(adBadge);
        mainContainer.addView(mediaView);
        mainContainer.addView(titleView);
        mainContainer.addView(descView);
        mainContainer.addView(installButton);

        // Add container to ad view
        adView.addView(mainContainer);

        // Set native ad data
        if (nativeAd.getMediaContent() != null) {
            // Sử dụng media content nếu có
            com.google.android.gms.ads.nativead.MediaView nativeMediaView = 
                new com.google.android.gms.ads.nativead.MediaView(context);
            nativeMediaView.setLayoutParams(mediaParams);
            nativeMediaView.setMediaContent(nativeAd.getMediaContent());
            
            // Thay thế ImageView bằng MediaView
            mainContainer.removeView(mediaView);
            mainContainer.addView(nativeMediaView, 1); // Add at index 1 (after AD badge)
            adView.setMediaView(nativeMediaView);
        } else if (nativeAd.getImages() != null && !nativeAd.getImages().isEmpty()) {
            // Sử dụng image đầu tiên nếu có
            mediaView.setImageDrawable(nativeAd.getImages().get(0).getDrawable());
            adView.setImageView(mediaView);
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