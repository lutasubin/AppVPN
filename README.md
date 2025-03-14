├── .gitignore
├── .metadata
├── android
    ├── .gitignore
    ├── app
    │   ├── build.gradle
    │   ├── google-services.json
    │   └── src
    │   │   ├── debug
    │   │       └── AndroidManifest.xml
    │   │   ├── main
    │   │       ├── AndroidManifest.xml
    │   │       ├── ic_launcher-playstore.png
    │   │       ├── java
    │   │       │   └── com
    │   │       │   │   └── Lutasubin
    │   │       │   │       └── freeVpn
    │   │       │   │           └── MainActivity.java
    │   │       └── res
    │   │       │   ├── drawable
    │   │       │       └── launch_background.xml
    │   │       │   ├── mipmap-anydpi-v26
    │   │       │       ├── ic_launcher.xml
    │   │       │       └── ic_launcher_round.xml
    │   │       │   ├── mipmap-hdpi
    │   │       │       ├── ic_launcher.webp
    │   │       │       ├── ic_launcher_foreground.webp
    │   │       │       └── ic_launcher_round.webp
    │   │       │   ├── mipmap-mdpi
    │   │       │       ├── ic_launcher.webp
    │   │       │       ├── ic_launcher_foreground.webp
    │   │       │       └── ic_launcher_round.webp
    │   │       │   ├── mipmap-xhdpi
    │   │       │       ├── ic_launcher.webp
    │   │       │       ├── ic_launcher_foreground.webp
    │   │       │       └── ic_launcher_round.webp
    │   │       │   ├── mipmap-xxhdpi
    │   │       │       ├── ic_launcher.webp
    │   │       │       ├── ic_launcher_foreground.webp
    │   │       │       └── ic_launcher_round.webp
    │   │       │   ├── mipmap-xxxhdpi
    │   │       │       ├── ic_launcher.webp
    │   │       │       ├── ic_launcher_foreground.webp
    │   │       │       └── ic_launcher_round.webp
    │   │       │   ├── values-night
    │   │       │       └── styles.xml
    │   │       │   └── values
    │   │       │       ├── ic_launcher_background.xml
    │   │       │       └── styles.xml
    │   │   └── profile
    │   │       └── AndroidManifest.xml
    ├── build.gradle
    ├── gradle.properties
    ├── gradle
    │   └── wrapper
    │   │   └── gradle-wrapper.properties
    ├── settings.gradle
    ├── settings_aar.gradle
    └── vpnLib
    │   ├── build.gradle
    │   ├── proguard-rules.pro
    │   └── src
    │       └── main
    │           ├── AndroidManifest.xml
    │           ├── aidl
    │               ├── com
    │               │   └── android
    │               │   │   └── vending
    │               │   │       └── billing
    │               │   │           └── IInAppBillingService.aidl
    │               └── de
    │               │   └── blinkt
    │               │       └── openvpn
    │               │           ├── api
    │               │               ├── APIVpnProfile.aidl
    │               │               ├── ExternalCertificateProvider.aidl
    │               │               ├── IOpenVPNAPIService.aidl
    │               │               └── IOpenVPNStatusCallback.aidl
    │               │           └── core
    │               │               ├── ConnectionStatus.aidl
    │               │               ├── IOpenVPNServiceInternal.aidl
    │               │               ├── IServiceStatus.aidl
    │               │               ├── IStatusCallbacks.aidl
    │               │               ├── LogItem.aidl
    │               │               └── TrafficHistory.aidl
    │           ├── assets
    │               ├── nopie_openvpn.arm64-v8a
    │               ├── nopie_openvpn.armeabi-v7a
    │               ├── nopie_openvpn.x86
    │               ├── nopie_openvpn.x86_64
    │               ├── pie_openvpn.arm64-v8a
    │               ├── pie_openvpn.armeabi-v7a
    │               ├── pie_openvpn.x86
    │               └── pie_openvpn.x86_64
    │           ├── java
    │               ├── de
    │               │   └── blinkt
    │               │   │   └── openvpn
    │               │   │       ├── DisconnectVPNActivity.java
    │               │   │       ├── FileProvider.java
    │               │   │       ├── LaunchVPN.java
    │               │   │       ├── OnBootReceiver.java
    │               │   │       ├── OpenVpnApi.java
    │               │   │       ├── VpnProfile.java
    │               │   │       ├── activities
    │               │   │           └── DisconnectVPN.java
    │               │   │       ├── api
    │               │   │           ├── APIVpnProfile.java
    │               │   │           ├── AppRestrictions.java
    │               │   │           ├── ConfirmDialog.java
    │               │   │           ├── ExternalAppDatabase.java
    │               │   │           ├── ExternalOpenVPNService.java
    │               │   │           ├── GrantPermissionsActivity.java
    │               │   │           ├── RemoteAction.java
    │               │   │           └── SecurityRemoteException.java
    │               │   │       ├── core
    │               │   │           ├── CIDRIP.java
    │               │   │           ├── ConfigParser.java
    │               │   │           ├── Connection.java
    │               │   │           ├── ConnectionStatus.java
    │               │   │           ├── DeviceStateReceiver.java
    │               │   │           ├── ExtAuthHelper.java
    │               │   │           ├── ICSOpenVPNApplication.java
    │               │   │           ├── LogFileHandler.java
    │               │   │           ├── LogItem.java
    │               │   │           ├── LollipopDeviceStateListener.java
    │               │   │           ├── NativeUtils.java
    │               │   │           ├── NetworkSpace.java
    │               │   │           ├── NetworkUtils.java
    │               │   │           ├── OpenVPNManagement.java
    │               │   │           ├── OpenVPNService.java
    │               │   │           ├── OpenVPNStatusService.java
    │               │   │           ├── OpenVPNThread.java
    │               │   │           ├── OpenVpnManagementThread.java
    │               │   │           ├── OrbotHelper.java
    │               │   │           ├── PRNGFixes.java
    │               │   │           ├── PasswordCache.java
    │               │   │           ├── Preferences.java
    │               │   │           ├── ProfileManager.java
    │               │   │           ├── ProxyDetection.java
    │               │   │           ├── StatusListener.java
    │               │   │           ├── TrafficHistory.java
    │               │   │           ├── VPNLaunchHelper.java
    │               │   │           ├── VpnStatus.java
    │               │   │           └── X509Utils.java
    │               │   │       └── utils
    │               │   │           ├── PropertiesService.java
    │               │   │           └── TotalTraffic.java
    │               └── org
    │               │   └── spongycastle
    │               │       └── util
    │               │           ├── encoders
    │               │               ├── Base64.java
    │               │               ├── Base64Encoder.java
    │               │               └── Encoder.java
    │               │           └── io
    │               │               └── pem
    │               │                   ├── PemGenerationException.java
    │               │                   ├── PemHeader.java
    │               │                   ├── PemObject.java
    │               │                   ├── PemObjectGenerator.java
    │               │                   ├── PemReader.java
    │               │                   └── PemWriter.java
    │           ├── jniLibs
    │               ├── arm64-v8a
    │               │   ├── libjbcrypto.so
    │               │   ├── libopenvpn.so
    │               │   ├── libopvpnutil.so
    │               │   └── libovpnexec.so
    │               ├── armeabi-v7a
    │               │   ├── libjbcrypto.so
    │               │   ├── libopenvpn.so
    │               │   ├── libopvpnutil.so
    │               │   └── libovpnexec.so
    │               ├── x86
    │               │   ├── libjbcrypto.so
    │               │   ├── libopenvpn.so
    │               │   ├── libopvpnutil.so
    │               │   └── libovpnexec.so
    │               └── x86_64
    │               │   ├── libjbcrypto.so
    │               │   ├── libopenvpn.so
    │               │   ├── libopvpnutil.so
    │               │   └── libovpnexec.so
    │           └── res
    │               ├── drawable-hdpi
    │                   ├── ic_menu_archive.png
    │                   ├── ic_menu_copy_holo_light.png
    │                   ├── ic_menu_log.png
    │                   ├── ic_quick.png
    │                   ├── ic_stat_vpn.png
    │                   ├── ic_stat_vpn_empty_halo.png
    │                   ├── ic_stat_vpn_offline.png
    │                   ├── ic_stat_vpn_outline.png
    │                   └── vpn_item_settings.png
    │               ├── drawable-mdpi
    │                   ├── ic_menu_archive.png
    │                   ├── ic_menu_copy_holo_light.png
    │                   ├── ic_menu_log.png
    │                   ├── ic_quick.png
    │                   ├── ic_stat_vpn.png
    │                   ├── ic_stat_vpn_empty_halo.png
    │                   ├── ic_stat_vpn_offline.png
    │                   ├── ic_stat_vpn_outline.png
    │                   └── vpn_item_settings.png
    │               ├── drawable-xhdpi
    │                   ├── ic_menu_archive.png
    │                   ├── ic_menu_copy_holo_light.png
    │                   ├── ic_menu_log.png
    │                   ├── ic_quick.png
    │                   ├── ic_stat_vpn.png
    │                   ├── ic_stat_vpn_empty_halo.png
    │                   ├── ic_stat_vpn_offline.png
    │                   ├── ic_stat_vpn_outline.png
    │                   └── vpn_item_settings.png
    │               ├── drawable-xxhdpi
    │                   ├── ic_menu_copy_holo_light.png
    │                   ├── ic_menu_log.png
    │                   ├── ic_quick.png
    │                   ├── ic_stat_vpn.png
    │                   ├── ic_stat_vpn_empty_halo.png
    │                   ├── ic_stat_vpn_offline.png
    │                   └── ic_stat_vpn_outline.png
    │               ├── drawable
    │                   └── ic_notification.png
    │               ├── layout
    │                   ├── api_confirm.xml
    │                   ├── import_as_config.xml
    │                   ├── launchvpn.xml
    │                   └── userpass.xml
    │               ├── values-sw600dp
    │                   ├── dimens.xml
    │                   └── styles.xml
    │               ├── values-v29
    │                   └── bools.xml
    │               ├── values
    │                   ├── arrays.xml
    │                   ├── attrs.xml
    │                   ├── bools.xml
    │                   ├── colours.xml
    │                   ├── dimens.xml
    │                   ├── ic_launcher_background.xml
    │                   ├── plurals.xml
    │                   ├── refs.xml
    │                   ├── strings.xml
    │                   ├── styles.xml
    │                   └── untranslatable.xml
    │               └── xml
    │                   └── app_restrictions.xml
├── assets
    ├── flags
    │   ├── UK.png
    │   ├── ad.png
    │   ├── ae.png
    │   ├── af.png
    │   ├── ag.png
    │   ├── ai.png
    │   ├── al.png
    │   ├── am.png
    │   ├── an.png
    │   ├── ao.png
    │   ├── aq.png
    │   ├── ar.png
    │   ├── as.png
    │   ├── at.png
    │   ├── au.png
    │   ├── aw.png
    │   ├── ax.png
    │   ├── az.png
    │   ├── ba.png
    │   ├── bb.png
    │   ├── bd.png
    │   ├── be.png
    │   ├── bf.png
    │   ├── bg.png
    │   ├── bh.png
    │   ├── bi.png
    │   ├── bj.png
    │   ├── bl.png
    │   ├── bm.png
    │   ├── bn.png
    │   ├── bo.png
    │   ├── bq.png
    │   ├── br.png
    │   ├── bs.png
    │   ├── bt.png
    │   ├── bv.png
    │   ├── bw.png
    │   ├── by.png
    │   ├── bz.png
    │   ├── ca.png
    │   ├── cc.png
    │   ├── cd.png
    │   ├── cf.png
    │   ├── cg.png
    │   ├── ch.png
    │   ├── ci.png
    │   ├── ck.png
    │   ├── cl.png
    │   ├── cm.png
    │   ├── cn.png
    │   ├── co.png
    │   ├── cr.png
    │   ├── cu.png
    │   ├── cv.png
    │   ├── cw.png
    │   ├── cx.png
    │   ├── cy.png
    │   ├── cz.png
    │   ├── de.png
    │   ├── default.png
    │   ├── dj.png
    │   ├── dk.png
    │   ├── dm.png
    │   ├── do.png
    │   ├── dz.png
    │   ├── ec.png
    │   ├── ee.png
    │   ├── eg.png
    │   ├── eh.png
    │   ├── er.png
    │   ├── es.png
    │   ├── et.png
    │   ├── eu.png
    │   ├── fi.png
    │   ├── fj.png
    │   ├── fk.png
    │   ├── fm.png
    │   ├── fo.png
    │   ├── fr.png
    │   ├── ga.png
    │   ├── gb-eng.png
    │   ├── gb-nir.png
    │   ├── gb-sct.png
    │   ├── gb-wls.png
    │   ├── gb.png
    │   ├── gd.png
    │   ├── ge.png
    │   ├── gf.png
    │   ├── gg.png
    │   ├── gh.png
    │   ├── gi.png
    │   ├── gl.png
    │   ├── gm.png
    │   ├── gn.png
    │   ├── gp.png
    │   ├── gq.png
    │   ├── gr.png
    │   ├── gs.png
    │   ├── gt.png
    │   ├── gu.png
    │   ├── gw.png
    │   ├── gy.png
    │   ├── hk.png
    │   ├── hm.png
    │   ├── hn.png
    │   ├── hr.png
    │   ├── ht.png
    │   ├── hu.png
    │   ├── id.png
    │   ├── ie.png
    │   ├── il.png
    │   ├── im.png
    │   ├── in.png
    │   ├── io.png
    │   ├── iq.png
    │   ├── ir.png
    │   ├── is.png
    │   ├── it.png
    │   ├── je.png
    │   ├── jm.png
    │   ├── jo.png
    │   ├── jp.png
    │   ├── ke.png
    │   ├── kg.png
    │   ├── kh.png
    │   ├── ki.png
    │   ├── km.png
    │   ├── kn.png
    │   ├── kp.png
    │   ├── kr.png
    │   ├── kw.png
    │   ├── ky.png
    │   ├── kz.png
    │   ├── la.png
    │   ├── lb.png
    │   ├── lc.png
    │   ├── li.png
    │   ├── lk.png
    │   ├── lr.png
    │   ├── ls.png
    │   ├── lt.png
    │   ├── lu.png
    │   ├── lv.png
    │   ├── ly.png
    │   ├── ma.png
    │   ├── mc.png
    │   ├── md.png
    │   ├── me.png
    │   ├── mf.png
    │   ├── mg.png
    │   ├── mh.png
    │   ├── mk.png
    │   ├── ml.png
    │   ├── mm.png
    │   ├── mn.png
    │   ├── mo.png
    │   ├── mp.png
    │   ├── mq.png
    │   ├── mr.png
    │   ├── ms.png
    │   ├── mt.png
    │   ├── mu.png
    │   ├── mv.png
    │   ├── mw.png
    │   ├── mx.png
    │   ├── my.png
    │   ├── mz.png
    │   ├── na.png
    │   ├── nc.png
    │   ├── ne.png
    │   ├── nf.png
    │   ├── ng.png
    │   ├── ni.png
    │   ├── nl.png
    │   ├── no.png
    │   ├── np.png
    │   ├── nr.png
    │   ├── nu.png
    │   ├── nz.png
    │   ├── om.png
    │   ├── pa.png
    │   ├── pe.png
    │   ├── pf.png
    │   ├── pg.png
    │   ├── ph.png
    │   ├── pk.png
    │   ├── pl.png
    │   ├── pm.png
    │   ├── pn.png
    │   ├── pr.png
    │   ├── ps.png
    │   ├── pt.png
    │   ├── pw.png
    │   ├── py.png
    │   ├── qa.png
    │   ├── re.png
    │   ├── ro.png
    │   ├── rs.png
    │   ├── ru.png
    │   ├── rw.png
    │   ├── sa.png
    │   ├── sb.png
    │   ├── sc.png
    │   ├── sd.png
    │   ├── se.png
    │   ├── sg.png
    │   ├── sh.png
    │   ├── si.png
    │   ├── sj.png
    │   ├── sk.png
    │   ├── sl.png
    │   ├── sm.png
    │   ├── sn.png
    │   ├── so.png
    │   ├── sr.png
    │   ├── ss.png
    │   ├── st.png
    │   ├── sv.png
    │   ├── sx.png
    │   ├── sy.png
    │   ├── sz.png
    │   ├── tc.png
    │   ├── td.png
    │   ├── tf.png
    │   ├── tg.png
    │   ├── th.png
    │   ├── tj.png
    │   ├── tk.png
    │   ├── tl.png
    │   ├── tm.png
    │   ├── tn.png
    │   ├── to.png
    │   ├── tr.png
    │   ├── tt.png
    │   ├── tv.png
    │   ├── tw.png
    │   ├── tz.png
    │   ├── ua.png
    │   ├── ug.png
    │   ├── um.png
    │   ├── us.png
    │   ├── uy.png
    │   ├── uz.png
    │   ├── va.png
    │   ├── vc.png
    │   ├── ve.png
    │   ├── vg.png
    │   ├── vi.png
    │   ├── vn.png
    │   ├── vu.png
    │   ├── wf.png
    │   ├── ws.png
    │   ├── xk.png
    │   ├── ye.png
    │   ├── yt.png
    │   ├── za.png
    │   ├── zm.png
    │   └── zw.png
    ├── icons
    │   ├── discord.png
    │   ├── dribble.png
    │   ├── facebook.png
    │   ├── instagram.png
    │   ├── messenger.png
    │   ├── pinterest.png
    │   ├── telegram.png
    │   └── twitter.png
    ├── images
    │   ├── earth.png
    │   ├── logo.png
    │   ├── no_results.png
    │   └── setting.png
    ├── lottie
    │   ├── loading.json
    │   └── loadingVPN.json
    ├── svg
    │   ├── Frame 14.svg
    │   ├── Frame 2.svg
    │   ├── Frame.svg
    │   ├── Group 17.svg
    │   ├── logo.svg
    │   └── webpage-not-found 1.svg
    └── vpn
    │   ├── japan.ovpn
    │   └── thailand.ovpn
├── firebase.json
├── lib
    ├── apis
    │   └── apis.dart
    ├── controllers
    │   ├── home_controller.dart
    │   ├── location_controller.dart
    │   └── native_ad_controller.dart
    ├── firebase_options.dart
    ├── helpers
    │   ├── ad_helper.dart
    │   ├── app_translations.dart
    │   ├── config.dart
    │   ├── my_dilogs.dart
    │   └── pref.dart
    ├── main.dart
    ├── models
    │   ├── ip_details.dart
    │   ├── network_data.dart
    │   ├── vpn.dart
    │   ├── vpn_config.dart
    │   └── vpn_status.dart
    ├── screens
    │   ├── home_screen.dart
    │   ├── langguage_2.dart
    │   ├── language_screen.dart
    │   ├── location_screen.dart
    │   ├── menu_screen.dart
    │   ├── network_test_screen.dart
    │   ├── rate_screen.dart
    │   ├── search_screen.dart
    │   ├── share_screen.dart
    │   ├── splash_screen.dart
    │   └── watch_ad_dialog.dart
    ├── services
    │   └── vpn_engine.dart
    ├── test
    │   └── test_screen.dart
    └── widgets
    │   ├── change_location.dart
    │   ├── count_down_time .dart
    │   ├── home_card.dart
    │   ├── network_card.dart
    │   └── vpn_cart.dart
├── pubspec.lock
└── pubspec.yaml
