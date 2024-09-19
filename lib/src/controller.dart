import 'package:flutter/widgets.dart';

/// An controller to manage the state of the expandable widgets.
/// It can be used to control the expansion of the widgets.
class ExpandableController extends ChangeNotifier {
  /// Creates an instance of [ExpandableController].
  ExpandableController({
    String? expandedID,
  }) : _expandedID = expandedID;

  String? _expandedID;

  /// The ID of the currently expanded widget.
  String? get expandedID => _expandedID;

  /// Sets as open the widget with the given [id].
  void open(String id) {
    _expandedID = id;
    notifyListeners();
  }

  /// Sets as closed the currently expanded widget.
  void close() {
    _expandedID = null;
    notifyListeners();
  }

  @override
  String toString() => 'ExpandableController(expandedID: $expandedID)';
}

/// Provides an [ExpandableController] to its descendants.
class ExpandableProvider extends StatefulWidget {
  /// Creates an instance of [ExpandableProvider].
  const ExpandableProvider({
    required this.child,
    this.controller,
    this.expandedID,
    super.key,
  }) : assert(
          expandedID == null || controller == null,
          'Cannot provide both controller and expandedID',
        );

  /// The widget below this widget in the tree.
  final Widget child;

  /// The controller to be provided. If not provided, a new controller will be
  /// created.
  final ExpandableController? controller;

  /// The ID of the widget that should be expanded by default. Can only be used
  /// if [controller] is not provided.
  final String? expandedID;

  /// Returns the [ExpandableController] of the closest [ExpandableProvider]
  /// ancestor if any.
  static ExpandableController? mayOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_ExpandableInheritedWidget>();
    return provider?.controller;
  }

  /// Returns the [ExpandableController] of the closest [ExpandableProvider]
  static ExpandableController of(BuildContext context) => mayOf(context)!;

  @override
  State<ExpandableProvider> createState() => _ExpandableProviderState();
}

class _ExpandableProviderState extends State<ExpandableProvider> {
  late final ExpandableController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ??
        ExpandableController(
          expandedID: widget.expandedID,
        );
  }

  @override
  Widget build(BuildContext context) => _ExpandableInheritedWidget(
        controller: _controller,
        child: widget.child,
      );
}

class _ExpandableInheritedWidget extends InheritedWidget {
  const _ExpandableInheritedWidget({
    required super.child,
    required this.controller,
  });

  final ExpandableController controller;

  @override
  bool updateShouldNotify(_ExpandableInheritedWidget oldWidget) =>
      controller != oldWidget.controller;
}
