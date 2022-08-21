import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:the_app/src/intl.dart';

import 'dev_tools.dart';

class PackageInfoWidget extends StatefulWidget {
  const PackageInfoWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PackageInfoState();
}

class _PackageInfoState extends State<PackageInfoWidget> {
  PackageInfo? _info;
  var count = 0;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) => setState(() => _info = info));
  }

  @override
  Widget build(BuildContext context) {
    final devTools = context.watch<DevTools>();
    final scopedInfo = _info;
    return ListTile(
      title: Text(l(context).appVersion),
      subtitle: Text(scopedInfo != null
          ? l(context)
              .appVersionInfo(scopedInfo.version, scopedInfo.buildNumber)
          : l(context).appVersionNotAvailable),
      onTap: devTools.isDeveloper
          ? null
          : () {
              if (++count >= 3) {
                devTools.isDeveloper = true;
              }
            },
    );
  }
}
