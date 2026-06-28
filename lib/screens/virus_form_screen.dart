import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/virus.dart';
import '../services/api_service.dart';

class VirusFormScreen extends StatefulWidget {
  final Virus? virus;

  const VirusFormScreen({super.key, this.virus});

  @override
  State<VirusFormScreen> createState() => _VirusFormScreenState();
}

class _VirusFormScreenState extends State<VirusFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  final _namaVirusController = TextEditingController();
  final _namaIlmiahController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _caraBerkembangBiakController = TextEditingController();
  final _referensiController = TextEditingController();

  String? _selectedBentuk;
  int? _selectedKategoriId;
  List<Kategori> _kategoriList = [];
  bool _isLoading = false;
  File? _selectedImage;

  final List<Map<String, String>> _bentukOptions = [
    {'value': 'helical', 'label': 'Helical'},
    {'value': 'icosahedral', 'label': 'Icosahedral'},
    {'value': 'prolate', 'label': 'Prolate'},
    {'value': 'envelope', 'label': 'Envelope'},
    {'value': 'complex', 'label': 'Complex'},
  ];

  @override
  void initState() {
    super.initState();
    _loadKategori();
    if (widget.virus != null) {
      _namaVirusController.text = widget.virus!.namaVirus;
      _namaIlmiahController.text = widget.virus!.namaIlmiah;
      _deskripsiController.text = widget.virus!.deskripsi;
      _caraBerkembangBiakController.text = widget.virus!.caraBerkembangBiak;
      _referensiController.text = widget.virus!.referensi ?? '';
      _selectedBentuk = widget.virus!.bentuk.isNotEmpty
          ? widget.virus!.bentuk
          : null;
      _selectedKategoriId = widget.virus!.kategori;
    }
  }

  Future<void> _loadKategori() async {
    try {
      final data = await _apiService.getKategori();
      setState(() => _kategoriList = data);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_selectedImage != null || widget.virus?.gambarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Gambar'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'nama_virus': _namaVirusController.text,
      'nama_ilmiah': _namaIlmiahController.text,
      'deskripsi': _deskripsiController.text,
      'cara_berkembang_biak': _caraBerkembangBiakController.text,
      'bentuk': _selectedBentuk ?? '',
      'referensi': _referensiController.text,
      if (_selectedKategoriId != null) 'kategori': _selectedKategoriId,
    };

    try {
      if (widget.virus == null) {
        await _apiService.createVirusWithImage(data, _selectedImage);
      } else {
        await _apiService.updateVirusWithImage(
            widget.virus!.id, data, _selectedImage);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.virus == null
                ? 'Virus berhasil ditambahkan'
                : 'Virus berhasil diperbarui'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaVirusController.dispose();
    _namaIlmiahController.dispose();
    _deskripsiController.dispose();
    _caraBerkembangBiakController.dispose();
    _referensiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.virus == null ? 'Tambah Virus' : 'Edit Virus'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Gambar
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : widget.virus?.gambarUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.virus!.gambarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap untuk pilih gambar',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          size: 60, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap untuk pilih gambar',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _namaVirusController,
                decoration: const InputDecoration(
                  labelText: 'Nama Virus',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.coronavirus),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Nama virus wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _namaIlmiahController,
                decoration: const InputDecoration(
                  labelText: 'Nama Ilmiah',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.science),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Nama ilmiah wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedKategoriId,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                hint: const Text('Pilih Kategori'),
                items: _kategoriList
                    .map((k) => DropdownMenuItem(
                  value: k.id,
                  child: Text(k.namaKategori),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedKategoriId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBentuk,
                hint: const Text('Pilih Bentuk'),
                decoration: const InputDecoration(
                  labelText: 'Bentuk',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shape_line),
                ),
                items: _bentukOptions
                    .map((b) => DropdownMenuItem(
                  value: b['value'],
                  child: Text(b['label']!),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBentuk = v),
                validator: (v) =>
                v == null || v.isEmpty ? 'Bentuk wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (v) =>
                v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caraBerkembangBiakController,
                decoration: const InputDecoration(
                  labelText: 'Cara Berkembang Biak',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.biotech),
                ),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty
                    ? 'Cara berkembang biak wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referensiController,
                decoration: const InputDecoration(
                  labelText: 'Referensi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.virus == null
                        ? 'Tambah Virus'
                        : 'Update Virus',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}