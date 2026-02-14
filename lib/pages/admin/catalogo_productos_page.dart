import 'package:flutter/material.dart';

import '../../widgets/ui_bits.dart'; // GradientBackground, SectionCard
import '../../data/admin_productos_repository.dart';
import '../../data/auth_repository.dart';
import '../../models/product.dart';
import '../../core/routes.dart'; // 👈 para RoutePaths.adminProductoForm

class AdminCatalogoProductosPage extends StatefulWidget {
    const AdminCatalogoProductosPage({super.key});

    @override
    State<AdminCatalogoProductosPage> createState() =>
        _AdminCatalogoProductosPageState();
}

class _AdminCatalogoProductosPageState
    extends State<AdminCatalogoProductosPage> {
    final TextEditingController _searchCtrl = TextEditingController();

    late final AdminProductosRepository _repo;

    // nuevos controladores para los scrollbars
    final ScrollController _verticalCtrl = ScrollController();
    final ScrollController _horizontalCtrl = ScrollController();

    List<Product> _productos = [];
    bool _loading = true;
    String? _error;

    String _filtro = '';
    int _rowsPerPage = 10;
    int _page = 0;

    int? _sortColumnIndex;
    bool _sortAscending = true;

    @override
    void initState() {
        super.initState();

        _repo = AdminProductosRepository(
            
        baseUrl: AuthRepository.baseUrl,
        auth: AuthRepository(),
        );

        _searchCtrl.addListener(() {
        setState(() {
            _filtro = _searchCtrl.text.trim().toLowerCase();
            _page = 0;
        });
        });

        _cargarProductos();
    }

    Future<void> _cargarProductos() async {
        setState(() {
        _loading = true;
        _error = null;
        });

        try {
        final data = await _repo.listar();
        setState(() {
            _productos = data;
            _loading = false;
        });
        } catch (e) {
        setState(() {
            _loading = false;
            _error = e.toString();
        });
        }
    }

    void _sort<T>(
        Comparable<T> Function(Product p) getField,
        int columnIndex,
        bool ascending,
    ) {
        setState(() {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
        _productos.sort((a, b) {
            final aValue = getField(a);
            final bValue = getField(b);
            final cmp = Comparable.compare(aValue, bValue);
            return ascending ? cmp : -cmp;
        });
        });
    }

    @override
    void dispose() {
        _searchCtrl.dispose();
        _verticalCtrl.dispose();
        _horizontalCtrl.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        // 🔎 Filtro local
        final filtrados = _productos.where((p) {
        if (_filtro.isEmpty) return true;
        return p.codigo.toLowerCase().contains(_filtro) ||
            p.descripcion.toLowerCase().contains(_filtro) ||
            (p.tipo?.toLowerCase().contains(_filtro) ?? false) ||
            (p.udm?.toLowerCase().contains(_filtro) ?? false);
        }).toList();

        final total = filtrados.length;
        final maxPage = total == 0 ? 0 : ((total - 1) / _rowsPerPage).floor();
        final currentPage = _page.clamp(0, maxPage);
        final rowsPage =
            filtrados.skip(currentPage * _rowsPerPage).take(_rowsPerPage).toList();

        final start = total == 0 ? 0 : currentPage * _rowsPerPage + 1;
        final end = total == 0 ? 0 : (currentPage * _rowsPerPage + rowsPage.length);

        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF6A1B9A),
            title: const Text('Catálogo de productos'),
        ),

        // 🔹 FAB → Nuevo producto (abre form)
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
            final result = await Navigator.of(context).pushNamed(
                RoutePaths.adminProductoForm,
            );

            // Si el form hace Navigator.pop(true) → recargamos
            if (result == true) {
                _cargarProductos();
            }
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo producto'),
        ),

        body: GradientBackground(
            child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SectionCard(
                    title: 'Catálogo',
                    subtitle:
                        'CRUD • Importación • Validaciones (enlace con módulo de import)',
                ),
                const SizedBox(height: 16),

                // 🔝 Buscador + export
                Row(
                    children: [
                    Expanded(
                        child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText:
                                'Buscar por código, descripción, UDM o tipo…',
                            border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                        ),
                        ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                        style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                        ),
                        side: const BorderSide(color: Colors.black12),
                        ),
                        onPressed: () {
                        // TODO: conectar con endpoint /admin/productos/export
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                            content: Text(
                                'Exportar a Excel (pendiente conectar al backend)',
                            ),
                            ),
                        );
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Exportar a Excel'),
                    ),
                    ],
                ),
                const SizedBox(height: 16),

                // Estado: loading / error / tabla
                if (_loading)
                    const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                    )
                else if (_error != null)
                    Expanded(
                    child: Center(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            const Icon(Icons.error_outline,
                                size: 40, color: Colors.red),
                            const SizedBox(height: 8),
                            const Text(
                            'Error al cargar productos',
                            style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                            onPressed: _cargarProductos,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            ),
                        ],
                        ),
                    ),
                    )
                else
                    Expanded(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                            ),
                            child: Column(
                                children: [
                                // 🧾 Tabla con scrollbars
                                Expanded(
                                    child: Scrollbar(
                                    controller: _verticalCtrl,
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                        controller: _verticalCtrl,
                                        scrollDirection: Axis.vertical,
                                        child: Scrollbar(
                                        controller: _horizontalCtrl,
                                        thumbVisibility: true,
                                        notificationPredicate: (notif) =>
                                            notif.metrics.axis ==
                                            Axis.horizontal,
                                        child: SingleChildScrollView(
                                            controller: _horizontalCtrl,
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                            sortColumnIndex: _sortColumnIndex,
                                            sortAscending: _sortAscending,
                                            headingRowHeight: 40,
                                            dataRowMinHeight: 40,
                                            dataRowMaxHeight: 56,
                                            columns: [
                                                DataColumn(
                                                label: const Text('Código'),
                                                onSort: (i, asc) =>
                                                    _sort<String>(
                                                    (p) => p.codigo,
                                                    i,
                                                    asc,
                                                ),
                                                ),
                                                DataColumn(
                                                label:
                                                    const Text('Descripción'),
                                                onSort: (i, asc) =>
                                                    _sort<String>(
                                                    (p) => p.descripcion,
                                                    i,
                                                    asc,
                                                ),
                                                ),
                                                DataColumn(
                                                label: const Text('Camas'),
                                                numeric: true,
                                                onSort: (i, asc) => _sort<num>(
                                                    (p) => p.camas ?? 0,
                                                    i,
                                                    asc,
                                                ),
                                                ),
                                                DataColumn(
                                                label: const Text('Cajas/cama'),
                                                numeric: true,
                                                onSort: (i, asc) => _sort<num>(
                                                    (p) => p.cajasPorCama ?? 0,
                                                    i,
                                                    asc,
                                                ),
                                                ),
                                                DataColumn(
                                                label:
                                                    const Text('Cajas/tarima'),
                                                numeric: true,
                                                onSort: (i, asc) => _sort<num>(
                                                    (p) => p.cajasPorTarima ?? 0,
                                                    i,
                                                    asc,
                                                ),
                                                ),
                                                const DataColumn(
                                                label: Text('UDM'),
                                                ),
                                                const DataColumn(
                                                label: Text('Tipo'),
                                                ),
                                                DataColumn(
                                                label: const Text(
                                                    'Vol. unitario'),
                                                numeric: true,
                                                onSort: (i, asc) => _sort<num>(
                                                    (p) =>
                                                        p.volumenUnitario ?? 0,
                                                    i,
                                                    asc,
                                                ),
                                                ),
                                                DataColumn(
                                                label:
                                                    const Text('Costo pack'),
                                                numeric: true,
                                                onSort: (i, asc) => _sort<num>(
                                                    (p) =>
                                                        p.costoPacUnitario ?? 0,
                                                    i,
                                                    asc,
                                                ),
                                                ),
                                                const DataColumn(
                                                label: Text('Acciones'),
                                                ),
                                            ],
                                            rows: rowsPage.map((p) {
                                                return DataRow(
                                                cells: [
                                                    DataCell(Text(p.codigo)),
                                                    DataCell(
                                                    SizedBox(
                                                        width: 260,
                                                        child: Text(
                                                        p.descripcion,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        ),
                                                    ),
                                                    ),
                                                    DataCell(Text(
                                                        '${p.camas ?? '-'}')),
                                                    DataCell(Text(
                                                        '${p.cajasPorCama ?? '-'}')),
                                                    DataCell(Text(
                                                        '${p.cajasPorTarima ?? '-'}')),
                                                    DataCell(
                                                        Text(p.udm ?? '-')),
                                                    DataCell(
                                                        Text(p.tipo ?? '-')),
                                                    DataCell(
                                                    Text(
                                                        p.volumenUnitario
                                                                ?.toStringAsFixed(
                                                                    4) ??
                                                            '-',
                                                    ),
                                                    ),
                                                    DataCell(
                                                    Text(
                                                        p.costoPacUnitario
                                                                ?.toStringAsFixed(
                                                                    4) ??
                                                            '-',
                                                    ),
                                                    ),

                                                    // 🔹 Acciones: Editar / Eliminar
                                                    DataCell(
                                                    Row(
                                                        children: [
                                                        IconButton(
                                                            icon: const Icon(
                                                            Icons.edit,
                                                            size: 20,
                                                            ),
                                                            tooltip:
                                                                'Editar producto',
                                                            onPressed:
                                                                () async {
                                                            final result =
                                                                await Navigator.of(
                                                                        context)
                                                                    .pushNamed(
                                                                RoutePaths
                                                                    .adminProductoForm,
                                                                arguments: p,
                                                            );

                                                            if (result ==
                                                                true) {
                                                                _cargarProductos();
                                                            }
                                                            },
                                                        ),
                                                        IconButton(
                                                            icon: const Icon(
                                                            Icons
                                                                .delete_outline,
                                                            size: 20,
                                                            ),
                                                            tooltip:
                                                                'Eliminar',
                                                            onPressed:
                                                                () async {
                                                            final ok =
                                                                await showDialog<
                                                                    bool>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (ctx) =>
                                                                        AlertDialog(
                                                                title: Text(
                                                                    'Eliminar ${p.codigo}?'),
                                                                content:
                                                                    const Text(
                                                                    'Esta acción no se puede deshacer.',
                                                                ),
                                                                actions: [
                                                                    TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            ctx,
                                                                            false),
                                                                    child:
                                                                        const Text(
                                                                            'Cancelar'),
                                                                    ),
                                                                    ElevatedButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            ctx,
                                                                            true),
                                                                    child:
                                                                        const Text(
                                                                            'Eliminar'),
                                                                    ),
                                                                ],
                                                                ),
                                                            );

                                                            if (ok ==
                                                                true) {
                                                                try {
                                                                await _repo
                                                                    .eliminar(
                                                                        p.id);
                                                                _cargarProductos();

                                                                if (mounted) {
                                                                    ScaffoldMessenger
                                                                            .of(context)
                                                                        .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text(
                                                                        'Producto ${p.codigo} eliminado',
                                                                        ),
                                                                    ),
                                                                    );
                                                                }
                                                                } catch (e) {
                                                                if (mounted) {
                                                                    ScaffoldMessenger
                                                                            .of(context)
                                                                        .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text(
                                                                        'Error al eliminar: $e',
                                                                        ),
                                                                    ),
                                                                    );
                                                                }
                                                                }
                                                            }
                                                            },
                                                        ),
                                                        ],
                                                    ),
                                                    ),
                                                ],
                                                );
                                            }).toList(),
                                            ),
                                        ),
                                        ),
                                    ),
                                    ),
                                ),

                                const SizedBox(height: 4),

                                // 🔻 Paginación
                                Row(
                                    children: [
                                    Text(
                                        total == 0
                                            ? 'Sin registros'
                                            : 'Mostrando $start–$end de $total',
                                        style:
                                            const TextStyle(fontSize: 13),
                                    ),
                                    const Spacer(),
                                    DropdownButton<int>(
                                        value: _rowsPerPage,
                                        items: const [
                                        DropdownMenuItem(
                                            value: 5,
                                            child: Text('5 por página'),
                                        ),
                                        DropdownMenuItem(
                                            value: 10,
                                            child: Text('10 por página'),
                                        ),
                                        DropdownMenuItem(
                                            value: 20,
                                            child: Text('20 por página'),
                                        ),
                                        ],
                                        onChanged: (v) {
                                        if (v == null) return;
                                        setState(() {
                                            _rowsPerPage = v;
                                            _page = 0;
                                        });
                                        },
                                    ),
                                    IconButton(
                                        icon: const Icon(Icons.first_page,
                                            size: 20),
                                        onPressed: currentPage > 0
                                            ? () {
                                                setState(() {
                                                _page = 0;
                                                });
                                            }
                                            : null,
                                    ),
                                    IconButton(
                                        icon: const Icon(Icons.chevron_left,
                                            size: 20),
                                        onPressed: currentPage > 0
                                            ? () {
                                                setState(() {
                                                _page = currentPage - 1;
                                                });
                                            }
                                            : null,
                                    ),
                                    IconButton(
                                        icon: const Icon(Icons.chevron_right,
                                            size: 20),
                                        onPressed: currentPage < maxPage
                                            ? () {
                                                setState(() {
                                                _page = currentPage + 1;
                                                });
                                            }
                                            : null,
                                    ),
                                    IconButton(
                                        icon: const Icon(Icons.last_page,
                                            size: 20),
                                        onPressed: currentPage < maxPage
                                            ? () {
                                                setState(() {
                                                _page = maxPage;
                                                });
                                            }
                                            : null,
                                    ),
                                    ],
                                ),
                                ],
                            ),
                            ),
                        ),
                        ),
                    ),
                    ),
                ],
            ),
            ),
        ),
        );
    }
}
