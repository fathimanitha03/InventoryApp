import 'dart:convert';
import '../models/receive_line_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class ReceiveService {
  final ApiService _apiService = ApiService();

  Future<int> createReceipt({
    required String invoiceNumber,
    required String receivingRackId,
    required String tradesPersonId,
    required List<ReceiveLineModel> lines,
  }) async {
    final response = await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      endpoint: '/api/InboundReceipts',
      body: {
        "invoiceNumber": invoiceNumber,
        "receivingRackId": receivingRackId,
        "tradesPersonId": tradesPersonId,
        "lines": lines.map((e) => e.toJson()).toList(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['inboundReceiptId'] ?? 0;
    } else {
      throw Exception('Failed to create inbound receipt');
    }
  }

  Future<void> confirmReceipt(int id) async {
    final response = await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      endpoint: '/api/InboundReceipts/$id/receive',
      body: {},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to confirm receipt');
    }
  }
}