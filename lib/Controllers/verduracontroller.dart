import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/verduramodel.dart';

class VerduraService {
  final String url =
      'https://raw.githubusercontent.com/KarlaCajas/ExamenVerduras/refs/heads/main/verduras.json';

  final List<Verdura> _verduras = [];

  Future<void> fetchVerduras() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _verduras.clear();
        _verduras.addAll(data.map((item) => Verdura.fromJson(item)).toList());
      } else {
        throw Exception('Error al cargar los datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar: $e');
    }
  }

  void addVerdura(Verdura nuevaVerdura) {
    _verduras.add(nuevaVerdura);
  }

  void updateVerdura(int codigo, Verdura verduraActualizada) {
    final index = _verduras.indexWhere((v) => v.codigo == codigo);
    if (index != -1) {
      _verduras[index] = verduraActualizada;
    } else {
      throw Exception('Verdura con código $codigo no encontrada');
    }
  }

  void deleteVerdura(int codigo) {
    final index = _verduras.indexWhere((v) => v.codigo == codigo);
    if (index != -1) {
      _verduras.removeAt(index);
    } else {
      throw Exception('Verdura con código $codigo no encontrada');
    }
  }

  List<Verdura> getAllVerduras() {
    return List.unmodifiable(_verduras);
  }
}
