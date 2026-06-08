import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SliderRow extends StatefulWidget {
  final String label;
  final String? hint;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;
  final String Function(double) format;
  final String? error;
  final String? prefix;
  final String? suffix;

  const SliderRow({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    required this.format,
    this.error,
    this.prefix,
    this.suffix,
  });

  @override
  State<SliderRow> createState() => _SliderRowState();
}

class _SliderRowState extends State<SliderRow> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  bool _editing = false;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(SliderRow old) {
    super.didUpdateWidget(old);
    if (widget.error != null && old.error == null) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = LuminaTokens(isDark: Theme.of(context).brightness == Brightness.dark);
    final pct = ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    final hasError = widget.error != null;

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                          height: 1.3,
                        ),
                      ),
                      if (widget.hint != null)
                        Text(
                          widget.hint!,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: t.faint,
                            height: 1.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _editing
                    ? SizedBox(
                        width: 116,
                        child: TextField(
                          controller: _textController,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                            filled: true,
                            fillColor: t.field,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.steelBlue, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.steelBlue, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.steelBlue, width: 1.5),
                            ),
                          ),
                          onSubmitted: (_) => _commitEdit(t),
                          onEditingComplete: () => _commitEdit(t),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _textController.text = widget.value.toString();
                          setState(() => _editing = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.field,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: hasError ? t.errorBorder : t.fieldBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              if (widget.prefix != null)
                                Text(
                                  widget.prefix!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: (hasError ? t.error : t.text).withOpacity(0.7),
                                  ),
                                ),
                              Text(
                                widget.format(widget.value),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: hasError ? t.error : t.text,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              if (widget.suffix != null)
                                Text(
                                  widget.suffix!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: (hasError ? t.error : t.text).withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 11),
            _LuminaSlider(
              value: widget.value,
              min: widget.min,
              max: widget.max,
              step: widget.step,
              pct: pct,
              hasError: hasError,
              t: t,
              onChanged: widget.onChanged,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: hasError
                  ? Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Row(
                        children: [
                          Icon(Icons.warning_rounded, size: 14, color: t.error),
                          const SizedBox(width: 5),
                          Text(
                            widget.error!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: t.error,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _commitEdit(LuminaTokens t) {
    final v = double.tryParse(_textController.text);
    if (v != null) widget.onChanged(v);
    setState(() => _editing = false);
  }
}

class _LuminaSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final double pct;
  final bool hasError;
  final LuminaTokens t;
  final ValueChanged<double> onChanged;

  const _LuminaSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.pct,
    required this.hasError,
    required this.t,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 6,
        thumbShape: _LuminaThumbShape(hasError: hasError, t: t),
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: hasError ? t.error : AppColors.steelBlueMid,
        inactiveTrackColor: t.track,
        trackShape: _LuminaTrackShape(hasError: hasError, t: t),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: ((max - min) / step).round(),
        onChanged: onChanged,
      ),
    );
  }
}

class _LuminaThumbShape extends SliderComponentShape {
  final bool hasError;
  final LuminaTokens t;
  const _LuminaThumbShape({required this.hasError, required this.t});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(22, 22);

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 11, paint);
    final border = Paint()
      ..color = hasError ? t.error : AppColors.steelBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 11, border);
    final shadow = Paint()
      ..color = (hasError ? t.error : AppColors.steelBlue).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, 9, shadow);
  }
}

class _LuminaTrackShape extends RoundedRectSliderTrackShape {
  final bool hasError;
  final LuminaTokens t;
  const _LuminaTrackShape({required this.hasError, required this.t});

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required Offset thumbCenter,
      Offset? secondaryOffset,
      bool isDiscrete = false,
      bool isEnabled = false,
      double additionalActiveTrackHeight = 2}) {
    final canvas = context.canvas;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activePaint = Paint()
      ..color = hasError ? t.error : AppColors.steelBlueMid
      ..style = PaintingStyle.fill;
    final inactivePaint = Paint()
      ..color = t.track
      ..style = PaintingStyle.fill;

    final rr = const Radius.circular(3);
    canvas.drawRRect(
      RRect.fromLTRBR(trackRect.left, trackRect.top, trackRect.right, trackRect.bottom, rr),
      inactivePaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom, rr),
      activePaint,
    );
  }
}
