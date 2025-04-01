import 'package:flutter/material.dart';
import 'package:expand/expand.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Expandable Widgets Example')),
        body: ExpandableProvider(
          child: ListView(
            children: [
              ExpandableTile(
                title: const Text('Tile 1'),
                detailsBuilder: (context) =>
                    Container(height: 200, color: Colors.red),
              ),
              ExpandableTile(
                title: const Text('Tile 2'),
                detailsBuilder: (context) =>
                    Container(height: 200, color: Colors.green),
              ),
              ExpandableTile(
                id: 'tile3',
                title: const Text('Tile 3'),
                trailing: const Icon(Icons.arrow_drop_down),
                detailsBuilder: (context) =>
                    Container(height: 200, color: Colors.blue),
              ),
              ExpandableCard(
                childBuilder: (context, _) => AspectRatio(
                  aspectRatio: 2,
                  child: Ink.image(
                    image: const NetworkImage('https://picsum.photos/400/200'),
                    fit: BoxFit.cover,
                  ),
                ),
                detailsBuilder: (context) => Column(
                  children: [
                    Container(height: 200, color: Colors.pink),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilledButton(
                        onPressed: () {
                          ExpandableProvider.of(context).open('tile3');
                        },
                        child: const Text('Open tile 3'),
                      ),
                    ),
                  ],
                ),
              ),
              ExpandableCard(
                advancedChildBuilder:
                    (context, trailingBuilder, onTap, animation, expanded) {
                  final listTile = ListTile(
                    title: const Text('Advanced Tile 4'),
                    trailing: Opacity(
                      // Use the animation to fade the trailing icon
                      // when the tile is expanded
                      opacity: 1 - (animation?.value ?? 0),
                      child: IconButton(
                        onPressed: () {
                          // This click works because the list tile is not wrapped
                          // in a IgnorePointer as is the case with the ExpandableTile
                        },
                        icon: Icon(Icons.abc),
                      ),
                    ),
                    onTap: expanded ? null : onTap,
                  );

                  if (expanded) return IgnorePointer(child: listTile);
                  return listTile;
                },
                detailsBuilder: (context) => Container(
                  height: 200,
                  color: Colors.yellow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
