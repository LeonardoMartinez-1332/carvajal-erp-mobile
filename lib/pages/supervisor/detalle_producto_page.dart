import 'package:flutter/material.dart';
import '../../data/producto_repository.dart'; 

class DetalleProductoPage extends StatelessWidget {
    const DetalleProductoPage({super.key, required this.producto});

    final Producto producto;

    @override
    Widget build(BuildContext context) {
        final cs = Theme.of(context).colorScheme;

        final camas = producto.camas;
        final cajasPorCama = producto.cajasPorCama;
        final cajasPorTarima = producto.cajasPorTarima;
        final pz = producto.pzXPt;
        final stockUnidades = producto.stockUnidades;

        return Scaffold(
        appBar: AppBar(
            title: Text(
            producto.descripcion.isNotEmpty
                ? producto.descripcion
                : 'Detalle de producto',
            ),
            backgroundColor: const Color(0xFF673AB7),
            foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Card principal con descripción y código
                Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                        producto.descripcion.isNotEmpty
                            ? producto.descripcion
                            : 'Sin descripción',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                        ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                        'Código: ${producto.codigo}',
                        style: const TextStyle(color: Colors.black54),
                        ),
                    ],
                    ),
                ),
                ),
                const SizedBox(height: 12),

                // Acomodo en tarima
                Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                        'Acomodo en tarima',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                        ),
                        ),
                        const SizedBox(height: 8),
                        _RowInfo(label: 'Camas', value: '$camas'),
                        _RowInfo(label: 'Cajas por cama', value: '$cajasPorCama'),
                        _RowInfo(
                            label: 'Cajas por tarima', value: '$cajasPorTarima'),
                    ],
                    ),
                ),
                ),
                const SizedBox(height: 12),

                // Unidades
                Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                        'Unidades',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                        ),
                        ),
                        const SizedBox(height: 8),
                        _RowInfo(
                            label: 'Piezas por paquete (pz_x_pt)', value: '$pz'),
                        _RowInfo(
                        label: 'Stock estimado (unidades)',
                        value: '$stockUnidades',
                        ),
                    ],
                    ),
                ),
                ),
                const SizedBox(height: 12),

                // Pallet visual
                Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                        'Vista rápida del pallet',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                        ),
                        ),
                        const SizedBox(height: 12),
                        _PalletPreview(camas: camas, cajasPorCama: cajasPorCama),
                    ],
                    ),
                ),
                ),
            ],
            ),
        ),
        );
    }
}

class _RowInfo extends StatelessWidget {
    const _RowInfo({required this.label, required this.value});

    final String label;
    final String value;

    @override
    Widget build(BuildContext context) {
        return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
            children: [
            Expanded(
                child: Text(
                label,
                style: const TextStyle(color: Colors.black54),
                ),
            ),
            Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            ],
        ),
        );
    }
}

class _PalletPreview extends StatelessWidget {
    final int camas;
    final int cajasPorCama;

    const _PalletPreview({
        required this.camas,
        required this.cajasPorCama,
    });

    @override
    Widget build(BuildContext context) {
        final cs = Theme.of(context).colorScheme;

        final camasSeguras = camas.clamp(1, 12);
        final cajasSeguras = cajasPorCama.clamp(1, 14);

        return Column(
        children: [
            Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.primary.withOpacity(.2)),
                color: Colors.grey.shade100,
            ),
            child: Column(
                children: List.generate(camasSeguras, (fila) {
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(cajasSeguras, (col) {
                        return Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                            width: 18,
                            height: 14,
                            decoration: BoxDecoration(
                            color: const Color(0xFFd7b892), // color cartón
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                                BoxShadow(
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                                color: Colors.black.withOpacity(.15),
                                ),
                            ],
                            ),
                        ),
                        );
                    }),
                    ),
                );
                }),
            ),
            ),

            // Dibujito del pallet
            const SizedBox(height: 6),
            Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.brown.shade400,
                boxShadow: [
                BoxShadow(
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                    color: Colors.black.withOpacity(.25),
                )
                ],
            ),
            ),

            const SizedBox(height: 10),
            Text(
            '$camas camas  •  $cajasPorCama cajas/cama',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
        ],
        );
    }
}
