import 'package:flutter/material.dart';

class ModuleScaffold extends StatelessWidget {
    const ModuleScaffold({
        super.key,
        required this.title,
        required this.body,
        this.actions,
        this.fab,
        this.appBarColor, // ← nuevo
    });

    final String title;
    final List<Widget>? actions;
    final Widget body;
    final Widget? fab;
    final Color? appBarColor; // ← nuevo

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            backgroundColor: appBarColor, // ← usa el color si viene
            title: Text(title),
            actions: actions,
        ),
        floatingActionButton: fab,
        body: SafeArea(child: body),
        );
    }
}
