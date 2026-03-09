import 'package:flutter/material.dart';

class BrowserToolbar extends StatelessWidget {
  const BrowserToolbar({
    super.key,
    required this.controller,
    required this.onGo,
    required this.onBack,
    required this.onForward,
    required this.onRefresh,
  });

  final TextEditingController controller;
  final VoidCallback onGo;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new)),
            IconButton(onPressed: onForward, icon: const Icon(Icons.arrow_forward_ios)),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => onGo(),
                decoration: const InputDecoration(
                  hintText: 'Paste or type URL',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh)),
          ],
        ),
      ),
    );
  }
}
