import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../../widgets/tag/widget.dart';

class FpSearchDelegate extends SearchDelegate {
  final List<FeaturePage> pages;

  FpSearchDelegate(this.pages);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: BackButtonIcon(),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildResults(_filterItems());

  @override
  Widget buildSuggestions(BuildContext context) =>
      _buildResults(_filterItems());

  Widget _buildResults(List<FeaturePage> items) => Padding(
        child: LayoutBuilder(
          builder: (_, bc) => GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: FpWidget.kPreferAspectRatio,
                  crossAxisCount: (bc.maxWidth / FpWidget.kPreferWidth).ceil(),
                ),
                itemBuilder: (_, i) => FpWidget(items[i]),
                itemCount: items.length,
                scrollDirection: Axis.vertical,
              ),
        ),
        padding: const EdgeInsets.all(2),
      );

  List<FeaturePage> _filterItems() => query.isEmpty
      ? pages
      : pages
          .where((p) => p.fullName.toLowerCase().contains(query.toLowerCase()))
          .toList();
}
