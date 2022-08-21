import 'package:flutter/material.dart';
import 'package:the_api/poll.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';

class PollWidget extends StatefulWidget {
  final PollOwner owner;

  PollWidget(this.owner) : assert(owner != null);

  @override
  State<PollWidget> createState() => _PollState();
}

class _PollState extends State<PollWidget> {
  final responses = GlobalKey<_PollResponsesState>();

  bool _isVoting = false;

  @override
  void initState() {
    super.initState();

    if (widget.owner.poll == null) {
      _fetch();
    }
  }

  @override
  Widget build(BuildContext _) {
    final poll = widget.owner.poll;
    if (poll == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final canVote = poll.permissions?.vote == true;
    final theme = Theme.of(context);

    return Container(
      child: Column(
        children: <Widget>[
          Text(poll.pollQuestion ?? '', style: theme.textTheme.headline6),
          _PollResponsesWidget(
            canVote: canVote,
            hasResults: poll.permissions?.result == true,
            key: responses,
            maxVotes: poll.pollMaxVotes ?? 1,
            poll: poll,
          ),
          canVote
              ? Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    child: Text(l(context).pollVote),
                    onPressed: _isVoting ? null : _vote,
                  ),
                )
              : const SizedBox.shrink(),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      decoration: BoxDecoration(
        color: theme.highlightColor,
      ),
      padding: const EdgeInsets.all(kPostBodyPadding),
      margin: const EdgeInsets.symmetric(vertical: kPostBodyPadding),
    );
  }

  void _fetch() => apiGet(
        ApiCaller.stateful(this),
        widget.owner.pollLink,
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('poll')) return;
          widget.owner.poll = Poll.fromJson(jsonMap['poll']);
        },
      );

  void _vote() => prepareForApiAction(context, () {
        if (_isVoting) return;

        final poll = widget.owner.poll;
        final linkVote = poll?.links?.vote ?? '';
        if (linkVote.isEmpty) return;

        setState(() => _isVoting = true);

        final apiCaller = ApiCaller.stateful(this);

        apiPost(
          apiCaller,
          linkVote,
          bodyFields: Map.fromEntries((responses
                      .currentState?._selectedResponseIds ??
                  {})
              .toList(growable: false)
              .asMap()
              .entries
              .map((e) => MapEntry("response_ids[${e.key}]", "${e.value}"))),
          onSuccess: (_) => _fetch(),
          onComplete: () => setState(() => _isVoting = false),
        );
      });
}

class _PollResponsesWidget extends StatefulWidget {
  final bool canVote;
  final bool hasResults;
  final int maxVotes;
  final Poll poll;

  const _PollResponsesWidget({
    this.canVote,
    this.hasResults,
    Key key,
    @required this.maxVotes,
    @required this.poll,
  })  : assert(canVote != null),
        assert(hasResults != null),
        assert(maxVotes != null),
        assert(poll != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PollResponsesState();
}

class _PollResponsesState extends State<_PollResponsesWidget> {
  final _selectedResponseIds = Set<int /*!*/ >();

  bool get isSingleChoice => widget.maxVotes == 1;
  Iterable<PollResponse> get responses => widget.poll.responses;

  @override
  void initState() {
    super.initState();

    for (final response in responses) {
      if (response.responseIsVoted == true) {
        _selectedResponseIds.add(response.responseId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pollVoteCount = widget.poll.pollVoteCount ?? 0;
    return Table(
      children: responses.map((response) {
        final responseVoteCount = response.responseVoteCount ?? 0;
        return TableRow(children: [
          widget.canVote
              ? (isSingleChoice
                  ? Radio<int>(
                      groupValue: _selectedResponseIds.isEmpty
                          ? null
                          : _selectedResponseIds.first,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: _onChanged,
                      value: response.responseId,
                    )
                  : Checkbox(
                      value: _selectedResponseIds.contains(response.responseId),
                      onChanged: (value) =>
                          _onChanged(response.responseId, value),
                    ))
              : const SizedBox.shrink(),
          InkWell(
            child: Padding(
              child: Text(
                response.responseAnswer ?? '',
                style: TextStyle(
                  fontWeight:
                      response.responseIsVoted == true ? FontWeight.bold : null,
                ),
              ),
              padding: const EdgeInsets.all(kPostBodyPadding),
            ),
            onTap: () => _onChanged(
              response.responseId,
              !_selectedResponseIds.contains(response.responseId),
            ),
          ),
          widget.hasResults && responseVoteCount > 0 && pollVoteCount > 0
              ? Padding(
                  child: Text(
                    "${(responseVoteCount / pollVoteCount * 100).toStringAsFixed(1)}%",
                    textAlign: TextAlign.end,
                  ),
                  padding: const EdgeInsets.all(kPostBodyPadding),
                )
              : const SizedBox.shrink(),
        ]);
      }).toList(),
      columnWidths: {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    );
  }

  void _onChanged(int responseId, [bool value]) {
    if (!widget.canVote) return;
    if (responseId == null) return;

    if (isSingleChoice) {
      return setState(() => _selectedResponseIds
        ..clear()
        ..add(responseId));
    }

    if (value == false) {
      return setState(() => _selectedResponseIds.remove(responseId));
    }

    final tmp = Set<int>.from(_selectedResponseIds);
    if (!tmp.add(responseId)) return;

    if (widget.maxVotes > 0 && tmp.length > widget.maxVotes) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l(context).pollErrorTooManyVotes(widget.maxVotes)),
      ));
      return;
    }

    setState(() => _selectedResponseIds.add(responseId));
  }
}
