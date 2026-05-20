import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'awto_inspect_controller.dart';
import 'awto_ai_log_sink.dart';
import 'awto_grid_overlay.dart';
import 'awto_hitbox_overlay.dart';
import 'awto_crosshair_overlay.dart';
import 'awto_status_line.dart';
import 'awto_inspect_menu.dart';

class AwtoInspectApp extends StatefulWidget {
  final bool enabled;
  final Widget child;
  final AwtoAiLogSink? aiLogSink;
  final Function(String)? onSourceOpen;

  const AwtoInspectApp({
    Key? key,
    this.enabled = true,
    required this.child,
    this.aiLogSink,
    this.onSourceOpen,
  }) : super(key: key);

  @override
  State<AwtoInspectApp> createState() => _AwtoInspectAppState();
}

class _AwtoInspectAppState extends State<AwtoInspectApp> {
  late AwtoInspectController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AwtoInspectController();
    if (widget.enabled) {
      _controller.setEnabled(true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _controller.updatePointerPosition(event.position);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _controller.updatePointerPosition(event.position);
  }

  void _handleSecondaryTap(TapDownDetails details) {
    final hoveredObject = _controller.hoveredObject;
    if (hoveredObject != null) {
      AwtoInspectMenu.showObjectMenu(
        context: context,
        object: hoveredObject,
        position: details.globalPosition,
        aiLogSink: widget.aiLogSink,
        onSourceOpen: widget.onSourceOpen,
      );
    }
  }

  void _handleLongPress(LongPressStartDetails details) {
    final hoveredObject = _controller.hoveredObject;
    if (hoveredObject != null) {
      AwtoInspectMenu.showObjectMenu(
        context: context,
        object: hoveredObject,
        position: details.globalPosition,
        aiLogSink: widget.aiLogSink,
        onSourceOpen: widget.onSourceOpen,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.enabled) {
      return widget.child;
    }

    return Listener(
      onPointerMove: _handlePointerMove,
      onPointerDown: _handlePointerDown,
      child: GestureDetector(
        onSecondaryTapDown: _handleSecondaryTap,
        onLongPressStart: _handleLongPress,
        child: Stack(
          children: [
            widget.child,
            if (_controller.enabled) ...[
              // Grid overlay
              if (_controller.gridEnabled)
                IgnorePointer(
                  child: CustomPaint(
                    painter: AwtoGridOverlay(
                      gridSize: _controller.gridSize,
                      alpha: _controller.gridAlpha,
                    ),
                    size: Size.infinite,
                  ),
                ),
              // Hitbox overlay
              if (_controller.hitboxesEnabled)
                IgnorePointer(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: AwtoHitboxOverlay(
                          alpha: _controller.objectAlpha,
                          hoveredObjectId: _controller.hoveredObject?.metadata.id,
                          selectedObjectId: _controller.selectedObject?.metadata.id,
                          createTextPainter: (id) {
                            final textPainter = TextPainter(
                              text: TextSpan(
                                text: '[$id]',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 100, 200, 100),
                                  fontSize: 11,
                                  fontFamily: 'Courier New',
                                ),
                              ),
                              textDirection: TextDirection.ltr,
                            );
                            textPainter.layout();
                            return textPainter;
                          },
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              // Crosshair overlay
              if (_controller.crosshairEnabled)
                IgnorePointer(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: AwtoCrosshairOverlay(
                          pointerPosition: _controller.currentPointerPosition,
                          alpha: 0.3,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              // Status line
              if (_controller.statusLineEnabled)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AwtoStatusLine(controller: _controller),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
