import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import 'package:carvajal_erp/models/ti_directa.dart';
import 'package:carvajal_erp/services/jobs_pdf_service.dart';

class JobsTiPdfPreviewPage extends StatelessWidget {
    final TiDirecta ti;

    const JobsTiPdfPreviewPage({
        super.key,
        required this.ti,
    });

    @override
    Widget build(BuildContext context) {
        final folio = ti.numTi.isNotEmpty ? ti.numTi : 'TI';

            return Scaffold(
            appBar: AppBar(
                title: Text('Vista previa – $folio'),
            ),
            body: PdfPreview(
                canChangePageFormat: true,
                canChangeOrientation: true,
                allowPrinting: true,
                allowSharing: true,
                initialPageFormat: PdfPageFormat.a4,
                pdfFileName: '$folio.pdf',

                // 🔹 Aquí usamos el servico que ya arma el PDF
                build: (format) async {
                return JobsPdfService.buildTiPdf(ti);
                },
            ),
        );
    }
}
