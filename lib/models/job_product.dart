class JobProduct {
    final int id;
    final String codigo;
    final String descripcion;
    final String? udm;
    final int? cajasPorTarima;
    final int? pzPorCaja;
    final int stockCajas;
    final int stockTarimas;

    JobProduct({
        required this.id,
        required this.codigo,
        required this.descripcion,
        this.udm,
        this.cajasPorTarima,
        this.pzPorCaja,
        required this.stockCajas,
        required this.stockTarimas,
    });

    factory JobProduct.fromJson(Map<String, dynamic> json) {
        return JobProduct(
        id: (json['id'] ?? json['producto_id'] ?? 0) as int,
        codigo: (json['codigo'] ?? '') as String,
        descripcion: (json['descripcion'] ?? '') as String,
        udm: json['udm'] as String?,
        cajasPorTarima: json['cajas_por_tarima'] as int?,
        pzPorCaja: json['pz_x_pt'] as int?,
        stockCajas:
            (json['stock_cajas'] ?? json['cajas'] ?? json['stock_actual'] ?? 0)
                as int,
        stockTarimas:
            (json['stock_tarimas'] ?? json['tarimas'] ?? 0) as int,
        );
    }
}
