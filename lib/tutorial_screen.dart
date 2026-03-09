import 'package:flutter/material.dart';

import 'widgets/primary_button.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _controller = PageController();
  int _index = 0;

  static const slides = [
    ('Browse', 'Open any supported platform in the built-in browser.'),
    ('Detect', 'Smart sniffer finds downloadable public videos instantly.'),
    ('Download & Watch Offline', 'Save videos and play in full-screen anytime.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, size: 108, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 24),
                      Text(slides[i].$1, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(slides[i].$2, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? Theme.of(context).colorScheme.primary : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: _index == slides.length - 1 ? 'Start Using App' : 'Next',
                onPressed: () {
                  if (_index == slides.length - 1) {
                    Navigator.pop(context);
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
