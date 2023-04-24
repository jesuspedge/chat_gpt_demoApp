import 'package:chatgpt_app/constants/api_constants.dart';
import 'package:chatgpt_app/constants/constants.dart';
import 'package:chatgpt_app/models/chat_model.dart';
import 'package:chatgpt_app/providers/chat_provider.dart';
import 'package:chatgpt_app/providers/models_provider.dart';
import 'package:chatgpt_app/services/assets_manager.dart';
import 'package:chatgpt_app/services/services.dart';
import 'package:chatgpt_app/widgets/chat_widget.dart';
import 'package:chatgpt_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late FocusNode focusNode;

  @override
  void initState() {
    textEditingController = TextEditingController();
    focusNode = FocusNode();

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Center(
          child: AlertDialog(
            backgroundColor: cardColor,
            insetPadding: const EdgeInsets.all(20),
            contentPadding: const EdgeInsets.all(20),
            title: const Text(
              'Introduce tu API KEY de Open AI:',
              style: TextStyle(color: Colors.white),
            ),
            content: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  maxLines: null,
                  onChanged: (texto) {
                    API_KEY = texto;
                  },
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white70),
                      hintText: 'Escribe tu API KEY'),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    if (API_KEY == '') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.red,
                          content: TextWidget(
                            label: 'Por favor introduce un API KEY.',
                          )));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.green,
                          content: TextWidget(
                            label: 'API KEY introducido: $API_KEY',
                          )));
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(color: Colors.white70),
                  ))
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(AssetsManager.openAILogo),
        ),
        title: const Text('Chat GPT'),
        actions: [
          IconButton(
              onPressed: () async {
                await Services.showCustomModalBottomSheet(
                    context: context, chatProvider: chatProvider);
              },
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ))
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Flexible(
              child: ListView.builder(
                  itemCount: chatProvider.getChatList.length,
                  reverse: true,
                  itemBuilder: ((context, index) {
                    List<ChatModel> reversedList =
                        chatProvider.getChatList.reversed.toList();
                    return ChatWidget(
                      message: reversedList[index].message,
                      chatIndex: reversedList[index].chatIndex,
                    );
                  }))),
          if (_isTyping) ...[
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 18,
            )
          ],
          const SizedBox(
            height: 15,
          ),
          Material(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    maxLines: null,
                    focusNode: focusNode,
                    controller: textEditingController,
                    onSubmitted: (value) async {
                      await sendMessage(
                          modelsProvider: modelsProvider,
                          chatProvider: chatProvider);
                    },
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Hola, ¿Cómo puedo ayudarte?',
                        hintStyle: TextStyle(color: Colors.grey)),
                    style: const TextStyle(color: Colors.white),
                  )),
                  IconButton(
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        await sendMessage(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.grey,
                      ))
                ],
              ),
            ),
          )
        ],
      )),
    );
  }

  Future<void> sendMessage(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: TextWidget(
            label:
                'No puedes escribir otro mensaje hasta recibir una respuesta.',
          )));
      return;
    }

    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: TextWidget(
            label: 'Por favor, escribe un mensaje.',
          )));
      return;
    }

    try {
      String message = textEditingController.text;
      setState(() {
        _isTyping = true;
        chatProvider.addUserMessage(message: message);
        textEditingController.clear();
        focusNode.unfocus();
      });

      await chatProvider.sendMessageAndGetAnswer(
          message: message, modelChosed: modelsProvider.getCurrentModel);

      setState(() {
        _isTyping = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          )));
    }
  }
}
