import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumSection(
              context,
              icon: Icons.history_edu_rounded,
              title: 'Latar Belakang',
              content: 'Kota Bogor (Buitenzorg) memiliki pertumbuhan infrastruktur yang sangat pesat. Wisatawan dan warga lokal seringkali kesulitan menemukan informasi fasilitas penting secara komprehensif dalam satu platform yang ringan dan akurat.',
            ),
            _buildPremiumSection(
              context,
              icon: Icons.error_outline_rounded,
              title: 'Permasalahan',
              content: 'Kurangnya akses cepat ke data lokasi spesifik seperti ketersediaan fasilitas hotel, jenis rumah sakit, atau jenis layanan SPBU tanpa harus membuka aplikasi pencarian yang berat dan memakan banyak data.',
            ),
            _buildPremiumSection(
              context,
              icon: Icons.ads_click_rounded,
              title: 'Tujuan',
              content: 'PetaBuitenzorg bertujuan untuk menjadi rekan perjalanan digital yang minimalis namun informatif bagi setiap orang yang berkunjung ke Kota Bogor.',
            ),
            _buildPremiumSection(
              context,
              icon: Icons.description_outlined,
              title: 'Deskripsi',
              content: 'PetaBuitenzorg adalah aplikasi pemetaan cerdas yang menyajikan visualisasi data hotel, pusat perbelanjaan, kesehatan, dan transportasi di wilayah Bogor dengan antarmuka modern dan performa tinggi.',
            ),
            const SizedBox(height: 12),
            Text(
              'Teknologi Inti',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildModernTechChip('Flutter', Icons.flutter_dash),
                _buildModernTechChip('Dart', Icons.code_rounded),
                _buildModernTechChip('OpenStreetMap', Icons.map_outlined),
                _buildModernTechChip('JSON Service', Icons.storage_rounded),
                _buildModernTechChip('Geolocator', Icons.my_location_rounded),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSection(BuildContext context, {required IconData icon, required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: AppColors.brandBlue),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.7,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTechChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brandBlue.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandBlue.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.brandBlue),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.brandBlue,
            ),
          ),
        ],
      ),
    );
  }
}
