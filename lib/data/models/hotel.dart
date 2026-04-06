class Hotel {
  final int id;
  final String nama;
  final String alamat;
  final double lat;
  final double lng;
  final double rating;
  final int kategori;
  final int harga;
  final List<String> fasilitas;
  final String pemesanan;
  final String peta;
  final String gambar;

  const Hotel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.kategori,
    required this.harga,
    required this.fasilitas,
    required this.pemesanan,
    required this.peta,
    required this.gambar,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      alamat: json['alamat'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      kategori: json['kategori'] as int,
      harga: json['harga'] as int,
      fasilitas: List<String>.from(json['fasilitas'] as List),
      pemesanan: json['pemesanan'] as String,
      peta: json['peta'] as String,
      gambar: json['gambar'] as String,
    );
  }

  String get assetGambar {
    // Convert "/images/hotel/Xxx.webp" to "assets/images/hotel/Xxx.webp"
    return 'assets$gambar';
  }

  String get hargaFormatted {
    final buffer = StringBuffer('Rp');
    final str = harga.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String get kategoriLabel => 'Bintang $kategori';
}
