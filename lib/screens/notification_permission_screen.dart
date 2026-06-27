import 'package:flutter/material.dart';
import '../push_notification_service.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  bool isLoading = false;
  String? successMessage;
  String? errorMessage;

  Future<void> enableNotifications() async {
    setState(() {
      isLoading = true;
      successMessage = null;
      errorMessage = null;
    });

    try {
      final ok = await PushNotificationService.initializeAndSaveToken();

      if (!mounted) return;

      if (ok) {
        setState(() {
          successMessage =
              'Bildirim izni alındı ve cihaz token kaydı oluşturuldu.';
        });
      } else {
        setState(() {
          errorMessage =
              'Bildirim izni alınamadı. iPhone ayarlarında bu web uygulaması için bildirim izni kapalı olabilir.';
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Bildirim açılırken hata oluştu: $error';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Bildirimler',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF07122A),
                                Color(0xFF1E3A8A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.white,
                                size: 42,
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Etkinlik Bildirimlerini Aç',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Program değişiklikleri, duyurular ve önemli hatırlatmalar telefonuna push bildirim olarak gelsin.',
                                style: TextStyle(
                                  color: Color(0xFFDDE7FF),
                                  fontSize: 14,
                                  height: 1.4,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: const Text(
                            'iPhone’da bildirim alabilmek için uygulamanın ana ekrandan açılmış olması ve bildirim izninin verilmesi gerekir.',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 14,
                              height: 1.45,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (successMessage != null)
                          _MessageBox(
                            message: successMessage!,
                            isError: false,
                          ),
                        if (errorMessage != null)
                          _MessageBox(
                            message: errorMessage!,
                            isError: true,
                          ),
                        if (successMessage != null || errorMessage != null)
                          const SizedBox(height: 18),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : enableNotifications,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.notifications_rounded),
                            label: Text(
                              isLoading
                                  ? 'Bildirim açılıyor...'
                                  : 'Bildirimleri Aç',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF07122A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _MessageBox extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBox({
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isError ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? const Color(0xFFB91C1C) : const Color(0xFF047857),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}