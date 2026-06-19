import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/botanica_theme.dart';
import '../models/prediction.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../widgets/seedling_logo.dart';
import '../widgets/ambient_background.dart';

class ChatScreen extends StatefulWidget {
  final Prediction? prediction;

  const ChatScreen({super.key, this.prediction});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final p = widget.prediction;
    _messages.add(ChatMessage(
      role: 'assistant',
      text: p != null
          ? "Your ${p.plant.toLowerCase()} shows signs of ${p.disease}. "
              "I can help you understand it and treat it — what would you like to know?"
          : "Hi, I'm Sage 🌱 — your plant-care companion. "
              "Ask me anything about crops, diseases, pests or growing conditions.",
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;
    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(role: 'user', text: trimmed));
      _sending = true;
    });
    _scrollToEnd();

    try {
      final reply = await ApiService.chat(
        messages: _messages,
        plant: widget.prediction?.plant,
        disease: widget.prediction?.disease,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', text: reply));
        _sending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(const ChatMessage(
          role: 'assistant',
          text:
              "I couldn't reach the server. Make sure the AgroCure API is running, then try again.",
        ));
        _sending = false;
      });
    }
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = widget.prediction;
    final showQuickReplies = _messages.length == 1 && !_sending;

    return Scaffold(
      backgroundColor: c.bg,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _header(c),
              if (p != null) _contextChip(c, p),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  children: [
                    for (final m in _messages) _bubble(c, m),
                    if (_sending) _typing(c),
                  ],
                ),
              ),
              if (showQuickReplies) _quickReplies(c, p),
              _inputBar(c),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BotanicaColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 18, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: c.ink),
          ),
          const SizedBox(width: 14),
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.btn, shape: BoxShape.circle),
            child: SeedlingLogo(size: 22, leafColor: c.btnInk, strokeWidth: 1.7),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sage', style: Serif.style(16, c.ink)),
              Text('Plant care companion',
                  style: TextStyle(color: c.sage, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contextChip(BotanicaColors c, Prediction p) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: c.surf2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c.terra, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text('${p.plant} · ${p.disease} · ${p.confidencePct}',
              style: TextStyle(color: c.ink2, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _bubble(BotanicaColors c, ChatMessage m) {
    final isUser = m.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? c.ink : c.surf,
          border: isUser ? null : Border.all(color: c.line),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 20 : 6),
            topRight: Radius.circular(isUser ? 6 : 20),
            bottomLeft: const Radius.circular(20),
            bottomRight: const Radius.circular(20),
          ),
        ),
        child: Text(
          m.text,
          style: TextStyle(
            color: isUser ? c.bg : c.ink,
            fontSize: 13,
            height: 1.55,
          ),
        ),
      ),
    );
  }

  Widget _typing(BotanicaColors c) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surf,
          border: Border.all(color: c.line),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration:
                  BoxDecoration(color: c.ink3, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickReplies(BotanicaColors c, Prediction? p) {
    final suggestions = p != null
        ? ['How do I treat it?', 'Is it contagious?', 'How do I prevent it?']
        : ['Tomato leaf tips', 'Common crop diseases', 'How does AgroCure work?'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (int i = 0; i < suggestions.length; i++)
            GestureDetector(
              onTap: () => _send(suggestions[i]),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: i == 0 ? c.acc : c.surf2,
                  borderRadius: BorderRadius.circular(20),
                  border: i == 0 ? null : Border.all(color: c.line),
                ),
                child: Text(suggestions[i],
                    style: TextStyle(
                        color: i == 0 ? c.accInk : c.ink2, fontSize: 11)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _inputBar(BotanicaColors c) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 6, 4),
            decoration: BoxDecoration(
              color: c.surf.withValues(alpha: isDark ? 0.72 : 0.82),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: c.line),
            ),
            child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                cursorColor: c.sage,
                style: TextStyle(color: c.ink, fontSize: 13),
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Ask about your plant…',
                  hintStyle: TextStyle(color: c.ink3, fontSize: 13),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _send(_controller.text),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.btn,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.btn.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_upward, color: c.btnInk, size: 17),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
