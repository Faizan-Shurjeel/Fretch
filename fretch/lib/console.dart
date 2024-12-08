import 'package:flutter/material.dart';

class ConsoleOutput extends StatelessWidget {
  final List<String> messages;
  final ScrollController _scrollController = ScrollController();

  ConsoleOutput({super.key, required this.messages});

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return Text(
            messages[index],
            style: const TextStyle(
              color: Colors.green,
              fontFamily: 'Consolas',
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }
}
