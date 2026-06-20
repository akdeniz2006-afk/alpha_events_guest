import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/pressable_scale.dart';
import 'login_screen.dart';

class OperationDashboardScreen extends StatefulWidget {
  const OperationDashboardScreen({super.key});

  @override
  State<OperationDashboardScreen> createState() =>
      _OperationDashboardScreenState();
}

class _OperationDashboardScreenState extends State<OperationDashboardScreen> {
  static const String eventId = 'zurich_2026';

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final ValueNotifier<int> searchVersion = ValueNotifier<int>(0);

  String selectedTab = 'Katılımcılar';
  String selectedFilter = 'Tümü';

  final List<String> tabs = const [
    'Katılımcılar',
    'Odalar',
    'Transfer',
    'Program',
    'Duyurular',
    'Aktiviteler',
  ];

  final List<String> filters = const [
    'Tümü',
    'Oda Eksik',
    'Transfer Eksik',
    'Check-in Bekleyen',
    'VIP / Not',
  ];

  bool get hasSearchText {
    return searchController.text.trim().isNotEmpty;
  }

  bool get hasActiveFilter {
    return selectedFilter != 'Tümü';
  }

  bool get canShowParticipantList {
    return hasSearchText || hasActiveFilter;
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    searchVersion.dispose();
    super.dispose();
  }

  void refreshSearchResults() {
    searchVersion.value++;
  }

  void refreshKeepingSearchFocus() {
    searchVersion.value++;
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> toggleCheckIn(OperationGuestItem item) async {
    final newStatus =
        item.checkInStatus == 'Tamamlandı' ? 'Bekliyor' : 'Tamamlandı';

    await FirebaseFirestore.instance
        .collection('event_guests')
        .doc(item.id)
        .update({
      'checkInStatus': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> guestsStream() {
    return FirebaseFirestore.instance
        .collection('event_guests')
        .where('eventId', isEqualTo: eventId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> transportsStream() {
    return FirebaseFirestore.instance
        .collection('event_transports')
        .where('eventId', isEqualTo: eventId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> programStream() {
    return FirebaseFirestore.instance
        .collection('event_program')
        .where('eventId', isEqualTo: eventId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> announcementsStream() {
    return FirebaseFirestore.instance
        .collection('event_announcements')
        .where('eventId', isEqualTo: eventId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> activitiesStream() {
    return FirebaseFirestore.instance
        .collection('event_activities')
        .where('eventId', isEqualTo: eventId)
        .snapshots();
  }

  List<OperationGuestItem> buildGuests(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = snapshot.docs.map((doc) {
      return OperationGuestItem.fromFirestore(id: doc.id, data: doc.data());
    }).toList();

    items.sort((a, b) {
      final vipSort = (b.isVip ? 1 : 0).compareTo(a.isVip ? 1 : 0);
      if (vipSort != 0) return vipSort;

      final missingSort = ((a.hasRoom && a.hasTransport) ? 1 : 0)
          .compareTo((b.hasRoom && b.hasTransport) ? 1 : 0);
      if (missingSort != 0) return missingSort;

      return normalizeSearchText(a.name).compareTo(normalizeSearchText(b.name));
    });

    return items;
  }

  String normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .trim();
  }

  bool containsNormalized(String source, String query) {
    return normalizeSearchText(source).contains(normalizeSearchText(query));
  }

  bool startsWithNormalized(String source, String query) {
    return normalizeSearchText(source).startsWith(normalizeSearchText(query));
  }

  bool get isSearchNumeric {
    final query = normalizeSearchText(searchController.text);
    return RegExp(r'^[0-9]+$').hasMatch(query);
  }

  List<OperationGuestItem> filterGuests(List<OperationGuestItem> items) {
    final query = normalizeSearchText(searchController.text);

    return items.where((item) {
      final queryLength = query.length;

      final matchesName = query.isNotEmpty && containsNormalized(item.name, query);

      final matchesRoomNumber = isSearchNumeric &&
          queryLength >= 2 &&
          containsNormalized(item.room, query);

      final matchesMainFields = queryLength >= 3 &&
          (containsNormalized(item.company, query) ||
              containsNormalized(item.department, query) ||
              containsNormalized(item.hotel, query) ||
              containsNormalized(item.transport, query) ||
              containsNormalized(item.arrival, query) ||
              containsNormalized(item.note, query));

      final matchesCodeFields = queryLength >= 4 &&
          (containsNormalized(item.code, query) ||
              containsNormalized(item.guestId, query));

      final matchesSearch = query.isEmpty ||
          matchesName ||
          matchesRoomNumber ||
          matchesMainFields ||
          matchesCodeFields;

      final matchesFilter = switch (selectedFilter) {
        'Tümü' => true,
        'Oda Eksik' => !item.hasRoom,
        'Transfer Eksik' => !item.hasTransport,
        'Check-in Bekleyen' => item.checkInStatus == 'Bekliyor',
        'VIP / Not' => item.isVip || item.note.isNotEmpty,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<OperationGuestItem> filterRoomGuests(List<OperationGuestItem> items) {
    final query = normalizeSearchText(searchController.text);

    return items.where((item) {
      final queryLength = query.length;

      final matchesName = query.isNotEmpty && containsNormalized(item.name, query);

      final matchesRoomNumber = queryLength >= 1 &&
          isSearchNumeric &&
          containsNormalized(item.room, query);

      final matchesHotel = queryLength >= 2 && containsNormalized(item.hotel, query);

      final matchesMainFields = queryLength >= 3 &&
          (containsNormalized(item.company, query) ||
              containsNormalized(item.department, query) ||
              containsNormalized(item.note, query));

      final matchesCodeFields = queryLength >= 4 &&
          (containsNormalized(item.code, query) ||
              containsNormalized(item.guestId, query));

      return query.isEmpty ||
          matchesName ||
          matchesRoomNumber ||
          matchesHotel ||
          matchesMainFields ||
          matchesCodeFields;
    }).toList();
  }

  int countWhere(
    List<OperationGuestItem> items,
    bool Function(OperationGuestItem) fn,
  ) {
    return items.where(fn).length;
  }

  bool matchesSearch(Map<String, dynamic> data) {
    final query = normalizeSearchText(searchController.text);
    if (query.isEmpty) return true;

    final joined = data.entries
        .where((entry) {
          final key = entry.key.toLowerCase();

          return key != 'phone' &&
              key != 'phonenumber' &&
              key != 'whatsapp' &&
              key != 'whatsappnumber' &&
              key != 'email' &&
              key != 'mail' &&
              key != 'receptionphone' &&
              key != 'driverphone' &&
              key != 'responsiblephone' &&
              key != 'contactphone';
        })
        .map((entry) => entry.value.toString())
        .join(' ');

    return containsNormalized(joined, query);
  }

  String textOf(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '-',
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }

    return fallback;
  }

  String listTextOf(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .join(', ');
    }

    return value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OperationHeader(onLogout: logout),
              const SizedBox(height: 14),
              OperationTabs(
                tabs: tabs,
                selectedTab: selectedTab,
                onChanged: (value) {
                  setState(() {
                    selectedTab = value;
                    searchController.clear();
                    selectedFilter = 'Tümü';
                  });
                },
              ),
              const SizedBox(height: 14),
              if (selectedTab == 'Katılımcılar') buildParticipantsTab(),
              if (selectedTab == 'Odalar') buildRoomsTab(),
              if (selectedTab == 'Transfer') buildTransportTab(),
              if (selectedTab == 'Program') buildProgramTab(),
              if (selectedTab == 'Duyurular') buildAnnouncementsTab(),
              if (selectedTab == 'Aktiviteler') buildActivitiesTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildParticipantsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: guestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const OperationLoading();
        }

        if (snapshot.hasError) {
          return OperationMessageBox(
            icon: Icons.error_outline_rounded,
            title: 'Katılımcılar alınamadı',
            message: '${snapshot.error}',
          );
        }

        final allItems = snapshot.hasData
            ? buildGuests(snapshot.data!)
            : <OperationGuestItem>[];

        final missingRoomCount = countWhere(allItems, (i) => !i.hasRoom);
        final missingTransportCount = countWhere(allItems, (i) => !i.hasTransport);
        final checkInWaitingCount =
            countWhere(allItems, (i) => i.checkInStatus == 'Bekliyor');
        final vipCount = countWhere(allItems, (i) => i.isVip || i.note.isNotEmpty);

        return Column(
          children: [
            OperationSummaryStrip(
              items: [
                OperationSummaryItem(
                  title: 'Toplam',
                  value: '${allItems.length}',
                  icon: Icons.groups_rounded,
                  color: AppColors.champagne,
                ),
                OperationSummaryItem(
                  title: 'Oda Eksik',
                  value: '$missingRoomCount',
                  icon: Icons.hotel_rounded,
                  color: AppColors.borusanOrange,
                ),
                OperationSummaryItem(
                  title: 'Transfer Eksik',
                  value: '$missingTransportCount',
                  icon: Icons.directions_bus_rounded,
                  color: AppColors.borusanOrange,
                ),
                OperationSummaryItem(
                  title: 'Check-in',
                  value: '$checkInWaitingCount',
                  icon: Icons.login_rounded,
                  color: AppColors.champagne,
                ),
                OperationSummaryItem(
                  title: 'VIP / Not',
                  value: '$vipCount',
                  icon: Icons.star_rounded,
                  color: AppColors.borusanOrange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            OperationSearchAndFilter(
              controller: searchController,
              focusNode: searchFocusNode,
              filters: filters,
              selectedFilter: selectedFilter,
              resultCount: null,
              hint: 'İsim ara. Kod için en az 4 karakter yaz.',
              onSearchChanged: (_) => refreshSearchResults(),
              onFilterChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<int>(
              valueListenable: searchVersion,
              builder: (context, _, __) {
                final visibleItems = canShowParticipantList
                    ? filterGuests(allItems)
                    : <OperationGuestItem>[];

                if (!canShowParticipantList) {
                  return OperationSearchPromptBox(
                    icon: Icons.search_rounded,
                    title: 'Katılımcı araması yapın',
                    message:
                        'Kalabalık etkinliklerde tüm katılımcılar otomatik listelenmez. İsimden aramak için bir harf yazabilirsiniz. Kod ile aramak için en az 4 karakter yazın.',
                    countText: '${allItems.length} katılımcı kayıtlı',
                  );
                }

                if (visibleItems.isEmpty) {
                  return const OperationMessageBox(
                    icon: Icons.search_off_rounded,
                    title: 'Katılımcı bulunamadı',
                    message: 'Arama veya filtreyi değiştirerek tekrar deneyin.',
                  );
                }

                return Column(
                  children: [
                    OperationResultHeader(
                      totalCount: allItems.length,
                      visibleCount: visibleItems.length,
                    ),
                    const SizedBox(height: 10),
                    ...visibleItems.map((item) {
                      return OperationGuestCard(
                        item: item,
                        onTap: () => openGuestDetail(item),
                        onToggleCheckIn: () => toggleCheckIn(item),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildRoomsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: guestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const OperationLoading();
        }

        if (snapshot.hasError) {
          return OperationMessageBox(
            icon: Icons.error_outline_rounded,
            title: 'Oda bilgileri alınamadı',
            message: '${snapshot.error}',
          );
        }

        final allGuests = snapshot.hasData
            ? buildGuests(snapshot.data!)
            : <OperationGuestItem>[];

        final roomGuests = allGuests.where((item) => item.hasRoom).toList();

        return Column(
          children: [
            OperationSummaryStrip(
              items: [
                OperationSummaryItem(
                  title: 'Katılımcı',
                  value: '${allGuests.length}',
                  icon: Icons.groups_rounded,
                  color: AppColors.champagne,
                ),
                OperationSummaryItem(
                  title: 'Oda Atanmış',
                  value: '${roomGuests.length}',
                  icon: Icons.hotel_rounded,
                  color: AppColors.champagne,
                ),
                OperationSummaryItem(
                  title: 'Oda Eksik',
                  value: '${allGuests.length - roomGuests.length}',
                  icon: Icons.meeting_room_rounded,
                  color: AppColors.borusanOrange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            OperationSearchBox(
              controller: searchController,
              focusNode: searchFocusNode,
              hint: 'Katılımcı, otel veya oda no ara...',
              resultCount: null,
              onChanged: (_) => refreshSearchResults(),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<int>(
              valueListenable: searchVersion,
              builder: (context, _, __) {
                final visibleRoomGuests = hasSearchText
                    ? filterRoomGuests(roomGuests)
                    : <OperationGuestItem>[];

                if (roomGuests.isEmpty) {
                  return const OperationMessageBox(
                    icon: Icons.info_outline_rounded,
                    title: 'Oda ataması yok',
                    message:
                        'event_guests içindeki katılımcı kayıtlarında oda bilgisi bulunamadı.',
                  );
                }

                if (!hasSearchText) {
                  return OperationSearchPromptBox(
                    icon: Icons.hotel_rounded,
                    title: 'Oda araması yapın',
                    message:
                        'Oda listesi otomatik açılmaz. Katılımcı adı, oda no veya otel adı yazarak arama yapın.',
                    countText: '${roomGuests.length} oda atanmış katılımcı',
                  );
                }

                if (visibleRoomGuests.isEmpty) {
                  return const OperationMessageBox(
                    icon: Icons.search_off_rounded,
                    title: 'Oda sonucu bulunamadı',
                    message: 'Katılımcı adı, otel veya oda numarası ile tekrar arayın.',
                  );
                }

                return Column(
                  children: [
                    OperationResultHeader(
                      totalCount: roomGuests.length,
                      visibleCount: visibleRoomGuests.length,
                    ),
                    const SizedBox(height: 10),
                    ...visibleRoomGuests.map((item) {
                      return OperationRoomGuestCard(
                        item: item,
                        onTap: () => openGuestDetail(item),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildTransportTab() {
    return CollectionTabBuilder(
      stream: transportsStream(),
      searchController: searchController,
      searchFocusNode: searchFocusNode,
      searchVersion: searchVersion,
      hint: 'Transfer, grup, araç, plaka, saat, buluşma noktası ara...',
      emptyTitle: 'Transfer kaydı yok',
      emptyMessage: 'Bu bölüm için henüz transfer grubu bulunmuyor.',
      matchesSearch: matchesSearch,
      onSearchChanged: refreshKeepingSearchFocus,
      recordBuilder: (doc) {
        final data = doc.data();

        final title = textOf(
          data,
          ['title', 'transportGroupId'],
          fallback: 'Transfer',
        );

        final time = textOf(data, ['time'], fallback: '');
        final location = textOf(data, ['location', 'meetingPoint'], fallback: '');
        final vehicle = textOf(data, ['vehicle'], fallback: '');
        final plate = textOf(data, ['plate'], fallback: '');
        final participantCount = textOf(data, ['participantCount'], fallback: '');
        final guestNames = listTextOf(data['guestNames']);

        return OperationRecordItem(
          icon: Icons.directions_bus_rounded,
          title: title,
          subtitle: [
            if (time.isNotEmpty && time != '-') time,
            if (location.isNotEmpty && location != '-') location,
          ].join(' · '),
          status: textOf(data, ['status', 'category', 'type'], fallback: ''),
          pills: [
            if (time.isNotEmpty && time != '-')
              OperationMiniPillData(Icons.schedule_rounded, time),
            if (participantCount.isNotEmpty && participantCount != '-')
              OperationMiniPillData(
                Icons.groups_rounded,
                '$participantCount kişi',
              ),
            if (vehicle.isNotEmpty && vehicle != '-')
              OperationMiniPillData(Icons.airport_shuttle_rounded, vehicle),
            if (plate.isNotEmpty && plate != '-')
              OperationMiniPillData(Icons.confirmation_number_rounded, plate),
          ],
          detailTitle: title,
          detailSubtitle: 'Transfer Bilgileri',
          rows: [
            InfoLine('Grup ID', textOf(data, ['transportGroupId'])),
            InfoLine('Başlık', textOf(data, ['title'])),
            InfoLine('Tip', textOf(data, ['type'])),
            InfoLine('Kategori', textOf(data, ['category'])),
            InfoLine('Saat', time),
            InfoLine('Lokasyon', textOf(data, ['location'])),
            InfoLine('Buluşma Noktası', textOf(data, ['meetingPoint'])),
            InfoLine('Araç', vehicle),
            InfoLine('Plaka', plate),
            InfoLine('Şoför', textOf(data, ['driver'])),
            InfoLine('Sorumlu', textOf(data, ['responsible'])),
            const InfoLine('Sorumlu Telefonu', 'Gizli'),
            InfoLine('Kapasite', textOf(data, ['capacity'])),
            InfoLine('Katılımcı Sayısı', participantCount),
            InfoLine('Katılımcılar', guestNames.isEmpty ? '-' : guestNames),
            InfoLine('Not', textOf(data, ['note'])),
            InfoLine('Uyarı', data['hasWarning'] == true ? 'Var' : 'Yok'),
            InfoLine('VIP', data['isVip'] == true ? 'Evet' : 'Hayır'),
          ],
        );
      },
    );
  }

  Widget buildProgramTab() {
    return CollectionTabBuilder(
      stream: programStream(),
      searchController: searchController,
      searchFocusNode: searchFocusNode,
      searchVersion: searchVersion,
      hint: 'Program, saat, lokasyon, konuşmacı ara...',
      emptyTitle: 'Program kaydı yok',
      emptyMessage: 'Bu bölüm için henüz program kaydı bulunmuyor.',
      matchesSearch: matchesSearch,
      onSearchChanged: refreshKeepingSearchFocus,
      recordBuilder: (doc) {
        final data = doc.data();

        final title = textOf(data, ['title'], fallback: 'Program');
        final day = textOf(data, ['dayTitle', 'dayDate'], fallback: '');
        final time = textOf(data, ['time'], fallback: '');
        final location = textOf(data, ['location'], fallback: '');

        return OperationRecordItem(
          icon: Icons.event_note_rounded,
          title: title,
          subtitle: [
            if (day.isNotEmpty && day != '-') day,
            if (time.isNotEmpty && time != '-') time,
            if (location.isNotEmpty && location != '-') location,
          ].join(' · '),
          status: textOf(data, ['guestAppStatus', 'status'], fallback: ''),
          pills: [
            if (day.isNotEmpty && day != '-')
              OperationMiniPillData(Icons.calendar_month_rounded, day),
            if (time.isNotEmpty && time != '-')
              OperationMiniPillData(Icons.schedule_rounded, time),
            if (location.isNotEmpty && location != '-')
              OperationMiniPillData(Icons.place_rounded, location),
          ],
          detailTitle: title,
          detailSubtitle: 'Program Bilgileri',
          rows: [
            InfoLine('Gün', textOf(data, ['dayTitle'])),
            InfoLine('Tarih', textOf(data, ['dayDate'])),
            InfoLine('Saat', time),
            InfoLine('Başlık', title),
            InfoLine('Lokasyon', location),
            InfoLine('Konuşmacı', textOf(data, ['speaker'])),
            InfoLine('Sorumlu', textOf(data, ['owner'])),
            InfoLine('Açıklama', textOf(data, ['description'])),
            InfoLine('Durum', textOf(data, ['status'])),
            InfoLine('Guest App', textOf(data, ['guestAppStatus'])),
            InfoLine('Öne Çıkan', data['isFeatured'] == true ? 'Evet' : 'Hayır'),
            InfoLine('Risk Notu', textOf(data, ['riskNote'])),
          ],
        );
      },
    );
  }

  Widget buildAnnouncementsTab() {
    return CollectionTabBuilder(
      stream: announcementsStream(),
      searchController: searchController,
      searchFocusNode: searchFocusNode,
      searchVersion: searchVersion,
      hint: 'Duyuru, açıklama, saat, hedef ara...',
      emptyTitle: 'Duyuru kaydı yok',
      emptyMessage: 'Bu bölüm için henüz duyuru bulunmuyor.',
      matchesSearch: matchesSearch,
      onSearchChanged: refreshKeepingSearchFocus,
      recordBuilder: (doc) {
        final data = doc.data();

        final title = textOf(data, ['title'], fallback: 'Duyuru');
        final date = textOf(data, ['date'], fallback: '');
        final time = textOf(data, ['time'], fallback: '');
        final type = textOf(data, ['type'], fallback: '');

        return OperationRecordItem(
          icon: Icons.campaign_rounded,
          title: title,
          subtitle: [
            if (date.isNotEmpty && date != '-') date,
            if (time.isNotEmpty && time != '-') time,
            if (type.isNotEmpty && type != '-') type,
          ].join(' · '),
          status: data['isUrgent'] == true
              ? 'Acil'
              : textOf(data, ['status', 'type'], fallback: ''),
          pills: [
            if (date.isNotEmpty && date != '-')
              OperationMiniPillData(Icons.calendar_month_rounded, date),
            if (time.isNotEmpty && time != '-')
              OperationMiniPillData(Icons.schedule_rounded, time),
            if (data['isUrgent'] == true)
              const OperationMiniPillData(
                Icons.priority_high_rounded,
                'Acil',
                warning: true,
              ),
          ],
          detailTitle: title,
          detailSubtitle: 'Duyuru Bilgileri',
          rows: [
            InfoLine('Tarih', date),
            InfoLine('Saat', time),
            InfoLine('Tip', type),
            InfoLine('Durum', textOf(data, ['status'])),
            InfoLine('Hedef', textOf(data, ['target'])),
            InfoLine('Öncelik', textOf(data, ['priority'])),
            InfoLine('Başlık', title),
            InfoLine('Açıklama', textOf(data, ['description'])),
            InfoLine('Acil', data['isUrgent'] == true ? 'Evet' : 'Hayır'),
          ],
        );
      },
    );
  }

  Widget buildActivitiesTab() {
    return CollectionTabBuilder(
      stream: activitiesStream(),
      searchController: searchController,
      searchFocusNode: searchFocusNode,
      searchVersion: searchVersion,
      hint: 'Aktivite, tarih, saat, lokasyon ara...',
      emptyTitle: 'Aktivite kaydı yok',
      emptyMessage: 'Bu bölüm için henüz aktivite kaydı bulunmuyor.',
      matchesSearch: matchesSearch,
      onSearchChanged: refreshKeepingSearchFocus,
      recordBuilder: (doc) {
        final data = doc.data();

        final title = textOf(data, ['title'], fallback: 'Aktivite');
        final date = textOf(data, ['date'], fallback: '');
        final time = textOf(data, ['time'], fallback: '');
        final location = textOf(data, ['location'], fallback: '');
        final capacity = textOf(data, ['capacity'], fallback: '');

        return OperationRecordItem(
          icon: Icons.local_activity_rounded,
          title: title,
          subtitle: [
            if (date.isNotEmpty && date != '-') date,
            if (time.isNotEmpty && time != '-') time,
            if (location.isNotEmpty && location != '-') location,
          ].join(' · '),
          status: textOf(data, ['category'], fallback: ''),
          pills: [
            if (date.isNotEmpty && date != '-')
              OperationMiniPillData(Icons.calendar_month_rounded, date),
            if (time.isNotEmpty && time != '-')
              OperationMiniPillData(Icons.schedule_rounded, time),
            if (capacity.isNotEmpty && capacity != '-')
              OperationMiniPillData(Icons.groups_rounded, 'Kapasite $capacity'),
          ],
          detailTitle: title,
          detailSubtitle: 'Aktivite Bilgileri',
          rows: [
            InfoLine('Başlık', title),
            InfoLine('Kategori', textOf(data, ['category'])),
            InfoLine('Tarih', date),
            InfoLine('Saat', time),
            InfoLine('Lokasyon', location),
            InfoLine('Kapasite', capacity),
            InfoLine('Açıklama', textOf(data, ['description'])),
            InfoLine(
              'Guest App Görünür',
              data['guestAppVisible'] == true ? 'Evet' : 'Hayır',
            ),
          ],
        );
      },
    );
  }

  void openGuestDetail(OperationGuestItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return OperationGuestDetailSheet(
          item: item,
          onToggleCheckIn: () {
            Navigator.of(context).pop();
            toggleCheckIn(item);
          },
        );
      },
    );
  }
}

class CollectionTabBuilder extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueNotifier<int> searchVersion;
  final String hint;
  final String emptyTitle;
  final String emptyMessage;
  final bool Function(Map<String, dynamic> data) matchesSearch;
  final OperationRecordItem Function(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) recordBuilder;
  final VoidCallback onSearchChanged;

  const CollectionTabBuilder({
    super.key,
    required this.stream,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchVersion,
    required this.hint,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.matchesSearch,
    required this.recordBuilder,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OperationSearchBox(
          controller: searchController,
          focusNode: searchFocusNode,
          hint: hint,
          onChanged: (_) => onSearchChanged(),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: searchVersion,
          builder: (context, _, __) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const OperationLoading();
                }

                if (snapshot.hasError) {
                  return OperationMessageBox(
                    icon: Icons.error_outline_rounded,
                    title: 'Veri alınamadı',
                    message: '${snapshot.error}',
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return OperationMessageBox(
                    icon: Icons.info_outline_rounded,
                    title: emptyTitle,
                    message: emptyMessage,
                  );
                }

                final visibleDocs = docs.where((doc) {
                  return matchesSearch(doc.data());
                }).toList();

                if (visibleDocs.isEmpty) {
                  return const OperationMessageBox(
                    icon: Icons.search_off_rounded,
                    title: 'Sonuç bulunamadı',
                    message: 'Arama metnini değiştirerek tekrar deneyin.',
                  );
                }

                final records = visibleDocs.map(recordBuilder).toList();

                return Column(
                  children: [
                    OperationResultHeader(
                      totalCount: docs.length,
                      visibleCount: visibleDocs.length,
                    ),
                    const SizedBox(height: 10),
                    ...records.map((record) {
                      return OperationRecordCard(record: record);
                    }),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class OperationHeader extends StatelessWidget {
  final VoidCallback onLogout;

  const OperationHeader({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: glassDecoration(radius: 26, opacity: 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.champagne.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: AppColors.champagne.withOpacity(0.18),
                  ),
                ),
                child: const Icon(
                  Icons.engineering_rounded,
                  color: AppColors.champagne,
                  size: 26,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Operasyon Paneli',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              PressableScale(
                onTap: onLogout,
                child: Container(
                  height: 39,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.075),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.white.withOpacity(0.72),
                        size: 19,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Çıkış',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          decoration: TextDecoration.none,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Telefon, WhatsApp ve e-posta gizlidir. Katılımcı ve oda listeleri arama ile açılır.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.56),
              decoration: TextDecoration.none,
              fontSize: 12,
              height: 1.28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class OperationTabs extends StatelessWidget {
  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onChanged;

  const OperationTabs({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = tabs[index];
          final selected = selectedTab == item;

          return PressableScale(
            onTap: () => onChanged(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.champagne.withOpacity(0.18)
                    : Colors.white.withOpacity(0.055),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: selected
                      ? AppColors.champagne.withOpacity(0.55)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Center(
                child: Text(
                  item,
                  style: TextStyle(
                    color: selected
                        ? AppColors.champagne
                        : Colors.white.withOpacity(0.62),
                    decoration: TextDecoration.none,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OperationSummaryStrip extends StatelessWidget {
  final List<OperationSummaryItem> items;

  const OperationSummaryStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final item = items[index];

          return Container(
            width: 112,
            padding: const EdgeInsets.all(12),
            decoration: glassDecoration(radius: 22, opacity: 0.065),
            child: Row(
              children: [
                Icon(item.icon, color: item.color, size: 23),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.52),
                          decoration: TextDecoration.none,
                          fontSize: 10.7,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OperationSummaryItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const OperationSummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class OperationSearchAndFilter extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> filters;
  final String selectedFilter;
  final int? resultCount;
  final String hint;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  const OperationSearchAndFilter({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.filters,
    required this.selectedFilter,
    required this.resultCount,
    required this.hint,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OperationSearchBox(
          controller: controller,
          focusNode: focusNode,
          hint: hint,
          resultCount: resultCount,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 39,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 7),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final selected = selectedFilter == filter;

              return PressableScale(
                onTap: () => onFilterChanged(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.champagne.withOpacity(0.18)
                        : Colors.white.withOpacity(0.055),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: selected
                          ? AppColors.champagne.withOpacity(0.55)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: selected
                            ? AppColors.champagne
                            : Colors.white.withOpacity(0.62),
                        decoration: TextDecoration.none,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class OperationSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final int? resultCount;
  final ValueChanged<String> onChanged;

  const OperationSearchBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
    this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: glassDecoration(radius: 19, opacity: 0.065),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.34),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.54),
          ),
          suffixIcon: resultCount == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      '$resultCount',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.48),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class OperationSearchPromptBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String countText;

  const OperationSearchPromptBox({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.countText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: glassDecoration(radius: 24, opacity: 0.065),
      child: Column(
        children: [
          Icon(icon, color: AppColors.champagne, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.52),
              decoration: TextDecoration.none,
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.champagne.withOpacity(0.12),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: AppColors.champagne.withOpacity(0.22),
              ),
            ),
            child: Text(
              countText,
              style: const TextStyle(
                color: AppColors.champagne,
                decoration: TextDecoration.none,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OperationResultHeader extends StatelessWidget {
  final int totalCount;
  final int visibleCount;

  const OperationResultHeader({
    super.key,
    required this.totalCount,
    required this.visibleCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$visibleCount sonuç',
          style: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '/ toplam $totalCount kayıt',
          style: TextStyle(
            color: Colors.white.withOpacity(0.44),
            decoration: TextDecoration.none,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.touch_app_rounded,
          color: Colors.white.withOpacity(0.34),
          size: 17,
        ),
        const SizedBox(width: 4),
        Text(
          'Detay için dokun',
          style: TextStyle(
            color: Colors.white.withOpacity(0.42),
            decoration: TextDecoration.none,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class OperationGuestCard extends StatelessWidget {
  final OperationGuestItem item;
  final VoidCallback onTap;
  final VoidCallback onToggleCheckIn;

  const OperationGuestCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleCheckIn,
  });

  Color get statusColor {
    if (item.isVip) return AppColors.borusanOrange;
    if (!item.hasRoom || !item.hasTransport) return AppColors.borusanOrange;
    if (item.checkInStatus == 'Tamamlandı') return AppColors.champagne;
    return Colors.white.withOpacity(0.74);
  }

  @override
  Widget build(BuildContext context) {
    final initial = item.name.isNotEmpty ? item.name.substring(0, 1) : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: PressableScale(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: glassDecoration(radius: 22, opacity: 0.068),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: statusColor.withOpacity(0.14),
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.isEmpty ? 'İsimsiz katılımcı' : item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 14.7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          [
                            if (item.company.isNotEmpty) item.company,
                            if (item.department.isNotEmpty) item.department,
                            if (item.code.isNotEmpty) item.code,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.48),
                            decoration: TextDecoration.none,
                            fontSize: 11.7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PressableScale(
                    onTap: onToggleCheckIn,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        color: item.checkInStatus == 'Tamamlandı'
                            ? AppColors.champagne.withOpacity(0.16)
                            : Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: item.checkInStatus == 'Tamamlandı'
                              ? AppColors.champagne.withOpacity(0.38)
                              : Colors.white.withOpacity(0.10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.checkInStatus == 'Tamamlandı'
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: item.checkInStatus == 'Tamamlandı'
                                ? AppColors.champagne
                                : Colors.white.withOpacity(0.56),
                            size: 17,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.checkInStatus == 'Tamamlandı'
                                ? 'Geldi'
                                : 'Bekliyor',
                            style: TextStyle(
                              color: item.checkInStatus == 'Tamamlandı'
                                  ? AppColors.champagne
                                  : Colors.white.withOpacity(0.58),
                              decoration: TextDecoration.none,
                              fontSize: 10.8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  SmallInfoPill(
                    icon: Icons.qr_code_rounded,
                    text: item.code.isEmpty ? item.guestId : item.code,
                  ),
                  SmallInfoPill(
                    icon: Icons.hotel_rounded,
                    text: item.hasRoom ? item.room : 'Oda eksik',
                    warning: !item.hasRoom,
                  ),
                  SmallInfoPill(
                    icon: Icons.directions_bus_rounded,
                    text: item.hasTransport ? item.transport : 'Transfer eksik',
                    warning: !item.hasTransport,
                  ),
                  if (item.isVip)
                    const SmallInfoPill(
                      icon: Icons.star_rounded,
                      text: 'VIP',
                      warning: true,
                    ),
                  if (item.note.isNotEmpty)
                    const SmallInfoPill(
                      icon: Icons.notes_rounded,
                      text: 'Not var',
                      warning: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OperationRoomGuestCard extends StatelessWidget {
  final OperationGuestItem item;
  final VoidCallback onTap;

  const OperationRoomGuestCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = item.name.isNotEmpty ? item.name.substring(0, 1) : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: PressableScale(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: glassDecoration(radius: 22, opacity: 0.068),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.champagne.withOpacity(0.13),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.champagne,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.isEmpty ? 'İsimsiz katılımcı' : item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 14.7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (item.hotel.isNotEmpty) item.hotel,
                        if (item.room.isNotEmpty) 'Oda ${item.room}',
                        if (item.code.isNotEmpty) item.code,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.48),
                        decoration: TextDecoration.none,
                        fontSize: 11.7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.champagne.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: AppColors.champagne.withOpacity(0.22),
                  ),
                ),
                child: Text(
                  item.room,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.champagne,
                    decoration: TextDecoration.none,
                    fontSize: 10.7,
                    fontWeight: FontWeight.w900,
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

class OperationRecordCard extends StatelessWidget {
  final OperationRecordItem record;

  const OperationRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: PressableScale(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) {
              return OperationRecordDetailSheet(record: record);
            },
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: glassDecoration(radius: 22, opacity: 0.068),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.champagne.withOpacity(0.13),
                    child: Icon(
                      record.icon,
                      color: AppColors.champagne,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title.isEmpty ? '-' : record.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 14.7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          record.subtitle.isEmpty ? '-' : record.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.48),
                            decoration: TextDecoration.none,
                            fontSize: 11.7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (record.status.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.champagne.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.champagne.withOpacity(0.22),
                        ),
                      ),
                      child: Text(
                        record.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.champagne,
                          decoration: TextDecoration.none,
                          fontSize: 10.7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (record.pills.isNotEmpty) ...[
                const SizedBox(height: 9),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: record.pills.map((pill) {
                    return SmallInfoPill(
                      icon: pill.icon,
                      text: pill.text,
                      warning: pill.warning,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class OperationRecordItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final List<OperationMiniPillData> pills;
  final String detailTitle;
  final String detailSubtitle;
  final List<InfoLine> rows;

  const OperationRecordItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.pills,
    required this.detailTitle,
    required this.detailSubtitle,
    required this.rows,
  });
}

class OperationMiniPillData {
  final IconData icon;
  final String text;
  final bool warning;

  const OperationMiniPillData(
    this.icon,
    this.text, {
    this.warning = false,
  });
}

class OperationRecordDetailSheet extends StatelessWidget {
  final OperationRecordItem record;

  const OperationRecordDetailSheet({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final visibleRows = record.rows.where((row) {
      final value = row.value.trim();
      return value.isNotEmpty && value != '-';
    }).toList();

    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101827),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: AppColors.champagne.withOpacity(0.13),
                    child: Icon(
                      record.icon,
                      color: AppColors.champagne,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.detailTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.detailSubtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.52),
                            decoration: TextDecoration.none,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DetailBlock(
                title: 'Detaylar',
                rows: visibleRows.map((row) {
                  return DetailLine(
                    icon: row.value == 'Gizli'
                        ? Icons.lock_rounded
                        : Icons.info_outline_rounded,
                    label: row.label,
                    value: row.value,
                    warning: row.warning,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoLine {
  final String label;
  final String value;
  final bool warning;

  const InfoLine(
    this.label,
    this.value, {
    this.warning = false,
  });
}

class SmallInfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool warning;

  const SmallInfoPill({
    super.key,
    required this.icon,
    required this.text,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = warning
        ? AppColors.borusanOrange
        : Colors.white.withOpacity(0.58);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 185),
            child: Text(
              text.isEmpty ? '-' : text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                decoration: TextDecoration.none,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OperationGuestDetailSheet extends StatelessWidget {
  final OperationGuestItem item;
  final VoidCallback onToggleCheckIn;

  const OperationGuestDetailSheet({
    super.key,
    required this.item,
    required this.onToggleCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101827),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(),
              const SizedBox(height: 18),
              Text(
                item.name.isEmpty ? 'İsimsiz katılımcı' : item.name,
                style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                [
                  if (item.company.isNotEmpty) item.company,
                  if (item.department.isNotEmpty) item.department,
                  if (item.code.isNotEmpty) item.code,
                ].join(' · '),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  decoration: TextDecoration.none,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              DetailBlock(
                title: 'Kimlik',
                rows: [
                  DetailLine(
                    icon: Icons.badge_rounded,
                    label: 'Guest ID',
                    value: item.guestId,
                  ),
                  DetailLine(
                    icon: Icons.qr_code_rounded,
                    label: 'Kod',
                    value: item.code,
                  ),
                  DetailLine(
                    icon: Icons.business_rounded,
                    label: 'Firma',
                    value: item.company,
                  ),
                  DetailLine(
                    icon: Icons.account_tree_rounded,
                    label: 'Departman',
                    value: item.department,
                  ),
                  const DetailLine(
                    icon: Icons.lock_rounded,
                    label: 'Telefon',
                    value: 'Gizli',
                  ),
                  const DetailLine(
                    icon: Icons.lock_rounded,
                    label: 'WhatsApp',
                    value: 'Gizli',
                  ),
                  const DetailLine(
                    icon: Icons.lock_rounded,
                    label: 'E-posta',
                    value: 'Gizli',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DetailBlock(
                title: 'Oda / Otel',
                rows: [
                  DetailLine(
                    icon: Icons.hotel_rounded,
                    label: 'Otel',
                    value: item.hotel,
                  ),
                  DetailLine(
                    icon: Icons.meeting_room_rounded,
                    label: 'Oda',
                    value: item.hasRoom ? item.room : 'Oda ataması eksik',
                    warning: !item.hasRoom,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DetailBlock(
                title: 'Transfer',
                rows: [
                  DetailLine(
                    icon: Icons.flight_land_rounded,
                    label: 'Varış',
                    value: item.arrival,
                  ),
                  DetailLine(
                    icon: Icons.directions_bus_rounded,
                    label: 'Transfer',
                    value: item.hasTransport
                        ? item.transport
                        : 'Transfer bilgisi eksik',
                    warning: !item.hasTransport,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DetailBlock(
                title: 'Durum',
                rows: [
                  DetailLine(
                    icon: Icons.login_rounded,
                    label: 'Check-in',
                    value: item.checkInStatus,
                  ),
                  DetailLine(
                    icon: Icons.star_rounded,
                    label: 'VIP',
                    value: item.isVip ? 'Evet' : 'Hayır',
                  ),
                  DetailLine(
                    icon: Icons.notes_rounded,
                    label: 'Not',
                    value: item.note,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PressableScale(
                onTap: onToggleCheckIn,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: item.checkInStatus == 'Tamamlandı'
                        ? Colors.white.withOpacity(0.08)
                        : AppColors.champagne.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.checkInStatus == 'Tamamlandı'
                          ? Colors.white.withOpacity(0.10)
                          : AppColors.champagne.withOpacity(0.40),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.checkInStatus == 'Tamamlandı'
                          ? 'Check-in Bekliyor Yap'
                          : 'Check-in Tamamlandı Yap',
                      style: TextStyle(
                        color: item.checkInStatus == 'Tamamlandı'
                            ? Colors.white.withOpacity(0.72)
                            : AppColors.champagne,
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
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

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class DetailBlock extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const DetailBlock({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows.where((row) => row is! SizedBox).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (visibleRows.isEmpty)
            Text(
              'Bilgi yok',
              style: TextStyle(
                color: Colors.white.withOpacity(0.50),
                decoration: TextDecoration.none,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...visibleRows,
        ],
      ),
    );
  }
}

class DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool warning;

  const DetailLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty || cleanValue == '-') {
      return const SizedBox.shrink();
    }

    final color = warning
        ? AppColors.borusanOrange
        : Colors.white.withOpacity(0.58);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.46),
                    decoration: TextDecoration.none,
                    fontSize: 11.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  cleanValue,
                  style: TextStyle(
                    color: warning
                        ? AppColors.borusanOrange
                        : Colors.white.withOpacity(0.84),
                    decoration: TextDecoration.none,
                    fontSize: 12.5,
                    height: 1.28,
                    fontWeight: FontWeight.w800,
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

class OperationLoading extends StatelessWidget {
  const OperationLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(
          color: AppColors.champagne,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class OperationMessageBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const OperationMessageBox({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: glassDecoration(radius: 24, opacity: 0.065),
      child: Column(
        children: [
          Icon(icon, color: AppColors.champagne, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.52),
              decoration: TextDecoration.none,
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class OperationGuestItem {
  final String id;
  final String guestId;
  final String name;
  final String company;
  final String department;
  final String code;
  final String room;
  final String hotel;
  final String transport;
  final String arrival;
  final String checkInStatus;
  final String note;
  final bool isVip;
  final bool hasRoom;
  final bool hasTransport;

  const OperationGuestItem({
    required this.id,
    required this.guestId,
    required this.name,
    required this.company,
    required this.department,
    required this.code,
    required this.room,
    required this.hotel,
    required this.transport,
    required this.arrival,
    required this.checkInStatus,
    required this.note,
    required this.isVip,
    required this.hasRoom,
    required this.hasTransport,
  });

  factory OperationGuestItem.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final room = (data['room'] ??
            data['roomNumber'] ??
            data['roomNo'] ??
            data['roomName'] ??
            '')
        .toString();

    final hotel = (data['hotel'] ??
            data['hotelName'] ??
            data['accommodationHotel'] ??
            '')
        .toString();

    final transport = (data['transport'] ??
            data['transportGroup'] ??
            data['transfer'] ??
            data['transferGroup'] ??
            '')
        .toString();

    return OperationGuestItem(
      id: id,
      guestId: (data['guestId'] ?? id).toString(),
      name: (data['guestName'] ?? data['name'] ?? '').toString(),
      company: (data['company'] ?? '').toString(),
      department: (data['department'] ?? '').toString(),
      code: (data['code'] ?? data['guestCode'] ?? '').toString(),
      room: room,
      hotel: hotel,
      transport: transport,
      arrival: (data['arrival'] ?? data['arrivalInfo'] ?? '').toString(),
      checkInStatus: (data['checkInStatus'] ?? 'Bekliyor').toString(),
      note: (data['note'] ?? '').toString(),
      isVip: data['isVip'] == true,
      hasRoom: data['hasRoom'] == true || room.trim().isNotEmpty,
      hasTransport: data['hasTransport'] == true || transport.trim().isNotEmpty,
    );
  }
}