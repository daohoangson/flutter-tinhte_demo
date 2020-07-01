// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Poll _$PollFromJson(Map<String, dynamic> json) {
  return Poll(
    json['poll_id'] as int,
  )
    ..pollQuestion = json['poll_question'] as String
    ..pollVoteCount = json['poll_vote_count'] as int
    ..pollMaxVotes = json['poll_max_votes'] as int
    ..pollIsOpen = json['poll_is_open'] as bool
    ..pollIsVoted = json['poll_is_voted'] as bool
    ..links = json['links'] == null
        ? null
        : PollLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..permissions = json['permissions'] == null
        ? null
        : PollPermissions.fromJson(json['permissions'] as Map<String, dynamic>)
    ..responses = (json['responses'] as List)
        ?.map((e) =>
            e == null ? null : PollResponse.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

PollLinks _$PollLinksFromJson(Map<String, dynamic> json) {
  return PollLinks()..vote = json['vote'] as String;
}

PollPermissions _$PollPermissionsFromJson(Map<String, dynamic> json) {
  return PollPermissions()
    ..vote = json['vote'] as bool
    ..result = json['result'] as bool;
}

PollResponse _$PollResponseFromJson(Map<String, dynamic> json) {
  return PollResponse(
    json['response_id'] as int,
  )
    ..responseAnswer = json['response_answer'] as String
    ..responseIsVoted = json['response_is_voted'] as bool
    ..responseVoteCount = json['response_vote_count'] as int
    ..voters = (json['voters'] as List)
        ?.map((e) =>
            e == null ? null : PollVoter.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

PollVoter _$PollVoterFromJson(Map<String, dynamic> json) {
  return PollVoter(
    json['user_id'] as int,
    json['username'] as String,
  );
}
