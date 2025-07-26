// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:vpn_basic_project/helpers/pref.dart';
// import 'package:vpn_basic_project/screens/home_screen.dart';
// import 'package:vpn_basic_project/screens/paywall2.dart';

// class PurchaseController extends GetxController {
//   final InAppPurchase _iap = InAppPurchase.instance;
//   final RxBool isAvailable = false.obs;
//   final RxList<ProductDetails> products = <ProductDetails>[].obs;
//   final RxBool isVip = false.obs;

//   late final StreamSubscription<List<PurchaseDetails>> _subscription;

//   static const Set<String> _kProductIds = {
//     'vpn_vip_3months',
//   };

//   @override
//   void onInit() {
//     super.onInit();
//     _initialize();
//     _listenToPurchaseUpdated();
//   }

//   void _initialize() async {
//     isAvailable.value = await _iap.isAvailable();
//     if (isAvailable.value) {
//       await _loadProducts();
//     }
//     await loadVipState();
//   }

//   Future<void> _loadProducts() async {
//     final response = await _iap.queryProductDetails(_kProductIds);
//     if (response.error != null) {
//       Get.snackbar('Error', 'Failed to load products');
//       return;
//     }
//     products.assignAll(response.productDetails);
//   }

//   void buyVip(ProductDetails product) {
//     final purchaseParam = PurchaseParam(productDetails: product);
//     _iap.buyNonConsumable(purchaseParam: purchaseParam);
//   }

//   void _listenToPurchaseUpdated() {
//     _subscription = _iap.purchaseStream.listen((purchases) {
//       for (var purchase in purchases) {
//         if (purchase.status == PurchaseStatus.purchased) {
//           _verifyAndUnlock(purchase);
//         } else if (purchase.status == PurchaseStatus.error) {
//           Get.snackbar('Purchase Failed', 'An error occurred.');
//         }
//       }
//     });
//   }

//   void _verifyAndUnlock(PurchaseDetails purchase) async {
//     isVip.value = true;
//     Pref.vipPurchaseTime = DateTime.now().millisecondsSinceEpoch;

//     Get.snackbar('Success', 'VIP activated for 3 months!');
//     Get.offAll(() => HomeScreen());
//   }

//   Future<void> loadVipState() async {
//     isVip.value = Pref.isVip;
//   }

//   void restoreVip() async {
//     await loadVipState();
//     Get.snackbar('Restored', 'VIP status updated.');
//   }

//   // 👉 Hàm tiện dụng để check VIP và điều hướng:
//   void checkVipAndNavigate() {
//     if (isVip.value) {
//       Get.offAll(() => HomeScreen());
//     } else {
//       Get.offAll(() => PaywallPage2());
//     }
//   }

//   @override
//   void onClose() {
//     _subscription.cancel();
//     super.onClose();
//   }
// }
