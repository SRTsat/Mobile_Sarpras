import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/barang.dart';
import '../services/api_service.dart';
import '../config.dart';

class BarangDetailScreen extends StatefulWidget {
  final Barang barang;

  const BarangDetailScreen({super.key, required this.barang});

  @override
  State<BarangDetailScreen> createState() => _BarangDetailScreenState();
}

class _BarangDetailScreenState extends State<BarangDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  DateTime? _tanggalPinjam;
  bool _isLoading = false;

  Future<void> _submitPeminjaman() async {
    if (!_formKey.currentState!.validate() || _tanggalPinjam == null) return;

    setState(() => _isLoading = true);

    final apiService = ApiService();
    final response = await apiService.post(
      'peminjaman',
      {
        'barang_id': widget.barang.id.toString(),
        'nama_peminjam': _namaController.text,
        'jumlah_pinjam': _jumlahController.text,
        'tanggal_pinjam': _tanggalPinjam!.toIso8601String().split('T')[0],
      },
    );

    setState(() => _isLoading = false);

    final data = json.decode(response.body);

    if (data['status'] == 'menunggu' || data['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peminjaman berhasil dikirim')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${data['message'] ?? 'Terjadi kesalahan'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final barang = widget.barang;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (barang.foto != null)
              Image.network(
                '$storageBaseUrl/${barang.foto}',
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            const SizedBox(height: 16),
            Text(barang.namaBarang, style: const TextStyle(fontSize: 20)),
            Text('Jumlah: ${barang.jumlah}'), 
            Text('Kondisi: ${barang.kondisi}'),
            const Divider(height: 32),
            const Text("Form Peminjaman", style: TextStyle(fontSize: 18)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(labelText: 'Nama Peminjam'),
                    validator: (val) => val!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: _jumlahController,
                    decoration: const InputDecoration(labelText: 'Jumlah Pinjam'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Jumlah wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _tanggalPinjam == null
                              ? 'Tanggal belum dipilih'
                              : 'Tanggal: ${_tanggalPinjam!.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2026),
                          );
                          if (picked != null) {
                            setState(() => _tanggalPinjam = picked);
                          }
                        },
                        child: const Text('Pilih Tanggal'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitPeminjaman,
                          child: const Text('Kirim Permintaan'),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
