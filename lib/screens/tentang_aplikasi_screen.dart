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
            _buildSection(
              'Latar Belakang',
              'Kota Bogor (Buitenzorg) memiliki pertumbuhan infrastruktur yang sangat pesat. Wisatawan dan warga lokal seringkali kesulitan menemukan informasi fasilitas penting secara komprehensif dalam satu platform yang ringan dan akurat.',
            ),
            _buildSection(
              'Permasalahan',
              'Kurangnya akses cepat ke data lokasi spesifik seperti ketersediaan fasilitas hotel, jenis rumah sakit, atau jenis layanan SPBU tanpa harus membuka aplikasi pencarian yang berat dan memakan banyak data.',
            ),
            _buildSection(
              'Tujuan',
              'PetaBuitenzorg bertujuan untuk menjadi rekan perjalanan digital yang minimalis namun informatif bagi setiap orang yang berkunjung ke Kota Bogor.',
            ),
            _buildSection(
              'Deskripsi',
              'PetaBuitenzorg adalah aplikasi pemetaan cerdas yang menyajikan visualisasi data hotel, pusat perbelanjaan, kesehatan, dan transportasi di wilayah Bogor dengan antarmuka modern dan performa tinggi.',
            ),
            const SizedBox(height: 16),
            Text(
              'Teknologi yang Digunakan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTechChip('Flutter'),
                _buildTechChip('Dart'),
                _buildTechChip('OpenStreetMap'),
                _buildTechChip('JSON Data Service'),
                _buildTechChip('Geolocator'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.brandBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.6,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
