import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'issue_screen.dart';
import 'login_screen.dart';
import 'receive_screen.dart';
import 'stock_check_screen.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _hubCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FC),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'One Hub',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventory Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage receive, issue, and stock activities from one place.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _hubCard(
              context: context,
              title: 'Receive',
              subtitle: 'Scan barcode, add quantity, and save received items',
              icon: Icons.call_received_rounded,
              color: Colors.green,
              page: const ReceiveScreen(),
            ),
            const SizedBox(height: 16),
            _hubCard(
              context: context,
              title: 'Issue',
              subtitle: 'Allocate products and deliver items by barcode',
              icon: Icons.outbox_rounded,
              color: Colors.orange,
              page: const IssueScreen(),
            ),
            const SizedBox(height: 16),
            _hubCard(
              context: context,
              title: 'Stock Check',
              subtitle: 'View stock details, balances, and scanned records',
              icon: Icons.inventory_2_rounded,
              color: Colors.indigo,
              page: const StockCheckScreen(),
            ),
          ],
        ),
      ),
    );
  }
}