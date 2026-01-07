import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product ID for premium
  static const String premiumProductId = 'gsports_premium_monthly';

  final _purchaseController = StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  void init() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        debugPrint('IAP Subscription Error: $error');
      },
    );
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase here
          // For this MVP, we consider it verified if status is purchased
          debugPrint('Purchase Successful: ${purchaseDetails.productID}');
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }

        _purchaseController.add(purchaseDetails);
      }
    }
  }

  Future<void> buyPremium() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      throw Exception('Store not available');
    }

    const Set<String> kIds = <String>{premiumProductId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(
      kIds,
    );

    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('Product not found');
    }

    final List<ProductDetails> products = response.productDetails;
    if (products.isEmpty) {
      throw Exception('No products available');
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: products.first,
    );
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}
