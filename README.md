# Expand

<div align="center">

  [![GitHub stars][github_stars_badge]][github_stars_link]
  [![Package: expand][package_badge]][package_link]
  [![Language: Dart][language_badge]][language_link]
  [![License: MIT][license_badge]][license_link]

</div>

[github_stars_badge]: https://img.shields.io/github/stars/2-5-perceivers/expand?style=flat&color=yellow
[github_stars_link]: https://github.com/2-5-perceivers/expand/stargazers
[package_badge]: https://img.shields.io/pub/v/expand?color=green
[package_link]: https://pub.dev/packages/expand
[language_badge]: https://img.shields.io/badge/language-Dart-blue
[language_link]: https://dart.dev
[license_badge]: https://img.shields.io/github/license/2-5-perceivers/expand
[license_link]: https://opensource.org/licenses/MIT

**expand** is a Flutter package designed to help creating sleek, fast and simple expandable widgets, using minimum code.

![Demo Gif](https://github.com/2-5-perceivers/expand/blob/master/images/demo.gif?raw=true)

## Installation

To use this package, add master_detail_flow as a dependency using:
```
flutter pub add expand
```

## Getting started

Wrap any list of expandable widgets in a ExpandableProvider, and you are done.

## Usage

Here is a basic example of how to use `ExpandableTile`:

```dart
ExpandableProvider(
child: ListView(
  children: [
    ExpandableTile(
      title: const Text('Tile 1'),
      detailsBuilder: (context) => Container(height: 200),
    ),
    ExpandableTile(
      title: const Text('Tile 2'),
      detailsBuilder: (context) => Container(height: 200),
    ),
  ],
),
),
```

The use of ExpandableProvider can be skipped using an `ExpandableController` that can be provided manually.

### Key components
* `ExpandableProvider` + `ExpandableController`: the state providers for expansion cards
* `ExpandableCard`: The base of all expandable widgets
* `ExpandableTile`: An ListTile with expandable details

For further details, visit the [documentation](https://pub.dev/documentation/expand/latest/).