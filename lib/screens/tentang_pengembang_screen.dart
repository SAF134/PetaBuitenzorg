import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/confirmation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class TentangPengembangScreen extends StatelessWidget {
  const TentangPengembangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Tentang Pengembang'),
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo/akmal.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 60, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Syauqi Akmal F',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'S1 Teknik Komputer \'22',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.brandBlue,
              ),
            ),
            Text(
              'Fakultas Teknik Elektro\nUniversitas Telkom',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSocialTile(
                    context,
                    imagePath: 'assets/images/logo/instagram.png',
                    label: 'Instagram',
                    value: '@saf.134',
                    onTap: () => _showLinkConfirmation(
                      context,
                      'Buka Instagram',
                      'Apakah Anda ingin mengunjungi profil Instagram @saf.134?',
                      'http://instagram.com/saf.134',
                    ),
                  ),
                  _buildSocialTile(
                    context,
                    imagePath: 'assets/images/logo/whatsapp.png',
                    label: 'WhatsApp',
                    value: '+62 812-9862-8236',
                    onTap: () => _showLinkConfirmation(
                      context,
                      'Buka WhatsApp',
                      'Apakah Anda ingin menghubungi pengembang melalui WhatsApp?',
                      'http://wa.me/6281298628236',
                    ),
                  ),
                  _buildSocialTile(
                    context,
                    imagePath: 'assets/images/logo/gmail.png',
                    label: 'Email',
                    value: 'syauqiakmal137@gmail.com',
                    onTap: () => _showLinkConfirmation(
                      context,
                      'Kirim Email',
                      'Apakah Anda ingin mengirim email ke syauqiakmal137@gmail.com?',
                      'mailto:syauqiakmal137@gmail.com',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialTile(
    BuildContext context, {
    required String imagePath,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: onTap,
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
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.link, size: 20, color: AppColors.primary),
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
            const Icon(Icons.arrow_outward, size: 16, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  void _showLinkConfirmation(BuildContext context, String title, String message, String url) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        onConfirm: () {
          _launch(url);
        },
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
