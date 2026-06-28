import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/virus.dart';

class ApiService {
  static const String baseUrl =
      'https://webservicesisteminformasivirus-production.up.railway.app/api';

  // ========== KATEGORI ==========
  Future<List<Kategori>> getKategori() async {
    final response = await http.get(Uri.parse('$baseUrl/kategori/'));
    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      List<dynamic> data = decoded is List ? decoded : decoded['results'] ?? [];
      return data.map((e) => Kategori.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil data kategori');
  }

  Future<Kategori> createKategori(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kategori/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Kategori.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal menambah kategori');
  }

  Future<Kategori> updateKategori(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/kategori/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Kategori.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal mengupdate kategori');
  }

  Future<void> deleteKategori(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/kategori/$id/'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus kategori');
    }
  }

  // ========== VIRUS ==========
  Future<List<Virus>> getVirus() async {
    final response = await http.get(Uri.parse('$baseUrl/virus/'));
    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      List<dynamic> data = decoded is List ? decoded : decoded['results'] ?? [];
      return data.map((e) => Virus.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil data virus');
  }

  Future<Virus> getVirusDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/virus/$id/'));
    if (response.statusCode == 200) {
      return Virus.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal mengambil detail virus');
  }

  Future<Virus> createVirus(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/virus/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Virus.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Gagal menambah virus');
  }

  Future<Virus> updateVirus(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/virus/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Virus.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Gagal mengupdate virus');
  }

  Future<void> deleteVirus(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/virus/$id/'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus virus');
    }
  }

  Future<List<Virus>> searchVirus(String query) async {
    final response =
    await http.get(Uri.parse('$baseUrl/virus/search/?q=$query'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['results'];
      return data.map((e) => Virus.fromJson(e)).toList();
    }
    throw Exception('Gagal mencari virus');
  }

  Future<Virus> createVirusWithImage(
      Map<String, dynamic> data, File? image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/virus/'),
    );
    data.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });
    if (image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('gambar', image.path));
    }
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      return Virus.fromJson(jsonDecode(body)['data']);
    }
    throw Exception('Gagal menambah virus');
  }

  Future<Virus> updateVirusWithImage(
      int id, Map<String, dynamic> data, File? image) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/virus/$id/'),
    );
    data.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });
    if (image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('gambar', image.path));
    }
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return Virus.fromJson(jsonDecode(body)['data']);
    }
    throw Exception('Gagal mengupdate virus');
  }
}