import 'dart:async';
import 'dart:developer';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Stub IAP Service for ad removal ($1.00)
/// 
/// Product ID must match what you create in Google Play Console.
/// See iap_guide.md for full setup instructions.
class IAPService {
  static const String removeAdsProductId = 'remove_ads';
  
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static bool _isAvailable = false;
  static ProductDetails? _removeAdsProduct;

  /// Initialize the IAP system. Call once at app startup.
  static Future<void> init() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      log('IAP: Store not available');
      return;
    }

    // Listen for purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => log('IAP Error: $error'),
    );

    // Load product details
    await _loadProducts();
  }

  static Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails({removeAdsProductId});
    if (response.error != null) {
      log('IAP: Error loading products: ${response.error}');
      return;
    }
    if (response.productDetails.isEmpty) {
      log('IAP: No products found. Make sure "$removeAdsProductId" exists in Play Console.');
      return;
    }
    _removeAdsProduct = response.productDetails.first;
    log('IAP: Product loaded — ${_removeAdsProduct!.title} (${_removeAdsProduct!.price})');
  }

  // Callback for when settings provider is connected
  static Function? onPurchaseSuccess;

  /// Trigger the purchase flow for ad removal
  static Future<void> buyRemoveAds() async {
    if (!_isAvailable || _removeAdsProduct == null) {
      log('IAP: Purchase not available');
      return;
    }
    final purchaseParam = PurchaseParam(productDetails: _removeAdsProduct!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Handle purchase updates
  static void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.productID == removeAdsProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          log('IAP: Purchase successful! User is now Pro.');
          onPurchaseSuccess?.call();
        } else if (purchase.status == PurchaseStatus.error) {
          log('IAP: Purchase error: ${purchase.error}');
        }
      }

      // Complete pending purchases
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// Restore previous purchases (call from Settings)
  static Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Whether the store and product are ready
  static bool get isAvailable => _isAvailable && _removeAdsProduct != null;

  /// Get the formatted price string
  static String get priceString => _removeAdsProduct?.price ?? '\$0.99';

  /// Clean up
  static void dispose() {
    _subscription?.cancel();
  }
}
