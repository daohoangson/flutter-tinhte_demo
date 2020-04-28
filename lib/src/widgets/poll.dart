import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinhte_api/poll.dart';
import 'package:tinhte_demo/src/api.dart';
import 'package:tinhte_demo/src/constants.dart';

class PollWidget extends StatefulWidget {
  final String link;

  PollWidget(this.link) : assert(link != null);

  @override
  State<PollWidget> createState() => _PollState();

  static SingleChildCloneableWidget buildProvider() =>
      ChangeNotifierProvider<_PollData>(builder: (_) => _PollData());
}

class _PollState extends State<PollWidget> {
  final responses = GlobalKey<_PollResponsesState>();

  bool _isVoting = false;

  @override
  Widget build(BuildContext _) =>
      Consumer<_PollData>(builder: (context, data, _) {
        if (data.poll == null) _fetch(data);
        return data.poll == null
            ? const Center(child: CircularProgressIndicator())
            : _buildPoll(context, data);
      });

  Widget _buildPoll(BuildContext context, _PollData data) {
    final poll = data.poll;
    final canVote = poll.permissions?.vote == true;
    final theme = Theme.of(context);

    return Container(
      child: Column(
        children: <Widget>[
          Text("Poll: ${poll.pollQuestion}", style: theme.textTheme.title),
          _PollResponsesWidget(
            canVote: canVote,
            hasResults: poll.permissions?.result == true,
            key: responses,
            maxVotes: poll.pollMaxVotes,
            poll: poll,
          ),
          canVote
              ? Align(
                  alignment: Alignment.centerRight,
                  child: RaisedButton(
                    child: Text('Vote'),
                    onPressed: _isVoting ? null : () => _vote(data),
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

  void _fetch(_PollData data) => apiGet(
        ApiCaller.stateful(this),
        widget.link,
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('poll')) return;
          final poll = Poll.fromJson(jsonMap['poll']);
          data.update(poll);
        },
      );

  void _vote(_PollData data) => prepareForApiAction(context, () {
        if (_isVoting) return;
        setState(() => _isVoting = true);

        final apiCaller = ApiCaller.stateful(this);

        apiPost(
          apiCaller,
          data.poll.links.vote,
          bodyFields: Map.fromEntries(responses
              .currentState._selectedResponseIds
              .toList(growable: false)
              .asMap()
              .entries
              .map((e) => MapEntry("response_ids[${e.key}]", "${e.value}"))),
          onSuccess: (_) => _fetch(data),
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
  final _selectedResponseIds = Set<int>();

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
  Widget build(BuildContext context) => Table(
        children: responses
            .map((response) => TableRow(children: [
                  widget.canVote
                      ? (isSingleChoice
                          ? Radio<int>(
                              groupValue: _selectedResponseIds.isEmpty
                                  ? null
                                  : _selectedResponseIds.first,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onChanged: _onChanged,
                              value: response.responseId,
                            )
                          : Checkbox(
                              value: _selectedResponseIds
                                  .contains(response.responseId),
                              onChanged: (value) =>
                                  _onChanged(response.responseId, value),
                            ))
                      : const SizedBox.shrink(),
                  InkWell(
                    child: Padding(
                      child: Text(
                        response.responseAnswer,
                        style: TextStyle(
                          fontWeight: response.responseIsVoted == true
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      padding: const EdgeInsets.all(kPostBodyPadding),
                    ),
                    onTap: () => _onChanged(
                      response.responseId,
                      !_selectedResponseIds.contains(response.responseId),
                    ),
                  ),
                  widget.hasResults
                      ? Padding(
                          child: Text(
                            "${(response.responseVoteCount / widget.poll.pollVoteCount * 100).toStringAsFixed(1)}%",
                            textAlign: TextAlign.end,
                          ),
                          padding: const EdgeInsets.all(kPostBodyPadding),
                        )
                      : const SizedBox.shrink(),
                ]))
            .toList(),
        columnWidths: {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      );

  void _onChanged(int responseId, [bool value]) {
    if (!widget.canVote) return;

    if (isSingleChoice) {
      return setState(() => _selectedResponseIds
        ..clear()
        ..add(responseId));
    }

    if (!value) {
      return setState(() => _selectedResponseIds.remove(responseId));
    }

    final tmp = Set<int>.from(_selectedResponseIds);
    if (!tmp.add(responseId)) return;

    if (widget.maxVotes > 0 && tmp.length > widget.maxVotes) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('You can only select up to ${widget.maxVotes} choices.'),
      ));
      return;
    }

    setState(() => _selectedResponseIds.add(responseId));
  }
}

class _PollData extends ChangeNotifier {
  Poll poll;

  void update(Poll newPoll) {
    poll = newPoll;
    notifyListeners();
  }
}
