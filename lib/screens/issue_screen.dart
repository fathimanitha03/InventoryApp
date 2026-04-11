import 'package:flutter/material.dart';
import '../models/issue_line_model.dart';
import '../models/product_item_model.dart';
import '../services/issue_service.dart';
import '../services/product_item_service.dart';

class IssueScreen extends StatefulWidget {
  const IssueScreen({super.key});

  @override
  State<IssueScreen> createState() => _IssueScreenState();
}

class _IssueScreenState extends State<IssueScreen> {
  final TextEditingController _customerRefController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final ProductItemService _productItemService = ProductItemService();
  final IssueService _issueService = IssueService();

  ProductItemModel? selectedProduct;
  List<IssueLineModel> lines = [];

  bool isSearching = false;
  bool isSaving = false;

  Future<void> _searchBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    setState(() {
      isSearching = true;
    });

    try {
      final product = await _productItemService.getByBarcode(barcode);
      setState(() {
        selectedProduct = product;
      });
    } catch (e) {
      setState(() {
        selectedProduct = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barcode not found: $e')),
      );
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  void _addLine() {
    if (selectedProduct == null) return;

    final qty = double.tryParse(_quantityController.text.trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid quantity')),
      );
      return;
    }

    setState(() {
      lines.add(
        IssueLineModel(
          barcode: selectedProduct!.barcode,
          productName: selectedProduct!.productName,
          quantity: qty,
        ),
      );
      _barcodeController.clear();
      _quantityController.clear();
      selectedProduct = null;
    });
  }

  void _removeLine(int index) {
    setState(() {
      lines.removeAt(index);
    });
  }

  Future<void> _saveIssue() async {
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final dispatchId = await _issueService.createDispatch(
        customerReference: _customerRefController.text.trim().isEmpty
            ? 'CUST-001'
            : _customerRefController.text.trim(),
      );

      for (final item in lines) {
        await _issueService.allocateBarcode(
          dispatchId: dispatchId,
          barcode: item.barcode,
        );
      }

      await _issueService.assignDispatch(
        dispatchId: dispatchId,
        vehicleId: '1',
        tradesPersonId: '1',
      );

      await _issueService.outForDelivery(dispatchId);
      await _issueService.deliver(dispatchId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue saved successfully')),
      );

      setState(() {
        lines.clear();
        _customerRefController.clear();
        _barcodeController.clear();
        _quantityController.clear();
        selectedProduct = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Widget _buildProductCard() {
    if (selectedProduct == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(selectedProduct!.productName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Barcode: ${selectedProduct!.barcode}'),
            Text('Item: ${selectedProduct!.itemName}'),
            Text('Vehicle: ${selectedProduct!.vehicleName}'),
            Text('Rack: ${selectedProduct!.rackName}'),
            Text('Warehouse: ${selectedProduct!.warehouseName}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLinesList() {
    if (lines.isEmpty) {
      return const Center(child: Text('No items added'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final item = lines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text(item.productName),
            subtitle: Text('Barcode: ${item.barcode}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Qty: ${item.quantity}'),
                IconButton(
                  onPressed: () => _removeLine(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _customerRefController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _customerRefController,
              decoration: InputDecoration(
                labelText: 'Customer Reference',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: 'Barcode',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(Icons.qr_code),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isSearching ? null : _searchBarcode,
                    child: isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Search'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProductCard(),
            if (selectedProduct != null) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon: const Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _addLine,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Added Items',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            _buildLinesList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveIssue,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Issue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}