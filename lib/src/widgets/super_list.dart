import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tinhte_api/links.dart';
import 'package:the_app/src/api.dart';

class SuperListView<T> extends StatefulWidget {
  final ApiMethod apiMethodInitial;
  final List<SuperListComplexItemRegister> complexItems;
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
  final double itemMaxWidth;
  final bool progressIndicator;
  final bool shrinkWrap;

  SuperListView({
    this.apiMethodInitial,
    this.complexItems,
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
  final items = <T>[];
  final String path;
  final SuperListState<T> state;

  String linksNext;
  int linksPage;
  int linksPages;
  String linksPrev;
  int scrollToRelativeIndex;

  FetchContext({
    this.apiMethod,
    this.id = FetchContextId.FetchCustom,
    this.path,
    @required this.state,
  })  : assert(state != null);
}

enum FetchContextId { FetchCustom, FetchInitial, FetchNext, FetchPrev }

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
  final List<SuperListComplexItemRegistration> _complexItems = [];
  final List<T> _items = [];

  var _isFetching = false;
  var _isRefreshing = false;
  String _fetchPathNext;
  String _fetchPathPrev;
  int _fetchedPageMax;
  int _fetchedPageMin;
  Map _initialJson;
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

    final enableRefreshIndicator =
        widget.enableRefreshIndicator ?? widget.fetchPathInitial != null;
    if (enableRefreshIndicator) {
      _refreshIndicatorKey = GlobalKey();
    }

    if (widget.enableScrollToIndex) _scrollController = AutoScrollController();

    widget.complexItems?.forEach((register) {
      final registration = register();
      if (registration != null) _complexItems.add(registration);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => fetch());
  }

  @override
  Widget build(BuildContext context) {
    Widget built = ListView.builder(
      itemBuilder: (context, i) {
        Widget built = _buildItem(context, i) ?? Container();

        if (widget.itemMaxWidth != null && !(built is SuperListItemFullWidth)) {
          built = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.itemMaxWidth),
              child: built,
            ),
          );
        }

        if (_scrollController != null) {
          built = AutoScrollTag(
            child: built,
            controller: _scrollController,
            highlightColor: Theme.of(context).accentColor.withOpacity(.1),
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
        onRefresh: _onRefresh,
        child: built,
      );
    }

    if (widget.infiniteScrollingVh > 0) {
      built = NotificationListener<ScrollNotification>(
        child: built,
        onNotification: (scrollInfo) {
          if (_isFetching) return false;
          if (_scrollController?.isAutoScrolling == true) return false;
          if (!(scrollInfo is UserScrollNotification)) return false;

          final m = scrollInfo.metrics;
          if (m.axisDirection != AxisDirection.down) return false;

          final lookAhead = widget.infiniteScrollingVh * m.viewportDimension;
          if (m.pixels < m.maxScrollExtent - lookAhead) return false;

          if (canFetchNext) fetchNext();
          return false;
        },
      );
    }

    built = MultiProvider(
      child: built,
      providers: _complexItems.map((r) => r._provider).toList()
        ..add(Provider<SuperListState<T>>.value(value: this)),
    );

    return built;
  }

  Future<void> fetch({
    bool clearItems = false,
    FetchContext fc,
  }) =>
      _fetch(
        fc ??
            FetchContext(
              apiMethod: widget.apiMethodInitial,
              id: FetchContextId.FetchInitial,
              path: widget.fetchPathInitial,
              state: this,
            ),
        onPreFetch: () {
          if (clearItems) _items.clear();
          _fetchPathNext = null;
          _fetchPathPrev = null;
          _fetchedPageMax = null;
          _fetchedPageMin = null;
          _initialJson = null;

          _complexItems.forEach((r) => r._clear != null ? r._clear() : null);
        },
        preFetchedJson: _initialJson,
      );

  Future<void> fetchNext({int scrollToRelativeIndex}) => _fetch(
        FetchContext(
          id: FetchContextId.FetchNext,
          path: _fetchPathNext,
          state: this,
        )..scrollToRelativeIndex = scrollToRelativeIndex,
        onPreFetch: () => _fetchPathNext = null,
      );

  Future<void> fetchPrev() => _fetch(
        FetchContext(
          id: FetchContextId.FetchPrev,
          path: _fetchPathPrev,
          state: this,
        ),
        onPreFetch: () => _fetchPathPrev = null,
      );

  int indexOf(T item) => _items.indexOf(item);

  void itemsAdd(T item) {
    if (!mounted) {
      _items.add(item);
      return;
    }

    setState(() {
      final index = _items.length;
      _items.add(item);

      scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
    });
  }

  void itemsInsert(int index, T item) {
    if (!mounted) {
      _items.insert(index, item);
      return;
    }

    setState(() {
      _items.insert(index, item);
      scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
    });
  }

  void itemsReplace(int index, Iterable<T> items) {
    if (!mounted) {
      _items.removeAt(index);
      if (items != null) _items.insertAll(index, items);
      return;
    }

    setState(() {
      _items.removeAt(index);
      if (items != null) _items.insertAll(index, items);
    });
  }

  void scrollToIndex(int index,
      {Duration duration: scrollAnimationDuration,
      AutoScrollPosition preferPosition}) {
    if (_scrollController == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final i = itemCountBefore + index;
      final d = duration;
      final p = preferPosition;
      await _scrollController.scrollToIndex(i, duration: d, preferPosition: p);
      _scrollController.highlight(i);
    });
  }

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
      widget.progressIndicator != false && !_isRefreshing && visible
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
      ApiCaller.stateful(this),
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

        final linksPage = fc.linksPage ?? 1;
        if (_fetchedPageMin == null || _fetchedPageMin > linksPage) {
          _fetchedPageMin = linksPage;
          _fetchPathPrev = fc.linksPrev;
        }
        if (_fetchedPageMax == null || _fetchedPageMax < linksPage) {
          _fetchedPageMax = linksPage;
          _fetchPathNext = fc.linksNext;
        }

        final itemsLengthBefore = _items.length;
        if (fc.items.isNotEmpty) {
          if (fc.id == FetchContextId.FetchPrev) {
            _items.insertAll(0, fc.items);
          } else {
            _items.addAll(fc.items);
          }
        }

        if (fc.scrollToRelativeIndex != null) {
          scrollToIndex(
            (fc.id != FetchContextId.FetchPrev ? itemsLengthBefore : 0) +
                fc.scrollToRelativeIndex,
            preferPosition: AutoScrollPosition.begin,
          );
        }
      });

  Future<void> _onRefresh() {
    if (_isRefreshing) return Future.value();
    _isRefreshing = true;
    return fetch(clearItems: true).whenComplete(() => _isRefreshing = false);
  }
}

typedef void _FetchOnSuccess<T>(Map json, FetchContext<T> fetchContext);
typedef Widget _ItemBuilder<T>(
  BuildContext context,
  SuperListState<T> state,
  T item,
);

typedef SuperListComplexItemRegistration SuperListComplexItemRegister();
typedef void SuperListComplexItemClearer();

class SuperListComplexItemRegistration {
  InheritedProvider _provider;
  SuperListComplexItemClearer _clear;

  SuperListComplexItemRegistration(
    InheritedProvider provider, {
    SuperListComplexItemClearer clear,
  })  : assert(provider != null),
        _provider = provider,
        _clear = clear;
}
