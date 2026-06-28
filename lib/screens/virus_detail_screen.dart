import 'package:flutter/material.dart';
import '../models/virus.dart';
import '../services/api_service.dart';
import 'virus_form_screen.dart';

class VirusDetailScreen extends StatefulWidget {
  final int virusId;

  const VirusDetailScreen({super.key, required this.virusId});

  @override
  State<VirusDetailScreen> createState() => _VirusDetailScreenState();
}

class _VirusDetailScreenState extends State<VirusDetailScreen> {
  final ApiService _apiService = ApiService();
  Virus? _virus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await _apiService.getVirusDetail(widget.virusId);
      setState(() {
        _virus = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_virus?.namaVirus ?? 'Detail Virus'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_virus != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VirusFormScreen(virus: _virus),
                  ),
                );
                _loadDetail();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _virus == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar atau Avatar
                    if (_virus!.gambarUrl != null &&
                        _virus!.gambarUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _virus!.gambarUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.green,
                              child: Text(
                                _virus!.namaVirus[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.green,
                          child: Text(
                            _virus!.namaVirus[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nama Virus', _virus!.namaVirus),
                    _buildInfoRow(
                        'Nama Ilmiah', _virus!.namaIlmiah,
                        italic: true),
                    if (_virus!.kategoriDetail != null)
                      _buildInfoRow('Kategori',
                          _virus!.kategoriDetail!.namaKategori),
                    _buildInfoRow('Bentuk', _virus!.bentukDisplay),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildSection('Deskripsi', _virus!.deskripsi),
            const SizedBox(height: 12),
            _buildSection(
                'Cara Berkembang Biak', _virus!.caraBerkembangBiak),
            if (_virus!.referensi != null &&
                _virus!.referensi!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSection('Referensi', _virus!.referensi!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool italic = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Divider(),
            Text(content),
          ],
        ),
      ),
    );
  }
}