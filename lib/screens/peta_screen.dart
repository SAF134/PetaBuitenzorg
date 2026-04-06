import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/confirmation_dialog.dart';
import '../data/data_service.dart';
import '../data/routing_service.dart';
import '../data/models/hotel.dart';
import '../data/models/rumah_sakit.dart';
import '../data/models/mall.dart';
import '../data/models/spbu.dart';
import '../widgets/category_chip.dart';
import '../theme/app_colors.dart';
import 'informasi_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PetaScreen extends StatefulWidget {
  const PetaScreen({super.key});

  @override
  State<PetaScreen> createState() => _PetaScreenState();
}

class _PetaScreenState extends State<PetaScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  final MapController _mapController = MapController();
  int _selectedFilter = 0; // 0 = Semua
  final _filterLabels = ['Semua', 'Hotel', 'Rumah Sakit', 'Mall', 'SPBU'];
  final _filterIcons = [Icons.layers, Icons.hotel, Icons.local_hospital, Icons.shopping_bag, Icons.local_gas_station];

  List<Hotel> _hotels = [];
  List<RumahSakit> _rumahSakits = [];
  List<Mall> _malls = [];
  List<Spbu> _spbus = [];
  final List<Polyline> _boundaryPolylines = [];
  bool _loaded = false;

  String? _popupTitle;
  String? _popupSubtitle;
  double? _popupRating;
  String? _popupUrl;
  String? _popupBookUrl;
  int? _popupHarga;
  String? _popupImage;
  String? _popupKategori;
  String? _popupJenis;
  String? _popupKelas;
  double? _popupLat;
  double? _popupLng;


  LatLng? _userLocation;
  bool _isTracking = false;

  // Default Bogor center
  static const _bogorCenter = LatLng(-6.5971, 106.8060);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadData();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // Location services are disabled
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return; // Permissions are denied
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return; // Permissions are permanently denied
    }

    // If permission granted, get initial location without moving map
    _updateUserLocation(false);
  }

  Future<void> _updateUserLocation(bool centerMap) async {
    try {
      setState(() => _isTracking = true);
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isTracking = false;
      });
      
      if (centerMap && _userLocation != null) {
        _mapController.move(_userLocation!, 15);
      }
    } catch (e) {
      setState(() => _isTracking = false);
      debugPrint("Error getting location: $e");
    }
  }


  Future<void> _loadData() async {
    _hotels = await DataService.getHotels();
    _rumahSakits = await DataService.getRumahSakits();
    _malls = await DataService.getMalls();
    _spbus = await DataService.getSpbus();
    
    // Load Boundary
    final boundaryData = await DataService.getBogorBoundary();
    _parseBoundary(boundaryData);

    if (mounted) setState(() => _loaded = true);
  }

  void _parseBoundary(Map<String, dynamic> geojson) {
    if (geojson['features'] == null) return;
    
    for (var feature in geojson['features']) {
      var geometry = feature['geometry'];
      if (geometry == null) continue;
      
      if (geometry['type'] == 'Polygon') {
        _addPolygon(geometry['coordinates']);
      } else if (geometry['type'] == 'MultiPolygon') {
        for (var polygon in geometry['coordinates']) {
          _addPolygon(polygon);
        }
      }
    }
  }

  void _addPolygon(List<dynamic> coordinates) {
    for (var ring in coordinates) {
      List<LatLng> points = [];
      for (var coord in ring) {
        points.add(LatLng(coord[1] * 1.0, coord[0] * 1.0));
      }
      _boundaryPolylines.add(Polyline(
        points: points,
        color: AppColors.primary.withAlpha(180),
        strokeWidth: 3.5,
      ));
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_selectedFilter == 0 || _selectedFilter == 1) {
      for (final h in _hotels) {
        markers.add(_createMarker(
          point: LatLng(h.lat, h.lng),
          color: _getHotelColor(h.kategori.toString()),
          icon: Icons.hotel,
          title: h.nama,
          subtitle: h.alamat,
          rating: h.rating,
          url: h.peta,
          bookUrl: h.pemesanan,
          harga: h.harga,
          image: h.assetGambar,
          kategori: h.kategori.toString(),
        ));
      }
    }

    if (_selectedFilter == 0 || _selectedFilter == 2) {
      for (final r in _rumahSakits) {
        markers.add(_createMarker(
          point: LatLng(r.lat, r.lng),
          color: _getJenisColor(r.jenis),
          icon: Icons.local_hospital,
          label: r.kelas,
          title: r.nama,
          subtitle: r.alamat,
          rating: r.rating,
          url: r.peta,
          image: r.assetGambar,
          jenis: r.jenis,
          kelas: r.kelas,
        ));
      }
    }

    if (_selectedFilter == 0 || _selectedFilter == 3) {
      for (final m in _malls) {
        markers.add(_createMarker(
          point: LatLng(m.lat, m.lng),
          color: AppColors.tertiary,
          icon: Icons.shopping_bag,
          title: m.nama,
          subtitle: m.alamat,
          rating: m.rating,
          url: m.peta,
          image: m.assetGambar,
        ));
      }
    }

    if (_selectedFilter == 0 || _selectedFilter == 4) {
      for (final s in _spbus) {
        markers.add(_createMarker(
          point: LatLng(s.lat, s.lng),
          color: _getJenisColor(s.jenis),
          icon: Icons.local_gas_station,
          title: s.nama,
          subtitle: s.alamat,
          rating: s.rating,
          url: s.peta,
          image: s.assetGambar,
          jenis: s.jenis,
        ));
      }
    }

    if (_userLocation != null) {
      markers.add(Marker(
        point: _userLocation!,
        width: 60,
        height: 60,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulse effect
                Container(
                  width: 30 * _pulseAnimation.value,
                  height: 30 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha((50 * (1.5 - _pulseAnimation.value)).toInt()),
                    shape: BoxShape.circle,
                  ),
                ),
                // Outer glow
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: Colors.blue.withAlpha(50), shape: BoxShape.circle),
                ),
                // White border
                Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                // Blue center
                Container(
                  width: 14, height: 14,
                  decoration: const BoxDecoration(color: Color(0xFF2196F3), shape: BoxShape.circle),
                ),
              ],
            );
          },
        ),
      ));
    }

    return markers;
  }

  Marker _createMarker({
    required LatLng point,
    required Color color,
    required IconData icon,
    String? label,
    required String title,
    required String subtitle,
    required double rating,
    required String url,
    String? bookUrl,
    int? harga,
    required String image,
    String? kategori,
    String? jenis,
    String? kelas,
  }) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _popupTitle = title;
            _popupSubtitle = subtitle;
            _popupRating = rating;
            _popupUrl = url;
            _popupBookUrl = bookUrl;
            _popupHarga = harga;
            _popupImage = image;
            _popupKategori = kategori;
            _popupJenis = jenis;
            _popupKelas = kelas;
            _popupLat = point.latitude;
            _popupLng = point.longitude;
          });
          _animationController.forward(from: 0.0);
        },
        child: Container(
          decoration: BoxDecoration(
            color: color.withAlpha(230),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: label != null 
              ? Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
              : Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      body: Stack(
        children: [
          // Map
          if (_loaded)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _bogorCenter,
                initialZoom: 12.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Zoom only, No Rotation
                ),
                onTap: (_, _) {
                  setState(() {
                    _popupTitle = null;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  subdomains: const ['0', '1', '2', '3'], // Multiple subdomains for faster loading
                  userAgentPackageName: 'com.petabuitenzorg.app',
                ),
                PolylineLayer(polylines: _boundaryPolylines),
                MarkerLayer(markers: _buildMarkers()),
              ],
            )
          else
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),

          // Filter chips
          Positioned(
            top: 12,
            left: 0, right: 0,
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filterLabels.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => CategoryChip(
                  label: _filterLabels[i],
                  icon: _filterIcons[i],
                  isSelected: _selectedFilter == i,
                  onTap: () => setState(() {
                    _selectedFilter = i;
                    _popupTitle = null;
                  }),
                ),
              ),
            ),
          ),

          // Map Buttons (Top Right)
          Positioned(
            top: 70, // Below filter chips
            right: 16,
            child: Column(
              children: [
                _MapButton(
                  icon: _isTracking ? Icons.sync : Icons.my_location_rounded,
                  isActive: _userLocation != null,
                  onTap: () => _updateUserLocation(true),
                ),
                const SizedBox(height: 12),
                _MapButton(
                  icon: Icons.refresh_rounded,
                  onTap: () {
                    _mapController.move(_bogorCenter, 13);
                    setState(() => _popupTitle = null);
                  },
                ),
              ],
            ),
          ),

          // Info popup
          if (_popupTitle != null)
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Positioned(
                  bottom: 24 + (1.0 - _slideAnimation.value) * -200, // Slides from below
                  left: 16, right: 16,
                  child: Opacity(
                    opacity: _slideAnimation.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.primary.withAlpha(30), width: 1),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withAlpha(12), blurRadius: 40, offset: const Offset(0, 12)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Section: Image & Badge
                    Stack(
                      children: [
                        if (_popupImage != null)
                          Image.asset(_popupImage!, height: 140, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(height: 140, width: double.infinity, color: AppColors.surfaceContainerHigh, child: const Icon(Icons.image_not_supported_outlined, size: 32)),
                          ),
                        // Dark gradient overlay on image
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withAlpha(80), Colors.transparent, Colors.black.withAlpha(100)],
                            ),
                          ),
                        ),
                        // Badges on Image
                        Positioned(
                          top: 12, left: 12,
                          child: Row(
                            children: [
                              if (_popupKategori != null) 
                                _buildPopupBadge('Bintang $_popupKategori', _getHotelColor(_popupKategori!)),
                              if (_popupJenis != null) 
                                _buildPopupBadge(_popupJenis!, _getJenisColor(_popupJenis!)),
                              if (_popupKelas != null) ...[
                                const SizedBox(width: 6),
                                _buildPopupBadge('Kelas $_popupKelas', _getKelasColor(_popupKelas!)),
                              ],
                            ],
                          ),
                        ),
                        // Close Button (Pojok Kanan Atas)
                        Positioned(
                          top: 12, right: 12,
                          child: GestureDetector(
                            onTap: () async {
                              await _animationController.reverse();
                              setState(() => _popupTitle = null);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.black.withAlpha(80), shape: BoxShape.circle),
                              child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        // Rating Badge
                        if (_popupRating != null)
                          Positioned(
                            bottom: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withAlpha(230), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8)]),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(_popupRating!.toStringAsFixed(1), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Content Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_popupTitle!, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (_popupHarga != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Rp${_popupHarga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(_popupSubtitle!, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_userLocation != null && _popupLat != null && _popupLng != null) ...[
                            _buildDistanceInfo(_userLocation!, _popupLat!, _popupLng!),
                            const SizedBox(height: 16),
                          ],
                          // Premium Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _PopupActionButton(
                                  label: 'Google Maps',
                                  icon: Icons.near_me_rounded,
                                  color: AppColors.primary,
                                  onTap: () {
                                    if (_popupUrl != null) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ConfirmationDialog(
                                          title: 'Buka Google Maps',
                                          message: 'Navigasi ke $_popupTitle?',
                                          icon: Icons.map_rounded,
                                          iconColor: AppColors.primary,
                                          iconBgColor: AppColors.primary.withAlpha(20),
                                          onConfirm: () => _launchUrl(_popupUrl!),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              if (_popupBookUrl != null) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _PopupActionButton(
                                    label: 'Pemesanan',
                                    icon: Icons.shopping_cart_rounded,
                                    color: AppColors.primary,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ConfirmationDialog(
                                          title: 'Tautan Pemesanan',
                                          message: 'Pesan kamar di $_popupTitle?',
                                          icon: Icons.shopping_cart_rounded,
                                          iconColor: AppColors.primary,
                                          iconBgColor: AppColors.primary.withAlpha(20),
                                          onConfirm: () => _launchUrl(_popupBookUrl!),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPopupBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withAlpha(200), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Color _getHotelColor(String bintang) {
    switch (bintang) {
      case '5': return Colors.red.shade600;
      case '4': return Colors.orange.shade700;
      case '3': return Colors.purple.shade600;
      case '2': return Colors.lightBlue.shade600;
      case '1': return Colors.grey.shade600;
      default: return AppColors.secondary;
    }
  }

  Color _getJenisColor(String jenis) {
    switch (jenis.toUpperCase()) {
      case 'RSIA': return Colors.lightBlue.shade400;
      case 'RSU': return Colors.green.shade600;
      case 'RSJ': return Colors.red.shade700;
      case 'PERTAMINA': return Colors.red.shade600;
      case 'BP': return Colors.green.shade600;
      case 'SHELL': return Colors.yellow.shade700;
      case 'VIVO': return const Color(0xFF0047AB);
      default: return AppColors.secondary;
    }
  }

  Color _getKelasColor(String kelas) {
    switch (kelas.toUpperCase()) {
      case 'A': return Colors.red.shade600;
      case 'B': return Colors.orange.shade700;
      case 'C': return Colors.purple.shade600;
      case 'D': return Colors.grey.shade600;
      default: return AppColors.primary;
    }
  }

  Widget _buildDistanceInfo(LatLng userLoc, double targetLat, double targetLng) {
    return FutureBuilder<double>(
      future: RoutingService.getRouteDistance(
        userLoc,
        LatLng(targetLat, targetLng),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withAlpha(30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 10, height: 10,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                const SizedBox(width: 6),
                Text(
                  'Menghitung...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }

        final double distanceInMeters = snapshot.data ?? RoutingService.getStraightLineDistance(userLoc, LatLng(targetLat, targetLng));

        String formattedDistance;
        if (distanceInMeters < 1000) {
          formattedDistance = '${distanceInMeters.round()} m';
        } else {
          formattedDistance = '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withAlpha(30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.route_rounded, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                formattedDistance,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'dari lokasi Anda',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary.withAlpha(200),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  const _MapButton({required this.icon, required this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: isActive ? AppColors.brandBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppColors.brandBlue : Colors.black).withAlpha(isActive ? 60 : 25),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 24, color: isActive ? Colors.white : AppColors.brandBlue),
      ),
    );
  }
}

class _PopupActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PopupActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
