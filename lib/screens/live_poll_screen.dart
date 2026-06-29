import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LivePollScreen extends StatefulWidget {
  const LivePollScreen({super.key});

  @override
  State<LivePollScreen> createState() => _LivePollScreenState();
}

class _LivePollScreenState extends State<LivePollScreen> {
  static const String activeEventId = 'zurich_2026';

  String _guestId = '';
  String _guestName = '';
  String _guestCode = '';
  String _whatsappNumber = '';
  bool _loadingGuest = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadGuest();
  }

  Future<void> _loadGuest() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _guestId = prefs.getString('guestId') ?? '';
      _guestName = prefs.getString('guestName') ?? '';
      _guestCode = prefs.getString('guestCode') ?? '';
      _whatsappNumber = prefs.getString('whatsappNumber') ?? '';
      _loadingGuest = false;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _activePollStream() {
    return FirebaseFirestore.instance
        .collection('event_polls')
        .where('eventId', isEqualTo: activeEventId)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _answerStream(String pollId) {
    final answerId = '${pollId}_${_guestId.isEmpty ? _whatsappNumber : _guestId}';

    return FirebaseFirestore.instance
        .collection('event_poll_answers')
        .doc(answerId)
        .snapshots();
  }

  Future<void> _submitAnswer({
    required String pollId,
    required int selectedIndex,
    required String selectedText,
  }) async {
    if (_guestId.isEmpty && _whatsappNumber.isEmpty) {
      _showMessage('Katılımcı bilgisi bulunamadı. Lütfen tekrar giriş yap.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final answerId = '${pollId}_${_guestId.isEmpty ? _whatsappNumber : _guestId}';

      await FirebaseFirestore.instance
          .collection('event_poll_answers')
          .doc(answerId)
          .set({
        'eventId': activeEventId,
        'pollId': pollId,
        'guestId': _guestId,
        'guestName': _guestName,
        'guestCode': _guestCode,
        'whatsappNumber': _whatsappNumber,
        'selectedOptionIndex': selectedIndex,
        'selectedOptionText': selectedText,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _showMessage('Cevabınız alındı.');
    } catch (error) {
      _showMessage('Cevap kaydedilemedi: $error');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  QueryDocumentSnapshot<Map<String, dynamic>>? _pickActivePoll(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final activeDocs = docs.where((doc) {
      final data = doc.data();
      return data['isActive'] == true;
    }).toList();

    if (activeDocs.isEmpty) return null;

    activeDocs.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return activeDocs.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FB),
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Canlı Anket',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: _loadingGuest
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _activePollStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _pagePadding(
                      _emptyCard(
                        'Canlı anket yüklenirken hata oluştu. Lütfen daha sonra tekrar deneyin.',
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final activePoll = _pickActivePoll(docs);

                  if (activePoll == null) {
                    return _pagePadding(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _heroCard(),
                          const SizedBox(height: 18),
                          _emptyCard(
                            'Şu anda aktif bir canlı anket bulunmuyor.',
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildPoll(activePoll.id, activePoll.data());
                },
              ),
      ),
    );
  }

  Widget _buildPoll(String pollId, Map<String, dynamic> pollData) {
    final question = (pollData['question'] ?? '').toString();
    final optionsRaw = pollData['options'];
    final options = optionsRaw is List
        ? optionsRaw.map((item) => item.toString()).toList()
        : <String>[];

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _answerStream(pollId),
      builder: (context, answerSnapshot) {
        final hasAnswered = answerSnapshot.data?.exists == true;
        final answerData = answerSnapshot.data?.data();
        final selectedIndexRaw = answerData?['selectedOptionIndex'];
        final selectedIndex = selectedIndexRaw is int
            ? selectedIndexRaw
            : int.tryParse('$selectedIndexRaw');

        return _pagePadding(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroCard(),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.045),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sahne Sorusu',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      question,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 22,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (hasAnswered)
                      _answeredInfo(selectedIndex)
                    else
                      const Text(
                        'Cevabınızı seçin:',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    const SizedBox(height: 12),
                    ...List.generate(options.length, (index) {
                      final optionText = options[index];
                      final isSelected = hasAnswered && selectedIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _optionButton(
                          index: index,
                          text: optionText,
                          selected: isSelected,
                          disabled: hasAnswered || _saving,
                          onTap: () {
                            _submitAnswer(
                              pollId: pollId,
                              selectedIndex: index,
                              selectedText: optionText,
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _answeredInfo(int? selectedIndex) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF047857),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              selectedIndex == null
                  ? 'Cevabınız alındı.'
                  : 'Cevabınız alındı. Seçiminiz: ${String.fromCharCode(65 + selectedIndex)}',
              style: const TextStyle(
                color: Color(0xFF065F46),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionButton({
    required int index,
    required String text,
    required bool selected,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF06122D) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF06122D) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: selected ? Colors.white : const Color(0xFFEFF6FF),
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF06122D)
                      : const Color(0xFF2563EB),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (_saving)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (selected)
              const Icon(
                Icons.check_rounded,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF06122D),
            Color(0xFF2563EB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.poll_rounded,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Canlı Anket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sahnedeki soruyu telefonunuzdan yanıtlayın.',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _pagePadding(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: child,
    );
  }
}