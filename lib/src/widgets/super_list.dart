import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:the_api/links.dart';
import 'package:the_app/src/abstracts/progress_indicator.dart';
import 'package:the_app/src/api.dart';

class SuperListView<T> extends StatefulWidget {
  final ApiMethod? apiMethodInitial;
  final List<SuperListComplexItemRegister>? complexItems;
  final bool? enableRefreshIndicator;
  final bool enableScrollToIndex;
  final String? fetchPathInitial;
  final FetchOnSuccess<T> fetchOnSuccess;
  final Widget? footer;
  final Widget? header;
  final double infiniteScrollingVh;
  final Map? initialJson;
  final Iterable<T>? initialItems;
  final ItemBuilder<T> itemBuilder;
  final double itemMaxWidth;
  final bool? progressIndicator;
  final bool? shrinkWrap;

  const SuperListView({
    this.apiMethodInitial,
    this.complexItems,
    this.enableRefreshIndicator,
    this.enableScrollToIndex = false,
    this.fetchPathInitial,
    required this.fetchOnSuccess,
    this.footer,
    this.header,
    this.infiniteScrollingVh = 1.5,
    this.initialJson,
    this.initialItems,
    required this.itemBuilder,
    this.itemMaxWidth = 600,
    super.key,
    this.progressIndicator,
    this.shrinkWrap,
  })  : assert((fetchPathInitial != null) || (initialJson != null));

  @override
  State<StatefulWidget> createState() => SuperListState<T>();
}

class FetchContext<T> {
  final ApiMethod? apiMethod;
  final FetchContextId id;
  final items = <T>[];
  final String? path;
  final SuperListState<T> state;

  String? linksNext;
  int? linksPage;
  int? linksPages;
  String? linksPrev;
  int? scrollToRelativeIndex;

  FetchContext({
    this.apiMethod,
    this.id = FetchContextId.fetchCustom,
    this.path,
    required this.state,
  });
}

enum FetchContextId { fetchCustom, fetchInitial, fetchNext, fetchPrev }

class SuperListItemFullWidth extends StatelessWidget {
  final Widget child;

  const SuperListItemFullWidth({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => child;
}

class SuperListState<T> extends State<SuperListView<T>> {
  final List<SuperListComplexItemRegistration> _complexItems = [];
  final List<T> _items = [];

  var _isFetching = false;
  var _isRefreshing = false;
  String? _fetchPathNext;
  String? _fetchPathPrev;
  int? _fetchedPageMax;
  int? _fetchedPageMin;
  Map? _initialJson;
  GlobalKey<RefreshIndicatorState>? _refreshIndicatorKey;
  ScrollController? _scrollController;
  AutoScrollController? _scrollControllerAuto;

  bool get canFetchNext => _fetchPathNext != null;
  bool get canFetchPrev => _fetchPathPrev != null;
  int? get fetchedPageMax => _fetchedPageMax;
  int? get fetchedPageMin => _fetchedPageMin;
  bool get isFetching => _isFetching;
  int get itemCountAfter => (widget.footer != null ? 1 : 0) + 1;
  int get itemCountBefore => 1 + (widget.header != null ? 1 : 0);
  Iterable<T> get items => _items;

  @override
  void initState() {
    super.initState();

    _initialJson = widget.initialJson;

    final Iterable<T>? initialItems = widget.initialItems;
    if (initialItems != null) _items.addAll(initialItems);

    final enableRefreshIndicator =
        widget.enableRefreshIndicator ?? widget.fetchPathInitial != null;
    if (enableRefreshIndicator) {
      _refreshIndicatorKey = GlobalKey();
    }

    if (widget.enableScrollToIndex) {
      _scrollControllerAuto = AutoScrollController();
    }
    _scrollController = _scrollControllerAuto ?? ScrollController();

    widget.complexItems?.forEach((register) {
      _complexItems.add(register());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => fetch());
  }

  @override
  Widget build(BuildContext context) {
    Widget built = ListView.builder(
      itemBuilder: (context, i) {
        Widget built = _buildItem(context, i) ?? Container();

        if (built is! SuperListItemFullWidth) {
          built = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.itemMaxWidth),
              child: built,
            ),
          );
        }

        final scrollController = _scrollControllerAuto;
        if (scrollController != null) {
          built = AutoScrollTag(
            controller: scrollController,
            highlightColor:
                Theme.of(context).colorScheme.secondary.withOpacity(.1),
            index: i,
            key: ValueKey(i),
            child: built,
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
          if (_scrollControllerAuto?.isAutoScrolling == true) return false;
          if (scrollInfo is! UserScrollNotification) return false;

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
      providers: _complexItems.map((r) => r._provider).toList()
        ..add(Provider<SuperListState<T>>.value(value: this)),
      child: built,
    );

    return built;
  }

  Future<void> fetch({
    bool clearItems = false,
    FetchContext<T>? fc,
  }) =>
      _fetch(
        fc ??
            FetchContext(
              apiMethod: widget.apiMethodInitial,
              id: FetchContextId.fetchInitial,
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

          for (var r in _complexItems) {
            r._clear?.call();
          }
        },
        preFetchedJson: _initialJson,
      );

  Future<void> fetchNext({int? scrollToRelativeIndex}) => _fetch(
        FetchContext(
          id: FetchContextId.fetchNext,
          path: _fetchPathNext,
          state: this,
        )..scrollToRelativeIndex = scrollToRelativeIndex,
        onPreFetch: () => _fetchPathNext = null,
      );

  Future<void> fetchPrev() => _fetch(
        FetchContext(
          id: FetchContextId.fetchPrev,
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
      _items.insertAll(index, items);
      return;
    }

    setState(() {
      _items.removeAt(index);
      _items.insertAll(index, items);
    });
  }

  void scrollTo(double offset,
          {Duration duration = scrollAnimationDuration,
          Curve curve = Curves.easeIn}) =>
      _scrollController?.animateTo(offset, duration: duration, curve: curve);

  void scrollToIndex(int index,
      {Duration duration = scrollAnimationDuration,
      AutoScrollPosition? preferPosition}) {
    final scrollController = _scrollControllerAuto;
    if (scrollController == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final i = itemCountBefore + index;
      final d = duration;
      final p = preferPosition;
      await scrollController.scrollToIndex(i, duration: d, preferPosition: p);
      scrollController.highlight(i);
    });
  }

  Widget? _buildItem(BuildContext context, int i) {
    if (i == 0) return _buildProgressIndicator(canFetchPrev && _isFetching);
    i--;

    final header = widget.header;
    if (header != null) {
      if (i == 0) return header;
      i--;
    }

    if (i < _items.length) return widget.itemBuilder(context, this, _items[i]);
    i -= _items.length;

    final footer = widget.footer;
    if (footer != null) {
      if (i == 0) return footer;
      i--;
    }

    return _buildProgressIndicator(_isFetching);
  }

  Widget _buildProgressIndicator(bool visible) =>
      widget.progressIndicator != false && !_isRefreshing && visible
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: SafeArea(
                child: Center(
                  child: AdaptiveProgressIndicator(),
                ),
              ),
            )
          : const SizedBox.shrink();

  Future<void> _fetch(
    FetchContext<T> fc, {
    VoidCallback? onPreFetch,
    Map? preFetchedJson,
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
    final ApiMethod apiMethod = fc.apiMethod ?? apiGet;
    apiMethod(
      ApiCaller.stateful(this),
      fc.path!,
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
        final fetchedPageMin = _fetchedPageMin;
        if (fetchedPageMin == null || fetchedPageMin > linksPage) {
          _fetchedPageMin = linksPage;
          _fetchPathPrev = fc.linksPrev;
        }
        final fetchedPageMax = _fetchedPageMax;
        if (fetchedPageMax == null || fetchedPageMax < linksPage) {
          _fetchedPageMax = linksPage;
          _fetchPathNext = fc.linksNext;
        }

        final itemsLengthBefore = _items.length;
        if (fc.items.isNotEmpty) {
          if (fc.id == FetchContextId.fetchPrev) {
            _items.insertAll(0, fc.items);
          } else {
            _items.addAll(fc.items);
          }
        }

        final scrollToRelativeIndex = fc.scrollToRelativeIndex;
        if (scrollToRelativeIndex != null) {
          scrollToIndex(
            (fc.id != FetchContextId.fetchPrev ? itemsLengthBefore : 0) +
                scrollToRelativeIndex,
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

typedef FetchOnSuccess<T> = void Function(
    Map json, FetchContext<T> fetchContext);
typedef ItemBuilder<T> = Widget? Function(
  BuildContext context,
  SuperListState<T> state,
  T item,
);

typedef SuperListComplexItemRegister = SuperListComplexItemRegistration
    Function();
typedef SuperListComplexItemClearer = void Function();

class SuperListComplexItemRegistration {
  final InheritedProvider _provider;
  final SuperListComplexItemClearer? _clear;

  SuperListComplexItemRegistration(
    InheritedProvider provider, {
    SuperListComplexItemClearer? clear,
  })  : _provider = provider,
        _clear = clear;
}
