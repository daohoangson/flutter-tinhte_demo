import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tinhte_api/links.dart';

import '../api.dart';

class SuperListView<T> extends StatefulWidget {
  final bool enableRefreshIndicator;
  final bool enableScrollToIndex;
  final String fetchPathInitial;
  final _FetchOnSuccess<T> fetchOnSuccess;
  final Widget footer;
  final Widget header;
  final int infiniteScrollingVh;
  final Map initialJson;
  final Iterable<T> initialItems;
  final _ItemBuilder<T> itemBuilder;
  final _ItemListenerRegister<T> itemListenerRegisterAppend;
  final _ItemListenerRegister<T> itemListenerRegisterPrepend;
  final int itemMaxWidth;
  final _ItemStreamRegister<T> itemStreamRegisterAppend;
  final _ItemStreamRegister<T> itemStreamRegisterPrepend;

  SuperListView({
    this.enableRefreshIndicator,
    this.enableScrollToIndex = false,
    this.fetchPathInitial,
    this.fetchOnSuccess,
    this.footer,
    this.header,
    this.infiniteScrollingVh = 2,
    this.initialJson,
    this.initialItems,
    this.itemBuilder,
    this.itemListenerRegisterAppend,
    this.itemListenerRegisterPrepend,
    this.itemMaxWidth = 600,
    this.itemStreamRegisterAppend,
    this.itemStreamRegisterPrepend,
    Key key,
  })  : assert((fetchPathInitial != null) || (initialJson != null)),
        assert(fetchOnSuccess != null),
        assert(itemBuilder != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => SuperListState<T>();
}

class FetchContext<T> {
  final FetchContextId id;
  final String path;
  final SuperListState<T> state;

  String linksNext;
  int linksPage;
  int linksPages;
  String linksPrev;
  int scrollToRelativeIndex;

  List<T> _items;

  Iterable<T> get items => _items;

  FetchContext(
    this.state, {
    @required this.id,
    @required this.path,
  })  : assert(id != null),
        assert(path != null);

  void addItem(T item) {
    _items ??= [];
    _items.add(item);
  }
}

enum FetchContextId { FetchInitial, FetchNext, FetchPrev }

class SuperListItemFullWidth extends StatelessWidget {
  final Widget child;

  SuperListItemFullWidth({
    this.child,
    Key key,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => child;
}

class SuperListState<T> extends State<SuperListView<T>> {
  final List<T> _items = [];

  var _isFetching = false;
  String _fetchPathNext;
  String _fetchPathPrev;
  int _fetchedPageMax;
  int _fetchedPageMin;
  Map _initialJson;
  VoidCallback _itemListenerRegisteredAppend;
  VoidCallback _itemListenerRegisteredPrepend;
  StreamSubscription _itemStreamSubAppend;
  StreamSubscription _itemStreamSubPrepend;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  AutoScrollController _scrollController;

  bool get canFetchNext => _fetchPathNext != null;
  bool get canFetchPrev => _fetchPathPrev != null;
  int get fetchedPageMax => _fetchedPageMax;
  int get fetchedPageMin => _fetchedPageMin;
  bool get isFetching => _isFetching;
  int get itemCountAfter =>
      (canFetchNext ? 1 : 0) + (widget.footer != null ? 1 : 0);
  int get itemCountBefore =>
      (canFetchPrev ? 1 : 0) + (widget.header != null ? 1 : 0);
  Iterable<T> get items => _items;
  AutoScrollController get scrollController => _scrollController;

  @override
  void initState() {
    super.initState();

    _initialJson = widget.initialJson;

    if (widget.initialItems != null) _items.addAll(widget.initialItems);

    if (widget.itemStreamRegisterAppend != null) {
      _itemStreamSubAppend = widget.itemStreamRegisterAppend(itemsAppend);
    }
    if (widget.itemStreamRegisterPrepend != null) {
      _itemStreamSubPrepend = widget.itemStreamRegisterPrepend(itemsPrepend);
    }

    final enableRefreshIndicator =
        widget.enableRefreshIndicator ?? widget.fetchPathInitial != null;
    if (enableRefreshIndicator) {
      _refreshIndicatorKey = GlobalKey();
    }

    if (widget.enableScrollToIndex) _scrollController = AutoScrollController();

    fetchInitial(clearItems: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.itemListenerRegisterAppend != null) {
      if (_itemListenerRegisteredAppend != null)
        _itemListenerRegisteredAppend();
      _itemListenerRegisteredAppend =
          widget.itemListenerRegisterAppend(itemsAppend);
    }

    if (widget.itemListenerRegisterPrepend != null) {
      if (_itemListenerRegisteredPrepend != null)
        _itemListenerRegisteredPrepend();
      _itemListenerRegisteredPrepend =
          widget.itemListenerRegisterPrepend(itemsPrepend);
    }
  }

  @override
  void deactivate() {
    if (_itemListenerRegisteredAppend != null) {
      _itemListenerRegisteredAppend();
      _itemListenerRegisteredAppend = null;
    }

    if (_itemListenerRegisteredPrepend != null) {
      _itemListenerRegisteredPrepend();
      _itemListenerRegisteredPrepend = null;
    }

    super.deactivate();
  }

  @override
  void dispose() {
    _itemStreamSubAppend?.cancel();
    _itemStreamSubPrepend?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget built = ListView.builder(
      itemBuilder: (context, i) {
        Widget built = _buildItem(context, i) ?? Container();

        if (widget.itemMaxWidth != null && !(built is SuperListItemFullWidth)) {
          built = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: built,
            ),
          );
        }

        if (_scrollController != null) {
          built = AutoScrollTag(
            child: built,
            controller: _scrollController,
            index: i,
            key: ValueKey(i),
          );
        }

        return built;
      },
      itemCount: itemCountBefore + _items.length + itemCountAfter,
      controller: _scrollController,
      padding: const EdgeInsets.all(0),
    );

    if (_refreshIndicatorKey != null) {
      built = RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchInitial,
        child: built,
      );
    }

    if (widget.infiniteScrollingVh > 0) {
      built = NotificationListener<ScrollNotification>(
        child: built,
        onNotification: (scrollInfo) {
          if (_isFetching) return;
          if (_scrollController?.isAutoScrolling == true) return;
          if (!(scrollInfo is ScrollEndNotification)) return;

          final m = scrollInfo.metrics;
          final lookAhead = widget.infiniteScrollingVh * m.viewportDimension;
          if (m.pixels < m.maxScrollExtent - lookAhead) return;

          if (canFetchNext)
            fetchNext().then((_) => Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Auto fetched page number $fetchedPageMax."),
                )));
        },
      );
    }

    return built;
  }

  Future<void> fetchInitial({bool clearItems = true}) => _fetch(
        FetchContext(
          this,
          id: FetchContextId.FetchInitial,
          path: widget.fetchPathInitial,
        ),
        onPreFetch: () {
          if (clearItems) _items.clear();
          _fetchPathNext = null;
          _fetchPathPrev = null;
          _fetchedPageMax = null;
          _fetchedPageMin = null;
          _initialJson = null;
        },
        preFetchedJson: _initialJson,
      );

  Future<void> fetchNext({int scrollToRelativeIndex}) => _fetch(
        FetchContext(
          this,
          id: FetchContextId.FetchNext,
          path: _fetchPathNext,
        )..scrollToRelativeIndex = scrollToRelativeIndex,
        onPreFetch: () => _fetchPathNext = null,
      );

  Future<void> fetchPrev() => _fetch(
        FetchContext(
          this,
          id: FetchContextId.FetchPrev,
          path: _fetchPathPrev,
        ),
        onPreFetch: () => _fetchPathPrev = null,
      );

  void itemsAppend(T item) {
    if (!mounted) return;
    setState(() => _items.add(item));
  }

  void itemsPrepend(T item) {
    if (!mounted) return;
    setState(() => _items.insert(0, item));
  }

  Widget _buildItem(BuildContext context, int i) {
    if (canFetchPrev) {
      if (i == 0) return _buildProgressIndicator(_isFetching);
      i--;
    }

    if (widget.header != null) {
      if (i == 0) return widget.header;
      i--;
    }

    if (i < _items.length) return widget.itemBuilder(context, this, _items[i]);
    i -= _items.length;

    if (widget.footer != null) {
      if (i == 0) return widget.footer;
      i--;
    }

    if (i == 0) return _buildProgressIndicator(_isFetching);

    return Container(width: 0, height: 0);
  }

  Widget _buildProgressIndicator(bool visible) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: visible ? const CircularProgressIndicator() : Container(),
        ),
      );

  Future<void> _fetch(
    FetchContext<T> fc, {
    VoidCallback onPreFetch,
    Map preFetchedJson,
  }) {
    if (_isFetching || !mounted) return Future.value();

    if (onPreFetch != null) onPreFetch();
    setState(() => _isFetching = true);

    if (preFetchedJson != null) {
      _fetchOnSuccess(preFetchedJson, fc);
      _fetchOnComplete(fc);
      return Future.value();
    }

    final c = Completer();
    apiGet(
      this,
      fc.path,
      onSuccess: (json) => _fetchOnSuccess(json, fc),
      onComplete: () {
        _fetchOnComplete(fc);
        c.complete();
      },
    );

    return c.future;
  }

  void _fetchOnSuccess(Map json, FetchContext<T> fc) {
    if (json.containsKey('links')) {
      final links = Links.fromJson(json['links']);
      fc.linksNext = links.next;
      fc.linksPage = links.page;
      fc.linksPages = links.pages;
      fc.linksPrev = links.prev;
    }

    return widget.fetchOnSuccess(json, fc);
  }

  void _fetchOnComplete(FetchContext<T> fc) => setState(() {
        _isFetching = false;

        _fetchPathNext = fc.linksNext;
        _fetchPathPrev = fc.linksPrev;
        final linksPage = fc.linksPage ?? 1;
        if (_fetchedPageMin == null || _fetchedPageMin > linksPage) {
          _fetchedPageMin = linksPage;
        }
        if (_fetchedPageMax == null || _fetchedPageMax < linksPage) {
          _fetchedPageMax = linksPage;
        }

        final itemsLengthBefore = _items.length;
        if (fc._items != null) {
          if (fc.id == FetchContextId.FetchPrev) {
            _items.insertAll(0, fc._items);
          } else {
            _items.addAll(fc._items);
          }
        }

        if (_scrollController != null && fc.scrollToRelativeIndex != null) {
          var scrollToIndex = itemCountBefore + fc.scrollToRelativeIndex;
          if (fc.id != FetchContextId.FetchPrev) {
            scrollToIndex += itemsLengthBefore;
          }
          _scrollController.scrollToIndex(
            scrollToIndex,
            preferPosition: AutoScrollPosition.begin,
          );
        }
      });
}

typedef void _FetchOnSuccess<T>(Map json, FetchContext<T> fetchContext);
typedef Widget _ItemBuilder<T>(
  BuildContext context,
  SuperListState<T> state,
  T item,
);
typedef void _ItemListener<T>(T item);
typedef VoidCallback _ItemListenerRegister<T>(_ItemListener<T> listener);
typedef StreamSubscription _ItemStreamRegister<T>(_ItemListener<T> listener);
