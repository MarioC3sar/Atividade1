---
sessionId: session-261104-141448-1qu8
---

# Diagnóstico

## Diagnóstico do Projeto Atual

O projeto é um **Flutter counter app padrão** — template inicial sem nenhuma funcionalidade de localização implementada.

### Estrutura atual
- **lib/main.dart**: Counter app padrão (StatefulWidget com contador)
- **pubspec.yaml**: Apenas dependências padrão (cupertino_icons, flutter_lints)
- **AndroidManifest.xml**: Sem permissões de localização
- **MainActivity.kt**: FlutterActivity padrão
- **Info.plist (iOS)**: Sem descrições de localização
- **assets/**: Diretório vazio
- **test/**: Teste do counter app

### Tabela de Requisitos

| Requisito | Situação | Arquivo | Correção Necessária |
|---|---|---|---|
| Modelo Localizacao | Ausente | - | Criar localizacao.dart |
| Banco SQLite | Ausente | - | Criar banco_localizacoes.dart, adicionar sqflite |
| Repositorio | Ausente | - | Criar repositorio_localizacoes.dart |
| Serviço Localização | Ausente | - | Criar servico_localizacao.dart, adicionar geolocator |
| Cache Mapa | Ausente | - | Criar cache_mapa.dart |
| App e Navegação | Ausente | - | Criar app.dart, reescrever main.dart |
| Tela Coleta | Ausente | - | Criar tela_coleta.dart |
| Tela Histórico | Ausente | - | Criar tela_localizacoes.dart |
| Widget Item Localização | Ausente | - | Criar item_localizacao.dart |
| Tela Mapa | Ausente | - | Criar tela_mapa.dart |
| Widget Mapa | Ausente | - | Criar mapa_localizacoes.dart |
| Permissões Android | Ausente | AndroidManifest.xml | Adicionar permissões de localização |
| Permissões iOS | Ausente | Info.plist | Adicionar descrições de localização |
| Ícone Personalizado | Ausente | - | Criar ícone e configurar flutter_launcher_icons |
| Foreground Service | Ausente | - | Configurar serviço em primeiro plano Android |
| Estrutura de pastas | Ausente | lib/ | Criar estrutura features/localizacoes/ |

### Conclusão
Todas as funcionalidades precisam ser implementadas do zero. A estrutura do projeto Flutter (Android, iOS, Gradle) será aproveitada, mas todo o código Dart e configurações nativas precisam ser criados.

# Design Técnico

## Arquitetura e Design Técnico

### Estrutura de Arquivos

```
lib/
├── main.dart (inicialização mínima: runApp)
├── app.dart (MaterialApp + rotas)
└── features/
    └── localizacoes/
        ├── models/
        │   └── localizacao.dart
        ├── data/
        │   ├── database/
        │   │   └── banco_localizacoes.dart
        │   └── repositories/
        │       └── repositorio_localizacoes.dart
        ├── services/
        │   ├── servico_localizacao.dart
        │   └── cache_mapa.dart
        └── presentation/
            ├── screens/
            │   ├── tela_coleta.dart
            │   ├── tela_localizacoes.dart
            │   └── tela_mapa.dart
            └── widgets/
                ├── item_localizacao.dart
                └── mapa_localizacoes.dart
assets/
└── icons/
    └── localizacoes.png
```

### Dependências a Adicionar

| Pacote | Propósito |
|---|---|
| sqflite | Banco SQLite local |
| path | Caminhos do banco |
| path_provider | Diretórios do app (cache, banco) |
| geolocator | GPS, permissões, stream de localização |
| connectivity_plus | Verificar conectividade (mapa) |
| flutter_foreground_task | Serviço em primeiro plano Android |
| get_location | Mapa interativo com atribuição |
| flutter_launcher_icons | Gerar ícones do app |

### Modelo Localizacao

```dart
class Localizacao {
  final int? id;
  final double latitude;
  final double longitude;
  final double precisao;
  final DateTime instante;

  // Construtor, toMap(), fromMap(), fromJson(), toJson()
  // Formatação: 6 casas decimais para lat/lon, 1 casa para precisão
}
```

### Banco SQLite

- Banco: `localizacoes.db`
- Tabela: `localizacoes`
- Colunas: id (INTEGER PRIMARY KEY AUTOINCREMENT), latitude (REAL NOT NULL), longitude (REAL NOT NULL), precisao (REAL NOT NULL), instante (TEXT NOT NULL — ISO 8601 UTC)
- Operações centralizadas no repositório, nunca SQL nas telas

### Serviço de Localização

- Stream contínuo via `geolocator.getPositionStream()`
- Intervalo: 20 segundos
- Precisão: `LocationAccuracy.best`
- Verificação de GPS e permissões antes de iniciar
- Tratamento de permissão negada permanentemente (redirecionar às configurações)
- Cancelamento correto do stream ao parar
- Prevenção de assinaturas duplicadas (flag de estado)

### Foreground Service (Android)

- Notificação persistente durante coleta
- Implementado via `flutter_foreground_task`
- Ativo apenas enquanto a coleta está em execução

### Fluxo de Coleta

1. Usuário clica "Iniciar coleta"
2. Verificar GPS → solicitar permissões → iniciar stream
3. Cada posição recebida → salvar no SQLite via repositório
4. Atualizar estado da UI (indicador visual)
5. Coleta continua ao navegar entre telas
6. Ao parar → cancelar stream, encerrar foreground service

### Fluxo de Histórico

1. Consultar repositório → últimas 100, ordenadas DESC por instante
2. Converter UTC para horário local na apresentação
3. Exibir com item_localizacao.dart
4. Limpar: diálogo de confirmação → repositório.limparTodos() → atualizar lista

### Fluxo do Mapa

1. Consultar repositório → últimas 100
2. Carregar mapa com get_location
3. Adicionar marcadores (vermelho para o mais recente)
4. Fit bounds para enquadrar todos os pontos
5. Botões: atualizar, enquadrar novamente

# Testes e Validação

## Estratégia de Validação

### Comandos de Linha de Comando

Após cada etapa significativa:
- `flutter pub get` — resolver dependências
- `dart format .` — formatar código
- `flutter analyze` — verificar erros e warnings
- `flutter test` — executar testes unitários

### Testes Unitários

- Atualizar `test/widget_test.dart` para testar a nova estrutura
- Testar modelo Localizacao (conversão toMap/fromMap)
- Testar formatação de dados (casas decimais)

### Cenários Funcionais (validação manual em dispositivo)

- Solicitação e negação de permissões
- GPS desabilitado e habilitado
- Iniciar e parar coleta
- Prevenção de streams duplicados
- Persistência de registros (fechar e reabrir app)
- Coleta ao navegar entre telas
- Histórico ordenado e limitado a 100
- Exclusão completa com confirmação
- Conversão UTC para horário local
- Mapa com marcadores e destaque vermelho
- Ícone personalizado

### Critérios de Aceitação

- Zero erros no `flutter analyze`
- Código formatado com `dart format`
- Separacao de responsabilidades mantida
- Nenhum SQL nas telas
- Streams corretamente gerenciados
- mounted verificado em operações assíncronas
- Dados armazenados apenas localmente

# Delivery Steps

### ✓ Step 1: modelo-banco-repositorio
Implementar modelo Localizacao, banco SQLite e repositório
- Criar lib/features/localizacoes/models/localizacao.dart com modelo tipado (id, latitude, longitude, precisao, instante) e métodos de conversão toMap/fromMap
- Criar lib/features/localizacoes/data/database/banco_localizacoes.dart com sqflite: criação do banco localizacoes.db, tabela localizacoes com schema obrigatório, métodos de inicialização e fechamento
- Criar lib/features/localizacoes/data/repositories/repositorio_localizacoes.dart com métodos: inserir(Localizacao), obterUltimas100() ordenado por instante DESC, limparTodos() preservando a tabela
- Adicionar dependências no pubspec.yaml: sqflite, path, path_provider
- Executar flutter pub get e flutter analyze para validar (pendente - Flutter SDK não disponível)

### ✓ Step 2: servico-localizacao-permissoes
Implementar serviço de localização com GPS, permissões e stream contínuo
- Criar lib/features/localizacoes/services/servico_localizacao.dart usando geolocator e connectivity_plus
- Implementar métodos: verificarGPS(), solicitarPermissoes(), iniciarColeta() que retorna Stream<Position> com intervalo de 20s e alta precisão, pararColeta() que cancela o stream
- Tratar estados de permissão: granted, denied, deniedForever (orientar às configurações), e GPS desabilitado
- Configurar permissões Android no AndroidManifest.xml: ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION, ACCESS_BACKGROUND_LOCATION, FOREGROUND_SERVICE
- Atualizar MainActivity.kt para suportar foreground service
- Adicionar dependências: geolocator, connectivity_plus, flutter_foreground_task
- Executar flutter analyze para validar (pendente - Flutter SDK não disponível)

### ✓ Step 3: cache-mapa
Implementar serviço de cache de mapa para armazenamento local
- Criar lib/features/localizacoes/services/cache_mapa.dart
- Implementar métodos para preparar o diretório de cache usando path_provider
- Configurar políticas de cache para imagens do mapa conforme get_location
- Garantir que o cache respeita as regras de uso do provedor de mapas
- Executar flutter analyze para validar (pendente - Flutter SDK não disponível)

### ✓ Step 4: navegacao-tela-coleta
Implementar estrutura de navegação e tela inicial de coleta
- Criar lib/app.dart com MaterialApp, título 'Localizações', e rotas entre as telas (coleta, histórico, mapa)
- Reescrever lib/main.dart apenas para runApp(App())
- Criar lib/features/localizacoes/presentation/screens/tela_coleta.dart com botões (Iniciar, Parar, Histórico, Mapa, Permissões), indicador visual do estado, habilitação/desabilitação conforme estado, integração com serviço e repositório, salvamento automático no SQLite, prevenção de assinaturas duplicadas, verificação de mounted, tratamento de erros
- Executar flutter analyze para validar (pendente - Flutter SDK não disponível)

### ✓ Step 5: tela-historico
Implementar tela de histórico com exclusão e confirmação
- Criar lib/features/localizacoes/presentation/widgets/item_localizacao.dart: widget reutilizável que exibe data/hora local, latitude e longitude (6 casas decimais), precisão (1 casa decimal)
- Criar lib/features/localizacoes/presentation/screens/tela_localizacoes.dart com lista das últimas 100 localizações (mais recente primeiro), conversão UTC para horário local, botão atualizar, botão limpar com diálogo de confirmação (Cancelar/Limpar), mensagem de sucesso, tratamento de erros
- Executar flutter analyze para validar (pendente - Flutter SDK não disponível)

### ✓ Step 6: tela-mapa
Implementar tela de mapa interativo com marcadores
- Criar lib/features/localizacoes/presentation/widgets/mapa_localizacoes.dart com mapa usando flutter_map (OpenStreetMap), marcador para cada localização, marcador vermelho para a mais recente, enquadramento automático, botões para enquadrar e atualizar, estados (carregamento, erro, vazio)
- Criar lib/features/localizacoes/presentation/screens/tela_mapa.dart com estados de carregamento e integração ao widget do mapa
- Adicionar dependência: flutter_map, flutter_map_location_marker, latlong2
- Executar flutter analyze para validar (pendente - Flutter SDK não disponível)

### ✓ Step 7: icone-android-permissoes-ios
Configurar ícone personalizado, permissões Android e iOS
- Criar assets/icons/localizacoes.png (ícone placeholder — substituir por ícone real)
- Configurar flutter_launcher_icons no pubspec.yaml para gerar ícones Android
- Executar flutter pub run flutter_launcher_icons (pendente - Flutter SDK não disponível)
- Completar permissões Android no AndroidManifest.xml: foreground service, background location
- Configurar permissões iOS no Info.plist: NSLocationWhenInUseUsageDescription, NSLocationAlwaysAndWhenInUseUsageDescription
- Executar flutter analyze para validar (pendente - Flutter SDK não disponível)

### ✓ Step 8: validacao-final
Validação final completa do projeto
- Executar flutter pub get (pendente - Flutter SDK não disponível)
- Executar dart format . para formatar todo o código (pendente - Flutter SDK não disponível)
- Executar flutter analyze e corrigir todos os warnings e erros (pendente - Flutter SDK não disponível)
- Atualizar test/widget_test.dart para testar a nova estrutura
- Executar flutter test (pendente - Flutter SDK não disponível)
- Revisão final: separação de responsabilidades, streams gerenciados, mounted verificado, erros tratados, dados locais, arquitetura conforme estrutura solicitada
- Gerar relatório final com resumo das funcionalidades, arquivos criados/modificados, dependências, configurações, e resultados dos comandos