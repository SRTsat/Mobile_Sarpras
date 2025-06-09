import 'package:flutter/material.dart';
import '../models/barang.dart';
import '../services/barang_service.dart';
import 'barang_detail_screen.dart';
import '../config.dart';

class BarangScreen extends StatefulWidget {
  const BarangScreen({super.key});

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  late Future<List<Barang>> _barangList;

  @override
  void initState() {
    super.initState();
    _barangList = BarangService.fetchBarangs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Barang')),
      body: FutureBuilder<List<Barang>>(
        future: _barangList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data barang'));
          }

          final barangs = snapshot.data!;

          return ListView.builder(
            itemCount: barangs.length,
            itemBuilder: (context, index) {
              final barang = barangs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: barang.foto != null
                      ? Image.network(
                          '$storageBaseUrl/${barang.foto}',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(barang.namaBarang),
                  subtitle:
                      Text('Jumlah: ${barang.jumlah} - ${barang.kondisi}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BarangDetailScreen(barang: barang),
                        ),
                      );
                    },
                    child: const Text('Pinjam'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
