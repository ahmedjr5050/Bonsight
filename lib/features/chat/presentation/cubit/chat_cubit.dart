import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bonssight/features/chat/data/chat_api_service.dart';

class ChatMessage extends Equatable {
  final String role; // 'user' or 'assistant'
  final String content;

  const ChatMessage({required this.role, required this.content});

  @override
  List<Object?> get props => [role, content];
}

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isSending, error];
}

class ChatCubit extends Cubit<ChatState> {
  final ChatApiService chatService;
  List<String> _fractureTypes = [];

  ChatCubit({required this.chatService}) : super(const ChatState());

  void seedContext({
    required String initialMessage,
    required List<String> fractureTypes,
  }) {
    _fractureTypes = fractureTypes;
    _sendUserMessage(initialMessage);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _sendUserMessage(text.trim());
  }

  Future<void> _sendUserMessage(String text) async {
    final history = state.messages
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(role: 'user', content: text),
        ],
        isSending: true,
        error: null,
      ),
    );

    try {
      final reply = await chatService.sendMessage(
        userMessage: text,
        fractureTypes: _fractureTypes,
        history: history,
      );
      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            ChatMessage(role: 'assistant', content: reply),
          ],
          isSending: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSending: false, error: e.toString()));
    }
  }
}
