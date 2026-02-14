import 'package:flutter/material.dart';

import '../../data/jobs_repository.dart';
import '../../models/job_product.dart';
import '../../models/ti_directa.dart';

class JobsNuevaTiPage extends StatefulWidget {
    const JobsNuevaTiPage({super.key});

    @override
    State<JobsNuevaTiPage> createState() => _JobsNuevaTiPageState();
}

class _JobsNuevaTiPageState extends State<JobsNuevaTiPage> {
    final JobsRepository _repo = JobsRepository();

    final TextEditingController _almacenOrigenCtrl =
        TextEditingController(text: '1'); // TODO: reemplazar por catálogo real
    final TextEditingController _almacenDestinoCtrl =
        TextEditingController(text: '2'); // TODO: reemplazar por catálogo real
    final TextEditingController _comentarioCtrl = TextEditingController();

    bool _loadingProductos = true;
    String? _error;
    List<JobProduct> _productos = [];

    // “Carrito” de líneas que se van a mandar a la TI
    final List<_LineaDraft> _lineas = [];

    @override
    void initState() {
        super.initState();
        _loadProductos();
    }

    @override
    void dispose() {
        _almacenOrigenCtrl.dispose();
        _almacenDestinoCtrl.dispose();
        _comentarioCtrl.dispose();
        super.dispose();
    }

    Future<void> _loadProductos() async {
        setState(() {
        _loadingProductos = true;
        _error = null;
        });

        try {
        // Por ahora no filtramos por almacén; luego podemos usar almacen_id.
        final productos = await _repo.getProductos();
        if (!mounted) return;
        setState(() {
            _productos = productos;
            _loadingProductos = false;
        });
        } catch (e) {
        if (!mounted) return;
        setState(() {
            _error = e.toString();
            _loadingProductos = false;
        });
        }
    }

    void _agregarLinea(JobProduct p) async {
        final result = await showModalBottomSheet<_LineaDraft>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (ctx) {
            final tarimasCtrl = TextEditingController();
            final cajasCtrl = TextEditingController();

            return Padding(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Center(
                    child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.shade200,
                        borderRadius: BorderRadius.circular(4),
                    ),
                    ),
                ),
                const SizedBox(height: 16),
                Text(
                    p.codigo,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                    p.descripcion,
                    style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Row(
                    children: [
                    Expanded(
                        child: TextField(
                        controller: tarimasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Tarimas',
                            prefixIcon: Icon(Icons.all_inbox_outlined),
                        ),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                        controller: cajasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Cajas',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        ),
                    ),
                    ],
                ),
                const SizedBox(height: 12),
                Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                    onPressed: () {
                        final t = int.tryParse(tarimasCtrl.text.trim()) ?? 0;
                        final c = int.tryParse(cajasCtrl.text.trim()) ?? 0;
                        if (t <= 0 && c <= 0) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                            content: Text(
                                'Captura al menos una tarima o una caja.',
                            ),
                            ),
                        );
                        return;
                        }
                        Navigator.pop(
                        ctx,
                        _LineaDraft(
                            producto: p,
                            tarimas: t,
                            cajas: c,
                        ),
                        );
                    },
                    child: const Text('Agregar'),
                    ),
                ),
                ],
            ),
            );
        },
        );

        if (result != null) {
        setState(() {
            _lineas.add(result);
        });
        }
    }

    Future<void> _crearTi() async {
        final almOri = int.tryParse(_almacenOrigenCtrl.text.trim());
        final almDes = int.tryParse(_almacenDestinoCtrl.text.trim());

        if (almOri == null || almDes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Almacén origen y destino son obligatorios.'),
            ),
        );
        return;
        }

        if (_lineas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Agrega al menos una línea a la TI.'),
            ),
        );
        return;
        }

        try {
        
                final lineasCreate = _lineas
                .map(
                (l) => TiLineaCreate(
                    productoId: l.producto.id,
                    tarimas: l.tarimas,
                    cajas: l.cajas,
                ),
                )
                .toList();

            // Ahora crearTi regresa solo el folio (String)
            final folio = await _repo.crearTi(
            almacenOrigenId: almOri,
            almacenDestinoId: almDes,
            comentario: _comentarioCtrl.text.trim().isEmpty
                ? null
                : _comentarioCtrl.text.trim(),
            lineas: lineasCreate,
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('TI creada correctamente: $folio'),
            ),
            );

        // Limpiamos carrito
        setState(() {
            _lineas.clear();
        });
        } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Error al crear TI: $e'),
            ),
        );
        }
    }

    int get _totalTarimas =>
        _lineas.fold(0, (sum, l) => sum + (l.tarimas));
    int get _totalCajas =>
        _lineas.fold(0, (sum, l) => sum + (l.cajas));

    @override
    Widget build(BuildContext context) {
        const barColor = Color(0xFF004D40);

        return Scaffold(
        appBar: AppBar(
            backgroundColor: barColor,
            foregroundColor: Colors.white,
            title: const Text('Nueva TI directa'),
        ),
        body: Column(
            children: [
            // Encabezado: almacenes + comentario
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                children: [
                    Row(
                    children: [
                        Expanded(
                        child: TextField(
                            controller: _almacenOrigenCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                            labelText: 'Almacén origen (ID)',
                            prefixIcon: Icon(Icons.store_mall_directory),
                            ),
                        ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                        child: TextField(
                            controller: _almacenDestinoCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                            labelText: 'Almacén destino (ID)',
                            prefixIcon: Icon(Icons.local_shipping_outlined),
                            ),
                        ),
                        ),
                    ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                    controller: _comentarioCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Comentario (opcional)',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                    maxLines: 1,
                    ),
                ],
                ),
            ),
            const Divider(height: 1),

            Expanded(
                child: _loadingProductos
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                'Error al cargar productos:\n$_error',
                                textAlign: TextAlign.center,
                            ),
                            ),
                        )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                            itemCount: _productos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (ctx, i) {
                            final p = _productos[i];
                            return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                title: Text(
                                    '${p.codigo} — ${p.descripcion}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                    'Stock: ${p.stockTarimas} tarimas / ${p.stockCajas} cajas',
                                ),
                                trailing: IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.teal,
                                    onPressed: () => _agregarLinea(p),
                                ),
                                ),
                            );
                            },
                        ),
            ),

            // Barra inferior con resumen y botón crear
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: const Border(
                    top: BorderSide(color: Colors.black12),
                ),
                ),
                child: Row(
                children: [
                    Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                            'Líneas: ${_lineas.length}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                            'Tarimas: $_totalTarimas   Cajas: $_totalCajas',
                            style: const TextStyle(fontSize: 12),
                        ),
                        ],
                    ),
                    ),
                    FilledButton.icon(
                    onPressed: _lineas.isEmpty ? null : _crearTi,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Generar TI'),
                    ),
                ],
                ),
            ),
            ],
        ),
        );
    }
}

// Modelo interno para el carrito
class _LineaDraft {
    final JobProduct producto;
    final int tarimas;
    final int cajas;

    _LineaDraft({
        required this.producto,
        required this.tarimas,
        required this.cajas,
    });
}
