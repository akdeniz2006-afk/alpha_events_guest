import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StagePollScreen extends StatelessWidget {
  const StagePollScreen({super.key});

  static const String activeEventId = 'zurich_2026';

  Stream<QuerySnapshot<Map<String, dynamic>>> _pollStream() {
    return FirebaseFirestore.instance
        .collection('event_polls')
        .where('eventId', isEqualTo: activeEventId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _answersStream(String pollId) {
    return FirebaseFirestore.instance
        .collection('event_poll_answers')
        .where('eventId', isEqualTo: activeEventId)
        .where('pollId', isEqualTo: pollId)
        .snapshots();
  }

  QueryDocumentSnapshot<Map<String, dynamic>>? _pickStagePoll(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final stageDocs = docs.where((doc) {
      final data = doc.data();
      final isActive = data['isActive'] == true || data['status'] == 'active';
      final showOnStage = data['showOnStage'] == true;
      return isActive && showOnStage;
    }).toList();

    if (stageDocs.isEmpty) return null;

    stageDocs.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return stageDocs.first;
  }

  Map<int, int> _countAnswers(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final counts = <int, int>{};

    for (final doc in docs) {
      final data = doc.data();
      final rawIndex = data['selectedOptionIndex'];
      final index = rawIndex is int ? rawIndex : int.tryParse('$rawIndex');

      if (index == null) continue;

      counts[index] = (counts[index] ?? 0) + 1;
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B1F),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _pollStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _message('Sahne anketi yüklenemedi.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final poll = _pickStagePoll(docs);

          if (poll == null) {
            return _waitingScreen();
          }

          final data = poll.data();
          final question = (data['question'] ?? '').toString();
          final optionsRaw = data['options'];
          final options = optionsRaw is List
              ? optionsRaw.map((item) => item.toString()).toList()
              : <String>[];
          final showResults = data['showResults'] == true;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _answersStream(poll.id),
            builder: (context, answerSnapshot) {
              final answers = answerSnapshot.data?.docs ?? [];
              final counts = _countAnswers(answers);
              final totalVotes = answers.length;

              if (showResults) {
                return _resultsScreen(
                  question: question,
                  options: options,
                  counts: counts,
                  totalVotes: totalVotes,
                );
              }

              return _questionScreen(
                question: question,
                options: options,
                totalVotes: totalVotes,
              );
            },
          );
        },
      ),
    );
  }

  Widget _waitingScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF050B1F),
            Color(0xFF102A67),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.poll_rounded,
            color: Colors.white,
            size: 90,
          ),
          SizedBox(height: 32),
          Text(
            'Canlı Anket Bekleniyor',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Admin panelden sahneye yansıtılacak anket seçildiğinde burada görünecek.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionScreen({
    required String question,
    required List<String> options,
    required int totalVotes,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF050B1F),
            Color(0xFF153A8A),
            Color(0xFF2563EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topBar(totalVotes: totalVotes, resultMode: false),
          const Spacer(),
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 58,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 42),
          ...List.generate(options.length, (index) {
            return _stageOption(
              letter: String.fromCharCode(65 + index),
              text: options[index],
            );
          }),
          const Spacer(),
          const Center(
            child: Text(
              'Cevabınızı telefonunuzdaki Guest App üzerinden gönderin',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultsScreen({
    required String question,
    required List<String> options,
    required Map<int, int> counts,
    required int totalVotes,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF050B1F),
            Color(0xFF102A67),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topBar(totalVotes: totalVotes, resultMode: true),
          const SizedBox(height: 46),
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 34),
          Expanded(
            child: Column(
              children: List.generate(options.length, (index) {
                final count = counts[index] ?? 0;
                final percent = totalVotes == 0
                    ? 0
                    : ((count / totalVotes) * 100).round();

                return _resultRow(
                  letter: String.fromCharCode(65 + index),
                  text: options[index],
                  count: count,
                  percent: percent,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar({
    required int totalVotes,
    required bool resultMode,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
          ),
          child: Text(
            resultMode ? 'CANLI SONUÇLAR' : 'CANLI ANKET',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
          ),
          child: Text(
            'Oy: $totalVotes',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stageOption({
    required String letter,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              letter,
              style: const TextStyle(
                color: Color(0xFF06122D),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow({
    required String letter,
    required String text,
    required int count,
    required int percent,
  }) {
    final widthFactor = percent / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: Color(0xFF06122D),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '%$percent',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 18),
              Text(
                '$count oy',
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(
                  height: 22,
                  color: Colors.white.withOpacity(0.14),
                ),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: Container(
                    height: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}