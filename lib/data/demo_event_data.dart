class DemoGuest {
  final String fullName;
  final String company;
  final String eventTitle;
  final String eventDate;
  final String location;
  final String hotelName;
  final String roomNumber;
  final String roomType;
  final String checkIn;
  final String checkOut;
  final String roommateName;
  final String guestCode;

  const DemoGuest({
    required this.fullName,
    required this.company,
    required this.eventTitle,
    required this.eventDate,
    required this.location,
    required this.hotelName,
    required this.roomNumber,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.roommateName,
    required this.guestCode,
  });
}

class ProgramItem {
  final String time;
  final String title;
  final String location;
  final String description;

  const ProgramItem({
    required this.time,
    required this.title,
    required this.location,
    required this.description,
  });
}

class ContactItem {
  final String title;
  final String name;
  final String phone;
  final String type;

  const ContactItem({
    required this.title,
    required this.name,
    required this.phone,
    required this.type,
  });
}

class AnnouncementItem {
  final String title;
  final String message;
  final String date;

  const AnnouncementItem({
    required this.title,
    required this.message,
    required this.date,
  });
}

class VideoItem {
  final String title;
  final String description;
  final String thumbnailLabel;

  const VideoItem({
    required this.title,
    required this.description,
    required this.thumbnailLabel,
  });
}

const DemoGuest demoGuest = DemoGuest(
  fullName: 'Ayşe Demir',
  company: 'Borusan',
  eventTitle: 'Borusan Liderlik Zirvesi 2026',
  eventDate: '14–16 Mayıs 2026',
  location: 'İstanbul',
  hotelName: 'Swissôtel The Bosphorus',
  roomNumber: '412',
  roomType: 'Twin Oda',
  checkIn: '14 Mayıs 2026 / 14:00',
  checkOut: '16 Mayıs 2026 / 12:00',
  roommateName: 'Elif Kaya',
  guestCode: 'ALP304',
);

const List<String> demoHotelPhotos = [
  'assets/hotels/bosphorus.jpg',
  'assets/hotels/indir.jpg',
  'assets/hotels/indir (1).jpg',
  'assets/hotels/OIP.jpg',
  'assets/hotels/OIP (1).jpg',
];

const List<ProgramItem> demoProgram = [
  ProgramItem(
    time: '09:30',
    title: 'Karşılama Kahvesi',
    location: 'Fuaye Alanı',
    description: 'Katılımcı karşılama ve kayıt masası.',
  ),
  ProgramItem(
    time: '10:00',
    title: 'Açılış Konuşması',
    location: 'Ana Salon',
    description: 'Şirket yönetimi açılış konuşması.',
  ),
  ProgramItem(
    time: '11:30',
    title: 'Strateji Oturumu',
    location: 'Ana Salon',
    description: 'Yeni dönem hedefleri ve vizyon paylaşımı.',
  ),
  ProgramItem(
    time: '13:00',
    title: 'Öğle Yemeği',
    location: 'Restoran',
    description: 'Katılımcılar için öğle yemeği servisi.',
  ),
  ProgramItem(
    time: '19:30',
    title: 'Gala Yemeği',
    location: 'Balo Salonu',
    description: 'Akşam yemeği ve sahne programı.',
  ),
];

const List<ContactItem> demoContacts = [
  ContactItem(
    title: 'Alpha Events Koordinatörü',
    name: 'Ece Yılmaz',
    phone: '+90 555 000 00 01',
    type: 'coordinator',
  ),
  ContactItem(
    title: 'Otel Resepsiyon',
    name: 'Swissôtel',
    phone: '+90 212 000 00 00',
    type: 'hotel',
  ),
  ContactItem(
    title: 'Transfer Sorumlusu',
    name: 'Murat Kaya',
    phone: '+90 555 000 00 02',
    type: 'transfer',
  ),
  ContactItem(
    title: 'Sağlık / Acil Durum',
    name: '112 Acil',
    phone: '112',
    type: 'health',
  ),
];

const List<AnnouncementItem> demoAnnouncements = [
  AnnouncementItem(
    title: 'Transfer Saati',
    message: 'Akşam yemeği transferi saat 18:30’da otel ana girişinden hareket edecektir.',
    date: '14 Mayıs',
  ),
  AnnouncementItem(
    title: 'Gala Yemeği',
    message: 'Gala yemeği Balo Salonu’nda yapılacaktır.',
    date: '14 Mayıs',
  ),
  AnnouncementItem(
    title: 'Yaka Kartı',
    message: 'Lütfen tüm programlara yaka kartınız ile katılım sağlayınız.',
    date: '14 Mayıs',
  ),
];

const List<VideoItem> demoVideos = [
  VideoItem(
    title: 'Etkinliğe Hoş Geldiniz',
    description: 'Program ve genel akış hakkında kısa bilgilendirme.',
    thumbnailLabel: 'WELCOME',
  ),
  VideoItem(
    title: 'Otel ve Transfer Bilgileri',
    description: 'Konaklama, transfer ve yardım noktaları.',
    thumbnailLabel: 'INFO',
  ),
];