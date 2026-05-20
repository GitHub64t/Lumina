import 'package:flutter/material.dart';

import '../../../../shared/widgets/responsive_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 18),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search articles',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
