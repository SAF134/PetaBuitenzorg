import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/confirmation_dialog.dart';
import 'tentang_aplikasi_screen.dart';
import 'tentang_pengembang_screen.dart';
import 'dukung_pengembang_screen.dart';

class InformasiScreen extends StatelessWidget {
  const InformasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Informasi Lengkap',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // App Logo & Name
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(20),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo/Logo_PetaBuitenzorg.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PetaBuitenzorg',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandBlue,
                    ),
                  ),
                  Text(
                    'Versi 1.0.0',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TentangAplikasiScreen())),
                  ),
                  _buildSettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Tentang Pengembang',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TentangPengembangScreen())),
                  ),
                  _buildSettingsTile(
                    icon: Icons.favorite_border_rounded,
                    title: 'Dukung Pengembang',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DukungPengembangScreen())),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  _buildSettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar Aplikasi',
                    titleColor: AppColors.error,
                    iconColor: AppColors.error,
                    onTap: () => _showExitConfirmation(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline.withAlpha(20)),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? AppColors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Konfirmasi Keluar',
        message: 'Apakah Anda yakin ingin keluar dari PetaBuitenzorg?',
        onConfirm: () => SystemNavigator.pop(),
      ),
    );
  }
}
