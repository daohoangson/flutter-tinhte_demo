import 'dart:io';
import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinhte_api/attachment.dart';
import 'package:tinhte_demo/src/widgets/image.dart';
import 'package:tinhte_demo/src/api.dart';

class AttachmentEditorWidget extends StatefulWidget {
  AttachmentEditorWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AttachmentEditorState();
}

class AttachmentEditorState extends State<AttachmentEditorWidget> {
  final List<_Attachment> _attachments = List();

  String _apiPostPath;
  String _attachmentHash;

  String get attachmentHash => _attachmentHash;

  @override
  Widget build(BuildContext _) => _attachments.isNotEmpty
      ? Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              itemBuilder: (_, i) => _buildAttachment(_attachments[i]),
              itemCount: _attachments.length,
              scrollDirection: Axis.horizontal,
            ),
          ),
        )
      : const SizedBox.shrink();

  Widget _buildAttachment(_Attachment attachment) => Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Opacity(
                opacity: attachment.ok ? 1.0 : 0.5,
                child: attachment.ok
                    ? buildCachedNetworkImage(
                        attachment.apiData.links.thumbnail,
                      )
                    : Image.file(
                        attachment.file,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: attachment.ok
                ? Icon(
                    Icons.cloud_done,
                    color: Theme.of(context).accentColor,
                  )
                : _UploadingIcon(),
          ),
        ],
      );

  void pickGallery() async {
    var image = await ImagePicker.pickImage(
      maxHeight: 2048.0,
      maxWidth: 2048.0,
      source: ImageSource.gallery,
    );
    if (image == null) return;

    final attachment = _Attachment(image);
    setState(() => _attachments.add(attachment));

    apiPost(
      ApiCaller.stateful(this),
      _apiPostPath,
      bodyFields: {'attachment_hash': _attachmentHash},
      fileFields: {'file': attachment.file},
      onSuccess: (jsonMap) {
        if (jsonMap.containsKey('attachment')) {
          final apiData = Attachment.fromJson(jsonMap['attachment']);
          setState(() => attachment.apiData = apiData);
        }
      },
    );
  }

  void setPath([String path]) => setState(() {
        _apiPostPath = path;
        _attachmentHash = "${Random.secure().nextDouble()}";

        _attachments.clear();
      });
}

class _Attachment {
  final File file;
  Attachment apiData;

  bool get ok => apiData != null;

  _Attachment(this.file);
}

class _UploadingIcon extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UploadingIconState();
}

class _UploadingIconState extends State<_UploadingIcon>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

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
