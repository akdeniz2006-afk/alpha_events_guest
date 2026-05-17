import 'package:flutter/material.dart';

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';
import '../widgets/pressable_scale.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  int organizationScore = 0;
  int programScore = 0;
  int accommodationScore = 0;
  int supportScore = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void submitEvaluation() {
    showEvaluationMessage(
      context,
      'Teşekkür ederiz. Değerlendirmeniz demo olarak kaydedildi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackHeader(
              title: 'Etkinlik Değerlendirme',
              subtitle: demoGuest.eventTitle,
            ),
            const SizedBox(height: 22),
            const EvaluationHeroCard(),
            const SizedBox(height: 20),
            EvaluationQuestionCard(
              title: 'Genel organizasyonu nasıl değerlendirirsiniz?',
              subtitle:
                  'Etkinliğin genel akışı, karşılama ve deneyim kalitesi.',
              score: organizationScore,
              onChanged: (value) {
                setState(() {
                  organizationScore = value;
                });
              },
            ),
            const SizedBox(height: 14),
            EvaluationQuestionCard(
              title: 'Program akışı nasıldı?',
              subtitle: 'Saat planı, içerik akışı ve yönlendirmeler.',
              score: programScore,
              onChanged: (value) {
                setState(() {
                  programScore = value;
                });
              },
            ),
            const SizedBox(height: 14),
            EvaluationQuestionCard(
              title: 'Konaklama deneyiminiz nasıldı?',
              subtitle: 'Otel, oda, check-in ve konaklama notları.',
              score: accommodationScore,
              onChanged: (value) {
                setState(() {
                  accommodationScore = value;
                });
              },
            ),
            const SizedBox(height: 14),
            EvaluationQuestionCard(
              title: 'Etkinlik destek deneyimi nasıldı?',
              subtitle: 'Koordinasyon, iletişim ve destek süreçleri.',
              score: supportScore,
              onChanged: (value) {
                setState(() {
                  supportScore = value;
                });
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'Ek yorumunuz',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.075),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: TextField(
                controller: commentController,
                maxLines: 5,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Eklemek istediğiniz yorumları yazabilirsiniz.',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.38),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 18),
            PressableScale(
              onTap: submitEvaluation,
              child: Container(
                height: 58,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E5E8C), Color(0xFF4C82AE)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4C82AE).withOpacity(0.28),
                      blurRadius: 22,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Değerlendirmeyi Gönder',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EvaluationHeroCard extends StatelessWidget {
  const EvaluationHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07101B), Color(0xFF14243A), Color(0xFF263B58)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF263B58).withOpacity(0.25),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.champagne.withOpacity(0.13),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: AppColors.champagne.withOpacity(0.24)),
            ),
            child: const Icon(
              Icons.rate_review_rounded,
              color: AppColors.champagne,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deneyiminiz bizim için değerli',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Geri bildiriminiz, bir sonraki etkinlik deneyimini daha iyi planlamamıza yardımcı olur.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    decoration: TextDecoration.none,
                    fontSize: 12.7,
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
}

class EvaluationQuestionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int score;
  final ValueChanged<int> onChanged;

  const EvaluationQuestionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.50),
              decoration: TextDecoration.none,
              fontSize: 12.5,
              height: 1.32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(5, (index) {
              final int value = index + 1;
              final bool selected = value <= score;

              return Padding(
                padding: EdgeInsets.only(right: index == 4 ? 0 : 8),
                child: PressableScale(
                  onTap: () => onChanged(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.champagne.withOpacity(0.18)
                          : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppColors.champagne.withOpacity(0.42)
                            : Colors.white.withOpacity(0.09),
                      ),
                    ),
                    child: Icon(
                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                      color: selected
                          ? AppColors.champagne
                          : Colors.white.withOpacity(0.38),
                      size: 25,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

void showEvaluationMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1F1F24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
