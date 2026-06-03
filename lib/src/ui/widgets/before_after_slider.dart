import 'package:flutter/material.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String beforeImageUrl;
  final String afterImageUrl;
  final Color handleColor;

  const BeforeAfterSlider({
    Key? key,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    this.handleColor = Colors.white,
  }) : super(key: key);

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _dividerOffset = 0.5; // Starts in the middle (50%)

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dividerOffset =
                  (details.localPosition.dx / width).clamp(0.0, 1.0);
            });
          },
          child: Stack(
            children: [
              // After (Result) image (always fills background)
              Positioned.fill(
                child: Image.network(
                  widget.afterImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child:
                        Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                ),
              ),
              // Before (Original model/person) image (clipped based on offset)
              Positioned.fill(
                child: ClipRect(
                  clipper: _SliderClipper(_dividerOffset),
                  child: Image.network(
                    widget.beforeImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image,
                          size: 64, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              // Drag Indicator Divider Line
              Positioned(
                left: width * _dividerOffset - 2,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  color: widget.handleColor,
                ),
              ),
              // Interactive Handle Bubble
              Positioned(
                left: width * _dividerOffset - 20,
                top: height / 2 - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.handleColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.swap_horiz,
                    color: widget.handleColor == Colors.white
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double offset;
  _SliderClipper(this.offset);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * offset, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) => oldClipper.offset != offset;
}
