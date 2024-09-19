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
            ],
          ),
        ),
      ),
    );
  }
}
