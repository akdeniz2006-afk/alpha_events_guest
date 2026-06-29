import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  static const String activeEventId = 'zurich_2026';

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Tümü';
  String _searchText = '';

  final List<String> _categories = const [
    'Tümü',
    'Genel Bilgiler',
    'Konaklama',
    'Transfer',
    'Program',
    'Yemek & Gala',
    'Fotoğraf & Video',
    'Teknik Destek',
    'Acil Durum',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _faqStream() {
    return FirebaseFirestore.instance
        .collection('event_faqs')
        .where('eventId', isEqualTo: activeEventId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final filtered = docs.where((doc) {
      final data = doc.data();

      final question = (data['question'] ?? '').toString().toLowerCase();
      final answer = (data['answer'] ?? '').toString().toLowerCase();
      final category = (data['category'] ?? '').toString();

      final matchesCategory =
          _selectedCategory == 'Tümü' || category == _selectedCategory;

      final query = _searchText.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty || question.contains(query) || answer.contains(query);

      return matchesCategory && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      final aData = a.data();
      final bData = b.data();

      final aOrder = aData['order'];
      final bOrder = bData['order'];

      final aNumber = aOrder is int ? aOrder : int.tryParse('$aOrder') ?? 999;
      final bNumber = bOrder is int ? bOrder : int.tryParse('$bOrder') ?? 999;

      return aNumber.compareTo(bNumber);
    });

    return filtered;
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
          'SSS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _faqStream(),
          builder: (context, snapshot) {
            final hasError = snapshot.hasError;

            final docs = snapshot.data?.docs ?? [];
            final filteredDocs = _filteredDocs(docs);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroCard(),
                  const SizedBox(height: 18),
                  _searchBox(),
                  const SizedBox(height: 14),
                  _categoryChips(),
                  const SizedBox(height: 18),
                  if (hasError)
                    _emptyCard(
                      'SSS kayıtları yüklenirken hata oluştu. Lütfen daha sonra tekrar deneyin.',
                    )
                  else if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (filteredDocs.isEmpty)
                    _emptyCard('Bu kategori için henüz soru bulunmuyor.')
                  else
                    ...filteredDocs.map((doc) {
                      return _faqItem(doc.data());
                    }),
                ],
              ),
            );
          },
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
            Color(0xFF233A8B),
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
            Icons.help_center_rounded,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sıkça Sorulan Sorular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Etkinlik, konaklama, transfer ve program hakkında hızlı cevaplar.',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w700,
      ),
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Soru veya cevap ara',
        hintStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF334155),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: Color(0xFF233A8B),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _categoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final selected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF334155),
                fontWeight: FontWeight.w800,
              ),
              selectedColor: const Color(0xFF06122D),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? const Color(0xFF06122D)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _faqItem(Map<String, dynamic> data) {
    final question = (data['question'] ?? '').toString();
    final answer = (data['answer'] ?? '').toString();
    final category = (data['category'] ?? 'Genel Bilgiler').toString();
    final isImportant = data['isImportant'] == true;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isImportant
              ? const Color(0xFFF59E0B)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          leading: CircleAvatar(
            backgroundColor: isImportant
                ? const Color(0xFFFFFBEB)
                : const Color(0xFFEFF6FF),
            child: Icon(
              isImportant
                  ? Icons.priority_high_rounded
                  : Icons.help_outline_rounded,
              color: isImportant
                  ? const Color(0xFFD97706)
                  : const Color(0xFF1D4ED8),
            ),
          ),
          title: Text(
            question,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              category,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 15,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}