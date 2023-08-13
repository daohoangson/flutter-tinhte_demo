import 'package:flutter/material.dart';
import 'package:the_api/feature_page.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/tag/widget.dart';

class FpSearchDelegate extends SearchDelegate {
  final List<FeaturePage> pages;

  FpSearchDelegate(this.pages);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
          tooltip: lm(context).cancelButtonLabel,
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const BackButtonIcon(),
        onPressed: () => close(context, null),
        tooltip: lm(context).backButtonTooltip,
      );

  @override
  Widget buildResults(BuildContext context) => _buildResults(_filterItems());

  @override
  Widget buildSuggestions(BuildContext context) =>
      _buildResults(_filterItems());

  Widget _buildResults(List<FeaturePage> items) => Padding(
        padding: const EdgeInsets.all(kTagWidgetPadding),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: FpWidget.kPreferAspectRatio,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
            maxCrossAxisExtent: FpWidget.kPreferWidth,
          ),
          itemBuilder: (_, i) => FpWidget(items[i]),
          itemCount: items.length,
          scrollDirection: Axis.vertical,
        ),
      );

  List<FeaturePage> _filterItems() => query.isEmpty
      ? pages
      : pages
          .where(
            (p) =>
                p.fullName?.toLowerCase().contains(query.toLowerCase()) == true,
          )
          .toList();
}
