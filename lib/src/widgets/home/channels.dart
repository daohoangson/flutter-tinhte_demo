import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../screens/content_list_view.dart';
import 'header.dart';

class ChannelsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HeaderWidget('Các kênh của Tinh tế'),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildContentListViewButton(
                    context: context,
                    icon: FontAwesomeIcons.volumeUp,
                    label: 'Audio',
                    listId: 9,
                  ),
                ),
                Expanded(
                  child: _buildContentListViewButton(
                    context: context,
                    icon: FontAwesomeIcons.cameraRetro,
                    label: 'Camera',
                    listId: 6,
                  ),
                ),
                Expanded(
                  child: _buildContentListViewButton(
                    context: context,
                    icon: FontAwesomeIcons.car,
                    label: 'Xe',
                    listId: 5,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  _buildContentListViewButton({
    BuildContext context,
    IconData icon,
    String label,
    int listId,
  }) {
    final style = Theme.of(context).textTheme.caption;

    return InkWell(
      child: Padding(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: style.fontSize * 2.5),
            ),
            Text(label, style: style),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ContentListViewScreen(
                listId: listId,
                title: label,
              ))),
    );
  }
}
