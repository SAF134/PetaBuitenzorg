import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/data_service.dart';
import '../data/models/hotel.dart';
import '../data/models/rumah_sakit.dart';
import '../data/models/mall.dart';
import '../data/models/spbu.dart';
import '../widgets/gradient_button.dart';
import '../widgets/rating_badge.dart';
import '../widgets/category_chip.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/filter_modal.dart';
import 'informasi_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../data/routing_service.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme/app_colors.dart';

class JelajahiScreen extends StatefulWidget {
  const JelajahiScreen({super.key});

  @override
  State<JelajahiScreen> createState() => _JelajahiScreenState();
}

class _JelajahiScreenState extends State<JelajahiScreen> {
  int _selectedTab = 0;
  final _tabs = ['Hotel', 'Rumah Sakit', 'Mall', 'SPBU'];
  final _icons = [Icons.hotel, Icons.local_hospital, Icons.shopping_bag, Icons.local_gas_station];

  List<Hotel> _hotels = [];
  List<RumahSakit> _rumahSakits = [];
  List<Mall> _malls = [];
  List<Spbu> _spbus = [];
  String _searchQuery = '';
  bool _loaded = false;
  LatLng? _userLocation;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  FilterStateData _filterData = FilterStateData();
  List<String> _availableHotelFas = [];
  List<String> _availableRsJenis = [];
  List<String> _availableSpbuJenis = [];
  List<String> _availableSpbuFas = [];
  List<String> _availableSpbuPen = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkLocationPermission();
    _scrollController.addListener(() {
      if (_scrollController.offset > 400) {
        if (!_showBackToTop) setState(() => _showBackToTop = true);
      } else {
        if (_showBackToTop) setState(() => _showBackToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final hotelData = await DataService.getHotels();
    final rsData = await DataService.getRumahSakits();
    final mallData = await DataService.getMalls();
    final spbuData = await DataService.getSpbus();
    if (mounted) {
      setState(() {
        _hotels = hotelData;
        _rumahSakits = rsData;
        _malls = mallData;
        _spbus = spbuData;
        _loaded = true;

        _availableHotelFas = _hotels.expand((h) => h.fasilitas).toSet().toList();
        _availableRsJenis = _rumahSakits.map((r) => r.jenis).toSet().toList();
        _availableSpbuJenis = _spbus.map((s) => s.jenis).toSet().toList();
        _availableSpbuFas = _spbus.expand((s) => s.fasilitas).toSet().toList();
        _availableSpbuPen = _spbus.expand((s) => s.penawaran).toSet().toList();
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
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
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Could not launch $url : $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo/Logo_PetaBuitenzorg.png',
              width: 32, height: 32, fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              'PetaBuitenzorg',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20, fontWeight: FontWeight.w700,
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
      floatingActionButton: _buildFAB(),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Cari nama ${_tabs[_selectedTab].toLowerCase()}...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => setState(() => _searchQuery = ''),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => FilterModal(
                                tabIndex: _selectedTab,
                                initialData: _filterData,
                                availableHotelFas: _availableHotelFas,
                                availableRsJenis: _availableRsJenis,
                                availableSpbuJenis: _availableSpbuJenis,
                                availableSpbuFas: _availableSpbuFas,
                                availableSpbuPen: _availableSpbuPen,
                                onApply: (newData) => setState(() => _filterData = newData),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withAlpha(50)),
                            ),
                            child: const Icon(Icons.tune_rounded, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tabs.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) => CategoryChip(
                          label: _tabs[i],
                          icon: _icons[i],
                          isSelected: _selectedTab == i,
                          onTap: () => setState(() => _selectedTab = i),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    if (_loaded) _buildList() else _buildShimmerList(),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                  ],
                ),
              ),
            ],
          ),
          // Floating Location Count Badge
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildFloatingCountBadge(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCountBadge() {
    int filteredCount = 0;
    int totalCount = 0;
    
    switch (_selectedTab) {
      case 0:
        filteredCount = _hotels.where((h) {
          if (!h.nama.toLowerCase().contains(_searchQuery)) return false;
          if (_filterData.hotelBintang.isNotEmpty && !_filterData.hotelBintang.contains(h.kategori)) return false;
          if (_filterData.hotelMinRating > 0 && h.rating < _filterData.hotelMinRating) return false;
          if (_filterData.hotelFasilitas.isNotEmpty && !_filterData.hotelFasilitas.every((f) => h.fasilitas.contains(f))) return false;
          return true;
        }).length;
        totalCount = _hotels.length;
        break;
      case 1:
        filteredCount = _rumahSakits.where((r) {
          if (!r.nama.toLowerCase().contains(_searchQuery)) return false;
          if (_filterData.rsJenis.isNotEmpty && !_filterData.rsJenis.contains(r.jenis)) return false;
          if (_filterData.rsKelas.isNotEmpty && !_filterData.rsKelas.contains(r.kelas)) return false;
          if (_filterData.rsMinRating > 0 && r.rating < _filterData.rsMinRating) return false;
          return true;
        }).length;
        totalCount = _rumahSakits.length;
        break;
      case 2:
        filteredCount = _malls.where((m) {
          if (!m.nama.toLowerCase().contains(_searchQuery)) return false;
          if (_filterData.mallMinRating > 0 && m.rating < _filterData.mallMinRating) return false;
          return true;
        }).length;
        totalCount = _malls.length;
        break;
      case 3:
        filteredCount = _spbus.where((s) {
          if (!s.nama.toLowerCase().contains(_searchQuery)) return false;
          if (_filterData.spbuJenis.isNotEmpty && !_filterData.spbuJenis.contains(s.jenis)) return false;
          if (_filterData.spbuMinRating > 0 && s.rating < _filterData.spbuMinRating) return false;
          return true;
        }).length;
        totalCount = _spbus.length;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brandBlue.withAlpha(230),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandBlue.withAlpha(75),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Menampilkan $filteredCount dari $totalCount lokasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    switch (_selectedTab) {
      case 0: return _buildHotelList();
      case 1: return _buildRsList();
      case 2: return _buildMallList();
      case 3: return _buildSpbuList();
      default: return const SliverToBoxAdapter(child: SizedBox());
    }
  }

  Widget _buildShimmerList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Shimmer.fromColors(
            baseColor: AppColors.surfaceContainerHigh,
            highlightColor: AppColors.surface,
            child: const ShimmerCard(),
          ),
          childCount: 5,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedScale(
      scale: _showBackToTop ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton(
        onPressed: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuart),
        backgroundColor: AppColors.primary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  final Map<String, double> _drivingDistanceCache = {};
  
  String _getDistanceKey(LatLng start, LatLng end) => '${start.latitude.toStringAsFixed(5)},${start.longitude.toStringAsFixed(5)}-${end.latitude.toStringAsFixed(5)},${end.longitude.toStringAsFixed(5)}';

  void _sortListByDistance<T>(List<T> list, String sortParam, LatLng Function(T) getLatLng) {
    if (_userLocation == null) return;
    list.sort((a, b) {
      final locA = getLatLng(a);
      final locB = getLatLng(b);
      final da = _drivingDistanceCache[_getDistanceKey(_userLocation!, locA)] ?? Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, locA.latitude, locA.longitude);
      final db = _drivingDistanceCache[_getDistanceKey(_userLocation!, locB)] ?? Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, locB.latitude, locB.longitude);
      return sortParam == 'Terjauh' ? db.compareTo(da) : da.compareTo(db);
    });
  }


  Widget _buildHotelList() {
    var filtered = _hotels.where((h) {
      if (!h.nama.toLowerCase().contains(_searchQuery)) return false;
      if (_filterData.hotelBintang.isNotEmpty && !_filterData.hotelBintang.contains(h.kategori)) return false;
      if (_filterData.hotelMinRating > 0 && h.rating < _filterData.hotelMinRating) return false;
      if (_filterData.hotelFasilitas.isNotEmpty && !_filterData.hotelFasilitas.every((f) => h.fasilitas.contains(f))) return false;
      if (_filterData.hotelHargaRange.isNotEmpty) {
        if (_filterData.hotelHargaRange == '<= 200.000' && h.harga > 200000) return false;
        if (_filterData.hotelHargaRange == '<= 400.000' && h.harga > 400000) return false;
        if (_filterData.hotelHargaRange == '<= 600.000' && h.harga > 600000) return false;
        if (_filterData.hotelHargaRange == '<= 800.000' && h.harga > 800000) return false;
        if (_filterData.hotelHargaRange == '<= 1.000.000' && h.harga > 1000000) return false;
        if (_filterData.hotelHargaRange == '> 1.000.000' && h.harga <= 1000000) return false;
      }
      return true;
    }).toList();
    _sortListByDistance(filtered, _filterData.hotelJarak, (h) => LatLng(h.lat, h.lng));
    return MultiSliver(children: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => AnimationConfiguration.staggeredList(
              position: i, duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _HotelCard(
                    hotel: filtered[i], userLocation: _userLocation,
                    onMap: () => showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Buka Google Maps',
                        message: 'Navigasi ke ${filtered[i].nama}?',
                        icon: Icons.map_rounded,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.primary.withAlpha(20),
                        onConfirm: () => _launchUrl(filtered[i].peta),
                      ),
                    ),
                    onBook: (url) => showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Tautan Pemesanan',
                        message: 'Pesan kamar di ${filtered[i].nama}?',
                        icon: Icons.shopping_cart_rounded,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.primary.withAlpha(20),
                        onConfirm: () => _launchUrl(url),
                      ),
                    ),
                    onDistanceFetched: (k, d) { if (_drivingDistanceCache[k] != d) setState(() => _drivingDistanceCache[k] = d); },
                  ),
                ),
              ),
            ),
            childCount: filtered.length,
          ),
        ),
      ),
    ]);
  }

  Widget _buildRsList() {
    var filtered = _rumahSakits.where((r) {
      if (!r.nama.toLowerCase().contains(_searchQuery)) return false;
      if (_filterData.rsJenis.isNotEmpty && !_filterData.rsJenis.contains(r.jenis)) return false;
      if (_filterData.rsKelas.isNotEmpty && !_filterData.rsKelas.contains(r.kelas)) return false;
      if (_filterData.rsMinRating > 0 && r.rating < _filterData.rsMinRating) return false;
      return true;
    }).toList();
    _sortListByDistance(filtered, _filterData.rsJarak, (r) => LatLng(r.lat, r.lng));
    return MultiSliver(children: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => AnimationConfiguration.staggeredList(
              position: i, duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _RsCard(
                    rs: filtered[i], userLocation: _userLocation,
                    onMap: () => showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Buka Google Maps',
                        message: 'Navigasi ke ${filtered[i].nama}?',
                        icon: Icons.map_rounded,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.primary.withAlpha(20),
                        onConfirm: () => _launchUrl(filtered[i].peta),
                      ),
                    ),
                    onDistanceFetched: (k, d) { if (_drivingDistanceCache[k] != d) setState(() => _drivingDistanceCache[k] = d); },
                  ),
                ),
              ),
            ),
            childCount: filtered.length,
          ),
        ),
      ),
    ]);
  }

  Widget _buildMallList() {
    var filtered = _malls.where((m) {
      if (!m.nama.toLowerCase().contains(_searchQuery)) return false;
      if (_filterData.mallMinRating > 0 && m.rating < _filterData.mallMinRating) return false;
      return true;
    }).toList();
    _sortListByDistance(filtered, _filterData.mallJarak, (m) => LatLng(m.lat, m.lng));
    return MultiSliver(children: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => AnimationConfiguration.staggeredList(
              position: i, duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _MallCard(
                    mall: filtered[i], userLocation: _userLocation,
                    onMap: () => showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Buka Google Maps',
                        message: 'Navigasi ke ${filtered[i].nama}?',
                        icon: Icons.map_rounded,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.primary.withAlpha(20),
                        onConfirm: () => _launchUrl(filtered[i].peta),
                      ),
                    ),
                    onDistanceFetched: (k, d) { if (_drivingDistanceCache[k] != d) setState(() => _drivingDistanceCache[k] = d); },
                  ),
                ),
              ),
            ),
            childCount: filtered.length,
          ),
        ),
      ),
    ]);
  }

  Widget _buildSpbuList() {
    var filtered = _spbus.where((s) {
      if (!s.nama.toLowerCase().contains(_searchQuery)) return false;
      if (_filterData.spbuJenis.isNotEmpty && !_filterData.spbuJenis.contains(s.jenis)) return false;
      if (_filterData.spbuMinRating > 0 && s.rating < _filterData.spbuMinRating) return false;
      if (_filterData.spbuPenawaran.isNotEmpty && !_filterData.spbuPenawaran.every((p) => s.penawaran.contains(p))) return false;
      if (_filterData.spbuFasilitas.isNotEmpty && !_filterData.spbuFasilitas.every((f) => s.fasilitas.contains(f))) return false;
      return true;
    }).toList();
    _sortListByDistance(filtered, _filterData.spbuJarak, (s) => LatLng(s.lat, s.lng));
    return MultiSliver(children: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => AnimationConfiguration.staggeredList(
              position: i, duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _SpbuCard(
                    spbu: filtered[i], userLocation: _userLocation,
                    onMap: () => showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Buka Google Maps',
                        message: 'Navigasi ke ${filtered[i].nama}?',
                        icon: Icons.map_rounded,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.primary.withAlpha(20),
                        onConfirm: () => _launchUrl(filtered[i].peta),
                      ),
                    ),
                    onDistanceFetched: (k, d) { if (_drivingDistanceCache[k] != d) setState(() => _drivingDistanceCache[k] = d); },
                  ),
                ),
              ),
            ),
            childCount: filtered.length,
          ),
        ),
      ),
    ]);
  }
}

class _HotelCard extends StatelessWidget {
  final Hotel hotel;
  final LatLng? userLocation;
  final VoidCallback onMap;
  final Function(String) onBook;
  final Function(String, double) onDistanceFetched;
  const _HotelCard({required this.hotel, this.userLocation, required this.onMap, required this.onBook, required this.onDistanceFetched});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    switch (hotel.kategori) {
      case 5: badgeColor = Colors.red.shade600; break;
      case 4: badgeColor = Colors.orange.shade700; break;
      case 3: badgeColor = Colors.purple.shade600; break;
      case 2: badgeColor = Colors.lightBlue.shade600; break;
      case 1: badgeColor = Colors.grey.shade600; break;
      default: badgeColor = AppColors.secondaryContainer;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withAlpha(40), width: 1.5), boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(8), blurRadius: 24, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: Image.asset(hotel.assetGambar, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 180, color: AppColors.surfaceContainerHigh, child: const Center(child: Icon(Icons.hotel, size: 48, color: AppColors.outline))))),
            Positioned(top: 12, right: 12, child: RatingBadge(rating: hotel.rating)),
            Positioned(top: 12, left: 12, child: _Badge(hotel.kategoriLabel, badgeColor, Colors.white)),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(hotel.nama, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis)),
                Row(children: [const Icon(Icons.account_balance_wallet_rounded, size: 14, color: AppColors.primary), const SizedBox(width: 4), Text(hotel.hargaFormatted, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary))]),
              ]),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary), const SizedBox(width: 4), Expanded(child: Text(hotel.alamat, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis))]),
              const SizedBox(height: 8),
              if (userLocation != null) _DistanceInfo(userLoc: userLocation!, targetLat: hotel.lat, targetLng: hotel.lng, onDistanceFetched: (d) => onDistanceFetched('${userLocation!.latitude},${userLocation!.longitude}-${hotel.lat},${hotel.lng}', d)),
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: hotel.fasilitas.take(3).map((f) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(8)), child: Text(f, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)))).toList()),
              const SizedBox(height: 14),
              Row(children: [Expanded(child: GradientButton(label: 'Google Maps', icon: Icons.near_me, onPressed: onMap)), const SizedBox(width: 8), Expanded(child: GradientButton(label: 'Pemesanan', icon: Icons.shopping_cart, onPressed: () => onBook(hotel.pemesanan)))]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _RsCard extends StatelessWidget {
  final RumahSakit rs;
  final LatLng? userLocation;
  final VoidCallback onMap;
  final Function(String, double) onDistanceFetched;
  const _RsCard({required this.rs, this.userLocation, required this.onMap, required this.onDistanceFetched});

  @override
  Widget build(BuildContext context) {
    Color kelasColor;
    switch (rs.kelas.toUpperCase()) {
      case 'A': kelasColor = Colors.red.shade600; break;
      case 'B': kelasColor = Colors.orange.shade700; break;
      case 'C': kelasColor = Colors.purple.shade600; break;
      case 'D': kelasColor = Colors.grey.shade600; break;
      default: kelasColor = AppColors.primaryContainer;
    }
    Color jenisColor;
    switch (rs.jenis.toUpperCase()) {
      case 'RSIA': jenisColor = Colors.lightBlue.shade400; break;
      case 'RSU': jenisColor = Colors.green.shade600; break;
      case 'RSJ': jenisColor = Colors.red.shade700; break;
      default: jenisColor = AppColors.secondaryContainer;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withAlpha(40), width: 1.5), boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(8), blurRadius: 24, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: Image.asset(rs.assetGambar, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 180, color: AppColors.surfaceContainerHigh, child: const Center(child: Icon(Icons.local_hospital, size: 48, color: AppColors.outline))))),
            Positioned(top: 12, right: 12, child: RatingBadge(rating: rs.rating)),
            Positioned(top: 12, left: 12, child: Row(children: [_Badge(rs.jenisLabel, jenisColor, Colors.white), const SizedBox(width: 6), _Badge(rs.kelasLabel, kelasColor, Colors.white)])),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rs.nama, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary), const SizedBox(width: 4), Expanded(child: Text(rs.alamat, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis))]),
              const SizedBox(height: 8),
              if (userLocation != null) _DistanceInfo(userLoc: userLocation!, targetLat: rs.lat, targetLng: rs.lng, onDistanceFetched: (d) => onDistanceFetched('${userLocation!.latitude},${userLocation!.longitude}-${rs.lat},${rs.lng}', d)),
              const SizedBox(height: 14),
              GradientButton(label: 'Google Maps', icon: Icons.near_me, onPressed: onMap),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _MallCard extends StatelessWidget {
  final Mall mall;
  final LatLng? userLocation;
  final VoidCallback onMap;
  final Function(String, double) onDistanceFetched;
  const _MallCard({required this.mall, this.userLocation, required this.onMap, required this.onDistanceFetched});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withAlpha(40), width: 1.5), boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(8), blurRadius: 24, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: Image.asset(mall.assetGambar, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 180, color: AppColors.surfaceContainerHigh, child: const Center(child: Icon(Icons.shopping_bag, size: 48, color: AppColors.outline))))),
            Positioned(top: 12, right: 12, child: RatingBadge(rating: mall.rating)),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mall.nama, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary), const SizedBox(width: 4), Expanded(child: Text(mall.alamat, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis))]),
              const SizedBox(height: 8),
              if (userLocation != null) _DistanceInfo(userLoc: userLocation!, targetLat: mall.lat, targetLng: mall.lng, onDistanceFetched: (d) => onDistanceFetched('${userLocation!.latitude},${userLocation!.longitude}-${mall.lat},${mall.lng}', d)),
              const SizedBox(height: 14),
              GradientButton(label: 'Google Maps', icon: Icons.near_me, onPressed: onMap),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _SpbuCard extends StatelessWidget {
  final Spbu spbu;
  final LatLng? userLocation;
  final VoidCallback onMap;
  final Function(String, double) onDistanceFetched;
  const _SpbuCard({required this.spbu, this.userLocation, required this.onMap, required this.onDistanceFetched});

  @override
  Widget build(BuildContext context) {
    Color brandColor;
    Color textColor = Colors.white;
    switch (spbu.jenis.toUpperCase()) {
      case 'PERTAMINA': brandColor = Colors.red.shade600; break;
      case 'BP': brandColor = Colors.green.shade600; break;
      case 'SHELL': brandColor = Colors.yellow.shade700; textColor = Colors.black87; break;
      case 'VIVO': brandColor = const Color(0xFF0047AB); break;
      default: brandColor = AppColors.secondaryContainer;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withAlpha(40), width: 1.5), boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(8), blurRadius: 24, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: Image.asset(spbu.assetGambar, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 180, color: AppColors.surfaceContainerHigh, child: const Center(child: Icon(Icons.local_gas_station, size: 48, color: AppColors.outline))))),
            Positioned(top: 12, right: 12, child: RatingBadge(rating: spbu.rating)),
            Positioned(top: 12, left: 12, child: _Badge(spbu.jenis, brandColor, textColor)),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(spbu.nama, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary), const SizedBox(width: 4), Expanded(child: Text(spbu.alamat, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis))]),
              const SizedBox(height: 8),
              if (userLocation != null) _DistanceInfo(userLoc: userLocation!, targetLat: spbu.lat, targetLng: spbu.lng, onDistanceFetched: (d) => onDistanceFetched('${userLocation!.latitude},${userLocation!.longitude}-${spbu.lat},${spbu.lng}', d)),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                ...spbu.penawaran.take(3).map((p) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(8)), child: Text(p, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)))),
              ]),
              const SizedBox(height: 14),
              GradientButton(label: 'Google Maps', icon: Icons.near_me, onPressed: onMap),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Badge(this.text, this.bg, this.fg);
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: bg.withAlpha(220), borderRadius: BorderRadius.circular(100)), child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.8)));
  }
}

class _DistanceInfo extends StatelessWidget {
  final LatLng userLoc;
  final double targetLat;
  final double targetLng;
  final Function(double) onDistanceFetched;
  const _DistanceInfo({required this.userLoc, required this.targetLat, required this.targetLng, required this.onDistanceFetched});
  @override
  Widget build(BuildContext context) {
    final double straightLineDist = RoutingService.getStraightLineDistance(userLoc, LatLng(targetLat, targetLng));
    return FutureBuilder<double>(
      future: RoutingService.getRouteDistance(userLoc, LatLng(targetLat, targetLng)),
      builder: (context, snapshot) {
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final double distanceInMeters = snapshot.data ?? straightLineDist;
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onDistanceFetched(snapshot.data!));
        }
        String formattedDistance = distanceInMeters < 1000 ? '${distanceInMeters.round()} m' : '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(isLoading ? 10 : 15), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withAlpha(isLoading ? 20 : 30))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (isLoading) const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary))
            else const Icon(Icons.route_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(isLoading ? '$formattedDistance (Calculating...)' : '$formattedDistance dari lokasi Anda', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
        );
      },
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 180, width: double.infinity, decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(top: Radius.circular(24)))), Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 150, height: 16, color: Colors.black), const SizedBox(height: 12), Container(width: 200, height: 12, color: Colors.black)]))]));
  }
}
