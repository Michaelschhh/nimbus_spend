import 'dart:async';
import 'dart:developer';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Stub IAP Service for ad removal ($1.00)
/// 
/// Product ID must match what you create in Google Play Console.
/// See iap_guide.md for full setup instructions.
class IAPService {
  static const String removeAdsProductId = 'remove_ads';
  static const String unlockThemesProductId = 'unlock_themes';
  static const String unlockSecurityProductId = 'unlock_security';
  static const String bundleProProductId = 'bundle_pro';
  
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static bool _isAvailable = false;
  static ProductDetails? _removeAdsProduct;
  static ProductDetails? _unlockThemesProduct;
  static ProductDetails? _unlockSecurityProduct;
  static ProductDetails? _bundleProProduct;

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
    final response = await _iap.queryProductDetails({
      removeAdsProductId, 
      unlockThemesProductId, 
      unlockSecurityProductId,
      bundleProProductId
    });
    if (response.error != null) {
      log('IAP: Error loading products: ${response.error}');
      return;
    }
    for (var product in response.productDetails) {
      if (product.id == removeAdsProductId) _removeAdsProduct = product;
      if (product.id == unlockThemesProductId) _unlockThemesProduct = product;
      if (product.id == unlockSecurityProductId) _unlockSecurityProduct = product;
      if (product.id == bundleProProductId) _bundleProProduct = product;
    }
    log('IAP: Products loaded — ${response.productDetails.length} items');
  }

  // Callback for when settings provider is connected
  static Function? onPurchaseSuccess;

  /// Trigger the purchase flow for ad removal
  static Future<void> buyRemoveAds() async {
    if (!_isAvailable || _removeAdsProduct == null) {
      // Mock for development if store is not available
      if (!_isAvailable) {
        log('IAP: Store not available, using mock buyRemoveAds');
        onPurchaseSuccess?.call('remove_ads');
        return;
      }
      return;
    }
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: _removeAdsProduct!));
  }

  static Future<void> buyUnlockThemes() async {
    if (!_isAvailable || _unlockThemesProduct == null) {
      if (!_isAvailable) {
        log('IAP: Store not available, using mock buyUnlockThemes');
        onPurchaseSuccess?.call('unlock_themes');
        return;
      }
      return;
    }
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: _unlockThemesProduct!));
  }

  static Future<void> buyUnlockSecurity() async {
    if (!_isAvailable || _unlockSecurityProduct == null) {
      if (!_isAvailable) {
        log('IAP: Store not available, using mock buyUnlockSecurity');
        onPurchaseSuccess?.call('unlock_security');
        return;
      }
      return;
    }
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: _unlockSecurityProduct!));
  }

  static Future<void> buyBundlePro() async {
    if (!_isAvailable || _bundleProProduct == null) {
      if (!_isAvailable) {
        log('IAP: Store not available, using mock buyBundlePro');
        onPurchaseSuccess?.call('bundle_pro');
        return;
      }
      return;
    }
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: _bundleProProduct!));
  }

  /// Handle purchase updates
  static void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        log('IAP: Purchase successful: ${purchase.productID}');
        onPurchaseSuccess?.call(purchase.productID);
      } else if (purchase.status == PurchaseStatus.error) {
        log('IAP: Purchase error: ${purchase.error}');
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
