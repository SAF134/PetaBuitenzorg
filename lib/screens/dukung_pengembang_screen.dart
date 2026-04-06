import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class DukungPengembangScreen extends StatelessWidget {
  const DukungPengembangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Dukung Pengembang'),
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.favorite, color: AppColors.brandBlue, size: 60),
            const SizedBox(height: 24),
            Text(
              'Terima Kasih atas Dukungan Anda!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Dukungan Anda sangat berarti bagi kelangsungan pengembangan aplikasi PetaBuitenzorg agar tetap gratis dan terupdate bagi warga Bogor.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.6,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            const SizedBox(height: 16),
            
            // Payment Details Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPaymentTile(
                    context,
                    label: 'Bank BSI',
                    value: '7208189233',
                    imagePath: 'assets/images/logo/bsi.png',
                  ),
                  _buildPaymentTile(
                    context,
                    label: 'Bank SeaBank',
                    value: '9012 1768 5910',
                    imagePath: 'assets/images/logo/seabank.png',
                  ),
                  _buildPaymentTile(
                    context,
                    label: 'Gopay',
                    value: '081298628236',
                    imagePath: 'assets/images/logo/gopay.png',
                  ),
                  _buildPaymentTile(
                    context,
                    label: 'DANA',
                    value: '081298628236',
                    imagePath: 'assets/images/logo/dana.png',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(
    BuildContext context, {
    required String label,
    required String value,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value.replaceAll(' ', '')));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nomor $label berhasil disalin!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.brandBlue,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Image.asset(
                imagePath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy_rounded, size: 18, color: AppColors.brandBlue),
          ],
        ),
      ),
    );
  }
}
