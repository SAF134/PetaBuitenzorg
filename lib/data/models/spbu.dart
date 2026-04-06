class Spbu {
  final int id;
  final String nama;
  final String jenis;
  final String alamat;
  final double lat;
  final double lng;
  final double rating;
  final List<String> fasilitas;
  final List<String> penawaran;
  final String peta;
  final String gambar;

  const Spbu({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.alamat,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.fasilitas,
    required this.penawaran,
    required this.peta,
    required this.gambar,
  });

  factory Spbu.fromJson(Map<String, dynamic> json) {
    return Spbu(
      id: json['id'] as int,
      nama: json['nama'] as String,
      jenis: json['jenis'] as String,
      alamat: json['alamat'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      fasilitas: List<String>.from(json['fasilitas'] as List),
      penawaran: List<String>.from(json['penawaran'] as List),
      peta: json['peta'] as String,
      gambar: json['gambar'] as String,
    );
  }

  String get assetGambar => 'assets$gambar';
}
