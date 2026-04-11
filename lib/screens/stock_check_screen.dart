import 'package:flutter/material.dart';

class StockCheckScreen extends StatefulWidget {
  const StockCheckScreen({super.key});

  @override
  State<StockCheckScreen> createState() => _StockCheckScreenState();
}

class _StockCheckScreenState extends State<StockCheckScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _dummyStock = [
    {
      "productName": "Brake Pad",
      "barcode": "BP-1001",
      "qty": 12,
      "location": "Rack A1",
      "vehicle": "Truck 01",
    },
    {
      "productName": "Engine Oil",
      "barcode": "EO-2044",
      "qty": 28,
      "location": "Rack B2",
      "vehicle": "Van 05",
    },
    {
      "productName": "Air Filter",
      "barcode": "AF-8877",
      "qty": 9,
      "location": "Rack C4",
      "vehicle": "Truck 03",
    },
  ];

  String _query = '';

  List<Map<String, dynamic>> get _filteredStock {
    if (_query.isEmpty) return _dummyStock;

    return _dummyStock.where((item) {
      final name = item['productName'].toString().toLowerCase();
      final barcode = item['barcode'].toString().toLowerCase();
      final location = item['location'].toString().toLowerCase();
      return name.contains(_query) ||
          barcode.contains(_query) ||
          location.contains(_query);
    }).toList();
  }

  Color _qtyColor(int qty) {
    if (qty <= 5) return Colors.red;
    if (qty <= 15) return Colors.orange;
    return Colors.green;
  }

  String _qtyLabel(int qty) {
    if (qty <= 5) return 'Low';
    if (qty <= 15) return 'Medium';
    return 'Good';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stockCard(Map<String, dynamic> item) {
    final int qty = item['qty'] as int;
    final Color statusColor = _qtyColor(qty);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['productName'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Barcode: ${item['barcode']}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _qtyLabel(qty),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'Balance Qty',
                  value: qty.toString(),
                ),
              ),
              Expanded(
                child: _infoTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: item['location'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoTile(
            icon: Icons.local_shipping_outlined,
            title: 'Vehicle',
            value: item['vehicle'],
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13.5),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredStock;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text(
          'Stock Check',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF5F7FC),
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.manage_search_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Monitor stock balances, search items, and review product availability.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _summaryCard(
                  title: 'Total Items',
                  value: _dummyStock.length.toString(),
                  icon: Icons.widgets_outlined,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  title: 'Visible Results',
                  value: filtered.length.toString(),
                  icon: Icons.filter_alt_outlined,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by product, barcode, or location',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      const BorderSide(color: Colors.indigo, width: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No stock items found',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _stockCard(filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}