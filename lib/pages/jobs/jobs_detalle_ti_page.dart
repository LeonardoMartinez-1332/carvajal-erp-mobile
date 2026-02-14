import 'package:flutter/material.dart';

import 'package:carvajal_erp/data/jobs_repository.dart';
import 'package:carvajal_erp/models/ti_directa.dart';
import 'package:carvajal_erp/models/ti_directa_resumen.dart';
import 'package:carvajal_erp/pages/jobs/jobs_ti_pdf_preview_page.dart';

class JobsDetalleTiPage extends StatefulWidget {
    const JobsDetalleTiPage({super.key});

    @override
    State<JobsDetalleTiPage> createState() => _JobsDetalleTiPageState();
    }

    class _JobsDetalleTiPageState extends State<JobsDetalleTiPage> {
    final JobsRepository _repo = JobsRepository();

    TiDirectaResumen? _resumen;
    TiDirecta? _ti;
    bool _loading = true;
    String? _error;

    bool _initialized = false;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        if (_initialized) return;
        _initialized = true;

        final args = ModalRoute.of(context)!.settings.arguments;

        if (args is TiDirectaResumen) {
        _resumen = args;
        _cargarDetalle(args.id);
        } else if (args is int) {
        _cargarDetalle(args);
        } else {
        setState(() {
            _error = 'Argumento inválido para detalle TI';
            _loading = false;
        });
        }
    }

    Future<void> _cargarDetalle(int id) async {
        try {
        final ti = await _repo.verTi(id);
        setState(() {
            _ti = ti;
            _loading = false;
        });
        } catch (e) {
        setState(() {
            _error = e.toString();
            _loading = false;
        });
        }
    }

    String _formatearFecha(DateTime? dt) {
        if (dt == null) return '';
        return '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}';
    }

    @override
    Widget build(BuildContext context) {
        final folio = _ti?.numTi ?? _resumen?.numTi ?? 'Detalle TI';

        return Scaffold(
        appBar: AppBar(
            title: Text(folio),
        ),
        body: _buildBody(),
        );
    }

    Widget _buildBody() {
        if (_loading) {
        return const Center(child: CircularProgressIndicator());
        }

        if (_error != null) {
        return Center(
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                Text(
                    _error!,
                    textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (_resumen != null)
                    ElevatedButton(
                    onPressed: () => _cargarDetalle(_resumen!.id),
                    child: const Text('Reintentar'),
                    ),
                ],
            ),
            ),
        );
        }

        final ti = _ti!;
        final lineas = ti.lineas ?? [];

        return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // === CABECERA ===
            Text(
                ti.numTi,
                style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                ),
            ),
            const SizedBox(height: 4),
            Text(
                _formatearFecha(ti.fecha),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Row(
                children: [
                const Icon(Icons.store, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                    'Origen: ${ti.almacenOrigen}',
                    style: const TextStyle(fontSize: 14),
                    ),
                ),
                ],
            ),
            const SizedBox(height: 8),
            Row(
                children: [
                const Icon(Icons.local_shipping, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                    'Destino: ${ti.almacenDestino}',
                    style: const TextStyle(fontSize: 14),
                    ),
                ),
                ],
            ),
            const SizedBox(height: 8),
            Row(
                children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Text(
                    'Estatus: ${ti.estatus.toUpperCase()}',
                    style: const TextStyle(fontSize: 14),
                ),
                ],
            ),
            const SizedBox(height: 16),

            if ((ti.comentario ?? '').isNotEmpty) ...[
                const Text(
                'Comentario',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                ),
                ),
                const SizedBox(height: 4),
                Text(
                ti.comentario!,
                style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
            ],

            const Divider(),
            const SizedBox(height: 8),

            const Text(
                'Líneas',
                style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                ),
            ),
            const SizedBox(height: 8),

            if (lineas.isEmpty)
                const Text('Esta TI no tiene líneas registradas.')
            else
                ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lineas.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                    final l = lineas[index];
                    final prod = l.producto;
                    final codigo = prod?.codigo ?? '-';
                    final desc = prod?.descripcion ?? '';

                    return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text(
                                codigo,
                                style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                            if (desc.isNotEmpty)
                                Text(
                                desc,
                                style: const TextStyle(fontSize: 13),
                                ),
                            const SizedBox(height: 4),
                            Text(
                                'Tarimas: ${l.tarimas ?? 0}   ·   Cajas: ${l.cajas ?? 0}',
                                style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                ),
                            ),
                            ],
                        ),
                        ),
                    ],
                    );
                },
                ),

            const SizedBox(height: 24),

            Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                onPressed: () {
                    final ti = _ti;
                    if (ti == null) return;

                    Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => JobsTiPdfPreviewPage(ti: ti),
                    ),
                    );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Ver PDF'),
                ),
            ),
            ],
        ),
        );
    }
}

