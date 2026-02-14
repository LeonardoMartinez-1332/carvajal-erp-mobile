import 'package:flutter/material.dart';

import '../../data/admin_productos_repository.dart';
import '../../data/auth_repository.dart';
import '../../models/product.dart';

class ProductoFormPage extends StatefulWidget {
    final Product? product; // null = nuevo

    const ProductoFormPage({super.key, this.product});

    @override
    State<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends State<ProductoFormPage> {
    final _formKey = GlobalKey<FormState>();

    late final AdminProductosRepository _repo;

    // controllers
    final _codigoCtrl = TextEditingController();
    final _descripcionCtrl = TextEditingController();
    final _camasCtrl = TextEditingController();
    final _cajasCamaCtrl = TextEditingController();
    final _cajasTarimaCtrl = TextEditingController();
    final _udmCtrl = TextEditingController();
    final _tipoCtrl = TextEditingController();
    final _volumenUnitarioCtrl = TextEditingController();
    final _costoPacCtrl = TextEditingController();

    bool _saving = false;

    bool get isEdit => widget.product != null;

    @override
    void initState() {
        super.initState();

        _repo = AdminProductosRepository(
        baseUrl: AuthRepository.baseUrl,
        auth: AuthRepository(),
        );

        final p = widget.product;
        if (p != null) {
        _codigoCtrl.text = p.codigo;
        _descripcionCtrl.text = p.descripcion;
        _camasCtrl.text = p.camas?.toString() ?? '';
        _cajasCamaCtrl.text = p.cajasPorCama?.toString() ?? '';
        _cajasTarimaCtrl.text = p.cajasPorTarima?.toString() ?? '';
        _udmCtrl.text = p.udm ?? '';
        _tipoCtrl.text = p.tipo ?? '';
        _volumenUnitarioCtrl.text =
            p.volumenUnitario != null ? p.volumenUnitario!.toString() : '';
        _costoPacCtrl.text =
            p.costoPacUnitario != null ? p.costoPacUnitario!.toString() : '';
        }
    }

    @override
    void dispose() {
        _codigoCtrl.dispose();
        _descripcionCtrl.dispose();
        _camasCtrl.dispose();
        _cajasCamaCtrl.dispose();
        _cajasTarimaCtrl.dispose();
        _udmCtrl.dispose();
        _tipoCtrl.dispose();
        _volumenUnitarioCtrl.dispose();
        _costoPacCtrl.dispose();
        super.dispose();
    }

    InputDecoration _fieldDecoration(String label, {String? hint}) {
        return InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        );
    }

    Future<void> _guardar() async {
        if (!_formKey.currentState!.validate()) return;

        num? _num(String v) =>
            v.trim().isEmpty ? null : num.tryParse(v.trim());

        setState(() => _saving = true);

        try {
        final producto = Product(
            id: widget.product?.id ?? 0,
            codigo: _codigoCtrl.text.trim(),
            descripcion: _descripcionCtrl.text.trim(),
            camas: _num(_camasCtrl.text)?.toInt(),
            cajasPorCama: _num(_cajasCamaCtrl.text)?.toInt(),
            pzXPt: widget.product?.pzXPt, // por ahora lo dejamos igual
            cajasPorTarima: _num(_cajasTarimaCtrl.text)?.toInt(),
            udm: _udmCtrl.text.trim().isEmpty ? null : _udmCtrl.text.trim(),
            tipo: _tipoCtrl.text.trim().isEmpty ? null : _tipoCtrl.text.trim(),
            vol: widget.product?.vol,
            w: widget.product?.w,
            volumenUnitario: _num(_volumenUnitarioCtrl.text)?.toDouble(),
            costoPacUnitario: _num(_costoPacCtrl.text)?.toDouble(),
        );

        if (isEdit) {
            await _repo.actualizar(producto);
        } else {
            await _repo.crear(producto);
        }

        if (!mounted) return;
        Navigator.of(context).pop(true); // true = hubo cambios
        } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')),
        );
        } finally {
        if (mounted) setState(() => _saving = false);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
            backgroundColor: const Color(0xFF1E4F9A),
            title: Text(isEdit ? 'Editar producto' : 'Nuevo producto'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                            isEdit
                                ? 'Actualiza los datos del producto'
                                : 'Registra un nuevo producto',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                            'Campos clave para el catálogo y las validaciones del WMS.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.black54),
                            ),
                            const SizedBox(height: 24),

                            // Código + Descripción
                            Text(
                            'Identificación',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Row(
                            children: [
                                Expanded(
                                flex: 2,
                                child: TextFormField(
                                    controller: _codigoCtrl,
                                    decoration: _fieldDecoration('Código'),
                                    validator: (v) => (v == null ||
                                            v.trim().isEmpty)
                                        ? 'Requerido'
                                        : null,
                                ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                flex: 5,
                                child: TextFormField(
                                    controller: _descripcionCtrl,
                                    decoration: _fieldDecoration('Descripción'),
                                    validator: (v) => (v == null ||
                                            v.trim().isEmpty)
                                        ? 'Requerido'
                                        : null,
                                ),
                                ),
                            ],
                            ),

                            const SizedBox(height: 24),

                            // Logística
                            Text(
                            'Parámetros logísticos',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Row(
                            children: [
                                Expanded(
                                child: TextFormField(
                                    controller: _camasCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration:
                                        _fieldDecoration('Camas', hint: 'Ej. 10'),
                                ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                child: TextFormField(
                                    controller: _cajasCamaCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: _fieldDecoration('Cajas/cama'),
                                ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                child: TextFormField(
                                    controller: _cajasTarimaCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: _fieldDecoration('Cajas/tarima'),
                                ),
                                ),
                            ],
                            ),

                            const SizedBox(height: 16),
                            Row(
                            children: [
                                Expanded(
                                child: TextFormField(
                                    controller: _udmCtrl,
                                    decoration: _fieldDecoration('UDM'),
                                ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                child: TextFormField(
                                    controller: _tipoCtrl,
                                    decoration: _fieldDecoration('Tipo'),
                                ),
                                ),
                            ],
                            ),

                            const SizedBox(height: 24),

                            // Costeo
                            Text(
                            'Costeo y volumen',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Row(
                            children: [
                                Expanded(
                                child: TextFormField(
                                    controller: _volumenUnitarioCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration:
                                        _fieldDecoration('Volumen unitario'),
                                ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                child: TextFormField(
                                    controller: _costoPacCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: _fieldDecoration(
                                        'Costo pack unitario'),
                                ),
                                ),
                            ],
                            ),

                            const SizedBox(height: 32),
                            Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                                onPressed: _saving ? null : _guardar,
                                style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                ),
                                ),
                                icon: _saving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                        ),
                                    )
                                    : const Icon(Icons.save),
                                label: Text(
                                _saving ? 'Guardando...' : 'Guardar',
                                ),
                            ),
                            ),
                        ],
                        ),
                    ),
                    ),
                ),
                ),
            ),
            ),
        ),
        );
    }
}
