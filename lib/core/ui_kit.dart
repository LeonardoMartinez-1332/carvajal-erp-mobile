import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Degradado corporativo
class AppGradient extends StatelessWidget {
    const AppGradient({super.key, required this.child});
    final Widget child;

    @override
    Widget build(BuildContext context) {
        return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
            colors: [AppColors.bgA, AppColors.bgB, AppColors.bgC],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            ),
        ),
        child: child,
        );
    }
}

/// Tarjeta sección con padding estándar
class SectionCard extends StatelessWidget {
    const SectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
    final Widget child;
    final EdgeInsets padding;

    @override
    Widget build(BuildContext context) {
        return Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: padding, child: child),
        );
    }
}

/// KPI mini etiqueta
class KpiBadge extends StatelessWidget {
    const KpiBadge({
        super.key,
        required this.icon,
        required this.label,
        required this.value,
        required this.color,
    });
    final IconData icon;
    final String label;
    final String value;
    final Color color;

    @override
    Widget build(BuildContext context) {
        return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(.96),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ]),
        ]),
        );
    }
}

/// Chip por estado (usa paleta del kit)
class EstadoChip extends StatelessWidget {
    const EstadoChip(this.text, {super.key, required this.color});
    final String text;
    final Color color;

    @override
    Widget build(BuildContext context) {
        return Chip(
        label: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        side: BorderSide(color: color),
        backgroundColor: color.withOpacity(.12),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
    }
}

/// Dialogo de confirmación estándar
Future<bool> confirmDialog(BuildContext context,
    {required String title, required String message, String okText = 'Aceptar', String cancelText = 'Cancelar'}) async {
    final res = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelText)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(okText)),
        ],
        ),
    );
    return res ?? false;
}

class FadeSlide extends StatefulWidget {
    const FadeSlide({super.key, required this.child, this.delayMs = 0});
    final Widget child; final int delayMs;
    @override State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide> with SingleTickerProviderStateMixin {
    late final AnimationController _c;
    late final Animation<double> _fade;
    late final Animation<Offset> _slide;
    @override
    void initState() {
        super.initState();
        _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
        _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
        _slide = Tween(begin: const Offset(0, .06), end: Offset.zero)
            .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
        Future.delayed(Duration(milliseconds: widget.delayMs), () => _c.forward());
    }
    @override void dispose() { _c.dispose(); super.dispose(); }
    @override Widget build(BuildContext context) =>
        FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
}
