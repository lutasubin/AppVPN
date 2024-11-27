import 'package:flutter/material.dart';
import 'package:get/get.dart';
class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'Why I need FAQ?',
      answer: 'It is a long established fact that a reader will '
          'be distracted by the readable content of a '
          'page when looking at its layout. The point of '
          'using Lorem Ipsum is that it has a more-or-'
          'less normal distribution of letters, as opposed '
          'to using \'Content here, content here\', making '
          'it look like readable English.\n\n'
          'Lorem Ipsum has been the industry\'s '
          'standard dummy text ever since the 1500s.',
    ),
    FAQItem(
      question: 'Is it safe?',
      answer: 'Please rest assured that our app is very safe and secure...',
    ),
    FAQItem(
      question: 'Can\'t connect, not stable or speed is slow?',
      answer: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('FAQ'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          return FAQExpansionTile(faqItem: faqItems[index]);
        },
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class FAQExpansionTile extends StatelessWidget {
  final FAQItem faqItem;

  const FAQExpansionTile({
    super.key,
    required this.faqItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            faqItem.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            faqItem.isExpanded ? Icons.remove : Icons.add,
            color: Colors.blue,
          ),
          onExpansionChanged: (expanded) {
            faqItem.isExpanded = expanded;
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faqItem.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 