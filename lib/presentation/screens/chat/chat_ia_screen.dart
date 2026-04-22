import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/providers/reports_provider.dart';

class ChatIaScreen extends ConsumerStatefulWidget {
  const ChatIaScreen({super.key});

  @override
  ConsumerState<ChatIaScreen> createState() => _ChatIaScreenState();
}

class _ChatIaScreenState extends ConsumerState<ChatIaScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Msg> _messages = [];
  ChatSession? _session;
  bool _isTyping = false;
  bool _ready = false;

  static const _suggestions = [
    '¿Qué zonas son más seguras ahora?',
    '¿Cómo reporto un incidente?',
    '¿Qué hago en caso de robo?',
    'Rutas seguras para esta hora',
    '¿Cómo activar el SOS?',
  ];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  void _initChat() {
    final service = AiService();
    if (!service.isReady) {
      setState(() {
        _messages.add(const _Msg(
          text: 'SafeBot no está disponible sin una clave de API configurada. '
              'Agrega GEMINI_API_KEY al archivo .env para activarlo.',
          isUser: false,
          isError: true,
        ));
      });
      return;
    }

    try {
      final reports = ref.read(reportsProvider).reportesCercanos;
      _session = service.startChatSession(reportesCercanos: reports);
      setState(() {
        _ready = true;
        _messages.add(const _Msg(
          text: '¡Hola! Soy SafeBot 🤖, tu asistente de seguridad en el campus. '
              'Estoy al tanto de los incidentes cercanos y listo para ayudarte. '
              '¿En qué puedo asistirte hoy?',
          isUser: false,
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(_Msg(
          text: 'Error al iniciar SafeBot: ${e.toString().replaceAll("Exception: ", "")}',
          isUser: false,
          isError: true,
        ));
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final query = text.trim();
    if (query.isEmpty || _session == null || _isTyping) return;

    _inputController.clear();
    setState(() {
      _messages.add(_Msg(text: query, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _session!.sendMessage(Content.text(query));
      final reply = response.text?.trim() ?? 'No pude procesar tu consulta.';
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_Msg(text: reply, isUser: false));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final detail = e.toString().replaceAll('Exception: ', '');
        setState(() {
          _isTyping = false;
          _messages.add(_Msg(
            text: 'Error al contactar SafeBot: $detail',
            isUser: false,
            isError: true,
          ));
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_messages.length <= 1 && _ready) _buildSuggestions(),
            Expanded(child: _buildMessages()),
            if (_isTyping) _buildTypingIndicator(),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SafeBot',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Text(
                  'Asistente de seguridad IA',
                  style: TextStyle(color: AppColors.accent, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.riskLow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 7, color: AppColors.riskLow),
                SizedBox(width: 5),
                Text('En línea',
                    style: TextStyle(color: AppColors.riskLow, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _send(_suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Text(
              _suggestions[i],
              style: const TextStyle(color: AppColors.accent, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _BubbleWidget(msg: _messages[i]),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
            ),
            child: const Icon(Icons.psychology_rounded,
                size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _send,
              decoration: InputDecoration(
                hintText: _ready
                    ? 'Pregúntale a SafeBot...'
                    : 'SafeBot no disponible',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                filled: true,
                fillColor: AppColors.cardColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _send(_inputController.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _ready ? AppColors.accent : Colors.white12,
                boxShadow: _ready
                    ? [
                        BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 8)
                      ]
                    : [],
              ),
              child: Icon(
                Icons.send_rounded,
                color: _ready ? Colors.black : Colors.white24,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class _Msg {
  final String text;
  final bool isUser;
  final bool isError;

  const _Msg({required this.text, required this.isUser, this.isError = false});
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _BubbleWidget extends StatelessWidget {
  final _Msg msg;

  const _BubbleWidget({required this.msg});

  @override
  Widget build(BuildContext context) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10, left: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, Color(0xFF0097A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.25),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            msg.text,
            style:
                const TextStyle(color: Colors.black, fontSize: 14, height: 1.4),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, bottom: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: msg.isError
                  ? AppColors.riskHigh.withValues(alpha: 0.2)
                  : const Color(0xFF1D1F33),
              border: Border.all(
                color: msg.isError
                    ? AppColors.riskHigh.withValues(alpha: 0.5)
                    : AppColors.accent.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              msg.isError
                  ? Icons.error_outline_rounded
                  : Icons.psychology_rounded,
              size: 16,
              color: msg.isError ? AppColors.riskHigh : AppColors.accent,
            ),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10, right: 60),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isError
                    ? AppColors.riskHigh.withValues(alpha: 0.1)
                    : AppColors.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: msg.isError
                      ? AppColors.riskHigh.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isError ? AppColors.riskHigh : Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset = ((_controller.value * 3) - i).clamp(0.0, 1.0);
            final opacity = (1 - (offset - 0.5).abs() * 2).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
