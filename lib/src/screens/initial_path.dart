import 'package:flutter/material.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/link.dart';
import 'package:the_app/src/screens/home.dart';

class InitialPathScreen extends StatefulWidget {
  final Widget? defaultWidget;
  final String? fallbackLink;
  final String path;

  const InitialPathScreen(this.path,
      {this.defaultWidget, this.fallbackLink, Key? key})
      : super(key: key);

  @override
  State<InitialPathScreen> createState() => _InitialPathState();
}

class _InitialPathState extends State<InitialPathScreen>
    with WidgetsBindingObserver {
  late final Future<Widget> _future;
  var _home = _ShouldRender.no;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = buildWidget(
      ApiCaller.stateful(this),
      widget.path,
      defaultWidget: widget.defaultWidget,
    ).catchError((error) async {
      await showApiErrorDialog(context, error);
    }).then((built) {
      if (built != null) return built;

      if (mounted) {
        _home = _ShouldRender.onResume;
        launchLink(
          context,
          widget.fallbackLink ?? widget.path,
          forceWebView: true,
        );
      }

      return const Scaffold(body: Center(child: Text('⚡️')));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _home == _ShouldRender.onResume) {
      setState(() => _home = _ShouldRender.yes);
    }
  }

  @override
  Widget build(BuildContext context) => _home == _ShouldRender.yes
      ? HomeScreen()
      : FutureBuilder<Widget>(
          builder: (__, snapshot) =>
              snapshot.data ??
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          future: _future,
        );
}

enum _ShouldRender { no, onResume, yes }
