import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConsoleOutput extends StatefulWidget {
  final List<String> messages;
  final Function() onClear;

  const ConsoleOutput({
    super.key, 
    required this.messages,
    required this.onClear,
  });

  @override
  State<ConsoleOutput> createState() => _ConsoleOutputState();
}

class _ConsoleOutputState extends State<ConsoleOutput> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _copyToClipboard() {
    final text = widget.messages.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Console output copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: widget.messages.isEmpty ? null : _copyToClipboard,
              tooltip: 'Copy console output',
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: widget.messages.isEmpty ? null : widget.onClear,
              tooltip: 'Clear console',
            ),
          ],
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                return SelectableText(
                  widget.messages[index],
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'Consolas',
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
