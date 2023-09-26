import 'package:flutter/material.dart';

class DialogUtils {
  static showLoaderDialog(BuildContext context, String loadingText) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 10),
          Text(loadingText),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showAlertDialog(
      {required String title,
      String? content,
      VoidCallback? onConfirmCallback,
      VoidCallback? onCancelCallback,
      required BuildContext context}) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("取消"),
      onPressed: () {
        onCancelCallback?.call();
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("確定"),
      onPressed: () {
        Navigator.pop(context);
        onConfirmCallback?.call();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Visibility(
          visible: content?.isNotEmpty == true, child: Text(content ?? "")),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static isDialogShowing(BuildContext context) {
    return ModalRoute.of(context)?.isCurrent != true;
  }
}
