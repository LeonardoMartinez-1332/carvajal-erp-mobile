import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class GradientBackground extends StatelessWidget {
    const GradientBackground({super.key, required this.child});
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

class SectionCard extends StatelessWidget {
    const SectionCard({
        super.key,
        this.title,
        this.subtitle,
        this.trailing,
        this.padding = const EdgeInsets.all(16),
        this.child,
    });

    final String? title;
    final String? subtitle;
    final Widget? trailing;
    final EdgeInsets padding;
    final Widget? child;

    @override
    Widget build(BuildContext context) {
        return Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
            padding: padding,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                if (title != null || subtitle != null || trailing != null)
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Expanded(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            if (title != null)
                            Text(
                                title!,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    ),
                            ),
                            if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                                subtitle!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    ),
                            ),
                            ],
                        ],
                        ),
                    ),
                    if (trailing != null) trailing!,
                    ],
                ),
                if (child != null) ...[
                if (title != null || subtitle != null || trailing != null)
                    const SizedBox(height: 12),
                child!,
                ],
            ],
            ),
        ),
        );
    }
}

/// KPI pequeño reutilizable (contadores de Usuarios/Productos/etc.)
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8)],
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                    value,
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: color,
                    ),
                ),
                const SizedBox(height: 2),
                Text(
                    label,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                ],
            ),
            ],
        ),
        );
    }
}
