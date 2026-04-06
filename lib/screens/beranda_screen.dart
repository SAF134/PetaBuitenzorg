import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../data/data_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/hotel.dart';
import '../data/models/rumah_sakit.dart';
import '../data/models/mall.dart';
import '../data/models/spbu.dart';
import 'informasi_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _hotelCount = 0;
  int _rsCount = 0;
  int _mallCount = 0;
  int _spbuCount = 0;
  bool _loaded = false;
  LatLng? _userLocation;
  double? _minHotelDist;
  double? _minRsDist;
  double? _minMallDist;
  double? _minSpbuDist;

  // Data for charts
  List<Hotel> _hotels = [];
  List<RumahSakit> _rumahSakits = [];
  List<Mall> _malls = [];
  List<Spbu> _spbus = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    _updateUserLocation();
  }

  Future<void> _updateUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        _calculateDistances();
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _calculateDistances() async {
    if (_userLocation == null) return;

    setState(() {
      if (_hotels.isNotEmpty) {
        _minHotelDist = _hotels.map((h) => Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, h.lat, h.lng)).reduce((a, b) => a < b ? a : b);
      }
      if (_rumahSakits.isNotEmpty) {
        _minRsDist = _rumahSakits.map((r) => Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, r.lat, r.lng)).reduce((a, b) => a < b ? a : b);
      }
      if (_malls.isNotEmpty) {
        _minMallDist = _malls.map((m) => Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, m.lat, m.lng)).reduce((a, b) => a < b ? a : b);
      }
      if (_spbus.isNotEmpty) {
        _minSpbuDist = _spbus.map((s) => Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, s.lat, s.lng)).reduce((a, b) => a < b ? a : b);
      }
    });
  }

  Future<void> _loadData() async {
    final hotels = await DataService.getHotels();
    final rs = await DataService.getRumahSakits();
    final malls = await DataService.getMalls();
    final spbus = await DataService.getSpbus();
    if (mounted) {
      setState(() {
        _hotels = hotels;
        _rumahSakits = rs;
        _malls = malls;
        _spbus = spbus;
        _hotelCount = hotels.length;
        _rsCount = rs.length;
        _mallCount = malls.length;
        _spbuCount = spbus.length;
        _loaded = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surfaceContainerLowest,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/logo/Logo_PetaBuitenzorg.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Text(
                  'PetaBuitenzorg',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlue,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.onSurfaceVariant),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InformasiScreen())),
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome Hero
                Text(
                  'Selamat Datang di PetaBuitenzorg',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aplikasi pemetaan dan informasi lokasi di Kota Bogor.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Grid
                if (_loaded) ...[
                  _buildStatsGrid(),
                  const SizedBox(height: 28),

                  // ──── CHARTS SECTION ────
                  _buildSectionTitle('Statistik Hotel', Icons.hotel),
                  const SizedBox(height: 16),
                  _buildHotelKategoriChart(),
                  const SizedBox(height: 16),
                  _buildHotelHargaChart(),
                  const SizedBox(height: 16),
                  _buildHotelRatingChart(),

                  const SizedBox(height: 28),
                  _buildSectionTitle('Statistik Rumah Sakit', Icons.local_hospital),
                  const SizedBox(height: 16),
                  _buildRsJenisChart(),
                  const SizedBox(height: 16),
                  _buildRsKelasChart(),
                  const SizedBox(height: 16),
                  _buildRsRatingChart(),

                  const SizedBox(height: 28),
                  _buildSectionTitle('Statistik Mall', Icons.shopping_bag),
                  const SizedBox(height: 16),
                  _buildMallRatingChart(),

                  const SizedBox(height: 28),
                  _buildSectionTitle('Statistik SPBU', Icons.local_gas_station),
                  const SizedBox(height: 16),
                  _buildSpbuJenisChart(),
                  const SizedBox(height: 16),
                  _buildSpbuRatingChart(),

                  const SizedBox(height: 24),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ──── Section Title ────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  // ──── CHART CARD WRAPPER ────
  Widget _chartCard({required String title, required Widget chart, double height = 220}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withAlpha(40), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withAlpha(8), blurRadius: 24, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: height, child: chart),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  // HOTEL CHARTS
  // ════════════════════════════════════════════

  Widget _buildHotelKategoriChart() {
    // Count hotels by kategori (star rating)
    final Map<int, int> kategoriCount = {};
    for (final h in _hotels) {
      kategoriCount[h.kategori] = (kategoriCount[h.kategori] ?? 0) + 1;
    }
    final sortedKeys = kategoriCount.keys.toList()..sort();
    
    final colors = [
      Colors.grey.shade500,
      Colors.lightBlue.shade500,
      Colors.purple.shade500,
      Colors.orange.shade600,
      Colors.red.shade500,
    ];

    return _chartCard(
      title: 'Distribusi Kategori Hotel',
      height: 250,
      chart: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sortedKeys.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final star = entry.value;
                  final count = kategoriCount[star]!;
                  final total = _hotels.length;
                  final pct = (count / total * 100);
                  return PieChartSectionData(
                    value: count.toDouble(),
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    color: colors[idx % colors.length],
                    radius: 50,
                    titlePositionPercentageOffset: 0.55,
                  );
                }).toList(),
                centerSpaceRadius: 36,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: sortedKeys.asMap().entries.map((entry) {
              final idx = entry.key;
              final star = entry.value;
              final count = kategoriCount[star]!;
              return _LegendItem(
                color: colors[idx % colors.length],
                label: 'Bintang $star ($count)',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelHargaChart() {
    // Group hotels by price range
    final ranges = <String, int>{
      '< 300rb': 0,
      '300rb - 500rb': 0,
      '500rb - 1jt': 0,
      '> 1jt': 0,
    };

    for (final h in _hotels) {
      if (h.harga < 300000) {
        ranges['< 300rb'] = ranges['< 300rb']! + 1;
      } else if (h.harga < 500000) {
        ranges['300rb - 500rb'] = ranges['300rb - 500rb']! + 1;
      } else if (h.harga < 1000000) {
        ranges['500rb - 1jt'] = ranges['500rb - 1jt']! + 1;
      } else {
        ranges['> 1jt'] = ranges['> 1jt']! + 1;
      }
    }

    final barColors = [
      const Color(0xFF4FC3F7),
      AppColors.primary,
      const Color(0xFF00468B),
      const Color(0xFF001B3E),
    ];

    final entries = ranges.entries.toList();
    final maxVal = entries.map((e) => e.value).fold(0, (a, b) => a > b ? a : b);

    return _chartCard(
      title: 'Distribusi Harga Hotel per Malam',
      height: 220,
      chart: BarChart(
        BarChartData(
          maxY: (maxVal + 2).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${entries[groupIndex].key}\n${rod.toY.toInt()} hotel',
                  GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[value.toInt()].key,
                        style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == value.roundToDouble()) {
                    return Text('${value.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.onSurfaceVariant));
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.outlineVariant.withAlpha(40), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            final idx = entry.key;
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  width: 28,
                  color: barColors[idx % barColors.length],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHotelRatingChart() {
    return _buildRatingBarChart(
      title: 'Distribusi Rating Hotel',
      items: _hotels.map((h) => h.rating).toList(),
      accentColor: AppColors.primary,
    );
  }

  // ════════════════════════════════════════════
  // RUMAH SAKIT CHARTS
  // ════════════════════════════════════════════

  Widget _buildRsJenisChart() {
    final Map<String, int> jenisCount = {};
    for (final r in _rumahSakits) {
      jenisCount[r.jenis] = (jenisCount[r.jenis] ?? 0) + 1;
    }

    final entries = jenisCount.entries.toList();
    
    // Specific color mapping requested by user
    final Map<String, Color> jenisColors = {
      'RSU': Colors.green.shade600,
      'RSJ': Colors.red.shade700,
      'RSIA': Colors.lightBlue.shade500,
    };

    return _chartCard(
      title: 'Distribusi Jenis Rumah Sakit',
      height: 250,
      chart: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: entries.map((entry) {
                  final jenis = entry.key;
                  final count = entry.value;
                  final total = _rumahSakits.length;
                  final pct = (count / total * 100);
                  return PieChartSectionData(
                    value: count.toDouble(),
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    color: jenisColors[jenis] ?? AppColors.primary,
                    radius: 50,
                    titlePositionPercentageOffset: 0.55,
                  );
                }).toList(),
                centerSpaceRadius: 36,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: entries.map((entry) {
              final jenis = entry.key;
              return _LegendItem(
                color: jenisColors[jenis] ?? AppColors.primary,
                label: '$jenis (${entry.value})',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRsKelasChart() {
    final Map<String, int> kelasCount = {};
    for (final r in _rumahSakits) {
      kelasCount[r.kelas] = (kelasCount[r.kelas] ?? 0) + 1;
    }

    final sortedKeys = kelasCount.keys.toList()..sort();
    final colors = [
      Colors.red.shade600,
      Colors.orange.shade700,
      Colors.purple.shade600,
      Colors.grey.shade600,
    ];

    final maxVal = kelasCount.values.fold(0, (a, b) => a > b ? a : b);

    return _chartCard(
      title: 'Distribusi Kelas Rumah Sakit',
      height: 200,
      chart: BarChart(
        BarChartData(
          maxY: (maxVal + 2).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  'Kelas ${sortedKeys[groupIndex]}\n${rod.toY.toInt()} RS',
                  GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < sortedKeys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Kelas ${sortedKeys[value.toInt()]}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == value.roundToDouble()) {
                    return Text('${value.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.onSurfaceVariant));
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.outlineVariant.withAlpha(40), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: sortedKeys.asMap().entries.map((entry) {
            final idx = entry.key;
            final kelas = entry.value;
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: kelasCount[kelas]!.toDouble(),
                  width: 32,
                  color: colors[idx % colors.length],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRsRatingChart() {
    return _buildRatingBarChart(
      title: 'Distribusi Rating Rumah Sakit',
      items: _rumahSakits.map((r) => r.rating).toList(),
      accentColor: AppColors.secondary,
    );
  }

  // ════════════════════════════════════════════
  // MALL CHARTS
  // ════════════════════════════════════════════

  Widget _buildMallRatingChart() {
    return _buildRatingBarChart(
      title: 'Distribusi Rating Mall',
      items: _malls.map((m) => m.rating).toList(),
      accentColor: AppColors.tertiary,
    );
  }

  // ════════════════════════════════════════════
  // SPBU CHARTS
  // ════════════════════════════════════════════

  Widget _buildSpbuJenisChart() {
    final Map<String, int> jenisCount = {};
    for (final s in _spbus) {
      jenisCount[s.jenis] = (jenisCount[s.jenis] ?? 0) + 1;
    }

    final brandColors = <String, Color>{
      'Pertamina': Colors.red.shade600,
      'Shell': Colors.yellow.shade700,
      'BP': Colors.green.shade600,
      'VIVO': const Color(0xFF0038A8), // Darker professional blue for Vivo
    };

    final entries = jenisCount.entries.toList();

    return _chartCard(
      title: 'Distribusi Jenis SPBU',
      height: 250,
      chart: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: entries.map((entry) {
                  final jenis = entry.key;
                  final count = entry.value;
                  final total = _spbus.length;
                  final pct = (count / total * 100);
                  return PieChartSectionData(
                    value: count.toDouble(),
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: jenis == 'Shell' ? Colors.black87 : Colors.white,
                    ),
                    color: brandColors[jenis] ?? AppColors.primary,
                    radius: 50,
                    titlePositionPercentageOffset: 0.55,
                  );
                }).toList(),
                centerSpaceRadius: 36,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: entries.map((e) {
              return _LegendItem(
                color: brandColors[e.key] ?? AppColors.primary,
                label: '${e.key} (${e.value})',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpbuRatingChart() {
    return _buildRatingBarChart(
      title: 'Distribusi Rating SPBU',
      items: _spbus.map((s) => s.rating).toList(),
      accentColor: AppColors.primary,
    );
  }

  // ════════════════════════════════════════════
  // SHARED: RATING BAR CHART
  // ════════════════════════════════════════════

  Widget _buildRatingBarChart({required String title, required List<double> items, required Color accentColor}) {
    // Group by rating ranges: ≤2, 2.1–3, 3.1–4, 4.1–5
    final ranges = <String, int>{
      '≤ 2.0': 0,
      '2.1 - 3.0': 0,
      '3.1 - 4.0': 0,
      '4.1 - 5.0': 0,
    };

    for (final r in items) {
      if (r <= 2.0) {
        ranges['≤ 2.0'] = ranges['≤ 2.0']! + 1;
      } else if (r <= 3.0) {
        ranges['2.1 - 3.0'] = ranges['2.1 - 3.0']! + 1;
      } else if (r <= 4.0) {
        ranges['3.1 - 4.0'] = ranges['3.1 - 4.0']! + 1;
      } else {
        ranges['4.1 - 5.0'] = ranges['4.1 - 5.0']! + 1;
      }
    }

    final entries = ranges.entries.toList();
    final maxVal = entries.map((e) => e.value).fold(0, (a, b) => a > b ? a : b);

    // Create gradient-like effect with lighter → darker shades
    final barColors = [
      accentColor.withAlpha(80),
      accentColor.withAlpha(130),
      accentColor.withAlpha(190),
      accentColor,
    ];

    return _chartCard(
      title: title,
      height: 200,
      chart: BarChart(
        BarChartData(
          maxY: (maxVal + 2).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${entries[groupIndex].key}\n${rod.toY.toInt()} lokasi',
                  GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[value.toInt()].key,
                        style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == value.roundToDouble()) {
                    return Text('${value.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.onSurfaceVariant));
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.outlineVariant.withAlpha(40), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            final idx = entry.key;
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  width: 28,
                  color: barColors[idx % barColors.length],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ──── EXISTING WIDGETS ────

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(
              icon: Icons.hotel,
              label: 'Hotel',
              count: _hotelCount,
              minDist: _minHotelDist,
              color: AppColors.primary,
              bgColor: AppColors.primaryFixed,
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              icon: Icons.local_hospital,
              label: 'Rumah Sakit',
              count: _rsCount,
              minDist: _minRsDist,
              color: AppColors.primary,
              bgColor: AppColors.primaryFixed,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(
              icon: Icons.shopping_bag,
              label: 'Mall',
              count: _mallCount,
              minDist: _minMallDist,
              color: AppColors.primary,
              bgColor: AppColors.primaryFixed,
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              icon: Icons.local_gas_station,
              label: 'SPBU',
              count: _spbuCount,
              minDist: _minSpbuDist,
              color: AppColors.primary,
              bgColor: AppColors.primaryFixed,
            )),
          ],
        ),
      ],
    );
  }
}

// ──── Legend Item ────
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final double? minDist;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    this.minDist,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withAlpha(40), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(8),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor.withAlpha(120),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

