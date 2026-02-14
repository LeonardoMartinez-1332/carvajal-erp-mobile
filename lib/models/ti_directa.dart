import 'job_product.dart';

class TiLineaCreate {
    final int productoId;
    final int tarimas;
    final int cajas;

    TiLineaCreate({
        required this.productoId,
        required this.tarimas,
        required this.cajas,
    });

    Map<String, dynamic> toJson() {
        return {
        'producto_id': productoId,
        'tarimas': tarimas,
        'cajas': cajas,
        };
    }
}

// ---------- LÍNEAS QUE VIENEN DEL BACKEND ----------
class TiLinea {
    final int id;
    final int? productoId;
    final int? tarimas;
    final int? cajas;
    final int? piezas;
    final JobProduct? producto;

    TiLinea({
        required this.id,
        this.productoId,
        this.tarimas,
        this.cajas,
        this.piezas,
        this.producto,
    });

    factory TiLinea.fromJson(Map<String, dynamic> json) {
        return TiLinea(
        id: json['id'] as int,
        productoId: json['producto_id'] as int?,
        tarimas: (json['tarimas'] as num?)?.toInt(),
        cajas: (json['cajas'] as num?)?.toInt(),
        piezas: (json['piezas'] as num?)?.toInt(),
        producto: json['producto'] != null
            ? JobProduct.fromJson(json['producto'] as Map<String, dynamic>)
            : null,
        );
    }
}

// ---------- TI COMPLETA ----------
class TiDirecta {
    final int id;
    final String numTi;
    final String npi;

    /// fecha en DateTime
    final DateTime? fecha;

    /// created_at crudo
    final String? createdAt;

    final String almacenOrigen;
    final String almacenDestino;
    final String? comentario;
    final String estatus;

    /// 👉 aquí vienen las líneas
    final List<TiLinea>? lineas;

    TiDirecta({
        required this.id,
        required this.numTi,
        required this.npi,
        required this.fecha,
        required this.createdAt,
        required this.almacenOrigen,
        required this.almacenDestino,
        required this.comentario,
        required this.estatus,
        required this.lineas,
    });

    factory TiDirecta.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['created_at']?.toString();

    // 🔍 Intentamos varios nombres por si el backend cambia
    List<dynamic>? rawLineas;

    final lineasJson = json['lineas'];
    if (lineasJson is List) {
        // Caso ideal: "lineas": [ {...}, {...} ]
        rawLineas = lineasJson;
    } else if (lineasJson is Map) {
        // Caso Laravel raro: "lineas": { "0": {...}, "1": {...} }
        rawLineas = lineasJson.values.toList();
    } else if (json['detalle'] is List) {
        rawLineas = json['detalle'] as List;
    } else if (json['ti_detalle'] is List) {
        rawLineas = json['ti_detalle'] as List;
    }

    final parsedLineas = rawLineas
        ?.map((e) => TiLinea.fromJson(e as Map<String, dynamic>))
        .toList();

    // Debug opcional
    // print('DEBUG fromJson lineas length: ${parsedLineas?.length}');

    return TiDirecta(
        id: json['id'] as int,
        numTi: json['num_ti']?.toString() ?? json['folio']?.toString() ?? '',
        npi: json['npi']?.toString() ?? '',
        fecha: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
        createdAt: createdAtStr,
        almacenOrigen: json['almacen_origen']?.toString() ?? '',
        almacenDestino: json['almacen_destino']?.toString() ?? '',
        comentario: json['comentario']?.toString(),
        estatus: json['estatus']?.toString() ?? '',
        lineas: parsedLineas,
    );
    }

}
