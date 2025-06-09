import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../config.dart';

class RiwayatPeminjamanScreen extends StatefulWidget {
  const RiwayatPeminjamanScreen({super.key});

  @override
  State<RiwayatPeminjamanScreen> createState() => _RiwayatPeminjamanScreenState();
}

class _RiwayatPeminjamanScreenState extends State<RiwayatPeminjamanScreen> {
  List<dynamic> _riwayat = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    try {
      final response = await ApiService().get('riwayat-peminjaman');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _riwayat = data is List ? data : data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  void showPengembalianDialog(int peminjamanId) {
    final namaController = TextEditingController();
    final jumlahController = TextEditingController();
    final kondisiController = TextEditingController();
    DateTime? tanggal;
    XFile? foto;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Pengembalian'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Pengembali'),
              ),
              TextField(
                controller: jumlahController,
                decoration: const InputDecoration(labelText: 'Jumlah Kembali'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: kondisiController,
                decoration: const InputDecoration(labelText: 'Kondisi Barang'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2026),
                  );
                  if (picked != null) {
                    tanggal = picked;
                  }
                },
                child: const Text('Pilih Tanggal Kembali'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    foto = pickedFile;
                  }
                },
                child: const Text('Pilih Foto Barang'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (namaController.text.isEmpty ||
                        jumlahController.text.isEmpty ||
                        kondisiController.text.isEmpty ||
                        tanggal == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harap isi semua field')),
                      );
                      return;
                    }

                    setState(() => _isSubmitting = true);
                    final token = await AuthService.getToken();
                    final uri = Uri.parse('$baseUrl/pengembalian');
                    final request = http.MultipartRequest('POST', uri);
                    request.headers['Authorization'] = 'Bearer $token';

                    request.fields.addAll({
                      'peminjaman_id': peminjamanId.toString(),
                      'nama_pengembali': namaController.text,
                      'jumlah_kembali': jumlahController.text,
                      'kondisi_barang': kondisiController.text,
                      'tanggal_kembali': tanggal!.toIso8601String().split('T')[0],
                    });

                    if (foto != null) {
                      request.files.add(await http.MultipartFile.fromBytes(
                        'foto_barang',
                        await foto!.readAsBytes(),
                        filename: foto!.name,
                      ));
                    }

                    final response = await request.send();
                    setState(() => _isSubmitting = false);

                    if (response.statusCode == 200) {
                      Navigator.pop(context);
                      fetchRiwayat(); // refresh
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Berhasil dikembalikan")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gagal mengembalikan")),
                      );
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kembalikan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Peminjaman')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _riwayat.isEmpty
              ? const Center(child: Text('Belum ada riwayat peminjaman'))
              : ListView.builder(
                  itemCount: _riwayat.length,
                  itemBuilder: (context, index) {
                    final item = _riwayat[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.assignment),
                        title: Text(
                          item['barang'] != null
                              ? item['barang']['nama_barang'] ?? '-'
                              : 'Barang tidak tersedia',
                        ),
                        subtitle: Text('Status: ${item['status']}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item['tanggal_pinjam']),
                            if (item['status'] == 'disetujui')
                              TextButton(
                                onPressed: () => showPengembalianDialog(item['id']),
                                child: const Text('Kembalikan'),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
