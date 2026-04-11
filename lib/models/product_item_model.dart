class ProductItemModel {
  final int id;
  final String serialNumber;
  final String barcode;
  final String itemName;
  final int productId;
  final String productName;
  final double price;
  final int vehicleId;
  final int rackId;
  final String rackName;
  final String vehicleName;
  final String warehouseName;
  final String locationDescription;

  ProductItemModel({
    required this.id,
    required this.serialNumber,
    required this.barcode,
    required this.itemName,
    required this.productId,
    required this.productName,
    required this.price,
    required this.vehicleId,
    required this.rackId,
    required this.rackName,
    required this.vehicleName,
    required this.warehouseName,
    required this.locationDescription,
  });

  factory ProductItemModel.fromJson(Map<String, dynamic> json) {
    return ProductItemModel(
      id: json['id'] ?? 0,
      serialNumber: json['serialNumber'] ?? '',
      barcode: json['barcode'] ?? '',
      itemName: json['itemName'] ?? '',
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      vehicleId: json['vehicleId'] ?? 0,
      rackId: json['rackId'] ?? 0,
      rackName: json['rackName'] ?? '',
      vehicleName: json['vehicleName'] ?? '',
      warehouseName: json['warehouseName'] ?? '',
      locationDescription: json['locationDescription'] ?? '',
    );
  }
}