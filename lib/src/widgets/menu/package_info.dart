import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';

import 'dev_tools.dart';

class PackageInfoWidget extends StatefulWidget {
  const PackageInfoWidget({super.key});

  @override
  State<StatefulWidget> createState() => _PackageInfoState();
}

class _PackageInfoState extends State<PackageInfoWidget> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) => _info = info);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(l(context).appVersion),
      onTap: () => _showAboutDialog(context),
    );
  }

  void _showAboutDialog(BuildContext context) {
    var count = 0;
    final info = _info;
    showAboutDialog(
      context: context,
      children: [
        InkWell(
          onTap: () {
            final newCount = ++count;
            if (newCount >= 3) {
              // starting from the the third tap
              // each one will toggle developer menu on or off
              context.read<DevTools>().isDeveloper = (newCount % 2) > 0;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Text(info != null
                ? l(context).appVersionInfo(info.version, info.buildNumber)
                : l(context).appVersionNotAvailable),
          ),
        ),
      ],
    );
  }
}
