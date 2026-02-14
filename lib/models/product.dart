class Product {
    final int id;
    final String codigo;
    final String descripcion;
    final int? camas;
    final int? cajasPorCama;
    final int? pzXPt;
    final int? cajasPorTarima;
    final String? udm;
    final String? tipo;
    final double? vol;
    final double? w;
    final double? volumenUnitario;
    final double? costoPacUnitario;

    Product({
        required this.id,
        required this.codigo,
        required this.descripcion,
        this.camas,
        this.cajasPorCama,
        this.pzXPt,
        this.cajasPorTarima,
        this.udm,
        this.tipo,
        this.vol,
        this.w,
        this.volumenUnitario,
        this.costoPacUnitario,
    });

    // 👇 Esto se queda como está para NO romper nada
    factory Product.fromMap(Map<String, dynamic> map) {
        num? _num(dynamic v) {
        if (v == null) return null;
        if (v is num) return v;
        return num.tryParse(v.toString());
        }

        return Product(
        id: int.parse(map['id'].toString()),
        codigo: map['codigo']?.toString() ?? '',
        descripcion: map['descripcion']?.toString() ?? '',
        camas: _num(map['camas'])?.toInt(),
        cajasPorCama: _num(map['cajas_por_cama'])?.toInt(),
        pzXPt: _num(map['pz_x_pt'])?.toInt(),
        cajasPorTarima: _num(map['cajas_por_tarima'])?.toInt(),
        udm: map['udm']?.toString(),
        tipo: map['tipo']?.toString(),
        vol: _num(map['vol'])?.toDouble(),
        w: _num(map['w'])?.toDouble(),
        volumenUnitario: _num(map['volumen_unitario'])?.toDouble(),
        costoPacUnitario: _num(map['costo_pac_unitario'])?.toDouble(),
        );
    }

    // 👇 Alias cómodo para usar en repos nuevos
    factory Product.fromJson(Map<String, dynamic> json) => Product.fromMap(json);

    // 👇 Para enviar datos al backend en crear/editar
    Map<String, dynamic> toJson() {
        return {
        'codigo': codigo,
        'descripcion': descripcion,
        'camas': camas,
        'cajas_por_cama': cajasPorCama,
        'pz_x_pt': pzXPt,
        'cajas_por_tarima': cajasPorTarima,
        'udm': udm,
        'tipo': tipo,
        'vol': vol,
        'w': w,
        'volumen_unitario': volumenUnitario,
        'costo_pac_unitario': costoPacUnitario,
        };
    }

    // (Opcional pero útil para formularios de edición)
    Product copyWith({
        int? id,
        String? codigo,
        String? descripcion,
        int? camas,
        int? cajasPorCama,
        int? pzXPt,
        int? cajasPorTarima,
        String? udm,
        String? tipo,
        double? vol,
        double? w,
        double? volumenUnitario,
        double? costoPacUnitario,
    }) {
        return Product(
        id: id ?? this.id,
        codigo: codigo ?? this.codigo,
        descripcion: descripcion ?? this.descripcion,
        camas: camas ?? this.camas,
        cajasPorCama: cajasPorCama ?? this.cajasPorCama,
        pzXPt: pzXPt ?? this.pzXPt,
        cajasPorTarima: cajasPorTarima ?? this.cajasPorTarima,
        udm: udm ?? this.udm,
        tipo: tipo ?? this.tipo,
        vol: vol ?? this.vol,
        w: w ?? this.w,
        volumenUnitario: volumenUnitario ?? this.volumenUnitario,
        costoPacUnitario: costoPacUnitario ?? this.costoPacUnitario,
        );
    }
}
