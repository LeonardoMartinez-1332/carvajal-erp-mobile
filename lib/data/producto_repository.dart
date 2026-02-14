import 'package:flutter/foundation.dart';
import 'api_client.dart';

class Producto {
    final int id;
    final String codigo;
    final String descripcion;
    final int camas;
    final int cajasPorCama;
    final int cajasPorTarima;      // total de cajas real de la tarima
    final int pzXPt;               // piezas por paquete (pz_x_pt)
    final String udm;
    final String tipo;
    final double? vol;
    final double? w;
    final double? volumenUnitario;
    final double? costoPacUnitario;

    Producto({
        required this.id,
        required this.codigo,
        required this.descripcion,
        required this.camas,
        required this.cajasPorCama,
        required this.cajasPorTarima,
        required this.pzXPt,
        required this.udm,
        required this.tipo,
        this.vol,
        this.w,
        this.volumenUnitario,
        this.costoPacUnitario,
    });

    /// Stock estimado en unidades (cajas_por_tarima * pz_x_pt)
    int get stockUnidades => cajasPorTarima * pzXPt;

    factory Producto.fromMap(Map<String, dynamic> map) {
        double? _toDouble(dynamic v) {
        if (v == null) return null;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString());
        }

        int _toInt(dynamic v) {
        if (v == null) return 0;
        if (v is num) return v.toInt();
        return int.tryParse(v.toString()) ?? 0;
        }

        return Producto(
        id: _toInt(map['id']),
        codigo: map['codigo']?.toString() ?? '',
        descripcion: (map['descripcion']?.toString().trim().isEmpty ?? true)
            ? 'Sin descripción'
            : map['descripcion'].toString(),
        camas: _toInt(map['camas']),
        cajasPorCama: _toInt(map['cajas_por_cama']),
        cajasPorTarima: _toInt(map['cajas_por_tarima']),
        pzXPt: _toInt(map['pz_x_pt']),
        udm: map['udm']?.toString() ?? '',
        tipo: map['tipo']?.toString() ?? '',
        vol: _toDouble(map['vol']),
        w: _toDouble(map['w']),
        volumenUnitario: _toDouble(map['volumen_unitario']),
        costoPacUnitario: _toDouble(map['costo_pac_unitario']),
        );
    }
}

class ProductoRepository {
    final ApiClient _api = ApiClient();

    Future<List<Producto>> getProductos() async {
        final resp = await _api.get('/productos');

        if (resp.statusCode == 200) {
        final dynamic data = ApiClient.decodeJson(resp);

        // Puede venir como lista directa o envuelta en { data: [...] }
        List<dynamic> list;
        if (data is List) {
            list = data;
        } else if (data is Map && data['data'] is List) {
            list = data['data'] as List;
        } else {
            throw Exception('Formato inesperado de /productos');
        }

        return list
            .map((e) => Producto.fromMap(e as Map<String, dynamic>))
            .toList();
        } else {
        debugPrint('Error /productos: ${resp.statusCode} ${resp.body}');
        throw Exception('No se pudieron cargar los productos.');
        }
    }
}
