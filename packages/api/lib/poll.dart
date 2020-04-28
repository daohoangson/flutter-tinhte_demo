import 'package:json_annotation/json_annotation.dart';

part 'poll.g.dart';

@JsonSerializable()
class Poll {
  final int pollId;
  String pollQuestion;
  int pollVoteCount;
  int pollMaxVotes;
  bool pollIsOpen;
  bool pollIsVoted;

  PollLinks links;
  PollPermissions permissions;
  List<PollResponse> responses;

  Poll(this.pollId);
  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);
}

@JsonSerializable()
class PollLinks {
  String vote;

  PollLinks();
  factory PollLinks.fromJson(Map<String, dynamic> json) =>
      _$PollLinksFromJson(json);
}

@JsonSerializable()
class PollPermissions {
  bool vote;
  bool result;

  PollPermissions();
  factory PollPermissions.fromJson(Map<String, dynamic> json) =>
      _$PollPermissionsFromJson(json);
}

@JsonSerializable()
class PollResponse {
  final int responseId;
  String responseAnswer;
  bool responseIsVoted;
  int responseVoteCount;
  List<PollVoter> voters;

  PollResponse(this.responseId);
  factory PollResponse.fromJson(Map<String, dynamic> json) =>
      _$PollResponseFromJson(json);
}

@JsonSerializable()
class PollVoter {
  final int userId;
  final String username;

  PollVoter(this.userId, this.username);
  factory PollVoter.fromJson(Map<String, dynamic> json) =>
      _$PollVoterFromJson(json);
}
