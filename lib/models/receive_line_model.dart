class ReceiveLineModel {
  final int productId;
  final String barcode;
  final String productName;
  final double quantity;

  ReceiveLineModel({
    required this.productId,
    required this.barcode,
    required this.productName,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      "productId": productId.toString(),
      "quantity": quantity,
    };
  }
}