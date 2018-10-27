import 'package:flutter/material.dart';
import 'package:tinhte_api/links.dart';

class PageNav extends StatelessWidget {
  final Links links;
  final PageNavCallback callback;

  PageNav(this.links, {@required this.callback, Key key})
      : assert(links != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: links.prev?.isNotEmpty == true
                  ? FlatButton(
                      child: Text(
                        'Previous',
                        textAlign: TextAlign.left,
                      ),
                      onPressed: () => _triggerCallback(-1, links.prev),
                    )
                  : Container(),
            ),
            Expanded(
              child: FlatButton(
                child: Text(
                  "Page ${links.page}",
                  textAlign: TextAlign.center,
                ),
                onPressed: null,
              ),
            ),
            Expanded(
              child: links.next?.isNotEmpty == true
                  ? FlatButton(
                      child: Text(
                        'Next',
                        textAlign: TextAlign.right,
                      ),
                      onPressed: () => _triggerCallback(1, links.next),
                    )
                  : Container(),
            ),
          ],
        ),
      );

  _triggerCallback(int delta, String url) {
    if (callback == null) return;

    callback(links.page + delta, url);
  }
}

typedef void PageNavCallback(int page, String url);
