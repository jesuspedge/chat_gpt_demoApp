import 'dart:convert';
import 'dart:io';

import 'package:chatgpt_app/constants/api_constants.dart';
import 'package:chatgpt_app/models/chat_model.dart';
import 'package:chatgpt_app/models/models_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  //Get all models
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(Uri.parse('$BASE_URL/models'),
          headers: {'Authorization': 'Bearer $API_KEY'});

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']['message']);
      }

      List tempModels = [];

      for (var model in jsonResponse['data']) {
        tempModels.add(model);
      }

      return ModelsModel.modelsFromSnapshot(tempModels);
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  //Send message
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      debugPrint('Model: $modelId');
      if (modelId == 'gpt-4' ||
          modelId == 'gpt-4-0314' ||
          modelId == 'gpt-4-32k' ||
          modelId == 'gpt-4-32k-0314' ||
          modelId == 'gpt-3.5-turbo' ||
          modelId == 'gpt-3.5-turbo-0301') {
        var response = await http.post(Uri.parse('$BASE_URL/chat/completions'),
            headers: {
              'Authorization': 'Bearer $API_KEY',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'model': modelId,
              'messages': [
                {'role': 'user', 'content': message}
              ]
            }));
        //Para convertir los caracteres especiales que se usan en
        //el español
        String stringResponse =
            const Utf8Decoder().convert(response.body.codeUnits);

        Map jsonResponse = jsonDecode(stringResponse);

        if (jsonResponse['error'] != null) {
          throw HttpException(jsonResponse['error']['message']);
        }

        List<ChatModel> chatList = [];

        if (jsonResponse['choices'].length > 0) {
          chatList = List.generate(
              jsonResponse['choices'].length,
              (index) => ChatModel(
                  message: jsonResponse['choices'][index]['message']['content'],
                  chatIndex: 1));
        }

        return chatList;
      } else {
        var response = await http.post(Uri.parse('$BASE_URL/completions'),
            headers: {
              'Authorization': 'Bearer $API_KEY',
              'Content-Type': 'application/json'
            },
            body: jsonEncode(
                {'model': modelId, 'prompt': message, 'max_tokens': 100}));

        //Para convertir los caracteres especiales que se usan en
        //el español
        String stringResponse =
            const Utf8Decoder().convert(response.body.codeUnits);

        Map jsonResponse = jsonDecode(stringResponse);

        if (jsonResponse['error'] != null) {
          throw HttpException(jsonResponse['error']['message']);
        }

        List<ChatModel> chatList = [];

        if (jsonResponse['choices'].length > 0) {
          chatList = List.generate(
              jsonResponse['choices'].length,
              (index) => ChatModel(
                  message: jsonResponse['choices'][index]['text'],
                  chatIndex: 1));
        }

        return chatList;
      }
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
