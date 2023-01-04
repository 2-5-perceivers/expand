import 'package:flutter/material.dart';

/// An M3 expandable tile
class ExpandableTile extends StatefulWidget {
  /// Creates a modern M3 expandable tile
  ///
  /// If [expandable] is true you must provide a childBuilder
  const ExpandableTile({
    super.key,
    this.controller,
    this.childBuilder,
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.marginCollapsed,
    this.marginExpanded,
    this.paddingCollapsed,
    this.paddingExpanded,
    this.shapeCollapsed,
    this.shapeExpanded,
    this.elevationCollapsed,
    this.elevationExpanded,
    this.expandable = true,
    this.rotateTrailingWhenExpanded = true,
    this.initiallyExpanded = false,
  }) : assert(!(expandable && childBuilder == null),
            'Expandable must be false if childBuilder is null');

  /// The [ExpandableTileController] that ensures only one tile is open at a
  /// time.
  final ExpandableTileController? controller;

  /// The callback for building the expansion details (child) when [expandable]
  /// is true.
  final Widget Function(BuildContext context)? childBuilder;

  /// The widget before the title.
  final Widget? leading;

  /// The widget after the title.
  final Widget? trailing;

  /// The title of the collapsed tile
  final Widget? title;

  /// The subtitle of the collapsed tile
  final Widget? subtitle;

  /// The margins around the tile when collapsed.
  ///
  /// Defaults to [EdgeInsets.zero]
  final EdgeInsets? marginCollapsed;

  /// The margins around the tile when expanded
  ///
  /// Defaults to a margin of 8 horizontal and 4 vertical
  final EdgeInsets? marginExpanded;

  /// The padding inside of the tile when collapsed
  ///
  /// Defaults to [EdgeInsets.zero]
  final EdgeInsets? paddingCollapsed;

  /// The padding inside of the tile when expanded
  ///
  /// Defaults to [EdgeInsets.zero]
  final EdgeInsets? paddingExpanded;

  /// The shape of the tile when collapsed
  ///
  /// Defaults to the [ListTileThemeData] shape
  final ShapeBorder? shapeCollapsed;

  /// The shape of the tile when collapsed
  ///
  /// Defaults to a rounded rectangle with 28 radius
  final ShapeBorder? shapeExpanded;

  /// Elevation for the tile when collapsed
  ///
  /// Defaults to 0
  final double? elevationCollapsed;

  /// Elevation for the tile when expanded
  ///
  /// Defaults to 2
  final double? elevationExpanded;

  /// If this is expandable
  final bool expandable;

  /// If this is true the trailing widgets rotates 180 degrees when expanded
  ///
  /// Use in combination with an arrow
  final bool rotateTrailingWhenExpanded;

  /// If this tile should start expanded
  final bool initiallyExpanded;

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile>
    with SingleTickerProviderStateMixin {
  late final Animatable<double> _animationCurve;
  late Animatable<double> _halfTween;

  Animatable<double>? _cardElevationTween;
  Animatable<ShapeBorder?>? _cardShapeTween;
  Animatable<EdgeInsets>? _cardMarginTween;
  Animatable<EdgeInsets>? _cardPaddingTween;

  AnimationController? _controller;
  Animation<double>? _iconTurns;
  Animation<double>? _heightFactor;

  Animation<double>? _cardElevation;
  Animation<ShapeBorder?>? _cardShape;
  Animation<EdgeInsets>? _cardMargin;
  Animation<EdgeInsets>? _cardPadding;

  EdgeInsets? marginCollapsed;
  EdgeInsets? marginExpanded;

  EdgeInsets? paddingCollapsed;
  EdgeInsets? paddingExpanded;

  ShapeBorder? shapeCollapsed;
  ShapeBorder? shapeExpanded;

  double? elevationCollapsed;
  double? elevationExpanded;

  bool _expanded = false;

  bool get expanded => _expanded;

  set expanded(final bool value) {
    _expanded = value;

    if (widget.controller == null) return;

    if (value) {
      widget.controller!.registerOpen(toStringShort());
    }
  }

  @override
  void initState() {
    super.initState();

    if (!widget.expandable) return;

    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 200,
      ),
      vsync: this,
    );

    _animationCurve = CurveTween(curve: Curves.easeInOutCubic);
    _halfTween = Tween<double>(begin: 0.0, end: 0.5);

    _heightFactor = _controller!.drive(_animationCurve);
    _iconTurns = _controller!.drive(_halfTween.chain(_animationCurve));

    expanded = widget.initiallyExpanded && widget.expandable;
    if (expanded) {
      _controller!.value = 1.0;
    }

    widget.controller!.addListener(_controllerListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.expandable) {
      updateAnimations(context);
    } else {
      updateDefaults();
    }
  }

  @override
  void didUpdateWidget(final ExpandableTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.expandable) {
      updateAnimations(context);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    widget.controller?.removeListener(_controllerListener);
    super.dispose();
  }

  void updateDefaults() {
    final ListTileThemeData listTileTheme = Theme.of(context).listTileTheme;

    marginCollapsed = widget.marginCollapsed ?? EdgeInsets.zero;
    marginExpanded = widget.marginExpanded ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    paddingCollapsed = widget.paddingCollapsed ?? EdgeInsets.zero;
    paddingExpanded = widget.paddingExpanded ?? EdgeInsets.zero;

    shapeCollapsed = widget.shapeCollapsed ??
        listTileTheme.shape ??
        const RoundedRectangleBorder();
    shapeExpanded = widget.shapeExpanded ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));

    elevationCollapsed = widget.elevationCollapsed ?? 0;
    elevationExpanded = widget.elevationExpanded ?? 2;
  }

  void updateAnimations(final BuildContext context) {
    updateDefaults();

    _cardElevationTween =
        Tween<double>(begin: elevationCollapsed, end: elevationExpanded);

    _cardShapeTween =
        ShapeBorderTween(begin: shapeCollapsed, end: shapeExpanded);

    _cardMarginTween =
        EdgeInsetsTween(begin: marginCollapsed, end: marginExpanded);
    _cardPaddingTween =
        EdgeInsetsTween(begin: paddingCollapsed, end: paddingExpanded);

    _cardElevation =
        _controller!.drive(_cardElevationTween!.chain(_animationCurve));

    _cardShape = _controller!.drive(_cardShapeTween!.chain(_animationCurve));

    _cardMargin = _controller!.drive(_cardMarginTween!.chain(_animationCurve));
    _cardPadding =
        _controller!.drive(_cardPaddingTween!.chain(_animationCurve));
  }

  void _controllerListener() {
    final bool value = widget.controller!.value == toStringShort();
    if (value == expanded) return;
    _handleTap(newValue: value);
  }

  void _handleTap({final bool? newValue}) {
    if (!widget.expandable) return;

    setState(() {
      expanded = newValue ?? !expanded;
      if (expanded) {
        _controller!.forward();
      } else {
        _controller!.reverse().then<void>((final void value) {
          if (!mounted) {
            return;
          }
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
    });
  }

  Widget? _buildTrailing(final BuildContext context) {
    if (!widget.rotateTrailingWhenExpanded ||
        widget.trailing == null ||
        !widget.expandable) {
      return widget.trailing;
    }
    return RotationTransition(
      turns: _iconTurns!,
      child: widget.trailing,
    );
  }

  @override
  Widget build(final BuildContext context) {
    final bool closed = !expanded && (_controller?.isDismissed ?? true);

    Widget? child;

    if (!closed) {
      child = widget.childBuilder?.call(context) ?? Container();
    } else {
      child = null;
    }

    final Widget result = Offstage(
      offstage: closed,
      child: !closed
          ? TickerMode(
              enabled: !closed,
              child: child!,
            )
          : null,
    );

    if (!widget.expandable) return _buildChildren(context, null);

    return AnimatedBuilder(
      animation: _controller!.view,
      builder: _buildChildren,
      child: closed ? null : result,
    );
  }

  Widget _buildChildren(final BuildContext context, final Widget? child) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: _cardMargin?.value ?? EdgeInsets.zero,
      child: Material(
        animationDuration: Duration.zero,
        type: MaterialType.card,
        clipBehavior: Clip.antiAlias,
        elevation: _cardElevation?.value ?? 0.0,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        shape: _cardShape?.value ?? shapeCollapsed,
        child: InkWell(
          onTap: widget.expandable ? _handleTap : null,
          child: Padding(
            padding: _cardPadding?.value ?? EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListTile(
                  leading: widget.leading,
                  title: widget.title,
                  subtitle: widget.subtitle,
                  trailing: _buildTrailing(context),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    heightFactor: _heightFactor?.value ?? 0,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A controller for [ExpandableTile] that ensures only one is open at a time
class ExpandableTileController extends ValueNotifier<String?> {
  /// Creates the controller
  ExpandableTileController() : super(null);

  /// used by the tile to register
  void registerOpen(final String newHashKey) {
    value = newHashKey;
  }
}
