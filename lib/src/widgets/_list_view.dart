import 'package:flutter/material.dart';

Widget buildProgressIndicator(bool isFetching) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isFetching ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
