import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/product_import_service.dart';

class ProductImportPage extends StatefulWidget {
  final String token; // pásalo desde tu login
    const ProductImportPage({super.key, required this.token});

    @override
    State<ProductImportPage> createState() => _ProductImportPageState();
    }

    class _ProductImportPageState extends State<ProductImportPage> {
    File? _file;
    String? _fileName;
    double _progress = 0;
    bool _loading = false;
    String? _msg;

    Future<void> _pickFile() async {
        final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        );
        if (res != null && res.files.single.path != null) {
        setState(() {
            _file = File(res.files.single.path!);
            _fileName = res.files.single.name;
            _msg = null;
            _progress = 0;
        });
        }
    }

    Future<void> _upload() async {
        if (_file == null) return;
        setState(() { _loading = true; _msg = null; _progress = 0; });

        try {
        final service = ProductImportService(widget.token);
        final resp = await service.uploadExcelFile(
            _file!,
            onSendProgress: (s, t) {
            if (t > 0) setState(() => _progress = s / t);
            },
        );
        setState(() => _msg = resp['message']?.toString());

        if (resp['ok'] == true) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Importación completada ✅')),
            );
        } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${_msg ?? 'falló la importación'}')),
            );
        }
        } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de red: $e')),
        );
        } finally {
        if (mounted) setState(() => _loading = false);
        }
    }

    @override
    Widget build(BuildContext context) {
        final canUpload = _file != null && !_loading;

        return Scaffold(
        appBar: AppBar(title: const Text('Importar productos')),
        body: Center(
            child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(_fileName ?? 'Ningún archivo seleccionado'),
                    subtitle: const Text('Acepta: .xlsx .xls .csv'),
                    trailing: OutlinedButton.icon(
                        onPressed: _loading ? null : _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Elegir archivo'),
                    ),
                    ),
                    const SizedBox(height: 12),
                    if (_loading)
                    LinearProgressIndicator(value: _progress == 0 ? null : _progress),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                    onPressed: canUpload ? _upload : null,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Subir e importar'),
                    ),
                    if (_msg != null) ...[
                    const SizedBox(height: 16),
                    Text(_msg!, textAlign: TextAlign.center),
                    ],
                ],
                ),
            ),
            ),
        ),
        );
    }
}
