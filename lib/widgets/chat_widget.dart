import 'package:chatgpt_app/constants/constants.dart';
import 'package:chatgpt_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  final String message;
  final int chatIndex;

  const ChatWidget({Key? key, required this.message, required this.chatIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: chatIndex == 0
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Card(
                          color: cardUserColor,
                          elevation: 2,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20))),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextWidget(
                              label: message,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ))
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Card(
                          color: cardBotColor,
                          elevation: 2,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          )),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextWidget(
                              label: message,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )),
        )
      ],
    );
  }
}
