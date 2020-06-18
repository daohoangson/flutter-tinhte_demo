import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinhte_demo/src/screens/content_list_view.dart';
import 'package:tinhte_demo/src/widgets/home/header.dart';
import 'package:url_launcher/url_launcher.dart';

class ChannelsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext _) => Card(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: LayoutBuilder(
          builder: (context, bc) => bc.maxWidth < 600
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeader(),
                    Row(
                      children: _buildContentListViewButtons(context)
                          .map((w) => Expanded(child: w))
                          .toList(),
                    ),
                  ],
                )
              : Row(
                  children: _buildContentListViewButtons(context)
                    ..insert(0, Expanded(child: _buildHeader()))
                    ..add(Expanded(child: Container())),
                ),
        ),
      );

  _buildButton({
    BuildContext context,
    IconData icon,
    String label,
    GestureTapCallback onTap,
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
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: style,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      ),
      onTap: onTap,
    );
  }

  _buildContentListViewButton({
    BuildContext context,
    IconData icon,
    String label,
    int listId,
  }) =>
      _buildButton(
        context: context,
        icon: icon,
        label: label,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ContentListViewScreen(
                  listId: listId,
                  title: label,
                ))),
      );

  List<Widget> _buildContentListViewButtons(BuildContext context) => [
        _buildButton(
          context: context,
          icon: FontAwesomeIcons.youtube,
          label: 'Video',
          onTap: () => launch(
                'https://www.youtube.com/channel/UCyQobySFx_h9oFwsBV0KGdg',
              ),
        ),
        _buildContentListViewButton(
          context: context,
          icon: FontAwesomeIcons.volumeUp,
          label: 'Audio',
          listId: 9,
        ),
        _buildContentListViewButton(
          context: context,
          icon: FontAwesomeIcons.cameraRetro,
          label: 'Camera',
          listId: 6,
        ),
        _buildContentListViewButton(
          context: context,
          icon: FontAwesomeIcons.car,
          label: 'Xe',
          listId: 5,
        ),
        _buildButton(
          context: context,
          icon: FontAwesomeIcons.dollarSign,
          label: 'Nhật tảo',
          onTap: () => launch('https://nhattao.com'),
        ),
      ];

  Widget _buildHeader() => HeaderWidget('Các kênh của Tinh tế');
}
