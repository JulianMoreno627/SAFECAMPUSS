import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contacto_emergencia.dart';

class EmergencyContactsState {
  final List<ContactoEmergencia> contacts;
  final bool isLoading;

  EmergencyContactsState({
    required this.contacts,
    this.isLoading = false,
  });

  EmergencyContactsState copyWith({
    List<ContactoEmergencia>? contacts,
    bool? isLoading,
  }) {
    return EmergencyContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EmergencyContactsNotifier extends StateNotifier<EmergencyContactsState> {
  static const String _boxName = 'emergency_contacts';

  EmergencyContactsNotifier() : super(EmergencyContactsState(contacts: [])) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final box = await Hive.openBox(_boxName);
    final List<dynamic> rawContacts = box.get('list', defaultValue: []);
    final contacts = rawContacts
        .map((c) => ContactoEmergencia.fromMap(Map<String, dynamic>.from(c)))
        .toList();
    state = state.copyWith(contacts: contacts, isLoading: false);
  }

  Future<void> addContact(ContactoEmergencia contact) async {
    final box = await Hive.openBox(_boxName);
    final newContacts = [...state.contacts, contact];
    await box.put('list', newContacts.map((c) => c.toMap()).toList());
    state = state.copyWith(contacts: newContacts);
  }

  Future<void> removeContact(String id) async {
    final box = await Hive.openBox(_boxName);
    final newContacts = state.contacts.where((c) => c.id != id).toList();
    await box.put('list', newContacts.map((c) => c.toMap()).toList());
    state = state.copyWith(contacts: newContacts);
  }
}

final emergencyContactsProvider =
    StateNotifierProvider<EmergencyContactsNotifier, EmergencyContactsState>((ref) {
  return EmergencyContactsNotifier();
});
