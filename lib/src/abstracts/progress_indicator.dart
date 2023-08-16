import 'package:flutter/material.dart';

@visibleForTesting
var debugDeterministic = false;

class AdaptiveProgressIndicator extends StatelessWidget {
  final double? value;

  const AdaptiveProgressIndicator({super.key, this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: debugDeterministic
          ? const Text('Loading...')
          : CircularProgressIndicator.adaptive(value: value),
    );
  }
}
