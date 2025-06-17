import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned(
                left: constraints.maxWidth / 6,
                top: constraints.maxHeight / 6,
                child: RectangleArea(
                  label: 'Top left',
                  color: Colors.yellow,
                  size: constraints.biggest.shortestSide / 4,
                ),
              ),
              Positioned(
                right: constraints.maxWidth / 6,
                top: constraints.maxHeight / 6,
                child: RectangleArea(
                  label: 'Top right',
                  color: Colors.green,
                  size: constraints.biggest.shortestSide / 4,
                ),
              ),
              Positioned(
                right: constraints.maxWidth / 6,
                bottom: constraints.maxHeight / 6,
                child: RectangleArea(
                  label: 'Bottom right',
                  color: Colors.blue,
                  size: constraints.biggest.shortestSide / 4,
                ),
              ),
              Positioned(
                left: constraints.maxWidth / 6,
                bottom: constraints.maxHeight / 6,
                child: RectangleArea(
                  label: 'Bottom left',
                  color: Colors.purple,
                  size: constraints.biggest.shortestSide / 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RectangleArea extends StatelessWidget {
  const RectangleArea({
    super.key,
    required this.label,
    required this.size,
    required this.color,
  });

  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ContextMenu(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color),
        child: Center(child: Text(label)),
      ),
    );
  }
}

class Interceptor extends StatelessWidget {
  final Widget child;

  const Interceptor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) {
        if (kIsWeb) {
          // Prevents default browser context menu
        }
      },
      child: child,
    );
  }
}

class ContextMenu extends StatefulWidget {
  final Widget child;
  final List<String> menuItems;
  final Function(String)? onItemSelected;

  const ContextMenu({
    super.key,
    required this.child,
    this.menuItems = const ['Create', 'Edit', 'Remove'],
    this.onItemSelected,
  });

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Offset _tapPosition = Offset.zero;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _showContextMenu(BuildContext context, TapDownDetails details) {
    _tapPosition = details.globalPosition;
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: _tapPosition.dy,
        left: _tapPosition.dx,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 0),
          child: Material(
            elevation: 8,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicWidth(
                child: _buildMenu(context),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.menuItems.map((item) {
        return InkWell(
          onTap: () {
            widget.onItemSelected?.call(item);
            _removeOverlay();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(item),
          ),
        );
      }).toList(),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onSecondaryTapDown: (details) => _showContextMenu(context, details),
        onTap: _removeOverlay,
        child: Interceptor(
          child: widget.child,
        ),
      ),
    );
  }
}