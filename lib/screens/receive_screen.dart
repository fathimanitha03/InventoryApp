import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final ApiService _apiService = ApiService();

  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  Map<String, dynamic>? product;
  final List<Map<String, dynamic>> addedItems = [];

  bool isLoading = false;
  bool isSaving = false;

  Future<void> fetchProduct() async {
    final barcode = _barcodeController.text.trim();

    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter barcode')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await _apiService.get(
        baseUrl: ApiConstants.baseUrl,
        endpoint: '${ApiConstants.productByBarcode}/$barcode',
      );

      if (res.statusCode == 200) {
        setState(() {
          product = jsonDecode(res.body) as Map<String, dynamic>;
        });
      } else {
        setState(() => product = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
      }
    } catch (e) {
      setState(() => product = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void addItem() {
    if (product == null) return;

    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid quantity')),
      );
      return;
    }

    final name = (product!["productName"] ?? "").toString();
    final desc = (product!["notes"] ?? "").toString();
    final location =
        "${product!["vehicleName"] ?? ''}/${product!["warehouseName"] ?? ''}"
            .replaceAll('//', '/')
            .trim();
    final rack = (product!["rackName"] ?? "").toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Add'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: $name'),
            const SizedBox(height: 6),
            Text('Description: ${desc.isEmpty ? "No description" : desc}'),
            const SizedBox(height: 6),
            Text('Location: ${location.isEmpty ? "No location" : location}'),
            const SizedBox(height: 6),
            Text('Rack: ${rack.isEmpty ? "No rack" : rack}'),
            const SizedBox(height: 6),
            Text('Quantity: $qty'),
            const SizedBox(height: 14),
            const Text('Do you want to add this item?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                addedItems.add({
                  "productId": product!["productId"],
                  "barcode": product!["barcode"],
                  "name": name,
                  "desc": desc,
                  "location": location,
                  "rack": rack,
                  "qty": qty,
                });

                _barcodeController.clear();
                _qtyController.clear();
                product = null;
              });

              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void removeItem(int index) {
    setState(() => addedItems.removeAt(index));
  }

  Future<void> saveReceive() async {
    if (addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to save')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final lines = addedItems.map((e) {
        return {
          "productId": e["productId"].toString(),
          "quantity": e["qty"],
        };
      }).toList();

      final res = await _apiService.post(
        baseUrl: ApiConstants.baseUrl,
        endpoint: ApiConstants.inboundReceipts,
        body: {
          "invoiceNumber": "AUTO",
          "receivingRackId": "1",
          "tradesPersonId": "1",
          "lines": lines,
        },
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receive saved successfully')),
        );

        setState(() {
          addedItems.clear();
          product = null;
          _barcodeController.clear();
          _qtyController.clear();
        });
      } else {
        throw Exception('Failed to save receive');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget _fieldTile({
    required IconData icon,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF55515E), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF55515E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    final productName = (product?["productName"] ?? "Product Name").toString();
    final description = ((product?["notes"] ?? "Description")).toString();
    final location =
        "${product?["vehicleName"] ?? 'Location'} / ${product?["warehouseName"] ?? 'Store 01'}";
    final rack = (product?["rackName"] ?? "Rack").toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          TextField(
            controller: _barcodeController,
            decoration: InputDecoration(
              hintText: 'Enter barcode',
              prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
              suffixIcon: IconButton(
                onPressed: isLoading ? null : fetchProduct,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_rounded),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _fieldTile(icon: Icons.inventory_2_outlined, text: productName),
          _fieldTile(icon: Icons.description_outlined, text: description),
          _fieldTile(icon: Icons.location_on_outlined, text: location),
          _fieldTile(icon: Icons.grid_view_rounded, text: rack),
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Quantity',
              prefixIcon: const Icon(Icons.tag_outlined),
              filled: true,
              fillColor: const Color(0xFFF7F7F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4758B8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF62B568),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"]?.toString() ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["desc"]?.toString().isNotEmpty == true
                      ? item["desc"].toString()
                      : 'No description',
                  style: const TextStyle(
                    color: Color(0xFF66616D),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Location: ${item["location"] ?? ""}',
                  style: const TextStyle(
                    color: Color(0xFF4758B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rack: ${item["rack"] ?? ""}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item["qty"]}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => removeItem(index),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFE2574C),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F1F3),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Receive',
          style: TextStyle(
            color: Color(0xFF1F1A24),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInputCard(),
          const SizedBox(height: 18),
          const Text(
            'Added Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1A24),
            ),
          ),
          const SizedBox(height: 12),
          if (addedItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No items added',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ...addedItems.asMap().entries.map(
                (e) => _buildItemCard(e.value, e.key),
              ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveReceive,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4758B8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Receive',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}