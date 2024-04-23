import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:friday/consts.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({Key? key}) : super(key: key);

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {

  final _openai= OpenAI.instance.build(
      token: OPENAI_API_KEY,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5,),
          ),
           enableLog: true,
          );

  final ChatUser _currentuser = ChatUser(id: '1',firstName: 'Ezio',lastName: 'Auditore');
  final ChatUser _gptchatuser = ChatUser(id: '2',firstName: 'friday',lastName: 'Ai');

  List<ChatMessage> _messages = <ChatMessage>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent,
        title: Text("FRIDAY"),
      ),
      body: DashChat(
          currentUser: _currentuser,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.deepOrangeAccent,
            containerColor: Colors.teal,
          textColor: Colors.white,
          ),
          onSend: (ChatMessage m) {
           getchatres(m);
          }, messages: _messages),
    );
  }
  Future<void> getchatres(ChatMessage m) async {
    setState(() {
      _messages.insert(0,m);
    });
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if(m.user== _currentuser) {
        return  Messages(role: Role.user, content: m.text);
      } else{
        return  Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request= ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory,
      maxToken: 200,);
    final response= await _openai.onChatCompletion(request: request);
    for(var element in response!.choices) {
      if(element.message !=null) {
        setState(() {
          _messages.insert(0, ChatMessage(
              user: _gptchatuser,
              createdAt: DateTime.now(),
              text: element.message!.content),
          );
        });
      }
    }
  }
}
