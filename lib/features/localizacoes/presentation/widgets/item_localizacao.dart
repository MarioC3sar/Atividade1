/// Widget reutilizável que exibe os dados de uma localização.
import 'package:flutter/material.dart';

import '../../models/localizacao.dart';

class ItemLocalizacao extends StatelessWidget {
  final Localizacao localizacao;

  const ItemLocalizacao({super.key, required this.localizacao});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instanteFormatado = _formatarDataHora(localizacao.instante);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 6),
                Text(
                  instanteFormatado,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.my_location, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Lat: ${localizacao.latitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.my_location, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Lon: ${localizacao.longitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.straighten, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Precisão: ${localizacao.precisao.toStringAsFixed(1)}m',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    final segundo = data.second.toString().padLeft(2, '0');
    return '$dia/$mes/$ano $hora:$minuto:$segundo';
  }
}
