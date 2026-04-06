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

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandBlue : Colors.grey[200],
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildHotelFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Jarak'),
        Row(
          children: ['Terdekat', 'Terjauh'].map((j) => _buildPillButton(
            label: j,
            isSelected: data.hotelJarak == j,
            onTap: () => setState(() => data.hotelJarak = j),
          )).toList(),
        ),
        _buildSectionLabel('Kategori'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [5, 4, 3, 2, 1].map((b) => _buildPillButton(
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
        ),
        _buildSectionLabel('Harga'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              '<= 200rb', '<= 400rb', '<= 600rb', '<= 800rb', '<= 1jt', '> 1jt'
            ].map((h) => _buildPillButton(
              label: h,
              isSelected: data.hotelHargaRange == h,
              onTap: () => setState(() => data.hotelHargaRange = data.hotelHargaRange == h ? '' : h),
            )).toList(),
          ),
        ),
        _buildSectionLabel('Rating'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [4.5, 4.0, 3.5, 3.0].map((r) => _buildPillButton(
              label: '$r+',
              isSelected: data.hotelMinRating == r,
              onTap: () => setState(() => data.hotelMinRating = data.hotelMinRating == r ? 0.0 : r),
            )).toList(),
          ),
        ),
        _buildSectionLabel('Fasilitas'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.availableHotelFas.map((f) => _buildPillButton(
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
        ),
      ],
    );
  }

  Widget _buildRsFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Jarak'),
        Row(
          children: ['Terdekat', 'Terjauh'].map((j) => _buildPillButton(
            label: j,
            isSelected: data.rsJarak == j,
            onTap: () => setState(() => data.rsJarak = j),
          )).toList(),
        ),
        _buildSectionLabel('Jenis'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.availableRsJenis.map((j) => _buildPillButton(
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
        ),
        _buildSectionLabel('Kelas'),
        Row(
          children: ['A', 'B', 'C', 'D'].map((k) => _buildPillButton(
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
        _buildSectionLabel('Rating'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [4.5, 4.0, 3.5, 3.0].map((r) => _buildPillButton(
              label: '$r+',
              isSelected: data.rsMinRating == r,
              onTap: () => setState(() => data.rsMinRating = data.rsMinRating == r ? 0.0 : r),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMallFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Jarak'),
        Row(
          children: ['Terdekat', 'Terjauh'].map((j) => _buildPillButton(
            label: j,
            isSelected: data.mallJarak == j,
            onTap: () => setState(() => data.mallJarak = j),
          )).toList(),
        ),
        _buildSectionLabel('Rating'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [4.5, 4.0, 3.5, 3.0].map((r) => _buildPillButton(
              label: '$r+',
              isSelected: data.mallMinRating == r,
              onTap: () => setState(() => data.mallMinRating = data.mallMinRating == r ? 0.0 : r),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpbuFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Jarak'),
        Row(
          children: ['Terdekat', 'Terjauh'].map((j) => _buildPillButton(
            label: j,
            isSelected: data.spbuJarak == j,
            onTap: () => setState(() => data.spbuJarak = j),
          )).toList(),
        ),
        _buildSectionLabel('Jenis'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.availableSpbuJenis.map((j) => _buildPillButton(
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
        ),
        _buildSectionLabel('Rating'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [4.5, 4.0, 3.5, 3.0].map((r) => _buildPillButton(
              label: '$r+',
              isSelected: data.spbuMinRating == r,
              onTap: () => setState(() => data.spbuMinRating = data.spbuMinRating == r ? 0.0 : r),
            )).toList(),
          ),
        ),
        _buildSectionLabel('Penawaran'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.availableSpbuPen.map((p) => _buildPillButton(
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
        ),
        _buildSectionLabel('Fasilitas'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.availableSpbuFas.map((f) => _buildPillButton(
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Lokasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => data.reset(widget.tabIndex)),
                icon: const Icon(Icons.refresh_rounded, color: AppColors.brandBlue, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: () {
                if (widget.tabIndex == 0) return _buildHotelFilters();
                if (widget.tabIndex == 1) return _buildRsFilters();
                if (widget.tabIndex == 2) return _buildMallFilters();
                if (widget.tabIndex == 3) return _buildSpbuFilters();
                return const SizedBox();
              }(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onApply(data);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.brandBlue.withAlpha(80),
            ),
            child: Text(
              'Terapkan Filter',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
