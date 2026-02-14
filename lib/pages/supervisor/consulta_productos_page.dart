import 'package:flutter/material.dart';
import '../../data/producto_repository.dart';
import 'detalle_producto_page.dart';

class ConsultaProductosPage extends StatefulWidget {
    const ConsultaProductosPage({super.key});

    @override
    State<ConsultaProductosPage> createState() => _ConsultaProductosPageState();
}

class _ConsultaProductosPageState extends State<ConsultaProductosPage> {
    final _repo = ProductoRepository();
    final TextEditingController _searchCtrl = TextEditingController();

    List<Producto> _all = [];
    List<Producto> _filtered = [];
    bool _loading = true;
    String? _error;

    @override
    void initState() {
        super.initState();
        _load();
        _searchCtrl.addListener(_applyFilter);
    }

    @override
    void dispose() {
        _searchCtrl.dispose();
        super.dispose();
    }

    Future<void> _load() async {
        setState(() {
        _loading = true;
        _error = null;
        });

        try {
        final data = await _repo.getProductos();
        setState(() {
            _all = data;
            _filtered = data;
            _loading = false;
        });
        } catch (e) {
        setState(() {
            _error = e.toString();
            _loading = false;
        });
        }
    }

    void _applyFilter() {
        final query = _searchCtrl.text.trim().toLowerCase();
        if (query.isEmpty) {
        setState(() => _filtered = _all);
        return;
        }

        setState(() {
        _filtered = _all.where((p) {
            final desc = p.descripcion.toLowerCase();
            final cod = p.codigo.toLowerCase();
            // numCaja ya no existe → buscamos solo por código y descripción
            return desc.contains(query) || cod.contains(query);
        }).toList();
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF673AB7),
            title: const Text('Consulta de Productos'),
            foregroundColor: Colors.white,
        ),
        body: Column(
            children: [
            // Buscador
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar producto...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    ),
                ),
                ),
            ),

            // Cuerpo (lista / carga / error)
            Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text('Error: $_error'))
                        : _filtered.isEmpty
                            ? const Center(
                                child: Text('No se encontraron productos.'),
                            )
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (context, index) {
                                    final p = _filtered[index];
                                    return _ProductoTile(producto: p);
                                },
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 4),
                                itemCount: _filtered.length,
                                ),
                            ),
            ),
            ],
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        );
    }
}

class _ProductoTile extends StatelessWidget {
    const _ProductoTile({super.key, required this.producto});

    final Producto producto;

    @override
    Widget build(BuildContext context) {
        final stock = producto.stockUnidades; // usa getter del modelo

        // Opcional: mostramos acomodo básico si hay datos
        final hasAcomodo =
            producto.camas > 0 && producto.cajasPorCama > 0 && producto.cajasPorTarima > 0;

        final subtitle = hasAcomodo
            ? 'Código: ${producto.codigo}  •  Camas: ${producto.camas}  •  Cajas/cama: ${producto.cajasPorCama}'
            : 'Código: ${producto.codigo}';

        return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
            leading:
                const Icon(Icons.inventory_2_outlined, color: Colors.deepPurple),
            title: Text(
            producto.descripcion.isNotEmpty
                ? producto.descripcion
                : 'Sin descripción',
            ),
            subtitle: Text(subtitle),
            trailing: Text(
            'Stock: $stock unidades',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(
                builder: (_) => DetalleProductoPage(producto: producto),
                ),
            );
            },
        ),
        );
    }
}
