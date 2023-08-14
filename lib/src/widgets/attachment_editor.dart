import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:the_api/attachment.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/abstracts/cached_network_image.dart' as cached;
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/api.dart';

class AttachmentEditorWidget extends StatefulWidget {
  final String? apiPostPath;
  final double height;
  final bool showPickIcon;

  const AttachmentEditorWidget({
    this.apiPostPath,
    this.height = 50,
    Key? key,
    this.showPickIcon = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AttachmentEditorState();
}

class AttachmentEditorState extends State<AttachmentEditorWidget> {
  final _attachments = <_Attachment>[];
  final _imagePicker = ImagePicker();

  String? _apiPostPath;
  String? _attachmentHash;

  String? get attachmentHash => _attachmentHash;

  int get itemCount =>
      _attachments.length +
      (widget.showPickIcon &&
              attachmentHash?.isNotEmpty == true &&
              Provider.of<User>(context).userIsVisitor == true
          ? 1
          : 0);

  @override
  void initState() {
    super.initState();

    if (widget.apiPostPath != null) {
      _apiPostPath = widget.apiPostPath;
      _attachmentHash = _generateHash();
    }
  }

  @override
  Widget build(BuildContext context) => itemCount > 0
      ? Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: widget.height,
            child: ListView.builder(
              itemBuilder: (_, i) => i < _attachments.length
                  ? _buildAttachment(_attachments[i])
                  : _buildPickIcon(),
              itemCount: itemCount,
              scrollDirection: Axis.horizontal,
            ),
          ),
        )
      : const SizedBox.shrink();

  Widget _buildAttachment(_Attachment attachment) {
    final apiData = attachment.apiData;
    final thumbnail = apiData?.links?.thumbnail;
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Opacity(
              opacity: apiData != null ? 1.0 : 0.5,
              child: thumbnail != null
                  ? cached.ImageWidget(thumbnail)
                  : Image.file(
                      attachment.file,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: apiData != null
              ? Icon(
                  Icons.cloud_done,
                  color: Theme.of(context).colorScheme.secondary,
                )
              : _UploadingIcon(),
        ),
      ],
    );
  }

  Widget _buildPickIcon() => Tooltip(
        message: l(context).pickGallery,
        child: InkWell(
          child: Container(
            color: Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Icon(FontAwesomeIcons.image, size: widget.height / 2),
            ),
          ),
          onTap: () => pickGallery(),
        ),
      );

  void pickGallery() async {
    var pickedFile = await _imagePicker.pickImage(
      maxHeight: 2048.0,
      maxWidth: 2048.0,
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final attachment = _Attachment(File(pickedFile.path));
    setState(() => _attachments.add(attachment));

    apiPost(
      ApiCaller.stateful(this),
      _apiPostPath!,
      bodyFields: {'attachment_hash': _attachmentHash!},
      fileFields: {'file': attachment.file},
      onSuccess: (jsonMap) {
        if (jsonMap.containsKey('attachment')) {
          final apiData = Attachment.fromJson(jsonMap['attachment']);
          setState(() => attachment.apiData = apiData);
        }
      },
    );
  }

  void setPath([String? path]) => setState(() {
        _apiPostPath = path;
        _attachmentHash = _generateHash();

        _attachments.clear();
      });

  static String _generateHash() => Random.secure().nextDouble().toString();
}

class _Attachment {
  final File file;
  Attachment? apiData;

  _Attachment(this.file);
}

class _UploadingIcon extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UploadingIconState();
}

class _UploadingIconState extends State<_UploadingIcon>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation = Tween(begin: 0.5, end: .9).animate(controller)
      ..addListener(() => setState(() {}));
    controller.repeat();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: animation.value,
        child: const Icon(Icons.cloud_upload),
      );
}
