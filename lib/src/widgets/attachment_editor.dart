import 'dart:io';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinhte_api/attachment.dart';

import '../api.dart';
import 'image.dart';

const kSize = 50.0;

class AttachmentEditor extends StatefulWidget {
  final String path;
  final String attachmentHash;

  AttachmentEditor(this.path, this.attachmentHash, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AttachmentEditorState();
}

class _AttachmentEditorState extends State<AttachmentEditor> {
  final List<_Attachment> attachments = List();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          height: kSize,
          child: ListView.builder(
            itemBuilder: (context, i) =>
                i == 0 ? _buildButton() : _buildAttachment(attachments[i - 1]),
            itemCount: 1 + attachments.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      );

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

  Widget _buildButton() => GestureDetector(
        child: SizedBox(
          height: kSize,
          width: kSize,
          child: Icon(
            Icons.add,
            size: kSize,
          ),
        ),
        onTap: _pickGallery,
      );

  void _pickGallery() async {
    var image = await ImagePicker.pickImage(
      maxHeight: 2048.0,
      maxWidth: 2048.0,
      source: ImageSource.gallery,
    );
    if (image == null) return;

    final attachment = _Attachment(image);
    setState(() => attachments.add(attachment));

    apiPost(
      ApiCaller.stateful(this),
      widget.path,
      bodyFields: {'attachment_hash': widget.attachmentHash},
      fileFields: {'file': attachment.file},
      onSuccess: (jsonMap) {
        if (jsonMap.containsKey('attachment')) {
          final apiData = Attachment.fromJson(jsonMap['attachment']);
          setState(() => attachment.apiData = apiData);
        }
      },
    );
  }
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
