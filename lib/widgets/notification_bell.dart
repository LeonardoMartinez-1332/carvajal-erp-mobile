import 'package:flutter/material.dart';

import '../data/notification_repository.dart';
import '../models/notification_summary.dart';

class NotificationBell extends StatefulWidget {
    final Future<void> Function()? onTap;

    const NotificationBell({
        super.key,
        this.onTap,
    });

    @override
    State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
    final NotificationRepository _repo = NotificationRepository();

    bool _loading = true;
    String? _error;
    int _noLeidas = 0;

    @override
    void initState() {
        super.initState();
        _cargarResumen();
    }

    @override
    void didUpdateWidget(covariant NotificationBell oldWidget) {
        super.didUpdateWidget(oldWidget);
        // Cada vez que el padre haga setState y se vuelva a construir este widget,
        // volvemos a preguntar cuántas no leídas hay.
        _cargarResumen();
    }

    Future<void> _cargarResumen() async {
        setState(() {
        _loading = true;
        _error = null;
        });

        try {
        final NotificationSummary resumen = await _repo.obtenerResumen();
        setState(() {
            _noLeidas = resumen.noLeidas;
            _loading = false;
        });
        } catch (e) {
        setState(() {
            _error = 'Error al cargar resumen';
            _loading = false;
        });
        }
    }

    @override
    Widget build(BuildContext context) {
        final hasBadge = _noLeidas > 0;

        return Stack(
        clipBehavior: Clip.none,
        children: [
            IconButton(
            onPressed: () async {
                if (widget.onTap != null) {
                await widget.onTap!();
                // cuando regrese de la navegación, el padre hará setState()
                // y eso disparará didUpdateWidget -> _cargarResumen()
                }
            },
            icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (hasBadge)
            Positioned(
                right: 8,
                top: 8,
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                    _noLeidas.toString(),
                    style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    ),
                ),
                ),
            ),
        ],
        );
    }
}
