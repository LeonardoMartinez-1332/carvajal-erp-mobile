class TiDirectaResumen {
    final int id;
    final String numTi;
    final String npi;
    final DateTime? fecha;
    final String almacenOrigen;
    final String almacenDestino;
    final String? comentario;
    final String estatus;

    TiDirectaResumen({
        required this.id,
        required this.numTi,
        required this.npi,
        required this.fecha,
        required this.almacenOrigen,
        required this.almacenDestino,
        required this.comentario,
        required this.estatus,
    });

    factory TiDirectaResumen.fromJson(Map<String, dynamic> json) {
        return TiDirectaResumen(
        id: json['id'] as int,
        numTi: json['num_ti'] as String? ?? json['folio'] as String? ?? '',
        npi: json['npi'] as String? ?? '',
        fecha: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        almacenOrigen: json['almacen_origen']?.toString() ?? '',
        almacenDestino: json['almacen_destino']?.toString() ?? '',
        comentario: json['comentario'] as String?,
        estatus: json['estatus']?.toString() ?? '',
        );
    }

    Map<String, dynamic> toJson() {
        return {
        'id': id,
        'num_ti': numTi,
        'npi': npi,
        'created_at': fecha?.toIso8601String(),
        'almacen_origen': almacenOrigen,
        'almacen_destino': almacenDestino,
        'comentario': comentario,
        'estatus': estatus,
        };
    }
}
