import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:the_app/src/intl.dart';

import 'dev_tools.dart';

class PackageInfoWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PackageInfoState();
}

class _PackageInfoState extends State<PackageInfoWidget> {
  PackageInfo _info;
  var count = 0;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) => setState(() => _info = info));
  }

  @override
  Widget build(BuildContext context) {
    final devTools = context.watch<DevTools>();
    return ListTile(
      title: Text(l(context).appVersion),
      subtitle: Text(_info != null
          ? l(context).appVersionInfo(_info.version, _info.buildNumber)
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
