/// Widget do mapa interativo com marcadores de localizações.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../../models/localizacao.dart';

class MapaLocalizacoes extends StatefulWidget {
  final List<Localizacao> localizacoes;

  const MapaLocalizacoes({super.key, required this.localizacoes});

  @override
  State<MapaLocalizacoes> createState() => _MapaLocalizacoesState();
}

class _MapaLocalizacoesState extends State<MapaLocalizacoes> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MapaLocalizacoes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.localizacoes.length != oldWidget.localizacoes.length) {
      _enquadrarPontos();
    }
  }

  void _enquadrarPontos() {
    if (widget.localizacoes.isEmpty) return;

    final pontos = widget.localizacoes
        .map((l) => latlng.LatLng(l.latitude, l.longitude))
        .toList();

    if (pontos.length == 1) {
      _mapController.move(pontos.first, _mapController.camera.zoom);
    } else {
      final bounds = LatLngBounds(
        latlng.LatLng(
          pontos.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
          pontos.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
        ),
        latlng.LatLng(
          pontos.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
          pontos.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
        ),
      );
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.localizacoes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma localização para exibir no mapa.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final marcadores = <Marker>[];
    for (var i = 0; i < widget.localizacoes.length; i++) {
      final loc = widget.localizacoes[i];
      final ehMaisRecente = (i == 0);

      marcadores.add(
        Marker(
          point: latlng.LatLng(loc.latitude, loc.longitude),
          child: Icon(
            ehMaisRecente ? Icons.location_on : Icons.pin_drop,
            color: ehMaisRecente ? Colors.red : Colors.blue,
            size: ehMaisRecente ? 40 : 30,
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: latlng.LatLng(
              widget.localizacoes.first.latitude,
              widget.localizacoes.first.longitude,
            ),
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.atividade1',
            ),
            MarkerLayer(markers: marcadores),
          ],
        ),
        // Botões de ação
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'enquadrar',
                mini: true,
                onPressed: _enquadrarPontos,
                child: const Icon(Icons.fit_screen),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'atualizar_mapa',
                mini: true,
                onPressed: () {
                  setState(() {});
                  _enquadrarPontos();
                },
                child: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        // Legenda
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 18),
                    SizedBox(width: 4),
                    Text('Mais recente', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pin_drop, color: Colors.blue, size: 18),
                    SizedBox(width: 4),
                    Text('Outras', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Map data © OpenStreetMap contributors',
                  style: TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
