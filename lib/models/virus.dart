class Kategori {
  final int id;
  final String namaKategori;
  final String? deskripsi;
  final int jumlahVirus;

  Kategori({
    required this.id,
    required this.namaKategori,
    this.deskripsi,
    required this.jumlahVirus,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      namaKategori: json['nama_kategori'],
      deskripsi: json['deskripsi'],
      jumlahVirus: json['jumlah_virus'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_kategori': namaKategori,
      'deskripsi': deskripsi,
    };
  }
}

class Virus {
  final int id;
  final String namaVirus;
  final String namaIlmiah;
  final int? kategori;
  final Kategori? kategoriDetail;
  final String deskripsi;
  final String caraBerkembangBiak;
  final String bentuk;
  final String bentukDisplay;
  final String? gambarUrl;
  final String? referensi;

  Virus({
    required this.id,
    required this.namaVirus,
    required this.namaIlmiah,
    this.kategori,
    this.kategoriDetail,
    required this.deskripsi,
    required this.caraBerkembangBiak,
    required this.bentuk,
    required this.bentukDisplay,
    this.gambarUrl,
    this.referensi,
  });

  factory Virus.fromJson(Map<String, dynamic> json) {
    return Virus(
      id: json['id'],
      namaVirus: json['nama_virus'],
      namaIlmiah: json['nama_ilmiah'],
      kategori: json['kategori'],
      kategoriDetail: json['kategori_detail'] != null
          ? Kategori.fromJson(json['kategori_detail'])
          : null,
      deskripsi: json['deskripsi'] ?? '',
      caraBerkembangBiak: json['cara_berkembang_biak'] ?? '',
      bentuk: json['bentuk'] ?? '',
      bentukDisplay: json['bentuk_display'] ?? '',
      gambarUrl: json['gambar_url'],
      referensi: json['referensi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_virus': namaVirus,
      'nama_ilmiah': namaIlmiah,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'cara_berkembang_biak': caraBerkembangBiak,
      'bentuk': bentuk,
      'referensi': referensi,
    };
  }
}