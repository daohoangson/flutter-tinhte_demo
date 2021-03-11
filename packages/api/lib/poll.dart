import 'package:freezed_annotation/freezed_annotation.dart';

part 'poll.freezed.dart';
part 'poll.g.dart';

@freezed
class Poll with _$Poll {
  const factory Poll(
    int pollId, {
    String? pollQuestion,
    int? pollVoteCount,
    int? pollMaxVotes,
    bool? pollIsOpen,
    bool? pollIsVoted,
    PollLinks? links,
    PollPermissions? permissions,
    @Default(const []) List<PollResponse> responses,
  }) = _Poll;

  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);
}

@freezed
class PollLinks with _$PollLinks {
  const factory PollLinks({
    String? vote,
  }) = _PollLinks;

  factory PollLinks.fromJson(Map<String, dynamic> json) =>
      _$PollLinksFromJson(json);
}

@freezed
class PollPermissions with _$PollPermissions {
  const factory PollPermissions({
    bool? vote,
    bool? result,
  }) = _PollPermissions;

  factory PollPermissions.fromJson(Map<String, dynamic> json) =>
      _$PollPermissionsFromJson(json);
}

@freezed
class PollResponse with _$PollResponse {
  const factory PollResponse(
    int responseId, {
    String? responseAnswer,
    bool? responseIsVoted,
    int? responseVoteCount,
    @Default(const []) List<PollVoter> voters,
  }) = _PollResponse;

  factory PollResponse.fromJson(Map<String, dynamic> json) =>
      _$PollResponseFromJson(json);
}

@freezed
class PollVoter with _$PollVoter {
  const factory PollVoter(int userId, String username) = _PollVoter;

  factory PollVoter.fromJson(Map<String, dynamic> json) =>
      _$PollVoterFromJson(json);
}
