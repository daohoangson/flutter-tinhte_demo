import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tinhte_demo/l10n/messages_all.dart';

final _numberFormatCompact = NumberFormat.compact();

L10n l(BuildContext context) => Localizations.of<L10n>(context, L10n);

MaterialLocalizations lm(BuildContext context) =>
    MaterialLocalizations.of(context);

class L10n {
  L10n(this.localeName);

  final String localeName;

  String get appTitle => Intl.message('tinhte.vn Demo', locale: localeName);

  String get appVersion => Intl.message('Version', locale: localeName);

  String appVersionInfo(String version, String buildNumber) =>
      Intl.message('$version (build number: $buildNumber)',
          args: [version, buildNumber],
          locale: localeName,
          name: 'appVersionInfo');

  String get appVersionNotAvailable => Intl.message('N/A', locale: localeName);

  String get apiError => Intl.message('API Error',
      desc: 'Default dialog title for API error', locale: localeName);

  String get apiUnexpectedResponse =>
      Intl.message('Unexpected API response', locale: localeName);

  String get forums => Intl.message('Forums',
      desc: 'Forum list appbar title', locale: localeName);

  String get home => Intl.message('Home',
      desc: 'Home bottom navigation item title', locale: localeName);

  String get justAMomentEllipsis => Intl.message('Just a moment...',
      desc: 'Placeholder text for link parsing', locale: localeName);

  String get loadingEllipsis => Intl.message('Loading...', locale: localeName);

  String get login => Intl.message('Login',
      desc: 'Login screen appbar title', locale: localeName);

  String get loginAssociate => Intl.message('Associate',
      desc: 'Label for "Associate" button', locale: localeName);

  String get loginAssociateEnterPassword => Intl.message(
      'An existing account has been found, '
      'please enter your password to associate it for future logins.',
      locale: localeName);

  String loginErrorCancelled(String method) =>
      Intl.message('$method has been cancelled.',
          args: [method], locale: localeName, name: 'loginErrorCancelled');

  String get loginGoogleErrorAccountIsNull =>
      Intl.message('Cannot get Google account information.',
          locale: localeName);

  String get loginGoogleErrorTokenIsEmpty =>
      Intl.message('Cannot get Google authentication info.',
          locale: localeName);

  String loginErrorNoAccessToken(String method) =>
      Intl.message('Cannot login with $method.',
          args: [method], locale: localeName, name: 'loginErrorNoAccessToken');

  String get loginErrorNoAccessTokenAutoRegister =>
      Intl.message('Cannot register new user account.', locale: localeName);

  String get loginErrorPasswordIsEmpty =>
      Intl.message('Please enter your password to login');

  String get loginErrorUsernameIsEmpty =>
      Intl.message('Please enter your username or email', locale: localeName);

  String get loginPassword => Intl.message('Password',
      desc: 'Label text for password field', locale: localeName);

  String get loginPasswordHint => Intl.message('hunter2',
      desc: 'Hint text for password field', locale: localeName);

  String get loginUsername => Intl.message('Username',
      desc: 'Label text for username field', locale: localeName);

  String get loginUsernameHint => Intl.message('keyboard_warrior',
      desc: 'Hint text for username field', locale: localeName);

  String get loginUsernameOrEmail => Intl.message('Username / email',
      desc: 'Label text for username / email field', locale: localeName);

  String get loginWithApple =>
      Intl.message('Sign in with Apple', locale: localeName);

  String get loginWithFacebook =>
      Intl.message('Sign in with Facebook', locale: localeName);

  String get loginWithGoogle =>
      Intl.message('Sign in with Google', locale: localeName);

  String get menu => Intl.message('Menu',
      desc: 'Menu screen appbar title', locale: localeName);

  String get menuDarkTheme => Intl.message('Dark theme', locale: localeName);

  String get menuDarkTheme0 =>
      Intl.message('No, use light theme', locale: localeName);

  String get menuDarkTheme1 =>
      Intl.message('Yes, use dark theme', locale: localeName);

  String get menuDarkThemeAuto =>
      Intl.message("Use system's color scheme", locale: localeName);

  String get menuLogout => Intl.message('Logout', locale: localeName);

  String get myFeed =>
      Intl.message('My Feed', desc: 'My feed appbar title', locale: localeName);

  String get navLowercaseNext => Intl.message('next', locale: localeName);

  String get navLowercasePrevious =>
      Intl.message('previous', locale: localeName);

  String navPageX(num page) => Intl.message('Page $page',
      args: [page], locale: localeName, name: 'navPageX');

  String navXOfY(num x, num y) => Intl.message('$x of $y',
      args: [x, y], locale: localeName, name: 'navXOfY');

  String get notifications => Intl.message('Notifications',
      desc: 'Notification list appbar title', locale: localeName);

  String get openInBrowser =>
      Intl.message('Open in browser', locale: localeName);

  String pollErrorTooManyVotes(num maxVotes) =>
      Intl.message('You can only select up to $maxVotes choices.',
          args: [maxVotes], locale: localeName, name: 'pollErrorTooManyVotes');

  String get pollVote => Intl.message('Vote', locale: localeName);

  String get postDelete => Intl.message('Delete', locale: localeName);

  String get postDeleteReasonHint =>
      Intl.message('Reason to delete post.', locale: localeName);

  String get postDeleted => Intl.message('Deleted post.', locale: localeName);

  String get postError => Intl.message('Post error', locale: localeName);

  String get postGoUnreadQuestion =>
      Intl.message('Continue reading?', locale: localeName);

  String get postGoUnreadYes => Intl.message('YES', locale: localeName);

  String get postLike => Intl.message('Like', locale: localeName);

  String postLoadXHidden(String number) =>
      Intl.message('Tap to load $number hidden replies...',
          args: [number], locale: localeName, name: 'postLoadXHidden');

  String get postReport => Intl.message('Report', locale: localeName);

  String get postReportReasonHint =>
      Intl.message('Problem to be reported.', locale: localeName);

  String get postReportedThanks =>
      Intl.message('Thank you for your report!', locale: localeName);

  String get postUnlike => Intl.message('Unlike', locale: localeName);

  String get postReply => Intl.message('Reply', locale: localeName);

  String get postReplyMessageHint =>
      Intl.message('Enter your message to post', locale: localeName);

  String get postReplyingToAt =>
      Intl.message('Replying to @', locale: localeName);

  String get privacyPolicy =>
      Intl.message('Privacy Policy', locale: localeName);

  String get search => Intl.message('Search',
      desc: 'Search bottom navigation item title', locale: localeName);

  String get searchEnterSomething =>
      Intl.message('Enter something to search', locale: localeName);

  String get searchThisUser =>
      Intl.message('Search for this user', locale: localeName);

  String get searchThisForum =>
      Intl.message('Search this forum', locale: localeName);

  String searchSubmitToContinue(String query) =>
      Intl.message("Submit to search for '$query'",
          args: [query], locale: localeName, name: 'searchSubmitToContinue');

  String searchThreadByUser(String username) =>
      Intl.message(" by user '$username'",
          args: [username], locale: localeName, name: 'searchThreadByUser');

  String searchThreadInForum(String forumTitle) =>
      Intl.message(" in forum '$forumTitle'",
          args: [forumTitle], locale: localeName, name: 'searchThreadInForum');

  String get share => Intl.message('Share', locale: localeName);

  String statsXReplies(String number) => Intl.message('$number replies',
      args: [number], locale: localeName, name: 'statsXReplies');

  String statsXReply(String number) => Intl.message('$number reply',
      args: [number], locale: localeName, name: 'statsXReply');

  String statsXViews(String number) => Intl.message('$number views',
      args: [number], locale: localeName, name: 'statsXViews');

  String get tagFollow => Intl.message('Follow', locale: localeName);

  String get tagFollowing => Intl.message('Following', locale: localeName);

  String get tagLowercaseDiscussions =>
      Intl.message('discussions', locale: localeName);

  String get tagLowercaseNews => Intl.message('news', locale: localeName);

  String get tagNotificationChannelAlert =>
      Intl.message('Alert', locale: localeName);

  String get tagNotificationChannelEmail =>
      Intl.message('Email', locale: localeName);

  String tagNotificationChannelExplainForX(String tag) => Intl.message(
      'Choose how you want to be notified when new contents '
      'are available in $tag:',
      args: [tag],
      locale: localeName,
      name: 'tagNotificationChannelExplainForX');

  String get tagNotificationChannels =>
      Intl.message('Notification channels', locale: localeName);

  String tagUnfollowXQuestion(String tag) => Intl.message('Unfollow $tag?',
      args: [tag], locale: localeName, name: 'tagUnfollowXQuestion');

  String get threadStickyBanner => Intl.message('Sticky', locale: localeName);

  String get topThreads => Intl.message('Top Threads', locale: localeName);

  String get userIgnore => Intl.message('Ignore', locale: localeName);

  String get userFollow => Intl.message('Follow', locale: localeName);

  String get userRegisterDate => Intl.message('Joined', locale: localeName);

  String get userUnfollow => Intl.message('Unfollow', locale: localeName);

  String get userUnignore => Intl.message('Unignore', locale: localeName);

  static Future<L10n> load(Locale locale) {
    final localeName = Intl.canonicalizedLocale(
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString());
    return initializeMessages(localeName).then((_) => L10n(localeName));
  }
}

class L10nDelegate extends LocalizationsDelegate<L10n> {
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
        'vi',
      ].contains(locale.languageCode);

  @override
  Future<L10n> load(Locale locale) => L10n.load(locale);

  @override
  bool shouldReload(L10nDelegate old) => false;
}

DateTime secondsToDateTime(int secondsSinceEpoch) =>
    DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);

String formatNumber(dynamic value) => _numberFormatCompact.format(value);

String formatTimestamp(int timestamp) {
  if (timestamp == null) return '';

  final d = secondsToDateTime(timestamp);
  if (DateTime.now().subtract(Duration(days: 30)).isBefore(d)) {
    return timeago.format(d);
  }

  // TODO: use date format from device locale
  return "${d.day}/${d.month}/${d.year}";
}
