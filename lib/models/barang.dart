class Barang {
  final int id;
  final String namaBarang;
  final int jumlah;
  final String kondisi;
  final String? foto;

  Barang({
    required this.id,
    required this.namaBarang,
    required this.jumlah,
    required this.kondisi,
    this.foto,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'],
      jumlah: json['jumlah'],
      kondisi: json['kondisi'],
      foto: json['foto'],
    );
  }
}
