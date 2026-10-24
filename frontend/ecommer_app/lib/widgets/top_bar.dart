import 'package:ecommer_app/services/notification_service.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  const TopBar({
    super.key,
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Saludo y Título
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Bienvenido!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Encuentra tu café',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // Botones de acción
        Row(
          children: [
            _buildIconButton(
              icon: Icons.person_outline_rounded,
              onTap: onProfileTap,
            ),
            const SizedBox(width: 10),
            // Campana con el número de notificaciones sin leer
            ListenableBuilder(
              listenable: NotificationService.instance,
              builder: (context, _) {
                final noLeidas = NotificationService.instance.noLeidas;
                return Badge(
                  isLabelVisible: noLeidas > 0,
                  label: Text('$noLeidas'),
                  backgroundColor: const Color(0xFFC88D51),
                  child: _buildIconButton(
                    icon: noLeidas > 0
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    onTap: onNotificationsTap,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF26221F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
