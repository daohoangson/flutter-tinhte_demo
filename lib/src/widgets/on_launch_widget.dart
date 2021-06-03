import 'package:flutter/material.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/link.dart';

class OnLaunchWidget extends StatefulWidget {
  final Widget defaultWidget;
  final Widget fallbackWidget;
  final String path;

  OnLaunchWidget(this.path, {this.defaultWidget, this.fallbackWidget, Key key})
      : assert(path != null),
        assert(fallbackWidget != null),
        super(key: key);

  @override
  State<OnLaunchWidget> createState() => _OnLaunchState();
}

class _OnLaunchState extends State<OnLaunchWidget> {
  var _cameBack = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // request builder in the next frame
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => _BuilderWidget(
            widget.path,
            defaultWidget: widget.defaultWidget,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      if (mounted) {
        setState(() => _cameBack = true);
      }
    });
  }

  @override
  Widget build(BuildContext _) {
    if (_cameBack) return widget.fallbackWidget;
    return SizedBox.shrink();
  }
}

class _BuilderWidget extends StatefulWidget {
  final Widget defaultWidget;
  final String path;

  _BuilderWidget(this.path, {this.defaultWidget, Key key})
      : assert(path != null),
        super(key: key);

  @override
  State<_BuilderWidget> createState() => _BuilderState();
}

class _BuilderState extends State<_BuilderWidget> {
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
      return null;
    }).then((widget) {
      if (widget == null && mounted) {
        // no widget could be built:
        // 1. Bad link
        // 2. API errors
        // -> go back to OnLaunchWidget, it will render the fallback widget
        Navigator.of(context).pop();
      }

      return widget;
    });
  }

  @override
  Widget build(BuildContext _) => FutureBuilder<Widget>(
        builder: (__, snapshot) {
          final widget = snapshot.data;
          if (widget == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return widget;
        },
        future: _future,
      );
}
