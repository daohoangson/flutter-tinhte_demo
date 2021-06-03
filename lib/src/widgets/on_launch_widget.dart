import 'package:flutter/material.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/link.dart';

class OnLaunchWidget extends StatefulWidget {
  final Widget defaultWidget;
  final Widget fallbackWidget;
  final String path;

  OnLaunchWidget(this.path, {this.defaultWidget, this.fallbackWidget, Key key})
      : assert(path != null),
        assert(defaultWidget != null),
        assert(fallbackWidget != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _OnLaunchState();
}

class _OnLaunchState extends State<OnLaunchWidget> {
  var _fallback = false;
  Future<Widget> _future;

  @override
  void initState() {
    super.initState();

    _future = buildWidget(
      ApiCaller.stateful(this),
      widget.path,
      defaultWidget: widget.defaultWidget,
    ).catchError((error) async {
      await showApiErrorDialog(context, error);
      setState(() => _fallback = true);
    });
  }

  @override
  Widget build(BuildContext _) => _fallback
      ? widget.fallbackWidget
      : FutureBuilder<Widget>(
          builder: (__, snapshot) => snapshot.hasData
              ? snapshot.data
              : const Center(child: CircularProgressIndicator()),
          future: _future,
        );
}
