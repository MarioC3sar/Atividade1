# 📍 Localizações

Aplicativo Flutter para coleta, armazenamento e visualização de localizações geográficas em tempo real.

## 📱 Funcionalidades

- **Coleta de localização em tempo real**: Captura coordenadas GPS do dispositivo com precisão e carimbo de tempo.
- **Armazenamento local**: Salva as localizações coletadas em banco de dados SQLite no dispositivo.
- **Histórico**: Consulta e exibe todas as localizações registradas em uma lista ordenada por data.
- **Visualização no mapa**: Exibe marcadores interativos das localizações salvas em um mapa com zoom automático.
- **Funcionamento offline**: Detecta a conectividade da rede e armazena os dados localmente para sincronização posterior.
- **Cache de tiles do mapa**: Baixa e armazena em cache os tiles do mapa para visualização sem conexão.

## 🏗️ Arquitetura

O projeto segue uma arquitetura orientada a recursos (**Feature-First**) com separação de camadas:

```
lib/
├── main.dart                          # Ponto de entrada
├── app.dart                           # Configuração do MaterialApp e rotas
└── features/
    └── localizacoes/
        ├── models/                    # Modelos de dados
        │   └── localizacao.dart
        ├── data/
        │   ├── database/              # Banco de dados SQLite
        │   │   └── banco_localizacoes.dart
        │   └── repositories/          # Repositórios (abstração de dados)
        │       └── repositorio_localizacoes.dart
        ├── services/                  # Serviços (GPS, conectividade, cache)
        │   ├── servico_localizacao.dart
        │   └── cache_mapa.dart
        └── presentation/
            ├── screens/               # Telas da aplicação
            │   ├── tela_coleta.dart
            │   ├── tela_localizacoes.dart
            │   └── tela_mapa.dart
            └── widgets/               # Widgets reutilizáveis
                ├── mapa_localizacoes.dart
                └── item_localizacao.dart
```

### Telas

| Tela | Rota | Descrição |
|---|---|---|
| **Coleta** | `/` | Tela inicial com controle para iniciar/parar a coleta de localização via GPS. |
| **Histórico** | `/historico` | Lista todas as localizações salvas com latitude, longitude, precisão e data/hora. |
| **Mapa** | `/mapa` | Exibe um mapa interativo com marcadores em cada posição registrada. |

## 🛠️ Tecnologias

| Pacote | Finalidade |
|---|---|
| `flutter_map` | Renderização de mapas interativos com OpenStreetMap |
| `geolocator` | Acesso ao GPS do dispositivo para coleta de coordenadas |
| `sqflite` | Banco de dados SQLite para armazenamento local |
| `connectivity_plus` | Detecção de conectividade de rede |
| `path_provider` | Acesso ao sistema de arquivos do dispositivo |
| `latlong2` | Manipulação de coordenadas geográficas |
| `flutter_map_location_marker` | Marcador de localização atual no mapa |
| `flutter_foreground_task` | Execução em segundo plano para coleta contínua |

## 📋 Requisitos

- **Flutter SDK**: 3.29.3 ou superior
- **Dart SDK**: 3.7.2 ou superior
- **Android SDK**: 36 (compileSdk)
- **Android NDK**: 27.0.12077973
- **Gradle**: 8.11.1
- **Kotlin**: 2.1.0
- **Dispositivo**: Android 6.0 (API 23) ou superior

## 🚀 Instalação

1. **Clone o repositório**:
   ```bash
   git clone <url-do-repositorio>
   cd atividade1
   ```

2. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**:
   ```bash
   flutter run
   ```

## 🔧 Configuração do Android

O projeto requer as seguintes configurações no ambiente Android:

- **compileSdk**: 36
- **minSdk**: 23
- **ndkVersion**: 27.0.12077973
- **Android Gradle Plugin**: 8.9.1
- **Gradle Wrapper**: 8.11.1
- **Kotlin**: 2.1.0

Essas configurações já estão aplicadas nos arquivos de Gradle do projeto.

## 📸 Capturas de Tela

### Tela de Coleta
Tela principal com indicador de status e botões para iniciar/parar a coleta, consultar o histórico e visualizar o mapa.

### Tela de Histórico
Lista ordenada das localizações registradas, exibindo coordenadas, precisão e data/hora de cada registro.

### Tela de Mapa
Mapa interativo com marcadores em cada localização salva, com zoom automático para abranger todos os pontos.

## 📄 Licença

Este projeto foi desenvolvido como atividade acadêmica.
