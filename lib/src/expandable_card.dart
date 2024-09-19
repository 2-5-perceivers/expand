import 'dart:async';

import 'package:expand/src/controller.dart';
import 'package:flutter/material.dart';

/// A callback definition for building the expanded details of the card
typedef ExpandableBuilder = Widget Function(BuildContext context);

/// A callback definition for building a widget wrapped in a another widget
typedef WrapperBuilder = Widget Function(Widget child);

/// A callback definition for building a widget with a wrapped trailing widget
typedef ClosedChildBuilder = Widget Function(
  BuildContext context,
  WrapperBuilder trailingBuilder,
);

/// A callback definition for building a widget with more parameters
typedef AdvancedChildBuilder = Widget Function(
  BuildContext context,
  WrapperBuilder trailingBuilder,
  void Function() onTap,

  /// For easy use of the API
  // ignore: avoid_positional_boolean_parameters
  bool expanded,
);

/// An M3 expandable card
class ExpandableCard extends StatefulWidget {
  /// Creates a modern M3 expandable card
  ///
  /// If [detailsBuilder] is null, the card will not be expandable
  const ExpandableCard({
    this.childBuilder,
    this.advancedChildBuilder,
    this.controller,
    this.detailsBuilder,
    this.marginCollapsed,
    this.marginExpanded,
    this.paddingCollapsed,
    this.paddingExpanded,
    this.shapeCollapsed,
    this.shapeExpanded,
    this.elevationCollapsed,
    this.elevationExpanded,
    this.rotateTrailingWhenExpanded = true,
    this.initiallyExpanded = false,
    super.key,
    this.id,
    this.animationDuration,
  })  : assert(
          detailsBuilder == null || !initiallyExpanded,
          'Cannot start expanded if detailsBuilder is not null',
        ),
        assert(
          childBuilder != null || advancedChildBuilder != null,
          'Either childBuilder or advancedChildBuilder must be provided',
        ),
        assert(
          childBuilder == null || advancedChildBuilder == null,
          'Cannot provide both childBuilder and advancedChildBuilder',
        );

  /// The [ExpandablecardController] that ensures only one card is open at a
  /// time. If this is null, it will be inherited from the nearest
  /// [ExpandablecardProvider] ancestor.
  final ExpandableController? controller;

  /// The ID of the card. If not provided, one will be generated
  final String? id;

  /// The duration of the animation. Defaults to 200 milliseconds
  final Duration? animationDuration;

  /// The callback for building the expanded details of the card. If null, the
  /// card will not be expandable.
  final ExpandableBuilder? detailsBuilder;

  /// The callback for building the child. The trailing widget builder can be
  /// used to make a trailing widget rotate when expanded
  final ClosedChildBuilder? childBuilder;

  /// The callback for building the child with advanced features
  final AdvancedChildBuilder? advancedChildBuilder;

  /// The margins around the card when collapsed.
  ///
  /// Defaults to [EdgeInsets.zero]
  final EdgeInsets? marginCollapsed;

  /// The margins around the card when expanded
  ///
  /// Defaults to a margin of 8 horizontal and 4 vertical
  final EdgeInsets? marginExpanded;

  /// The padding inside of the card when collapsed
  ///
  /// Defaults to [EdgeInsets.zero]
  final EdgeInsets? paddingCollapsed;

  /// The padding inside of the card when expanded
  ///
  /// Defaults to [EdgeInsets.zero]
  final EdgeInsets? paddingExpanded;

  /// The shape of the card when collapsed
  ///
  /// Defaults to the [ListcardThemeData] shape
  final ShapeBorder? shapeCollapsed;

  /// The shape of the card when collapsed
  ///
  /// Defaults to a rounded rectangle with 28 radius
  final ShapeBorder? shapeExpanded;

  /// Elevation for the card when collapsed
  ///
  /// Defaults to 0
  final double? elevationCollapsed;

  /// Elevation for the card when expanded
  ///
  /// Defaults to 2
  final double? elevationExpanded;

  /// If this is true the trailing widgets rotates 180 degrees when expanded
  ///
  /// Use in combination with an arrow
  final bool rotateTrailingWhenExpanded;

  /// If this card should start expanded
  final bool initiallyExpanded;

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late final Animatable<double> _animationCurve;
  late Animatable<double> _halfTween;

  late Animatable<double> _cardElevationTween;
  late Animatable<ShapeBorder?> _cardShapeTween;
  late Animatable<EdgeInsets> _cardMarginTween;
  late Animatable<EdgeInsets> _cardPaddingTween;

  AnimationController? _animationController;
  Animation<double>? _heightFactor;
  late Animation<double> _iconTurns;

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

  ExpandableController? controller;
  late String id;

  bool _expanded = false;

  @override
  void initState() {
    super.initState();

    updateValues();
    if (widget.detailsBuilder != null) {
      initAnimations();
      updateAnimations();
    }

    _expanded = widget.initiallyExpanded;
    if (_expanded) {
      _animationController?.value = 1.0;
    }
    initID();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initController();
  }

  @override
  void didUpdateWidget(ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.detailsBuilder != oldWidget.detailsBuilder) {
      if (widget.detailsBuilder == null) {
        _animationController?.value = 0;
        _animationController?.dispose();
        _animationController = null;
      } else if (oldWidget.detailsBuilder == null) {
        initAnimations();
        updateAnimations();
      }
    }

    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController?.duration =
          widget.animationDuration ?? const Duration(milliseconds: 200);
    }

    if (widget.marginCollapsed != oldWidget.marginCollapsed ||
        widget.marginExpanded != oldWidget.marginExpanded ||
        widget.paddingCollapsed != oldWidget.paddingCollapsed ||
        widget.paddingExpanded != oldWidget.paddingExpanded ||
        widget.shapeCollapsed != oldWidget.shapeCollapsed ||
        widget.shapeExpanded != oldWidget.shapeExpanded ||
        widget.elevationCollapsed != oldWidget.elevationCollapsed ||
        widget.elevationExpanded != oldWidget.elevationExpanded) {
      if (widget.detailsBuilder != null) {
        updateAnimations();
      } else {
        updateValues();
      }
    }

    if (widget.id != oldWidget.id) {
      initID();
    }

    if (widget.controller != oldWidget.controller) {
      initController();
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    controller?.removeListener(_controllerListener);
    super.dispose();
  }

  void updateValues() {
    marginCollapsed = widget.marginCollapsed ?? EdgeInsets.zero;
    marginExpanded = widget.marginExpanded ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    paddingCollapsed = widget.paddingCollapsed ?? EdgeInsets.zero;
    paddingExpanded = widget.paddingExpanded ?? EdgeInsets.zero;

    shapeCollapsed = widget.shapeCollapsed ?? const RoundedRectangleBorder();
    shapeExpanded = widget.shapeExpanded ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));

    elevationCollapsed = widget.elevationCollapsed ?? 0;
    elevationExpanded = widget.elevationExpanded ?? 2;
  }

  void updateAnimations() {
    _cardElevationTween =
        Tween<double>(begin: elevationCollapsed, end: elevationExpanded);

    _cardShapeTween =
        ShapeBorderTween(begin: shapeCollapsed, end: shapeExpanded);

    _cardMarginTween =
        EdgeInsetsTween(begin: marginCollapsed, end: marginExpanded);
    _cardPaddingTween =
        EdgeInsetsTween(begin: paddingCollapsed, end: paddingExpanded);

    _cardElevation =
        _animationController!.drive(_cardElevationTween.chain(_animationCurve));

    _cardShape =
        _animationController!.drive(_cardShapeTween.chain(_animationCurve));

    _cardMargin =
        _animationController!.drive(_cardMarginTween.chain(_animationCurve));
    _cardPadding =
        _animationController!.drive(_cardPaddingTween.chain(_animationCurve));
  }

  void _controllerListener() {
    final value = controller!.expandedID == id;
    if (value == _expanded) return;

    _expanded = value;
    unawaited(_handleNewExpandedValue());
  }

  Future<void> _handleNewExpandedValue() async {
    if (widget.detailsBuilder == null) return;

    setState(() {});

    if (_expanded) {
      _animationController!.forward();
    } else {
      _animationController!.reverse().then<void>((value) {
        if (!mounted) {
          return;
        }
        if (!_expanded) {
          setState(() {
            // Rebuild without the details if item collapsed
          });
        }
      });
    }
  }

  void _handleTap() {
    if (_expanded) {
      controller!.close();
    } else {
      controller!.open(id);
    }
  }

  Widget _buildTrailing(Widget child) {
    if (!widget.rotateTrailingWhenExpanded || widget.detailsBuilder == null) {
      return child;
    }
    return RotationTransition(
      turns: _iconTurns,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final closed = !_expanded && (_animationController?.isDismissed ?? true);

    Widget? child;

    if (!closed) {
      child = widget.detailsBuilder?.call(context) ?? Container();
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

    if (widget.detailsBuilder == null) return _buildChildren(context, null);

    return AnimatedBuilder(
      animation: _animationController!.view,
      builder: _buildChildren,
      child: closed ? null : result,
    );
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final theme = Theme.of(context);

    return Padding(
      padding: _cardMargin?.value ?? marginCollapsed ?? EdgeInsets.zero,
      child: Material(
        animationDuration: Duration.zero,
        type: MaterialType.card,
        clipBehavior: Clip.antiAlias,
        elevation: _cardElevation?.value ?? elevationCollapsed!,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        shape: _cardShape?.value ?? shapeCollapsed,
        child: InkWell(
          onTap: widget.detailsBuilder != null ? _handleTap : null,
          child: Padding(
            padding: _cardPadding?.value ?? paddingCollapsed!,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                widget.childBuilder?.call(
                      context,
                      _buildTrailing,
                    ) ??
                    widget.advancedChildBuilder!.call(
                      context,
                      _buildTrailing,
                      _handleTap,
                      _expanded,
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

  void initController() {
    controller?.removeListener(_controllerListener);

    if (widget.controller != null) {
      controller = widget.controller;
    } else {
      final c = ExpandableProvider.mayOf(context);
      assert(c != null, 'No ExpandableController found');
      controller = c;
    }
    if (_expanded) {
      controller!.open(id);
    }
    _controllerListener();
    controller!.addListener(_controllerListener);
  }

  void initID() {
    if (widget.id != null) {
      id = widget.id!;
    } else {
      id = hashCode.toString();
    }
  }

  void initAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 200),
      vsync: this,
    );

    _animationCurve = CurveTween(curve: Curves.easeInOutCubic);
    _halfTween = Tween<double>(begin: 0, end: 0.5);

    _heightFactor = _animationController!.drive(_animationCurve);
    _iconTurns = _animationController!.drive(_halfTween.chain(_animationCurve));
  }
}
