import 'dart:convert';
import '../models/issue_line_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class IssueService {
  final ApiService _apiService = ApiService();

  Future<int> createDispatch({
    required String customerReference,
  }) async {
    final response = await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      endpoint: '/api/OutboundDispatches',
      body: {
        "customerReference": customerReference,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['outboundDispatchId'] ?? 0;
    } else {
      throw Exception('Failed to create dispatch');
    }
  }

  Future<void> allocateBarcode({
    required int dispatchId,
    required String barcode,
  }) async {
    final response = await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      endpoint: '/api/OutboundDispatches/$dispatchId/allocate',
      body: {
        "barcode": barcode,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to allocate barcode');
    }
  }

  Future<void> assignDispatch({
    required int dispatchId,
    required String vehicleId,
    required String tradesPersonId,
  }) async {
    final response = await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      endpoint: '/api/OutboundDispatches/$dispatchId/assign',
      body: {
        "vehicleId": vehicleId,
        "tradesPersonId": tradesPersonId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign dispatch');
    }
  }

  Future<void> outForDelivery(int dispatchId) async {
    final response = await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      endpoint: '/api/OutboundDispatches/$dispatchId/out-for-delivery',
      body: {},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark out for delivery');
    }
  }

  Future<void> deliver(int dispatchId) async {
    final response = await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      endpoint: '/api/OutboundDispatches/$dispatchId/deliver',
      body: {},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to deliver dispatch');
    }
  }
}