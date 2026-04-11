import 'dart:convert';
import '../models/product_item_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class ProductItemService {
  final ApiService _apiService = ApiService();

  Future<ProductItemModel> getByBarcode(String barcode) async {
    final response = await _apiService.get(
      baseUrl: ApiConstants.baseUrl,
      endpoint: '/api/ProductItems/barcode/$barcode',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductItemModel.fromJson(data);
    } else {
      throw Exception('Product not found');
    }
  }
}