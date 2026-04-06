class Mall {
  final int id;
  final String nama;
  final String alamat;
  final double lat;
  final double lng;
  final double rating;
  final String peta;
  final String gambar;

  const Mall({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.peta,
    required this.gambar,
  });

  factory Mall.fromJson(Map<String, dynamic> json) {
    return Mall(
      id: json['id'] as int,
      nama: json['nama'] as String,
      alamat: json['alamat'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      peta: json['peta'] as String,
      gambar: json['gambar'] as String,
    );
  }

  String get assetGambar => 'assets$gambar';
}
