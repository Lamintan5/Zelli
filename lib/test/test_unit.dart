import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomSheetWithSlidingItems extends StatefulWidget {
  @override
  _BottomSheetWithSlidingItemsState createState() =>
      _BottomSheetWithSlidingItemsState();
}

class _BottomSheetWithSlidingItemsState
    extends State<BottomSheetWithSlidingItems> {
  // Function to show the Cupertino Bottom Sheet
  void _showCupertinoBottomSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => SizedBox(
        height: 400, // Adjust height based on your design
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Menu'),
          ),
          child: Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return CupertinoPageRoute(
                builder: (context) => BottomSheetContent(),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Cupertino Bottom Sheet Example'),
      ),
      child: Center(
        child: CupertinoButton(
          onPressed: () => _showCupertinoBottomSheet(context),
          child: Text('Show Bottom Sheet'),
        ),
      ),
    );
  }
}

// The initial content of the bottom sheet
class BottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CupertinoButton(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ItemDetailScreen(
                  title: 'Item 1',
                  description: 'Details of Item 1',
                ),
              ),
            );
          },
          child: Row(
            children: [
              Icon(CupertinoIcons.star),
              SizedBox(width: 10),
              Text('Item 1'),
            ],
          ),
        ),
        CupertinoButton(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ItemDetailScreen(
                  title: 'Item 2',
                  description: 'Details of Item 2',
                ),
              ),
            );
          },
          child: Row(
            children: [
              Icon(CupertinoIcons.heart),
              SizedBox(width: 10),
              Text('Item 2'),
            ],
          ),
        ),
        // Add more items similarly
      ],
    );
  }
}

// The screen that shows detailed content of the clicked item
class ItemDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  ItemDetailScreen({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        previousPageTitle: 'Back',
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(description),
        ),
      ),
    );
  }
}

void main() {
  runApp(CupertinoApp(home: BottomSheetWithSlidingItems()));
}
