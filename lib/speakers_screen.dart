import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './widgets/app_page.dart';

class SpeakersScreen extends StatelessWidget {
  const SpeakersScreen({super.key});

  static const String eventId = 'zurich_2026';

  List<_SpeakerData> demoSpeakers() {
    return const [
      _SpeakerData(
        id: 'speaker_1',
        fullName: 'Dr. Mehmet Yılmaz',
        title: 'Liderlik ve Değişim Yönetimi',
        topic: 'Yeni Nesil Liderlik ve Kurumsal Dönüşüm',
        photoUrl:
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=800',
      ),
      _SpeakerData(
        id: 'speaker_2',
        fullName: 'Ayşe Demir',
        title: 'Strateji Danışmanı',
        topic: 'Takım Motivasyonu ve Sürdürülebilir Başarı',
        photoUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800',
      ),
      _SpeakerData(
        id: 'speaker_3',
        fullName: 'Murat Kaya',
        title: 'Teknoloji ve İnovasyon Uzmanı',
        topic: 'Yapay Zeka Çağında İş Dünyası',
        photoUrl:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800',
      ),
    ];
  }

  Stream<List<_SpeakerData>> speakersStream() {
    return FirebaseFirestore.instance
        .collection('event_speakers')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      final speakers = snapshot.docs.map((doc) {
        final data = doc.data();

        return _SpeakerData(
          id: doc.id,
          fullName: (data['fullName'] ?? data['name'] ?? '').toString(),
          title: (data['title'] ?? '').toString(),
          topic: (data['topic'] ?? '').toString(),
          photoUrl: (data['photoUrl'] ?? '').toString(),
        );
      }).where((speaker) {
        return speaker.fullName.trim().isNotEmpty;
      }).toList();

      speakers.sort((a, b) => a.fullName.compareTo(b.fullName));

      if (speakers.isEmpty) {
        return demoSpeakers();
      }

      return speakers;
    });
  }

  void openQuestionDialog(BuildContext context, _SpeakerData speaker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SpeakerQuestionSheet(speaker: speaker),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SafeArea(
        child: StreamBuilder<List<_SpeakerData>>(
          stream: speakersStream(),
          builder: (context, snapshot) {
            final speakers = snapshot.data ?? demoSpeakers();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Konuşmacılar',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0F172A),
                            Color(0xFF1E3A8A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.record_voice_over_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Etkinlik konuşmacıları',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Konuşmacıları inceleyebilir ve oturum öncesinde soru gönderebilirsin.',
                            style: TextStyle(
                              color: Color(0xFFDDE7FF),
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 130),
                  sliver: SliverList.separated(
                    itemCount: speakers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final speaker = speakers[index];

                      return SpeakerCard(
                        speaker: speaker,
                        onAskQuestion: () => openQuestionDialog(
                          context,
                          speaker,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SpeakerData {
  final String id;
  final String fullName;
  final String title;
  final String topic;
  final String photoUrl;

  const _SpeakerData({
    required this.id,
    required this.fullName,
    required this.title,
    required this.topic,
    required this.photoUrl,
  });
}

class SpeakerCard extends StatelessWidget {
  final _SpeakerData speaker;
  final VoidCallback onAskQuestion;

  const SpeakerCard({
    super.key,
    required this.speaker,
    required this.onAskQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpeakerPhoto(url: speaker.photoUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    speaker.fullName,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (speaker.title.trim().isNotEmpty)
                    Text(
                      speaker.title,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Konuşma Konusu',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          speaker.topic.trim().isEmpty
                              ? 'Konu bilgisi yakında eklenecek.'
                              : speaker.topic,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: onAskQuestion,
                      icon: const Icon(Icons.question_answer_rounded, size: 18),
                      label: const Text('Soru Sor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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

class SpeakerPhoto extends StatelessWidget {
  final String url;

  const SpeakerPhoto({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 112,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.trim().isEmpty
          ? const Icon(
              Icons.person_rounded,
              color: Color(0xFF64748B),
              size: 44,
            )
          : HtmlNetworkImage(
              key: ValueKey(url),
              url: url,
            ),
    );
  }
}


class HtmlNetworkImage extends StatefulWidget {
  final String url;

  const HtmlNetworkImage({
    super.key,
    required this.url,
  });

  @override
  State<HtmlNetworkImage> createState() => _HtmlNetworkImageState();
}

class _HtmlNetworkImageState extends State<HtmlNetworkImage> {
  late final String viewType;

  static final Set<String> registeredViewTypes = <String>{};

  @override
  void initState() {
    super.initState();

    viewType = 'guest-speaker-image-${widget.url.hashCode}';

    if (!registeredViewTypes.contains(viewType)) {
      registeredViewTypes.add(viewType);

      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final image = html.ImageElement()
            ..src = widget.url
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover'
            ..style.border = '0'
            ..style.display = 'block';

          return image;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewType);
  }
}


class SpeakerQuestionSheet extends StatefulWidget {
  final _SpeakerData speaker;

  const SpeakerQuestionSheet({
    super.key,
    required this.speaker,
  });

  @override
  State<SpeakerQuestionSheet> createState() => _SpeakerQuestionSheetState();
}

class _SpeakerQuestionSheetState extends State<SpeakerQuestionSheet> {
  final TextEditingController questionController = TextEditingController();

  bool isSending = false;
  String infoMessage = '';
  bool isErrorMessage = false;

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> getGuestInfo() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'guestId': prefs.getString('guestId') ?? '',
      'guestName': prefs.getString('guestName') ?? '',
      'guestCode': prefs.getString('guestCode') ?? '',
      'whatsappNumber': prefs.getString('whatsappNumber') ?? '',
      'eventId': prefs.getString('eventId') ?? SpeakersScreen.eventId,
    };
  }

  Future<void> submitQuestion() async {
    final question = questionController.text.trim();

    if (question.length < 5) {
      setState(() {
        infoMessage = 'Lütfen sorunuzu biraz daha detaylı yazın.';
        isErrorMessage = true;
      });
      return;
    }

    setState(() {
      isSending = true;
      infoMessage = '';
      isErrorMessage = false;
    });

    try {
      final guest = await getGuestInfo();

      await FirebaseFirestore.instance.collection('speaker_questions').add({
        'eventId': guest['eventId']!.isEmpty
            ? SpeakersScreen.eventId
            : guest['eventId'],
        'speakerId': widget.speaker.id,
        'speakerName': widget.speaker.fullName,
        'speakerTopic': widget.speaker.topic,
        'question': question,
        'guestId': guest['guestId'],
        'guestName': guest['guestName'],
        'guestCode': guest['guestCode'],
        'whatsappNumber': guest['whatsappNumber'],
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        infoMessage = 'Sorunuz başarıyla kaydedildi.';
        isErrorMessage = false;
      });

      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorunuz konuşmacıya iletilmek üzere kaydedildi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          infoMessage = 'Soru gönderilemedi: $error';
          isErrorMessage = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.speaker.fullName,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.speaker.topic,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: questionController,
                minLines: 4,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
                cursorColor: Color(0xFF2563EB),
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Konuşmacıya sormak istediğiniz soruyu yazın...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                ),
              ),
              if (infoMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isErrorMessage
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isErrorMessage
                          ? const Color(0xFFFECACA)
                          : const Color(0xFFA7F3D0),
                    ),
                  ),
                  child: Text(
                    infoMessage,
                    style: TextStyle(
                      color: isErrorMessage
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF047857),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isSending ? null : submitQuestion,
                  icon: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(isSending ? 'Gönderiliyor...' : 'Soruyu Gönder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}