import 'package:flutter/material.dart';

import '../../widgets/ui_bits.dart'; // GradientBackground, SectionCard

class AdminDashboardPage extends StatelessWidget {
    const AdminDashboardPage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF2E7D32),
            title: const Text('Dashboards / KPIs'),
        ),
        body: GradientBackground(
            child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Center(
                child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const SectionCard(
                        title: 'Visión ejecutiva',
                        subtitle: 'KPIs clave • Tendencias • Salud del sistema',
                    ),
                    const SizedBox(height: 16),

                    // ====== FILA 1: KPIs principales ======
                    Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: const [
                        _KpiCard(
                            icon: Icons.inventory_2_outlined,
                            iconColor: Color(0xFF1976D2),
                            title: 'Inventario total',
                            value: '1,248 PT',
                            helper: 'Stock actual en WMS',
                            trendLabel: '+3.2 % mes',
                            trendPositive: true,
                        ),
                        _KpiCard(
                            icon: Icons.local_shipping_outlined,
                            iconColor: Color(0xFF43A047),
                            title: 'OT abiertas',
                            value: '27',
                            helper: 'Órdenes en curso',
                            trendLabel: '-5 vs ayer',
                            trendPositive: true,
                        ),
                        _KpiCard(
                            icon: Icons.warning_amber_outlined,
                            iconColor: Color(0xFFF9A825),
                            title: 'Alertas',
                            value: '4',
                            helper: 'Cortes / incidencias',
                            trendLabel: '2 críticas',
                            trendPositive: false,
                        ),
                        ],
                    ),

                    const SizedBox(height: 24),

                    // ====== FILA 2: Tendencias + nivel de servicio ======
                    Expanded(
                        child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            // Tendencias
                            Expanded(
                            flex: 2,
                            child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    Row(
                                        children: const [
                                        Icon(Icons.trending_up,
                                            size: 22, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text(
                                            'Tendencias de movimiento',
                                            style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                        ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                        'Últimos 7 días • Entradas vs salidas',
                                        style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Aquí van barras / progresos simples
                                    const _TrendRow(
                                        label: 'Entradas (PT)',
                                        value: 0.78,
                                        helper: '7,420 cajas',
                                    ),
                                    const SizedBox(height: 12),
                                    const _TrendRow(
                                        label: 'Salidas (PT)',
                                        value: 0.64,
                                        helper: '6,120 cajas',
                                    ),
                                    const SizedBox(height: 12),
                                    const _TrendRow(
                                        label: 'Devoluciones',
                                        value: 0.18,
                                        helper: '540 cajas',
                                    ),
                                    const Spacer(),
                                    const Text(
                                        'Tip: estos datos son mock. Cuando tengas el endpoint, '
                                        'solo reemplaza los valores y listo.',
                                        style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black45,
                                        ),
                                    )
                                    ],
                                ),
                                ),
                            ),
                            ),

                            const SizedBox(width: 16),

                            // Nivel de servicio / últimos eventos
                            Expanded(
                            flex: 1,
                            child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: SingleChildScrollView(   // 👈 Agregado
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Row(
                                        children: const [
                                            Icon(Icons.speed_outlined,
                                                size: 22, color: Colors.deepPurple),
                                            SizedBox(width: 8),
                                            Text(
                                            'Nivel de servicio',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                            ),
                                            ),
                                        ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                        'Fill rate y performance reciente',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                        ),
                                        ),
                                        SizedBox(height: 16),

                                        // Donita
                                        Center(
                                        child: SizedBox(
                                            width: 120,
                                            height: 120,
                                            child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                                SizedBox(
                                                width: 120,
                                                height: 120,
                                                child: CircularProgressIndicator(
                                                    value: 0.92,
                                                    strokeWidth: 10,
                                                    backgroundColor: Colors.grey.shade200,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(Color(0xFF43A047)),
                                                ),
                                                ),
                                                Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                    Text(
                                                    '92%',
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                    'Fill rate',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54,
                                                    ),
                                                    ),
                                                ],
                                                ),
                                            ],
                                            ),
                                        ),
                                        ),

                                        SizedBox(height: 16),
                                        Divider(),
                                        SizedBox(height: 8),
                                        Text(
                                        'Últimas acciones',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                        ),
                                        ),
                                        SizedBox(height: 8),

                                        _LogItem(
                                        title: 'Ajuste de inventario',
                                        subtitle:
                                            'Supervisor | PT FOAM CUP 32oz · -120 cajas',
                                        ),
                                        _LogItem(
                                        title: 'Nueva TI Jobs',
                                        subtitle:
                                            'OT 12457 • Traslado PT → Picking',
                                        ),
                                        _LogItem(
                                        title: 'Devolución registrada',
                                        subtitle:
                                            'Whataburger • 2 pallets en revisión',
                                        ),
                                    ],
                                    ),
                                ),
                                ),
                            ),
                            )

                        ],
                        ),
                    ),
                    ],
                ),
                ),
            ),
            ),
        ),
        );
    }
}

// ================== WIDGETS PRIVADOS ==================

class _KpiCard extends StatelessWidget {
    final IconData icon;
    final Color iconColor;
    final String title;
    final String value;
    final String helper;
    final String trendLabel;
    final bool trendPositive;

    const _KpiCard({
        required this.icon,
        required this.iconColor,
        required this.title,
        required this.value,
        required this.helper,
        required this.trendLabel,
        required this.trendPositive,
    });

    @override
    Widget build(BuildContext context) {
        final trendColor = trendPositive ? Colors.green : Colors.red;

        return SizedBox(
        width: 260,
        child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                    children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 22, color: iconColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                        ),
                        ),
                    ),
                    ],
                ),
                const SizedBox(height: 14),
                Text(
                    value,
                    style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    ),
                ),
                const SizedBox(height: 4),
                Text(
                    helper,
                    style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    ),
                ),
                const SizedBox(height: 8),
                Row(
                    children: [
                    Icon(
                        trendPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: trendColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                        trendLabel,
                        style: TextStyle(
                        fontSize: 11,
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                        ),
                    ),
                    ],
                ),
                ],
            ),
            ),
        ),
        );
    }
}

class _TrendRow extends StatelessWidget {
    final String label;
    final double value; // 0–1
    final String helper;

    const _TrendRow({
        required this.label,
        required this.value,
        required this.helper,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
            children: [
                Expanded(
                child: Text(
                    label,
                    style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    ),
                ),
                ),
                Text(
                helper,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                ),
                ),
            ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
            ),
            ),
        ],
        );
    }
}

class _LogItem extends StatelessWidget {
    final String title;
    final String subtitle;

    const _LogItem({
        required this.title,
        required this.subtitle,
    });

    @override
    Widget build(BuildContext context) {
        return ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
            Icons.circle,
            size: 10,
            color: Color(0xFF90A4AE),
        ),
        title: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        );
    }
}
