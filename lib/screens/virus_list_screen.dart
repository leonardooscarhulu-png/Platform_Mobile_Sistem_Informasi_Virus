import 'package:flutter/material.dart';
import '../models/virus.dart';
import '../services/api_service.dart';
import 'virus_detail_screen.dart';
import 'virus_form_screen.dart';
import 'kategori_list_screen.dart';

class VirusListScreen extends StatefulWidget {
  const VirusListScreen({super.key});

  @override
  State<VirusListScreen> createState() => _VirusListScreenState();
}

class _VirusListScreenState extends State<VirusListScreen> {
  final ApiService _apiService = ApiService();
  List<Virus> _virusList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVirus();
  }

  Future<void> _loadVirus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final data = await _apiService.getVirus();
      setState(() {
        _virusList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteVirus(int id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah anda yakin ingin menghapus virus "$nama"?'),
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
        await _apiService.deleteVirus(id);
        _loadVirus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Virus "$nama" berhasil dihapus')),
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
        title: const Text('Sistem Informasi Virus'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KategoriListScreen()),
            ),
            tooltip: 'Kategori',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVirus,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVirus,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      )
          : _virusList.isEmpty
          ? const Center(child: Text('Belum ada data virus'))
          : RefreshIndicator(
        onRefresh: _loadVirus,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _virusList.length,
          itemBuilder: (context, index) {
            final virus = _virusList[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                  vertical: 6, horizontal: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    virus.namaVirus[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  virus.namaVirus,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      virus.namaIlmiah,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic),
                    ),
                    if (virus.kategoriDetail != null)
                      Text(
                        'Kategori: ${virus.kategoriDetail!.namaKategori}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    Text(
                      'Bentuk: ${virus.bentukDisplay}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: Colors.orange),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VirusFormScreen(virus: virus),
                          ),
                        );
                        _loadVirus();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () =>
                          _deleteVirus(virus.id, virus.namaVirus),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VirusDetailScreen(virusId: virus.id),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VirusFormScreen()),
          );
          _loadVirus();
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}