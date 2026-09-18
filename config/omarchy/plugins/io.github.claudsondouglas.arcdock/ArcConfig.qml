// ArcConfig — os ajustes do dock e o arquivo em que eles moram.
//
// Existe um só, dentro do serviço (ver `config` no Arcdock): o dock lê dele por
// binding e a janela de ajustes escreve nele por `set()`. Sem cópia dos dois
// lados — mexer num controle repinta o dock no mesmo quadro, antes de qualquer
// gravação acontecer.
//
// Uma chave *ausente* do arquivo não é zero: é "siga o tema". Os padrões saem
// do `Style` sempre que existe token para a medida, então um tema de
// espaçamento maior já abre o dock junto, e o arquivo só guarda o que o usuário
// de fato mudou. É isso que o "Restaurar padrões" devolve: ele apaga a chave em
// vez de gravar o número que hoje é padrão.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: config

  // Config, e não estado: os ajustes ficam em `~/.config`, ao lado do
  // `shell.json`, enquanto os fixados e os recentes continuam em
  // `~/.local/state` (ver `statePath` no Arcdock). Um é escolha do usuário, que
  // ele pode versionar junto com o resto da config; o outro é a fileira que a
  // sessão montou.
  readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME")
    || Quickshell.env("HOME") + "/.config") + "/omarchy"
  readonly property string path: config.configDir + "/arc-dock.json"

  // Os padrões. São a aparência do dock do macOS, que é o que este plugin
  // persegue: vidro claro bem aberto, ícones juntos, onda discreta sob o
  // ponteiro. Foram medidos em uso, e não escolhidos na teoria — cada um foi
  // ajuste do usuário antes de virar padrão (2026-09-11).
  //
  // Nenhuma medida vem do tema: o dock do macOS tem a densidade *dele*, e um
  // tema mais roomy da shell não deveria abrir a fileira. O espaço entre slots
  // é zero porque cada ícone já tem folga própria em volta (ver `iconPadding`
  // no Arcdock), e a folga da casca é o mínimo que ainda separa o ícone da
  // borda. Todas são ajustáveis, que é o que tira delas o peso de estarem
  // escritas aqui.
  readonly property var defaults: ({
    iconSize: 52,
    slotGap: 0,
    dockPadding: 5,
    edgeMargin: 14,
    // A ampliação: o ícone embaixo do ponteiro cresce, os vizinhos crescem
    // menos, e a casca se abre para caber o que cresceu. Os 125% são o ponto
    // em que o ícone sob o ponteiro se destaca sem a fileira inteira se mexer a
    // cada travessia do cursor — 140 já lia como animação com o ícone de 52.
    // O teto de 200 é onde a onda deixa de ser realce de vez.
    //
    // O alcance é contado em *slots de cada lado*, e não em pixels: é a unidade
    // em que a onda se lê ("dois vizinhos para cada lado"), e assim ela
    // acompanha sozinha uma troca de tamanho de ícone ou de espaçamento do
    // tema. Com 1 a onda é um pico solitário; de 3 para cima ela pega a fileira
    // inteira num dock pequeno.
    magnify: true,
    magnifyScale: 125,
    magnifyReach: 2,
    // O vidro: fundo translúcido sobre o blur do Hyprland, em vez do tom cheio
    // do tema. A opacidade é *inteira, em por cento*, e não uma fração de 0 a
    // 1: assim ela passa pela mesma faixa e pelo mesmo saneamento das outras
    // medidas, e no arquivo editado à mão "25" se lê tão direto quanto "52 px".
    // Os 25% são o vidro do macOS: o fundo atravessa quase inteiro, e o que
    // segura o ícone é o blur, não a casca.
    glass: true,
    glassOpacity: 25,
    // O *tom* do vidro, separado do tema do desktop. "theme" puxa a casca de
    // `popups.background` e acompanha o tema; "light" e "dark" fixam o tom
    // independente dele. O padrão é o claro porque é o dock do macOS sobre um
    // desktop claro — e puxando cor do tema não se chega nele, porque a cor do
    // popup de um tema não é a cor de um dock.
    //
    // Não é redundante com `glassOpacity`: a opacidade diz *quanto* do fundo
    // atravessa, esta diz *de que cor* é o que fica na frente. Baixar a
    // opacidade de uma casca clara não a escurece, só a apaga.
    dockTheme: "light",
    edge: "bottom",
    screenName: "",
    // Esconde quando uma janela cobre o dock, e não só em tela cheia: com
    // janelas flutuantes (o modo do usuário) uma janela maximizada por
    // geometria não é fullscreen, e o dock ficaria por cima dela.
    autoHide: "covered",
    hideDelay: 500,
    slideDuration: 180,
    showLauncher: true,
    showSeparator: true,
    showIndicators: true,
    // Como um app aberto se marca. "dot" é um ponto só, tenha o app uma janela
    // ou seis. "dots" põe um ponto por janela (até o teto do slot), e "bar"
    // troca os pontos por um traço sob o ícone. O padrão é um ponto por janela:
    // com o ícone de 52 o slot aguenta a contagem, e ela é a informação que o
    // menu de contexto só dá com um clique a mais.
    indicatorStyle: "dots",
    // O contador de notificações no canto do ícone nasce ligado: é uma marca
    // que só aparece quando há o que contar, então ligada e sem notificação
    // ela não muda nada na fileira — e quem já viu um dock do macOS espera
    // que o número esteja lá quando uma chega.
    showBadges: true,
    // Quatro recentes: com ícone de 52 e slots colados, seis já empurravam o
    // dock para uma lista.
    recentCount: 4
  })

  // Faixa de cada medida. Vale para o que a janela de ajustes escreve *e* para
  // o que vier do arquivo: ele é editável à mão, e um `iconSize: 4000` copiado
  // errado deixaria o dock maior que a tela sem jeito de voltar pela interface.
  readonly property var limits: ({
    iconSize: [24, 96],
    slotGap: [0, 24],
    dockPadding: [0, 24],
    edgeMargin: [0, 64],
    // O piso é 110 porque abaixo disso a onda existe no papel e não na tela: o
    // olho não separa 5% de escala do vizinho, e o dock só ficaria reservando
    // folga na janela sem nada acontecer nela.
    magnifyScale: [110, 200],
    magnifyReach: [1, 4],
    // Nunca chega a zero: uma casca invisível deixaria os ícones flutuando sem
    // dock nenhum, e o piso é também o que o blur usa para saber o que é casca
    // e o que é folga transparente (ver `glassIgnoreAlpha` no Arcdock).
    glassOpacity: [10, 100],
    hideDelay: [0, 3000],
    slideDuration: [0, 600],
    // Zero desliga o grupo dos recentes. O teto vale também para o histórico
    // guardado em disco (ver `recentHistoryLimit` no Arcdock): é ele que diz
    // quanta memória de apps fechados o dock chega a ter.
    recentCount: [0, 12]
  })

  // O mesmo para as chaves de texto: um valor fora da lista cai no padrão, em
  // vez de deixar o dock ancorado numa borda que ele não sabe desenhar.
  readonly property var choices: ({
    edge: ["bottom", "top", "left", "right"],
    autoHide: ["never", "fullscreen", "covered", "always"],
    dockTheme: ["theme", "light", "dark"],
    indicatorStyle: ["dot", "dots", "bar"]
  })

  // O que veio do arquivo, cru. Só as chaves que o usuário mudou moram aqui.
  property var stored: ({})

  // ------------------------------------------------------------- leitura
  //
  // As três formas são separadas porque o saneamento é diferente em cada uma, e
  // porque o QML precisa do tipo certo para não converter na hora do binding.

  function num(key) {
    var fallback = config.defaults[key]
    var raw = config.stored[key]
    var value = (typeof raw === "number" && isFinite(raw)) ? raw : fallback
    var range = config.limits[key]
    if (range) value = Math.max(range[0], Math.min(range[1], value))
    return Math.round(value)
  }

  function str(key) {
    var fallback = String(config.defaults[key])
    var raw = config.stored[key]
    if (typeof raw !== "string") return fallback
    var allowed = config.choices[key]
    // Sem lista de valores a chave é texto livre (o nome do monitor), e aí o
    // que vier vale — o dock já trata um nome que não existe mais.
    if (allowed && allowed.indexOf(raw) < 0) return fallback
    return raw
  }

  function flag(key) {
    var raw = config.stored[key]
    return typeof raw === "boolean" ? raw : !!config.defaults[key]
  }

  // A leitura de fora é por estas, e não por `num`/`str`/`flag`: o tipo fica
  // declarado num lugar só, e quem consome não precisa saber de qual das três
  // famílias a chave é.
  readonly property int iconSize: config.num("iconSize")
  readonly property int slotGap: config.num("slotGap")
  readonly property int dockPadding: config.num("dockPadding")
  readonly property int edgeMargin: config.num("edgeMargin")
  readonly property bool magnify: config.flag("magnify")
  readonly property int magnifyScale: config.num("magnifyScale")
  readonly property int magnifyReach: config.num("magnifyReach")
  readonly property bool glass: config.flag("glass")
  readonly property int glassOpacity: config.num("glassOpacity")
  readonly property int hideDelay: config.num("hideDelay")
  readonly property int slideDuration: config.num("slideDuration")
  readonly property string edge: config.str("edge")
  readonly property string screenName: config.str("screenName")
  readonly property string autoHide: config.str("autoHide")
  readonly property string dockTheme: config.str("dockTheme")
  readonly property string indicatorStyle: config.str("indicatorStyle")
  readonly property bool showLauncher: config.flag("showLauncher")
  readonly property bool showSeparator: config.flag("showSeparator")
  readonly property bool showIndicators: config.flag("showIndicators")
  readonly property bool showBadges: config.flag("showBadges")
  readonly property int recentCount: config.num("recentCount")

  // Esta chave está no padrão do tema? É o que a janela de ajustes mostra para
  // dizer "isto ainda segue o tema" — e o que decide se o "Restaurar padrões"
  // tem o que fazer.
  function isDefault(key) {
    return config.stored[key] === undefined
  }

  // Quantas chaves saíram do padrão. É o que o cabeçalho da janela de ajustes
  // mostra em vez de um "sim/não": "3 ajustes" diz de quanto o dock se afastou
  // do tema, e é a mesma conta que decide se o "Restaurar tudo" tem o que
  // fazer. Só conta as chaves conhecidas — uma sobra de versão futura do
  // plugin não é ajuste do usuário.
  readonly property int overrideCount: {
    var count = 0
    for (var key in config.stored) {
      if (config.defaults[key] !== undefined) count++
    }
    return count
  }

  readonly property bool customized: config.overrideCount > 0

  // ------------------------------------------------------------- escrita

  // Gravar o valor que já é padrão só encheria o arquivo de linhas que o tema
  // já dava de graça — e prenderia a medida ao número de hoje, quando o ponto
  // da ausência é justamente acompanhar o tema. Então voltar ao padrão *apaga*.
  function set(key, value) {
    if (config.defaults[key] === undefined) return
    var next = ({})
    for (var k in config.stored) next[k] = config.stored[k]
    if (value === undefined || value === null || value === config.defaults[key]) delete next[key]
    else next[key] = value
    config.apply(next)
  }

  function resetAll() {
    // Só as chaves conhecidas: o arquivo pode ter ganhado outras coisas de uma
    // versão futura do plugin, e restaurar ajustes não é motivo para apagá-las.
    var next = ({})
    for (var k in config.stored) {
      if (config.defaults[k] === undefined) next[k] = config.stored[k]
    }
    config.apply(next)
  }

  // O único caminho de escrita, e o que decide se o disco precisa saber.
  //
  // Um gesto que não muda nada não grava. Isso é mais que economia: um
  // deslizante arrastado até o valor que já estava lá, ou um controle que
  // emite o próprio valor ao nascer, chamaria `set` com o que já vale — e uma
  // gravação nesse instante, antes da primeira leitura ter chegado, gravaria o
  // objeto vazio por cima do arquivo do usuário. Já apagou uma config assim.
  function apply(next) {
    if (JSON.stringify(next) === JSON.stringify(config.stored)) return
    config.stored = next
    saveTimer.restart()
  }

  // Um controle contínuo (os deslizantes) dispara escrita a cada quadro do
  // arrasto. O dock acompanha na hora, porque lê de `stored`; o disco não
  // precisa — esta carência junta o gesto inteiro numa gravação só.
  Timer {
    id: saveTimer
    interval: 250
    onTriggered: config.save()
  }

  // O texto da última gravação nossa. `watchChanges` está ligado para uma
  // edição à mão valer na hora, e sem esta comparação a nossa própria gravação
  // voltaria como se fosse de fora — recolocando `stored` no meio de um arrasto
  // que ainda está acontecendo.
  property string lastWritten: ""

  // A primeira leitura já respondeu — com conteúdo, ou dizendo que o arquivo
  // não existe. Antes disso `stored` está vazio porque ninguém leu ainda, e não
  // porque o usuário não ajustou nada: gravar aí apagaria o arquivo dele.
  property bool loaded: false

  function save() {
    if (!config.loaded) return
    config.lastWritten = JSON.stringify({ version: 1, settings: config.stored }, null, 2) + "\n"
    configFile.setText(config.lastWritten)
  }

  function load(raw) {
    var text = String(raw || "").trim()
    // Arquivo ainda inexistente ou vazio é a primeira execução: tudo padrão.
    if (text.length === 0) return

    var data = null
    try {
      data = JSON.parse(text)
    } catch (error) {
      // Ficar com os padrões é melhor que ficar sem dock. E o arquivo não é
      // reescrito daqui: sobrescrever um JSON que o usuário estragou editando
      // levaria junto o resto do que ele tinha ajustado.
      console.warn("arcdock: could not read settings from", config.path, "-", error)
      return
    }

    var settings = (data && Util.isPlainObject(data.settings)) ? data.settings : {}
    var next = ({})
    for (var key in settings) next[key] = settings[key]
    config.stored = next
  }

  FileView {
    id: configFile
    path: config.path
    // Ligado: o arquivo é config, e editar config à mão tem que valer sem
    // reiniciar a shell — é assim que o resto do Omarchy se comporta.
    watchChanges: true
    // Curto e reescrito inteiro: sem isto um desligamento no meio da gravação
    // deixaria os ajustes pela metade. A gravação cria o diretório se ele
    // ainda não existir — não há `mkdir` a chamar antes dela.
    atomicWrites: true
    // Cala a leitura de um arquivo que ainda não existe — primeira execução,
    // não erro.
    printErrors: false
    onFileChanged: configFile.reload()
    onLoaded: {
      config.loaded = true
      // A nossa própria gravação voltando: nada mudou, e reatribuir `stored`
      // aqui atropelaria um arrasto em curso.
      if (configFile.text() === config.lastWritten) return
      config.load(configFile.text())
    }
    // Falhar a leitura é a primeira execução (arquivo ainda não existe), e é
    // resposta tanto quanto um arquivo cheio: a partir daqui `stored` vazio
    // quer mesmo dizer "nada ajustado", e gravar já é seguro.
    onLoadFailed: config.loaded = true
    onSaveFailed: function (error) {
      console.warn("arcdock: could not write settings to", config.path, "-", error)
    }
  }

  Component.onCompleted: configFile.reload()
}
