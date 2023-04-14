import 'package:chatgpt_app/constants/constants.dart';
import 'package:chatgpt_app/providers/chat_provider.dart';
import 'package:chatgpt_app/widgets/models_dropdown_widget.dart';
import 'package:chatgpt_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class Services {
  static Future<void> showCustomModalBottomSheet(
      {required BuildContext context,
      required ChatProvider chatProvider}) async {
    await showModalBottomSheet(
        backgroundColor: scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        context: context,
        builder: (context) {
          return Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Flexible(
                      child: TextWidget(
                    label: 'Elige un modelo:',
                    fontSize: 16,
                  )),
                  Flexible(flex: 2, child: ModelsDropDownWidget())
                ],
              ));
        });
  }
}
