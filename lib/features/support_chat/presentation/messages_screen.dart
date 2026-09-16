import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/models/support_message.dart';
import 'package:mywork/features/support_chat/application/support_chat_providers.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _input = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final conversationId = ref.read(conversationIdProvider).valueOrNull;
    if (conversationId == null) return;

    setState(() => _sending = true);
    try {
      await ref.read(supportChatRepositoryProvider).sendMessage(
            conversationId: conversationId,
            content: text,
          );
      _input.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Support MyWork')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => const Center(child: Text('Erreur de chargement')),
              data: (rows) {
                final messages = rows.map(SupportMessage.fromMap).toList();
                if (messages.isEmpty) {
                  return const Center(child: Text('Écrivez-nous, nous vous répondrons rapidement.'));
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[messages.length - 1 - index];
                    return Align(
                      alignment: m.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: m.isFromUser
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          m.content,
                          style: TextStyle(
                            color: m.isFromUser ? Theme.of(context).colorScheme.onPrimary : null,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(hintText: 'Votre message...'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
