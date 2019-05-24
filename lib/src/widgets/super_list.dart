import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tinhte_api/links.dart';

import '../api.dart';

class SuperListView<T> extends StatefulWidget {
  final ApiMethod apiMethodInitial;
  final bool enableRefreshIndicator;
  final bool enableScrollToIndex;
  final String fetchPathInitial;
  final _FetchOnSuccess<T> fetchOnSuccess;
  final Widget footer;
  final Widget header;
  final double infiniteScrollingVh;
  final Map initialJson;
  final Iterable<T> initialItems;
  final _ItemBuilder<T> itemBuilder;
  final int itemMaxWidth;
  final _ItemStreamRegister<T> itemStreamRegister;
  final bool progressIndicator;
  final bool shrinkWrap;

  SuperListView({
    this.apiMethodInitial,
    this.enableRefreshIndicator,
    this.enableScrollToIndex = false,
    this.fetchPathInitial,
    this.fetchOnSuccess,
    this.footer,
    this.header,
    this.infiniteScrollingVh = 1.5,
    this.initialJson,
    this.initialItems,
    this.itemBuilder,
    this.itemMaxWidth = 600,
    this.itemStreamRegister,
    Key key,
    this.progressIndicator,
    this.shrinkWrap,
  })  : assert((fetchPathInitial != null) || (initialJson != null)),
        assert(fetchOnSuccess != null),
        assert(itemBuilder != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => SuperListState<T>();
}

class FetchContext<T> {
  final ApiMethod apiMethod;
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
    this.apiMethod,
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
  StreamSubscription _itemStreamSub;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  AutoScrollController _scrollController;

  bool get canFetchNext => _fetchPathNext != null;
  bool get canFetchPrev => _fetchPathPrev != null;
  int get fetchedPageMax => _fetchedPageMax;
  int get fetchedPageMin => _fetchedPageMin;
  bool get isFetching => _isFetching;
  int get itemCountAfter => (widget.footer != null ? 1 : 0) + 1;
  int get itemCountBefore => 1 + (widget.header != null ? 1 : 0);
  Iterable<T> get items => _items;

  @override
  void initState() {
    super.initState();

    _initialJson = widget.initialJson;

    if (widget.initialItems != null) _items.addAll(widget.initialItems);

    if (widget.itemStreamRegister != null) {
      _itemStreamSub = widget.itemStreamRegister(this);
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
  void dispose() {
    _itemStreamSub?.cancel();
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
      shrinkWrap: widget.shrinkWrap == true,
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
          if (!(scrollInfo is UserScrollNotification)) return;

          final m = scrollInfo.metrics;
          if (m.axisDirection != AxisDirection.down) return;

          final lookAhead = widget.infiniteScrollingVh * m.viewportDimension;
          if (m.pixels < m.maxScrollExtent - lookAhead) return;

          if (canFetchNext) fetchNext();
        },
      );
    }

    return built;
  }

  Future<void> fetchInitial({bool clearItems = true}) => _fetch(
        FetchContext(
          this,
          apiMethod: widget.apiMethodInitial,
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

  void itemsAdd(T item) {
    if (!mounted) {
      _items.add(item);
      return;
    }

    setState(() {
      final index = _items.length;
      _items.add(item);

      WidgetsBinding.instance.addPostFrameCallback(
        (_) => scrollToIndex(index, preferPosition: AutoScrollPosition.begin),
      );
    });
  }

  void itemsInsert(int index, T item) {
    if (!mounted) {
      _items.insert(index, item);
      return;
    }

    setState(() {
      _items.insert(index, item);

      WidgetsBinding.instance.addPostFrameCallback(
        (_) => scrollToIndex(index, preferPosition: AutoScrollPosition.begin),
      );
    });
  }

  void jumpTo(double value) => _scrollController?.jumpTo(value);

  Future scrollToIndex(int index,
          {Duration duration: scrollAnimationDuration,
          AutoScrollPosition preferPosition}) =>
      _scrollController?.scrollToIndex(
        itemCountBefore + index,
        duration: duration,
        preferPosition: preferPosition,
      );

  Widget _buildItem(BuildContext context, int i) {
    if (i == 0) return _buildProgressIndicator(canFetchPrev && _isFetching);
    i--;

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

    return _buildProgressIndicator(_isFetching);
  }

  Widget _buildProgressIndicator(bool visible) =>
      widget.progressIndicator != false && visible
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Center(child: CircularProgressIndicator()),
            )
          : SizedBox.shrink();

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
    final apiMethod = fc.apiMethod ?? apiGet;
    apiMethod(
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
typedef StreamSubscription _ItemStreamRegister<T>(SuperListState<T> state);