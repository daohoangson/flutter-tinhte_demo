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

  String get appTitle =>
      Intl.message('tinhte.vn Demo', locale: localeName, name: 'appTitle');

  String get appVersion =>
      Intl.message('Version', locale: localeName, name: 'appVersion');

  String appVersionInfo(String version, String buildNumber) =>
      Intl.message('$version (build number: $buildNumber)',
          args: [version, buildNumber],
          locale: localeName,
          name: 'appVersionInfo');

  String get appVersionNotAvailable =>
      Intl.message('N/A', locale: localeName, name: 'appVersionNotAvailable');

  String get apiError => Intl.message('API Error',
      desc: 'Default dialog title for API error',
      locale: localeName,
      name: 'apiError');

  String get apiUnexpectedResponse => Intl.message('Unexpected API response',
      locale: localeName, name: 'apiUnexpectedResponse');

  String get forums => Intl.message('Forums',
      desc: 'Forum list appbar title', locale: localeName, name: 'forums');

  String get home => Intl.message('Home',
      desc: 'Home bottom navigation item title',
      locale: localeName,
      name: 'home');

  String get justAMomentEllipsis => Intl.message('Just a moment...',
      desc: 'Placeholder text for link parsing',
      locale: localeName,
      name: 'justAMomentEllipsis');

  String get loadingEllipsis =>
      Intl.message('Loading...', locale: localeName, name: 'loadingEllipsis');

  String get login => Intl.message('Login',
      desc: 'Login screen appbar title', locale: localeName, name: 'login');

  String get loginAssociate => Intl.message('Associate',
      desc: 'Label for "Associate" button',
      locale: localeName,
      name: 'loginAssociate');

  String get loginAssociateEnterPassword => Intl.message(
      'An existing account has been found, '
      'please enter your password to associate it for future logins.',
      locale: localeName,
      name: 'loginAssociateEnterPassword');

  String loginErrorCancelled(String method) =>
      Intl.message('$method has been cancelled.',
          args: [method], locale: localeName, name: 'loginErrorCancelled');

  String get loginGoogleErrorAccountIsNull =>
      Intl.message('Cannot get Google account information.',
          locale: localeName, name: 'loginGoogleErrorAccountIsNull');

  String get loginGoogleErrorTokenIsEmpty =>
      Intl.message('Cannot get Google authentication info.',
          locale: localeName, name: 'loginGoogleErrorTokenIsEmpty');

  String loginErrorNoAccessToken(String method) =>
      Intl.message('Cannot login with $method.',
          args: [method], locale: localeName, name: 'loginErrorNoAccessToken');

  String get loginErrorNoAccessTokenAutoRegister =>
      Intl.message('Cannot register new user account.',
          locale: localeName, name: 'loginErrorNoAccessTokenAutoRegister');

  String get loginErrorPasswordIsEmpty =>
      Intl.message('Please enter your password to login',
          name: 'loginErrorPasswordIsEmpty');

  String get loginErrorUsernameIsEmpty =>
      Intl.message('Please enter your username or email',
          locale: localeName, name: 'loginErrorUsernameIsEmpty');

  String get loginPassword => Intl.message('Password',
      desc: 'Label text for password field',
      locale: localeName,
      name: 'loginPassword');

  String get loginPasswordHint => Intl.message('hunter2',
      desc: 'Hint text for password field',
      locale: localeName,
      name: 'loginPasswordHint');

  String get loginUsername => Intl.message('Username',
      desc: 'Label text for username field',
      locale: localeName,
      name: 'loginUsername');

  String get loginUsernameHint => Intl.message('keyboard_warrior',
      desc: 'Hint text for username field',
      locale: localeName,
      name: 'loginUsernameHint');

  String get loginUsernameOrEmail => Intl.message('Username / email',
      desc: 'Label text for username / email field',
      locale: localeName,
      name: 'loginUsernameOrEmail');

  String get loginWithApple => Intl.message('Sign in with Apple',
      locale: localeName, name: 'loginWithApple');

  String get loginWithFacebook => Intl.message('Sign in with Facebook',
      locale: localeName, name: 'loginWithFacebook');

  String get loginWithGoogle => Intl.message('Sign in with Google',
      locale: localeName, name: 'loginWithGoogle');

  String get menu => Intl.message('Menu',
      desc: 'Menu screen appbar title', locale: localeName, name: 'menu');

  String get menuDarkTheme =>
      Intl.message('Dark theme', locale: localeName, name: 'menuDarkTheme');

  String get menuDarkTheme0 => Intl.message('No, use light theme',
      locale: localeName, name: 'menuDarkTheme0');

  String get menuDarkTheme1 => Intl.message('Yes, use dark theme',
      locale: localeName, name: 'menuDarkTheme1');

  String get menuDarkThemeAuto => Intl.message("Use system's color scheme",
      locale: localeName, name: 'menuDarkThemeAuto');

  String get menuLogout =>
      Intl.message('Logout', locale: localeName, name: 'menuLogout');

  String get myFeed => Intl.message('My Feed',
      desc: 'My feed appbar title', locale: localeName, name: 'myFeed');

  String get navLowercaseNext =>
      Intl.message('next', locale: localeName, name: 'navLowercaseNext');

  String get navLowercasePrevious => Intl.message('previous',
      locale: localeName, name: 'navLowercasePrevious');

  String navPageX(num page) => Intl.message('Page $page',
      args: [page], locale: localeName, name: 'navPageX');

  String navXOfY(num x, num y) => Intl.message('$x of $y',
      args: [x, y], locale: localeName, name: 'navXOfY');

  String get notifications => Intl.message('Notifications',
      desc: 'Notification list appbar title',
      locale: localeName,
      name: 'notifications');

  String get openInBrowser => Intl.message('Open in browser',
      locale: localeName, name: 'openInBrowser');

  String get pickGallery => Intl.message('Select image to upload',
      locale: localeName, name: 'pickGallery');

  String pollErrorTooManyVotes(num howMany) => Intl.plural(howMany,
      one: 'You can only choose one.',
      other: 'You can only select up to $howMany choices.',
      args: [howMany],
      locale: localeName,
      name: 'pollErrorTooManyVotes');

  String get pollVote =>
      Intl.message('Vote', locale: localeName, name: 'pollVote');

  String get postDelete =>
      Intl.message('Delete', locale: localeName, name: 'postDelete');

  String get postDeleteReasonHint => Intl.message('Reason to delete post.',
      locale: localeName, name: 'postDeleteReasonHint');

  String get postDeleted =>
      Intl.message('Deleted post.', locale: localeName, name: 'postDeleted');

  String get postError =>
      Intl.message('Post error', locale: localeName, name: 'postError');

  String get postGoUnreadQuestion => Intl.message('Continue reading?',
      locale: localeName, name: 'postGoUnreadQuestion');

  String get postGoUnreadYes =>
      Intl.message('YES', locale: localeName, name: 'postGoUnreadYes');

  String get postLike =>
      Intl.message('Like', locale: localeName, name: 'postLike');

  String postLoadXHidden(String number) =>
      Intl.message('Tap to load $number hidden replies...',
          args: [number], locale: localeName, name: 'postLoadXHidden');

  String get postReport =>
      Intl.message('Report', locale: localeName, name: 'postReport');

  String get postReportReasonHint => Intl.message('Problem to be reported.',
      locale: localeName, name: 'postReportReasonHint');

  String get postReportedThanks => Intl.message('Thank you for your report!',
      locale: localeName, name: 'postReportedThanks');

  String get postUnlike =>
      Intl.message('Unlike', locale: localeName, name: 'postUnlike');

  String get postReply =>
      Intl.message('Reply', locale: localeName, name: 'postReply');

  String get postReplyMessageHint => Intl.message('Enter your message to post',
      locale: localeName, name: 'postReplyMessageHint');

  String get postReplyingToAt => Intl.message('Replying to @',
      locale: localeName, name: 'postReplyingToAt');

  String get privacyPolicy =>
      Intl.message('Privacy Policy', locale: localeName, name: 'privacyPolicy');

  String get searchEnterSomething => Intl.message('Enter something to search',
      locale: localeName, name: 'searchEnterSomething');

  String get searchThisUser => Intl.message('Search for this user',
      locale: localeName, name: 'searchThisUser');

  String get searchThisForum => Intl.message('Search this forum',
      locale: localeName, name: 'searchThisForum');

  String searchSubmitToContinue(String query) =>
      Intl.message("Submit to search for '$query'",
          args: [query], locale: localeName, name: 'searchSubmitToContinue');

  String searchThreadByUser(String username) =>
      Intl.message(" by user '$username'",
          args: [username], locale: localeName, name: 'searchThreadByUser');

  String searchThreadInForum(String forumTitle) =>
      Intl.message(" in forum '$forumTitle'",
          args: [forumTitle], locale: localeName, name: 'searchThreadInForum');

  String get share => Intl.message('Share', locale: localeName, name: 'share');

  String statsXReplies(num howMany) =>
      _statsXReplies(howMany, formatNumber(howMany));

  String _statsXReplies(num howMany, String formatted) => Intl.plural(howMany,
      one: '$howMany reply',
      other: '$formatted replies',
      args: [howMany, formatted],
      locale: localeName,
      name: '_statsXReplies');

  String statsXViews(num howMany) =>
      _statsXViews(howMany, formatNumber(howMany));

  String _statsXViews(num howMany, String formatted) => Intl.plural(howMany,
      one: '$howMany view',
      other: '$formatted views',
      args: [howMany, formatted],
      locale: localeName,
      name: '_statsXViews');

  String get tagFollow =>
      Intl.message('Follow', locale: localeName, name: 'tagFollow');

  String get tagFollowing =>
      Intl.message('Following', locale: localeName, name: 'tagFollowing');

  String get tagLowercaseDiscussions => Intl.message('discussions',
      locale: localeName, name: 'tagLowercaseDiscussions');

  String get tagLowercaseNews =>
      Intl.message('news', locale: localeName, name: 'tagLowercaseNews');

  String get tagNotificationChannelAlert => Intl.message('Alert',
      locale: localeName, name: 'tagNotificationChannelAlert');

  String get tagNotificationChannelEmail => Intl.message('Email',
      locale: localeName, name: 'tagNotificationChannelEmail');

  String tagNotificationChannelExplainForX(String tag) => Intl.message(
      'Choose how you want to be notified when new contents '
      'are available in $tag:',
      args: [tag],
      locale: localeName,
      name: 'tagNotificationChannelExplainForX');

  String get tagNotificationChannels => Intl.message('Notification channels',
      locale: localeName, name: 'tagNotificationChannels');

  String tagUnfollowXQuestion(String tag) => Intl.message('Unfollow $tag?',
      args: [tag], locale: localeName, name: 'tagUnfollowXQuestion');

  String get threadBookmark => 'Bookmark';    

  String get threadBookmarkUndo => 'Unbookmark';

  String get threadCreateBody =>
      Intl.message('Post body', locale: localeName, name: 'threadCreateBody');

  String get threadCreateBodyHint =>
      Intl.message('', locale: localeName, name: 'threadCreateBodyHint');

  String get threadCreateChooseAForum => Intl.message('Choose a forum',
      locale: localeName, name: 'threadCreateChooseAForum');

  String get threadCreateError => Intl.message('Creating thread error',
      locale: localeName, name: 'threadCreateError');

  String get threadCreateErrorBodyIsEmpty =>
      Intl.message('Please enter a post body to create thread',
          locale: localeName, name: 'threadCreateErrorBodyIsEmpty');

  String get threadCreateErrorTitleIsEmpty =>
      Intl.message('Please enter a title to create thread',
          locale: localeName, name: 'threadCreateErrorTitleIsEmpty');

  String get threadCreateNew => Intl.message('Create new thread',
      locale: localeName, name: 'threadCreateNew');

  String get threadCreateSubmit =>
      Intl.message('Submit', locale: localeName, name: 'threadCreateSubmit');

  String get threadCreateTitle => Intl.message('Thread title',
      locale: localeName, name: 'threadCreateTitle');

  String get threadCreateTitleHint => Intl.message('Something interesting',
      locale: localeName, name: 'threadCreateTitleHint');

  String get threadStickyBanner =>
      Intl.message('Sticky', locale: localeName, name: 'threadStickyBanner');

  String get topThreads =>
      Intl.message('Top Threads', locale: localeName, name: 'topThreads');

  String get userIgnore =>
      Intl.message('Ignore', locale: localeName, name: 'userIgnore');

  String get userFollow =>
      Intl.message('Follow', locale: localeName, name: 'userFollow');

  String get userRegisterDate =>
      Intl.message('Joined', locale: localeName, name: 'userRegisterDate');

  String get userUnfollow =>
      Intl.message('Unfollow', locale: localeName, name: 'userUnfollow');

  String get userUnignore =>
      Intl.message('Unignore', locale: localeName, name: 'userUnignore');

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
