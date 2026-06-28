import 'package:flutter/material.dart';
import '../models/virus.dart';
import '../services/api_service.dart';

class KategoriListScreen extends StatefulWidget {
  const KategoriListScreen({super.key});

  @override
  State<KategoriListScreen> createState() => _KategoriListScreenState();
}

class _KategoriListScreenState extends State<KategoriListScreen> {
  final ApiService _apiService = ApiService();
  List<Kategori> _kategoriList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getKategori();
      setState(() {
        _kategoriList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showKategoriDialog({Kategori? kategori}) async {
    final namaController =
    TextEditingController(text: kategori?.namaKategori ?? '');
    final deskripsiController =
    TextEditingController(text: kategori?.deskripsi ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(kategori == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'nama_kategori': namaController.text,
                'deskripsi': deskripsiController.text,
              };
              try {
                if (kategori == null) {
                  await _apiService.createKategori(data);
                } else {
                  await _apiService.updateKategori(kategori.id, data);
                }
                if (mounted) Navigator.pop(context);
                _loadKategori();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              kategori == null ? 'Tambah' : 'Update',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteKategori(int id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus kategori "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _apiService.deleteKategori(id);
        _loadKategori();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kategori "$nama" berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Virus'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadKategori,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kategoriList.isEmpty
          ? const Center(child: Text('Belum ada kategori'))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _kategoriList.length,
        itemBuilder: (context, index) {
          final kategori = _kategoriList[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(
                  kategori.namaKategori[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                kategori.namaKategori,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kategori.deskripsi != null)
                    Text(kategori.deskripsi!),
                  Text(
                    'Jumlah Virus: ${kategori.jumlahVirus}',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: Colors.orange),
                    onPressed: () =>
                        _showKategoriDialog(kategori: kategori),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () => _deleteKategori(
                        kategori.id, kategori.namaKategori),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showKategoriDialog(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}