import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class FilterStateData {
  // Hotel
  List<int> hotelBintang = [];
  String hotelHargaRange = '';
  double hotelMinRating = 0.0;
  String hotelJarak = 'Terdekat';
  List<String> hotelFasilitas = [];

  // Rumah Sakit
  List<String> rsJenis = [];
  List<String> rsKelas = [];
  double rsMinRating = 0.0;
  String rsJarak = 'Terdekat';

  // Mall
  double mallMinRating = 0.0;
  String mallJarak = 'Terdekat';

  // SPBU
  List<String> spbuJenis = [];
  double spbuMinRating = 0.0;
  String spbuJarak = 'Terdekat';
  List<String> spbuPenawaran = [];
  List<String> spbuFasilitas = [];

  FilterStateData copy() {
    return FilterStateData()
      ..hotelBintang = List.from(hotelBintang)
      ..hotelHargaRange = hotelHargaRange
      ..hotelMinRating = hotelMinRating
      ..hotelJarak = hotelJarak
      ..hotelFasilitas = List.from(hotelFasilitas)
      ..rsJenis = List.from(rsJenis)
      ..rsKelas = List.from(rsKelas)
      ..rsMinRating = rsMinRating
      ..rsJarak = rsJarak
      ..mallMinRating = mallMinRating
      ..mallJarak = mallJarak
      ..spbuJenis = List.from(spbuJenis)
      ..spbuMinRating = spbuMinRating
      ..spbuJarak = spbuJarak
      ..spbuPenawaran = List.from(spbuPenawaran)
      ..spbuFasilitas = List.from(spbuFasilitas);
  }

  void reset(int tabIndex) {
    if (tabIndex == 0) {
      hotelBintang.clear();
      hotelHargaRange = '';
      hotelMinRating = 0.0;
      hotelJarak = 'Terdekat';
      hotelFasilitas.clear();
    } else if (tabIndex == 1) {
      rsJenis.clear();
      rsKelas.clear();
      rsMinRating = 0.0;
      rsJarak = 'Terdekat';
    } else if (tabIndex == 2) {
      mallMinRating = 0.0;
      mallJarak = 'Terdekat';
    } else if (tabIndex == 3) {
      spbuJenis.clear();
      spbuMinRating = 0.0;
      spbuJarak = 'Terdekat';
      spbuPenawaran.clear();
      spbuFasilitas.clear();
    }
  }
}

class FilterModal extends StatefulWidget {
  final int tabIndex;
  final FilterStateData initialData;
  final Function(FilterStateData) onApply;
  final List<String> availableHotelFas;
  final List<String> availableRsJenis;
  final List<String> availableSpbuJenis;
  final List<String> availableSpbuFas;
  final List<String> availableSpbuPen;

  const FilterModal({
    super.key,
    required this.tabIndex,
    required this.initialData,
    required this.onApply,
    this.availableHotelFas = const [],
    this.availableRsJenis = const [],
    this.availableSpbuJenis = const [],
    this.availableSpbuFas = const [],
    this.availableSpbuPen = const [],
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late FilterStateData data;

  @override
  void initState() {
    super.initState();
    data = widget.initialData.copy();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline.withAlpha(50),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildHotelFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Jarak'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['Terdekat', 'Terjauh'].map((j) => _buildChip(
            label: j,
            isSelected: data.hotelJarak == j,
            onTap: () => setState(() => data.hotelJarak = j),
          )).toList(),
        ),
        _buildSectionTitle('Kategori'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [5, 4, 3, 2, 1].map((b) => _buildChip(
            label: 'Bintang $b',
            isSelected: data.hotelBintang.contains(b),
            onTap: () {
              setState(() {
                if (data.hotelBintang.contains(b)) {
                  data.hotelBintang.remove(b);
                } else {
                  data.hotelBintang.add(b);
                }
              });
            },
          )).toList(),
        ),
        _buildSectionTitle('Harga'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            '<= 200.000', '<= 400.000', '<= 600.000', '<= 800.000', '<= 1.000.000', '> 1.000.000'
          ].map((h) => _buildChip(
            label: h,
            isSelected: data.hotelHargaRange == h,
            onTap: () => setState(() => data.hotelHargaRange = data.hotelHargaRange == h ? '' : h),
          )).toList(),
        ),
        _buildSectionTitle('Rating'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [4.5, 4.0, 3.5, 3.0].map((r) => _buildChip(
            label: '$r+',
            isSelected: data.hotelMinRating == r,
            onTap: () => setState(() => data.hotelMinRating = data.hotelMinRating == r ? 0.0 : r),
          )).toList(),
        ),
        _buildSectionTitle('Fasilitas'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: widget.availableHotelFas.map((f) => _buildChip(
            label: f,
            isSelected: data.hotelFasilitas.contains(f),
            onTap: () {
              setState(() {
                if (data.hotelFasilitas.contains(f)) {
                  data.hotelFasilitas.remove(f);
                } else {
                  data.hotelFasilitas.add(f);
                }
              });
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildRsFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Jarak'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['Terdekat', 'Terjauh'].map((j) => _buildChip(
            label: j,
            isSelected: data.rsJarak == j,
            onTap: () => setState(() => data.rsJarak = j),
          )).toList(),
        ),
        _buildSectionTitle('Jenis'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: widget.availableRsJenis.map((j) => _buildChip(
            label: j,
            isSelected: data.rsJenis.contains(j),
            onTap: () {
              setState(() {
                if (data.rsJenis.contains(j)) {
                  data.rsJenis.remove(j);
                } else {
                  data.rsJenis.add(j);
                }
              });
            },
          )).toList(),
        ),
        _buildSectionTitle('Kelas'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['A', 'B', 'C', 'D'].map((k) => _buildChip(
            label: 'Kelas $k',
            isSelected: data.rsKelas.contains(k),
            onTap: () {
              setState(() {
                if (data.rsKelas.contains(k)) {
                  data.rsKelas.remove(k);
                } else {
                  data.rsKelas.add(k);
                }
              });
            },
          )).toList(),
        ),
        _buildSectionTitle('Rating'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [4.5, 4.0, 3.5, 3.0].map((r) => _buildChip(
            label: '$r+',
            isSelected: data.rsMinRating == r,
            onTap: () => setState(() => data.rsMinRating = data.rsMinRating == r ? 0.0 : r),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMallFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Jarak'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['Terdekat', 'Terjauh'].map((j) => _buildChip(
            label: j,
            isSelected: data.mallJarak == j,
            onTap: () => setState(() => data.mallJarak = j),
          )).toList(),
        ),
        _buildSectionTitle('Rating'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [4.5, 4.0, 3.5, 3.0].map((r) => _buildChip(
            label: '$r+',
            isSelected: data.mallMinRating == r,
            onTap: () => setState(() => data.mallMinRating = data.mallMinRating == r ? 0.0 : r),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSpbuFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Jarak'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['Terdekat', 'Terjauh'].map((j) => _buildChip(
            label: j,
            isSelected: data.spbuJarak == j,
            onTap: () => setState(() => data.spbuJarak = j),
          )).toList(),
        ),
        _buildSectionTitle('Jenis'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: widget.availableSpbuJenis.map((j) => _buildChip(
            label: j,
            isSelected: data.spbuJenis.contains(j),
            onTap: () {
              setState(() {
                if (data.spbuJenis.contains(j)) {
                  data.spbuJenis.remove(j);
                } else {
                  data.spbuJenis.add(j);
                }
              });
            },
          )).toList(),
        ),
        _buildSectionTitle('Rating'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [4.5, 4.0, 3.5, 3.0].map((r) => _buildChip(
            label: '$r+',
            isSelected: data.spbuMinRating == r,
            onTap: () => setState(() => data.spbuMinRating = data.spbuMinRating == r ? 0.0 : r),
          )).toList(),
        ),
        _buildSectionTitle('Penawaran'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: widget.availableSpbuPen.map((p) => _buildChip(
            label: p,
            isSelected: data.spbuPenawaran.contains(p),
            onTap: () {
              setState(() {
                if (data.spbuPenawaran.contains(p)) {
                  data.spbuPenawaran.remove(p);
                } else {
                  data.spbuPenawaran.add(p);
                }
              });
            },
          )).toList(),
        ),
        _buildSectionTitle('Fasilitas'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: widget.availableSpbuFas.map((f) => _buildChip(
            label: f,
            isSelected: data.spbuFasilitas.contains(f),
            onTap: () {
              setState(() {
                if (data.spbuFasilitas.contains(f)) {
                  data.spbuFasilitas.remove(f);
                } else {
                  data.spbuFasilitas.add(f);
                }
              });
            },
          )).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.outline.withAlpha(50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Lokasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => data.reset(widget.tabIndex));
                },
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 22),
                tooltip: 'Reset Filter',
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: () {
                if (widget.tabIndex == 0) return _buildHotelFilters();
                if (widget.tabIndex == 1) return _buildRsFilters();
                if (widget.tabIndex == 2) return _buildMallFilters();
                if (widget.tabIndex == 3) return _buildSpbuFilters();
                return const SizedBox();
              }(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              widget.onApply(data);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              'Terapkan Filter',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
