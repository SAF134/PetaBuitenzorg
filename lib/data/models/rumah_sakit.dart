class RumahSakit {
  final int id;
  final String nama;
  final String jenis;
  final String kelas;
  final double lat;
  final double lng;
  final double rating;
  final String alamat;
  final String peta;
  final String gambar;

  const RumahSakit({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.kelas,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.alamat,
    required this.peta,
    required this.gambar,
  });

  factory RumahSakit.fromJson(Map<String, dynamic> json) {
    return RumahSakit(
      id: json['id'] as int,
      nama: json['nama'] as String,
      jenis: json['jenis'] as String,
      kelas: json['kelas'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      alamat: json['alamat'] as String,
      peta: json['peta'] as String,
      gambar: json['gambar'] as String,
    );
  }

  String get assetGambar => 'assets$gambar';

  String get jenisLabel {
    switch (jenis) {
      case 'RSU':
        return 'RSU';
      case 'RSIA':
        return 'RSIA';
      case 'RSJ':
        return 'RSJ';
      default:
        return jenis;
    }
  }

  String get kelasLabel => 'Kelas $kelas';
}
