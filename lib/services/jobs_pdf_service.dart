// lib/services/jobs_pdf_service.dart

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:carvajal_erp/models/ti_directa.dart';

class JobsPdfService {
    /// Genera el PDF de una TI y regresa los bytes.
    static Future<Uint8List> buildTiPdf(TiDirecta ti) async {
        final pdf = pw.Document(
        title: 'Transferencia Interna ${ti.numTi}',
        author: 'ERP Carvajal Empaques',
        subject: 'Movimiento interno de almacenes',
        keywords: 'TI, Carvajal, Convermex, ERP',
        );

        // Logo corporativo
        final logoBytes =
            await rootBundle.load('assets/Logo-marcas-empaques-5.jpeg');
        final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

        final lineas = ti.lineas ?? [];

        pdf.addPage(
        pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(24),
            build: (context) => [
            _buildHeader(ti, logo),
            pw.SizedBox(height: 6),
            _buildSeparator(),
            pw.SizedBox(height: 12),
            _buildDatosGenerales(ti),
            pw.SizedBox(height: 16),
            _buildDetalleTabla(lineas),
            ],
            footer: (context) => _buildFooter(ti, context),
        ),
        );

        return pdf.save();
    }

    // ---------- HEADER (logo + título + QR) ----------
    static pw.Widget _buildHeader(TiDirecta ti, pw.ImageProvider logo) {
        return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
            pw.Container(
            width: 90,
            height: 40,
            child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
            pw.Spacer(),
            pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
                pw.Text(
                'Transferencia Interna (TI)',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                'ERP Carvajal Empaques',
                style: pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                'Folio: ${ti.numTi}',
                style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                ),
                ),
            ],
            ),
            pw.SizedBox(width: 16),
            // QR con el folio de la TI
            pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: ti.numTi,
            width: 40,
            height: 40,
            ),
        ],
        );
    }

    // Línea azul corporativa bajo el encabezado
    static pw.Widget _buildSeparator() {
        return pw.Container(
        height: 1.5,
        color: PdfColors.blue800,
        );
    }

    // ---------- DATOS GENERALES ----------
    static pw.Widget _buildDatosGenerales(TiDirecta ti) {
        String fechaStr = '';
        if (ti.fecha != null) {
        final f = ti.fecha!;
        fechaStr =
            '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year} '
            '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';
        }

        final comentario =
            (ti.comentario ?? '').isEmpty ? '-' : ti.comentario!;

        return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
            pw.Text(
            'Datos generales',
            style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
            ),
            ),
            pw.SizedBox(height: 4),
            pw.Table(
            columnWidths: {
                0: pw.FractionColumnWidth(0.18),
                2: pw.FractionColumnWidth(0.20),
            },
            children: [
                pw.TableRow(
                children: [
                    _cellLabel('Fecha:'),
                    _cellValue(fechaStr.isEmpty ? '-' : fechaStr),
                    _cellLabel('Estatus:'),
                    _cellValue(ti.estatus.toUpperCase()),
                ],
                ),
                pw.TableRow(
                children: [
                    _cellLabel('Almacén origen:'),
                    _cellValue(ti.almacenOrigen),
                    _cellLabel('Almacén destino:'),
                    _cellValue(ti.almacenDestino),
                ],
                ),
                // Comentario
                pw.TableRow(
                children: [
                    _cellLabel('Comentario:'),
                    _cellValue(comentario),
                    _cellValue(''),
                    _cellValue(''),
                ],
                ),
            ],
            ),
        ],
        );
    }

    static pw.Widget _cellLabel(String text) => pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text(
            text,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
            ),
            ),
        );

    static pw.Widget _cellValue(String text) => pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 10),
            ),
        );

    // ---------- TABLA DETALLE ----------
    static pw.Widget _buildDetalleTabla(List<TiLinea> lineas) {
        return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
            pw.Text(
            'Detalle de material',
            style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
            ),
            ),
            pw.SizedBox(height: 4),
            pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: {
                0: pw.FractionColumnWidth(0.14), // Código
                1: pw.FractionColumnWidth(0.30), // Descripción
                2: pw.FractionColumnWidth(0.08), // Udm
                3: pw.FractionColumnWidth(0.10), // Tarimas
                4: pw.FractionColumnWidth(0.12), // Cajas x tarima
                5: pw.FractionColumnWidth(0.10), // Cajas totales
                6: pw.FractionColumnWidth(0.08), // Pz x caja
                7: pw.FractionColumnWidth(0.08), // Piezas totales
            },
            children: [
                pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                    _th('Código'),
                    _th('Descripción'),
                    _th('Udm'),
                    _th('Tarimas'),
                    _th('Cajas x tarima'),
                    _th('Cajas totales'),
                    _th('Pz x caja'),
                    _th('Piezas totales'),
                ],
                ),
            ] +
                lineas.map((l) {
                    final prod = l.producto;
                    final codigo = prod?.codigo ?? '-';
                    final desc = prod?.descripcion ?? '-';
                    final udm = prod?.udm ?? 'PZ';
                    final tarimas = l.tarimas ?? 0;
                    final cajas = l.cajas ?? 0;
                    final cajasPorTarima = prod?.cajasPorTarima ?? 0;
                    final pzPorCaja = prod?.pzPorCaja ?? 0;
                    final pzTotales = cajas * pzPorCaja;

                    return pw.TableRow(
                    children: [
                        _tdText(codigo),
                        _tdText(desc),
                        _tdText(udm),
                        _tdNum(tarimas),
                        _tdNum(cajasPorTarima),
                        _tdNum(cajas),
                        _tdNum(pzPorCaja),
                        _tdNum(pzTotales),
                    ],
                    );
                }).toList(),
            ),
        ],
        );
    }

    static pw.Widget _th(String text) => pw.Padding(
            padding:
                pw.EdgeInsets.symmetric(vertical: 3, horizontal: 3),
            child: pw.Text(
            text,
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
            ),
            ),
        );

    static pw.Widget _tdText(String text) => pw.Padding(
            padding:
                pw.EdgeInsets.symmetric(vertical: 2, horizontal: 3),
            child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 9),
            ),
        );

    static pw.Widget _tdNum(num value) => pw.Padding(
            padding:
                pw.EdgeInsets.symmetric(vertical: 2, horizontal: 3),
            child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
                value.toString(),
                style: pw.TextStyle(fontSize: 9),
            ),
            ),
        );

    // ---------- PIE DE PÁGINA ----------
    static pw.Widget _buildFooter(TiDirecta ti, pw.Context context) {
        return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
            pw.Divider(color: PdfColors.grey400, thickness: 0.5),
            pw.SizedBox(height: 2),
            pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
                pw.Text(
                'Carvajal Empaques / Convermex',
                style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                ),
                ),
                pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                ),
                ),
            ],
            ),
            pw.SizedBox(height: 2),
            pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
                'Documento generado automáticamente por ERP Carvajal',
                style: pw.TextStyle(
                fontSize: 7,
                color: PdfColors.grey500,
                ),
            ),
            ),
        ],
        );
    }
}
