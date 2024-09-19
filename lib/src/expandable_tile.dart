import 'package:expand/src/controller.dart';
import 'package:expand/src/expandable_card.dart';
import 'package:flutter/material.dart';

/// A tile that can be expanded to show more details.
class ExpandableTile extends StatelessWidget {
  /// Creates an instance of [ExpandableTile].
  const ExpandableTile({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isThreeLine = false,
    this.dense,
    this.visualDensity,
    this.controller,
    this.id,
    this.animationDuration,
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
  });

  /// The title of the tile.
  final Widget title;

  /// The subtitle of the tile.
  final Widget? subtitle;

  /// A widget to display before the title.
  final Widget? leading;

  /// A widget to display after the title. If [rotateTrailingWhenExpanded] is
  /// true, it will rotate 180 degrees when expanded.
  final Widget? trailing;

  /// Whether this list tile is intended to display three lines of text.
  final bool isThreeLine;

  /// Whether this list tile is part of a vertically dense list.
  final bool? dense;

  /// The visual density of the list tile.
  final VisualDensity? visualDensity;

  // The [ExpandablecardController] that ensures only one card is open at a
  /// time. If this is null, it will be inherited from the nearest
  /// [ExpandablecardProvider] ancestor.
  final ExpandableController? controller;

  /// The ID of the tile. If not provided, one will be generated.
  final String? id;

  /// The duration of the animation when expanding or collapsing the card.
  final Duration? animationDuration;

  /// The callback for building the expanded details of the card. If null, the
  /// card will not be expandable.
  final WidgetBuilder? detailsBuilder;

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
  Widget build(BuildContext context) => ExpandableCard(
        controller: controller,
        id: id,
        animationDuration: animationDuration,
        detailsBuilder: detailsBuilder,
        marginCollapsed: marginCollapsed,
        marginExpanded: marginExpanded,
        paddingCollapsed: paddingCollapsed,
        paddingExpanded: paddingExpanded,
        shapeCollapsed: shapeCollapsed,
        shapeExpanded: shapeExpanded,
        elevationCollapsed: elevationCollapsed,
        elevationExpanded: elevationExpanded,
        rotateTrailingWhenExpanded: rotateTrailingWhenExpanded,
        initiallyExpanded: initiallyExpanded,
        advancedChildBuilder: (context, trailingBuilder, onTap, _) => ListTile(
          onTap: onTap,
          title: title,
          subtitle: subtitle,
          visualDensity: visualDensity,
          dense: dense,
          isThreeLine: isThreeLine,
          leading: leading,
          trailing: trailing == null ? null : trailingBuilder(trailing!),
        ),
      );
}
