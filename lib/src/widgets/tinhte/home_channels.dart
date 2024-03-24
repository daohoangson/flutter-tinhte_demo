import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_app/src/screens/content_list_view.dart';
import 'package:the_app/src/widgets/home/header.dart';
import 'package:url_launcher/url_launcher.dart';

class ChannelsWidget extends StatelessWidget {
  const ChannelsWidget({super.key});

  @override
  Widget build(BuildContext context) => Card(
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
    required BuildContext context,
    IconData? icon,
    required String label,
    GestureTapCallback? onTap,
  }) {
    final style = Theme.of(context).textTheme.bodySmall;
    final fontSize = style?.fontSize;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: fontSize != null ? fontSize * 2.5 : null),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: style,
            ),
          ],
        ),
      ),
    );
  }

  _buildContentListViewButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int listId,
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
          onTap: () => launchUrl(
            Uri.parse(
                'https://www.youtube.com/channel/UCyQobySFx_h9oFwsBV0KGdg'),
          ),
        ),
        _buildContentListViewButton(
          context: context,
          icon: FontAwesomeIcons.volumeHigh,
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
          onTap: () => launchUrl(Uri.parse('https://nhattao.com')),
        ),
      ];

  Widget _buildHeader() => const HeaderWidget('Các kênh của Tinh tế');
}
