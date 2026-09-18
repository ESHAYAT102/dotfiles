// ArcSettings — a janela de ajustes do dock.
//
// É o segundo ponto de entrada deste plugin (ver `panel` no manifesto). O host
// monta esta superfície separada do serviço e injeta nela o serviço vivo, então
// aqui não existe cópia dos ajustes: os controles leem e escrevem no `config`
// do próprio dock, e mexer num deslizante repinta a fileira no mesmo quadro —
// antes de qualquer gravação em disco acontecer.
//
// Por isso também não há "aplicar" nem "cancelar". A pré-visualização *é* o
// resultado, e o caminho de volta é o botão de desfazer de cada linha — que
// apaga a chave em vez de gravar o número que hoje é padrão, para a medida
// voltar a seguir o tema (ver `set` no ArcConfig).
//
// ------------------------------------------------------------------ o formato
//
// O cartão segue o formato do Omaland, o painel de ajustes do Hyprland: uma
// **trilha de seções** à esquerda e uma **página de linhas** à direita, cada
// linha com nome e explicação de um lado e o controle do outro. A troca em
// relação às duas abas de antes não é enfeite:
//
// - Com abas, achar um ajuste era lembrar em qual das duas ele estava. A
//   trilha mostra as seis seções ao mesmo tempo, e a marca "·" ao lado de cada
//   uma diz onde há coisa fora do padrão sem precisar entrar para conferir.
// - Com o controle *embaixo* do rótulo, cada linha ocupava três alturas e a
//   página virava uma rolagem longa. Com ele à direita, um deslizante, um
//   interruptor e uma escolha entre opções ficam todos na mesma coluna e a
//   seção inteira cabe na tela.
// - O rótulo, a explicação e o valor param de brigar por ordem de leitura: a
//   pergunta está sempre à esquerda e a resposta sempre à direita.
//
// A janela responde ao teclado inteiro (setas ou hjkl, Tab entre seções,
// Backspace devolve a linha ao padrão), porque quem abre ajustes de dock quase
// sempre está com a mão no teclado — e porque o Esc precisava de um lugar onde
// ele não fosse a única tecla que faz algo.
//
// Os controles são os do kit da shell (`qs.Ui`), e não desenhos próprios: esta
// janela é uma superfície do Omarchy como as outras, e um controle inventado
// aqui destoaria dos painéis da bar no primeiro tema que o usuário trocasse.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
  id: root

  // Injetados pelo host quando a superfície é montada.
  property var shell: null
  property var manifest: null
  // O serviço deste mesmo plugin — o dock que está no ar. É por ele que se
  // chega ao `config`.
  property var service: null

  readonly property string pluginId: (manifest && manifest.id) ? String(manifest.id) : "io.github.claudsondouglas.arcdock"

  // O host injeta `service` ao montar a superfície, mas serviço e painel são
  // montados por caminhos diferentes e nada garante qual chega primeiro. Se a
  // injeção não tiver acontecido, o serviço é pedido ao host na abertura.
  function resolveService() {
    if (root.service) return
    if (root.shell && typeof root.shell.serviceFor === "function")
      root.service = root.shell.serviceFor(root.pluginId)
  }

  readonly property var config: root.service ? root.service.config : null

  // ------------------------------------------------------ ciclo do plugin
  //
  // `opened` é o que o host lê para saber se um `toggle` deve abrir ou fechar
  // (ver `isPluginOpen` na shell), e é o que a janela usa para aparecer.
  property bool opened: false

  function open(payloadJson) {
    root.resolveService()
    root.opened = true
    // O foco só existe depois da janela aparecer; pedi-lo no mesmo quadro
    // deixaria o teclado morto até o primeiro clique.
    Qt.callLater(root.grabKeys)
  }

  function close() {
    root.opened = false
  }

  // O teclado mora num item só (ver `keyCatcher`), e qualquer controle que
  // roube o foco — o dropdown do monitor é o caso — devolve por aqui.
  function grabKeys() {
    keyCatcher.forceActiveFocus()
  }

  // --------------------------------------------------------- o catálogo
  //
  // As seções e as linhas são declaradas como *dados*, e não como uma pilha de
  // controles escritos um a um. Duas coisas caem disso de graça: a trilha da
  // esquerda é o mesmo `sections` repetido, e o teclado sabe andar pelas linhas
  // sem que nenhuma delas precise saber que existe teclado.
  //
  // A faixa de cada número **não** mora aqui: ela mora no `limits` do
  // ArcConfig, que é quem também sanea o arquivo editado à mão. Repetir os
  // limites nos dois lugares abriria espaço para eles discordarem.
  //
  // `needs` é a chave do interruptor que precisa estar ligado para a linha
  // valer. A linha continua à vista, apagada: escondê-la faria a seção mudar de
  // tamanho a cada clique, e some justamente a explicação de por que aquilo
  // some.
  readonly property var sections: [
    {
      id: "size",
      icon: "󰩨",
      title: "Size",
      blurb: "Icon size and the gaps that separate the dock from everything else.",
      items: [
        { key: "iconSize", type: "int", label: "Icon size", suffix: " px",
          description: "The icon's side at rest, before any magnification." },
        { key: "slotGap", type: "int", label: "Gap between slots", suffix: " px",
          description: "Space between an icon and its neighbor." },
        { key: "dockPadding", type: "int", label: "Inner padding", suffix: " px",
          description: "Space between the row and the edge of the shell." },
        { key: "edgeMargin", type: "int", label: "Distance to the edge", suffix: " px",
          description: "How far the dock sits from the screen edge." }
      ]
    },
    {
      id: "magnify",
      icon: "󰍉",
      title: "Magnification",
      blurb: "The wave that lifts the icon under the pointer.",
      items: [
        { key: "magnify", type: "bool", label: "Wave under the pointer",
          description: "The icon under the cursor grows and rises above the shell, neighbors grow less, and the dock opens up to fit." },
        { key: "magnifyScale", type: "int", label: "Size at the peak", suffix: " %", needs: "magnify",
          description: "How much the peak icon grows relative to its resting size." },
        { key: "magnifyReach", type: "int", label: "Reach", suffix: " slots", suffixOne: " slot", needs: "magnify",
          description: "How many neighbors on each side rise along with the peak icon." }
      ]
    },
    {
      id: "background",
      icon: "󰉓",
      title: "Background",
      blurb: "What color the shell is, and how much of the desktop shows through.",
      items: [
        { key: "dockTheme", type: "enum", label: "Shell tone" },
        { key: "glass", type: "bool", label: "Frosted glass",
          description: "The shell turns translucent and Hyprland blurs what passes behind it." },
        { key: "glassOpacity", type: "int", label: "Shell opacity", suffix: " %", needs: "glass",
          description: "How much of the shell is color, and how much is the desktop showing through." }
      ]
    },
    {
      id: "content",
      icon: "󰀻",
      title: "Content",
      blurb: "What the row shows besides the apps that are open.",
      items: [
        { key: "showLauncher", type: "bool", label: "App button",
          description: "The button that opens the app menu, at the end of the row." },
        { key: "showSeparator", type: "bool", label: "Separator",
          description: "Divides the groups in the row: apps with a slot, recents and the app button." },
        { key: "showIndicators", type: "bool", label: "State dots",
          description: "The mark under the icon that says the app is open. Without it, a pinned closed app looks the same as an open one." },
        { key: "indicatorStyle", type: "enum", label: "Open app mark", needs: "showIndicators" },
        { key: "showBadges", type: "bool", label: "Notification counter",
          description: "The red number on the corner of the icon, as on macOS: how many notifications arrived since the app was last focused." },
        { key: "recentCount", type: "int", label: "Recent apps",
          description: "Apps you opened and closed stay within reach, between the ones with a slot and the button. Zero turns the group off." }
      ]
    },
    {
      id: "position",
      icon: "󰍹",
      title: "Position",
      blurb: "Which edge and which screen the dock lives on.",
      items: [
        { key: "edge", type: "enum", label: "Screen edge",
          description: "Which side of the screen the dock anchors to." },
        { key: "screenName", type: "enum", widget: "dropdown", label: "Monitor",
          description: "Which output the dock shows on. Automatic follows the largest." }
      ]
    },
    {
      id: "hide",
      icon: "󰈉",
      title: "Hide",
      blurb: "When the dock gets out of the way, and how fast.",
      items: [
        { key: "autoHide", type: "enum", label: "When to hide" },
        { key: "hideDelay", type: "int", label: "Grace before hiding", suffix: " ms", step: 50,
          description: "How long the dock waits with the pointer away before hiding." },
        { key: "slideDuration", type: "int", label: "Slide duration", suffix: " ms", step: 20,
          description: "How long the dock takes to leave and to come back." }
      ]
    }
  ]

  // A seção aberta e a linha sob o cursor. Nenhuma das duas é gravada: o host
  // desmonta a superfície ao fechar, e uma seção lembrada da sessão passada só
  // atrapalharia quem abriu a janela pelo mesmo motivo da primeira vez.
  property int sectionIndex: 0
  property int cursorIndex: 0

  readonly property var section: root.sections[Math.max(0, Math.min(root.sections.length - 1, root.sectionIndex))]
  readonly property var rows: root.section.items

  // ------------------------------------------------------- opções de texto
  //
  // Os rótulos das escolhas são curtos de propósito: eles dividem a largura de
  // uma linha só, e a explicação de cada um é o texto que muda embaixo do nome
  // da linha conforme a escolha (ver `descriptionFor`).
  readonly property var dockThemeOptions: [
    { value: "theme", label: "Theme" },
    { value: "light", label: "Light" },
    { value: "dark", label: "Dark" }
  ]

  readonly property var indicatorStyleOptions: [
    { value: "dot", label: "One dot" },
    { value: "dots", label: "Per window" },
    { value: "bar", label: "Bar" }
  ]

  readonly property var edgeOptions: [
    { value: "bottom", label: "Bottom" },
    { value: "top", label: "Top" },
    { value: "left", label: "Left" },
    { value: "right", label: "Right" }
  ]

  readonly property var autoHideOptions: [
    { value: "never", label: "Never" },
    { value: "fullscreen", label: "Fullscreen" },
    { value: "covered", label: "Covered" },
    { value: "always", label: "Always" }
  ]

  // As saídas ligadas, mais a opção automática. O nome é a identidade que o
  // dock guarda: é ele que ainda casa com a mesma tela depois de um reinício,
  // ao contrário da ordem em que o compositor as devolve.
  readonly property var screenOptions: {
    var options = [{ value: "", label: "Automatic (largest)" }]
    var screens = Quickshell.screens || []
    for (var i = 0; i < screens.length; i++) {
      var candidate = screens[i]
      if (!candidate || !candidate.name) continue
      options.push({
        value: String(candidate.name),
        label: String(candidate.name) + " · " + candidate.width + "×" + candidate.height
      })
    }
    return options
  }

  function optionsFor(spec) {
    if (spec.key === "dockTheme") return root.dockThemeOptions
    if (spec.key === "indicatorStyle") return root.indicatorStyleOptions
    if (spec.key === "edge") return root.edgeOptions
    if (spec.key === "autoHide") return root.autoHideOptions
    if (spec.key === "screenName") return root.screenOptions
    return []
  }

  // ----------------------------------------------------------- explicações
  //
  // Uma escolha entre opções não cabe no rótulo: "Coberto" só quer dizer alguma
  // coisa junto da frase que descreve o que acontece. Então a explicação das
  // linhas de escolha é *o valor de agora*, e não uma descrição fixa — ela
  // troca junto com o clique, e é ela que dá o retorno de que o clique valeu.
  function descriptionFor(spec) {
    if (!root.config) return String(spec.description || "")

    if (spec.key === "dockTheme") {
      if (root.config.dockTheme === "light") return "Light glass, regardless of the desktop theme."
      if (root.config.dockTheme === "dark") return "Dark glass, regardless of the desktop theme: the dock stays dark even on a light theme."
      return "The shell takes the active theme's popup tone and changes with it."
    }
    if (spec.key === "indicatorStyle") {
      if (root.config.indicatorStyle === "dots") return "Each open window gets a dot, up to two."
      if (root.config.indicatorStyle === "bar") return "A bar under the icon, easier to see than a dot on light icons."
      return "A single dot, whether the app has one window or several."
    }
    if (spec.key === "autoHide") {
      if (root.config.autoHide === "never") return "The dock stays put, even over a fullscreen app."
      if (root.config.autoHide === "always") return "The dock only shows when the pointer touches the edge."
      if (root.config.autoHide === "covered") return "Hides as soon as any window reaches its area, including two apps side by side with neither in fullscreen."
      return "Hides when one app takes the whole screen, and comes back when the pointer touches the edge."
    }
    return String(spec.description || "")
  }

  // O blur é do compositor, não do dock: com ele desligado a casca fica
  // translúcida e *nítida*, e sem este aviso o interruptor pareceria quebrado.
  // Fica na própria linha, e não no rodapé: um aviso global apareceria também
  // enquanto se mexe na posição do dock, onde ele não quer dizer nada.
  function warningFor(spec) {
    if (spec.key !== "glass") return ""
    if (!root.config || !root.config.glass) return ""
    if (!root.service || root.service.compositorBlur) return ""
    return "Hyprland blur is off, so the shell is translucent without being frosted. "
      + "Enable decoration:blur in ~/.config/hypr/looknfeel.lua."
  }

  // ---------------------------------------------------------------- valores

  function valueFor(spec) {
    if (!root.config) return spec.type === "bool" ? false : 0
    if (spec.type === "bool") return root.config.flag(spec.key)
    if (spec.type === "enum") return root.config.str(spec.key)
    return root.config.num(spec.key)
  }

  function isModified(key) {
    return !!root.config && !root.config.isDefault(key)
  }

  // Uma linha depende de um interruptor? Só vale enquanto ele estiver ligado.
  function isAvailable(spec) {
    if (!root.config) return false
    if (!spec.needs) return true
    return root.config.flag(spec.needs) === true
  }

  function stepFor(spec) {
    var step = Number(spec.step)
    return (isFinite(step) && step > 0) ? step : 1
  }

  function limitsFor(spec) {
    if (root.config && root.config.limits[spec.key]) return root.config.limits[spec.key]
    return [0, 1]
  }

  function setValue(spec, value) {
    if (!root.config) return
    root.config.set(spec.key, value)
  }

  // Voltar ao padrão é *apagar* a chave, e não gravar o número que hoje é
  // padrão: a ausência é o que faz a medida seguir o tema (ver `set` no
  // ArcConfig).
  function resetKeys(keys) {
    if (!root.config) return
    for (var i = 0; i < keys.length; i++) root.config.set(keys[i], undefined)
  }

  function resetSection() {
    var keys = []
    for (var i = 0; i < root.section.items.length; i++) keys.push(root.section.items[i].key)
    root.resetKeys(keys)
  }

  function sectionModified(entry) {
    for (var i = 0; i < entry.items.length; i++)
      if (root.isModified(entry.items[i].key)) return true
    return false
  }

  // ---------------------------------------------------------------- teclado

  function moveCursor(delta) {
    var count = root.rows.length
    if (count === 0) return
    root.cursorIndex = (root.cursorIndex + delta + count) % count
    rowsView.positionViewAtIndex(root.cursorIndex, ListView.Contain)
  }

  function moveSection(delta) {
    var count = root.sections.length
    root.sectionIndex = (root.sectionIndex + delta + count) % count
    root.cursorIndex = 0
    rowsView.positionViewAtIndex(0, ListView.Beginning)
  }

  function cursorSpec() {
    if (root.cursorIndex < 0 || root.cursorIndex >= root.rows.length) return null
    return root.rows[root.cursorIndex]
  }

  // Esquerda/direita mexe no valor sem tirar a mão do lugar: num interruptor é
  // desliga/liga, numa escolha é o vizinho da lista, e num número é um passo.
  function nudge(direction) {
    var spec = root.cursorSpec()
    if (!spec || !root.isAvailable(spec)) return

    if (spec.type === "bool") {
      root.setValue(spec, direction > 0)
      return
    }
    if (spec.type === "enum") {
      var options = root.optionsFor(spec)
      if (options.length === 0) return
      var at = 0
      for (var i = 0; i < options.length; i++)
        if (String(options[i].value) === String(root.valueFor(spec))) at = i
      root.setValue(spec, options[(at + direction + options.length) % options.length].value)
      return
    }

    var range = root.limitsFor(spec)
    var step = root.stepFor(spec)
    var next = Number(root.valueFor(spec)) + step * direction
    root.setValue(spec, Math.max(range[0], Math.min(range[1], Math.round(next / step) * step)))
  }

  function activateCursor() {
    var spec = root.cursorSpec()
    if (!spec || !root.isAvailable(spec)) return
    if (spec.type === "bool") root.setValue(spec, root.valueFor(spec) !== true)
    else if (spec.type === "enum") root.nudge(1)
  }

  function resetCursor() {
    var spec = root.cursorSpec()
    if (spec && root.isModified(spec.key)) root.resetKeys([spec.key])
  }

  // --------------------------------------------------------------- métricas
  //
  // Mesma família de medidas do resto do plugin: a folga do cartão é a folga de
  // painel do tema, e o raio é o da casca do dock — as curvas correm paralelas.
  readonly property int padding: Style.spacing.panelPadding
  readonly property int radius: Style.cornerRadius
  readonly property int railWidth: Style.space(150)

  readonly property var borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(2)))

  // O caminho do arquivo com o `$HOME` encurtado: o cabeçalho diz *onde* os
  // ajustes moram, e o caminho absoluto de uma home longa empurraria o resto da
  // linha para fora.
  readonly property string displayPath: {
    if (!root.config) return ""
    var home = Quickshell.env("HOME") || ""
    var path = String(root.config.path)
    return (home.length > 0 && path.indexOf(home) === 0) ? "~" + path.slice(home.length) : path
  }

  // Cores dos deslizantes do kit. Eles esperam a bar como fonte de tema; sem
  // ela caem em cinzas fixos, que num tema claro viram um sulco preto no meio
  // do cartão. Este objeto entrega os mesmos dois tons que a casca usa.
  readonly property QtObject sliderTheme: QtObject {
    readonly property color background: Color.popups.background
    readonly property color foreground: Color.popups.text
  }

  // ------------------------------------------------------------- uma linha
  //
  // Nome e explicação à esquerda, controle à direita — e é a mesma linha para
  // um deslizante, um interruptor, uma escolha entre opções e um dropdown. É
  // isso que faz as quatro famílias lerem como a mesma coisa: a coluna da
  // direita é sempre a resposta, seja ela um número ou um botão.
  //
  // A linha não guarda valor nenhum. Ela lê do `config` e escreve nele — o dock
  // repinta no mesmo quadro, e não existe estado aqui para sair de sincronia.
  component OptionRow: Item {
    id: row

    required property var spec
    property int rowIndex: 0

    readonly property string key: String(row.spec.key)
    readonly property bool isBool: row.spec.type === "bool"
    readonly property bool isEnum: row.spec.type === "enum"
    readonly property bool isSlider: row.spec.type === "int"
    readonly property bool isDropdown: row.isEnum && row.spec.widget === "dropdown"
    readonly property bool modified: root.isModified(row.key)
    readonly property bool available: root.isAvailable(row.spec)
    readonly property bool hasCursor: root.cursorIndex === row.rowIndex
    readonly property string warning: root.warningFor(row.spec)

    // O sufixo tem uma segunda forma para o singular onde a unidade é contável:
    // "1 slots" não é português, e a coluna do valor é curta demais para
    // esconder isso.
    function formatted() {
      if (!row.isSlider) return ""
      var value = Number(root.valueFor(row.spec))
      if (!isFinite(value)) return "—"
      var suffix = (value === 1 && row.spec.suffixOne !== undefined)
        ? row.spec.suffixOne
        : (row.spec.suffix || "")
      return Math.round(value) + String(suffix)
    }

    implicitHeight: Math.max(labels.implicitHeight, control.implicitHeight) + Style.spacing.xxl
    // Apagada, e não escondida: a linha continua ocupando o lugar dela, então
    // ligar o interruptor de cima não faz a seção inteira pular.
    opacity: row.available ? 1 : 0.38
    enabled: row.available

    Behavior on opacity { NumberAnimation { duration: 120 } }

    // A marca da linha sob o cursor sangra para dentro da folga do cartão, para
    // a faixa alcançar as duas pontas em vez de flutuar no meio.
    Rectangle {
      anchors.fill: parent
      anchors.leftMargin: -Style.spacing.md
      anchors.rightMargin: -Style.spacing.md
      radius: Style.cornerRadius
      color: row.hasCursor ? Style.hoverFillFor(Color.popups.text, Color.accent) : "transparent"
      Behavior on color { ColorAnimation { duration: 100 } }
    }

    // O ponteiro move o cursor do teclado em vez de ter um realce só dele:
    // duas marcas de "onde estou" competindo é o que faz Backspace apagar a
    // linha errada.
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.NoButton
      hoverEnabled: true
      onEntered: root.cursorIndex = row.rowIndex
    }

    Column {
      id: labels
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      // Quase metade da linha, e não os 42% do Omaland: as explicações deste
      // plugin são frases inteiras ("o ícone embaixo do cursor cresce e sobe
      // acima da casca…"), e numa coluna estreita elas viravam quatro linhas
      // enquanto o deslizante ao lado sobrava largura sem usar.
      width: Math.round(parent.width * 0.46)
      spacing: Style.spacing.xxs

      Row {
        width: parent.width
        spacing: Style.spacing.sm

        Text {
          text: String(row.spec.label)
          color: Color.popups.text
          font.family: Style.fontFamily
          font.pixelSize: Style.font.subtitle
        }

        // Ponto cheio = esta chave está gravada no arquivo. É a única marca de
        // "isto saiu do padrão do tema", e a mesma que o botão de desfazer da
        // direita apaga.
        Rectangle {
          width: Style.space(5)
          height: width
          radius: width / 2
          color: Color.accent
          opacity: row.modified ? 1 : 0
          anchors.verticalCenter: parent.verticalCenter
          Behavior on opacity { NumberAnimation { duration: 120 } }
        }
      }

      Text {
        text: root.descriptionFor(row.spec)
        visible: text !== ""
        width: parent.width
        wrapMode: Text.WordWrap
        color: Color.muted
        font.family: Style.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        text: row.warning
        visible: row.warning !== ""
        width: parent.width
        wrapMode: Text.WordWrap
        color: Color.urgent
        font.family: Style.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    Row {
      id: control
      anchors.right: parent.right
      anchors.left: labels.right
      anchors.leftMargin: Style.spacing.xxl
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.spacing.lg
      // Da direita para a esquerda: o desfazer fica sempre na mesma coluna, na
      // ponta, e o controle cresce para dentro em vez de empurrá-lo.
      layoutDirection: Qt.RightToLeft

      readonly property int valueWidth: Style.space(52)

      // O lugar do desfazer é reservado mesmo vazio, senão os deslizantes de
      // uma seção ficariam cada um com um comprimento.
      Item {
        width: undoButton.width
        height: undoButton.height
        anchors.verticalCenter: parent.verticalCenter

        PanelActionButton {
          id: undoButton
          iconText: "󰕌"
          tooltipText: "Reset to default"
          foreground: Color.popups.text
          opacity: row.modified ? 1 : 0
          enabled: row.modified
          onClicked: root.resetKeys([row.key])
          Behavior on opacity { NumberAnimation { duration: 120 } }
        }
      }

      Text {
        visible: row.isSlider
        text: row.formatted()
        // No padrão do tema o valor recua; mexido, ele assume o destaque.
        color: row.modified ? Color.accent : Color.popups.text
        font.family: Style.fontFamily
        font.pixelSize: Style.font.body
        horizontalAlignment: Text.AlignRight
        width: control.valueWidth
        anchors.verticalCenter: parent.verticalCenter
      }

      ToggleSwitch {
        visible: row.isBool
        checked: root.valueFor(row.spec) === true
        hasCursor: row.hasCursor
        foreground: Color.popups.text
        accent: Color.accent
        anchors.verticalCenter: parent.verticalCenter
        onToggled: root.setValue(row.spec, root.valueFor(row.spec) !== true)
      }

      PanelSlider {
        visible: row.isSlider
        width: Math.max(Style.space(90),
                        control.width - undoButton.width - control.valueWidth - Style.spacing.lg * 2)
        bar: root.sliderTheme
        integer: true
        step: root.stepFor(row.spec)
        minimum: root.limitsFor(row.spec)[0]
        maximum: root.limitsFor(row.spec)[1]
        value: Number(root.valueFor(row.spec))
        fillColor: row.modified ? Color.accent : Color.popups.text
        knobColor: row.modified ? Color.accent : Color.popups.text
        anchors.verticalCenter: parent.verticalCenter
        // Arredondado ao passo: uma carência de 437 ms não é uma escolha, é o
        // pixel em que o dedo parou.
        onMoved: function (next) {
          var step = root.stepFor(row.spec)
          root.setValue(row.spec, Math.round(next / step) * step)
        }
      }

      ButtonGroup {
        visible: row.isEnum && !row.isDropdown
        options: root.optionsFor(row.spec)
        value: String(root.valueFor(row.spec))
        foreground: Color.popups.text
        background: Color.popups.background
        accent: Color.accent
        fontFamily: Style.fontFamily
        // O foco é do `keyCatcher`: um controle que o tomasse mataria o hjkl
        // até o próximo clique fora dele.
        focusable: false
        anchors.verticalCenter: parent.verticalCenter
        onChanged: function (next) { root.setValue(row.spec, next) }
      }

      // O monitor é a única escolha cuja lista o dock não conhece de antemão —
      // ela vem do compositor, com nomes longos e em número variável. Um
      // dropdown cabe onde uma fileira de botões não caberia.
      Dropdown {
        visible: row.isDropdown
        width: Math.min(Style.spacing.dropdownWidth,
                        Math.max(Style.space(120), control.width - undoButton.width - Style.spacing.lg))
        showLabel: false
        options: root.optionsFor(row.spec)
        value: String(root.valueFor(row.spec))
        foreground: Color.popups.text
        background: Color.popups.background
        hasCursor: row.hasCursor
        anchors.verticalCenter: parent.verticalCenter
        onChanged: function (next) { root.setValue(row.spec, next) }
        // O popup precisa do foco para andar com as setas; ao fechar ele volta,
        // senão o teclado da janela ficaria morto a partir daí.
        onPopupOpenChanged: if (!popupOpen) Qt.callLater(root.grabKeys)
      }
    }
  }

  // --------------------------------------------------------------- a janela

  PanelWindow {
    id: window
    visible: root.opened
    color: "transparent"

    // Na tela do dock, e não na que o compositor devolver primeiro: os ajustes
    // são daquele dock, e mostrá-los noutro monitor deixaria a
    // pré-visualização fora do campo de visão.
    screen: root.service ? root.service.dockScreen : null

    anchors { top: true; bottom: true; left: true; right: true }

    WlrLayershell.namespace: "arc-dock-settings"
    // Overlay, e não Top: o dock vive no Top, e os ajustes precisam ficar por
    // cima dele — inclusive por cima da casca que eles estão mexendo.
    WlrLayershell.layer: WlrLayer.Overlay
    // Exclusivo porque a janela é dirigida pelo teclado.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    // Sem véu de fundo, ao contrário do Omaland e do menu do Omarchy. O véu
    // existe para apagar o que está atrás e prender o olho no cartão — e aqui o
    // que está atrás é o dock que os controles estão mexendo. Escurecê-lo
    // desmancharia a pré-visualização, que é o que esta janela tem de melhor.
    //
    // Clicar fora fecha. O MouseArea cobre a tela inteira, mas fica *atrás* do
    // cartão, então um clique dentro dele nunca chega aqui.
    MouseArea {
      anchors.fill: parent
      onClicked: root.close()
    }

    BorderSurface {
      id: card
      anchors.centerIn: parent
      width: Math.min(Style.space(820), window.width - Style.gapsOut * 4)
      // Altura fixa, e não a da seção aberta: com o cartão centrado, seguir a
      // seção da vez faria a trilha, o cabeçalho e o rodapé pularem de lugar a
      // cada troca — e isso custa mais que a folga que sobra embaixo de uma
      // seção curta.
      height: Math.min(Style.space(460), window.height - Style.gapsOut * 4)
      radius: root.radius
      color: Color.popups.background
      borderSpec: root.borderSpec
      padding: root.padding

      // Engole o clique para o MouseArea de fechar não o receber.
      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.onPressed: function (event) {
          // hjkl espelha as setas, mas só sem modificador: Ctrl+L e parentes
          // continuam sendo do compositor.
          var vim = !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))

          if (event.key === Qt.Key_Escape) { root.close(); event.accepted = true }
          else if (event.key === Qt.Key_Down || (vim && event.key === Qt.Key_J)) {
            root.moveCursor(1); event.accepted = true
          }
          else if (event.key === Qt.Key_Up || (vim && event.key === Qt.Key_K)) {
            root.moveCursor(-1); event.accepted = true
          }
          else if (event.key === Qt.Key_Right || (vim && event.key === Qt.Key_L)) {
            root.nudge(1); event.accepted = true
          }
          else if (event.key === Qt.Key_Left || (vim && event.key === Qt.Key_H)) {
            root.nudge(-1); event.accepted = true
          }
          // O Back-tab chega como Key_Backtab ou como um Key_Tab com Shift,
          // dependendo do compositor e do mapa de teclado.
          else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            var back = event.key === Qt.Key_Backtab || (event.modifiers & Qt.ShiftModifier)
            root.moveSection(back ? -1 : 1)
            event.accepted = true
          }
          else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                   || event.key === Qt.Key_Space) { root.activateCursor(); event.accepted = true }
          else if (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete) {
            root.resetCursor(); event.accepted = true
          }
        }
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.spacing.panelGap

        // ------------------------------------------------------ cabeçalho
        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: Math.max(titleBlock.implicitHeight, headerActions.implicitHeight)

          Column {
            id: titleBlock
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.spacing.xxs

            Text {
              text: "Arc Dock"
              color: Color.popups.text
              font.family: Style.fontFamily
              font.pixelSize: Style.font.heading
            }

            Text {
              text: root.config ? root.displayPath : "The dock is not running, so there is nothing to adjust."
              color: Color.muted
              font.family: Style.fontFamily
              font.pixelSize: Style.font.caption
            }
          }

          Row {
            id: headerActions
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.spacing.lg

            // Quantos ajustes saíram do padrão, e não um "modificado" sim/não:
            // é o que diz de quanto o dock se afastou do tema antes de decidir
            // se vale restaurar tudo.
            Text {
              visible: !!root.config
              text: {
                if (!root.config) return ""
                var count = root.config.overrideCount
                if (count === 0) return "Defaults"
                return count + (count === 1 ? " change" : " changes")
              }
              color: (root.config && root.config.overrideCount > 0) ? Color.accent : Color.muted
              font.family: Style.fontFamily
              font.pixelSize: Style.font.caption
              anchors.verticalCenter: parent.verticalCenter
            }

            Button {
              text: "Reset all"
              // Sem nada fora do padrão não há o que restaurar, e um botão que
              // não faz nada só faz duvidar se o clique valeu.
              enabled: !!root.config && root.config.customized
              opacity: enabled ? 1 : 0.4
              bordered: true
              focusable: false
              foreground: Color.popups.text
              accent: Color.accent
              fontFamily: Style.fontFamily
              anchors.verticalCenter: parent.verticalCenter
              onClicked: root.config.resetAll()
            }

            PanelActionButton {
              iconText: "󰅖"
              tooltipText: "Close  ·  Esc"
              foreground: Color.popups.text
              anchors.verticalCenter: parent.verticalCenter
              onClicked: root.close()
            }
          }
        }

        PanelSeparator { foreground: Color.popups.text; Layout.fillWidth: true }

        // ------------------------------------------- trilha + seção aberta
        RowLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: Style.spacing.panelGap
          visible: !!root.config

          Column {
            id: rail
            Layout.preferredWidth: root.railWidth
            Layout.alignment: Qt.AlignTop
            spacing: Style.spacing.xs

            Repeater {
              model: root.sections

              Button {
                required property var modelData
                required property int index

                width: rail.width
                // O "·" diz que há coisa fora do padrão lá dentro, sem obrigar
                // a entrar em cada seção para conferir.
                text: modelData.title + (root.sectionModified(modelData) ? "  ·" : "")
                iconText: modelData.icon
                leftAlign: true
                selected: root.sectionIndex === index
                focusable: false
                foreground: Color.popups.text
                background: Color.popups.background
                accent: Color.accent
                fontFamily: Style.fontFamily
                onClicked: {
                  root.sectionIndex = index
                  root.cursorIndex = 0
                }
              }
            }
          }

          Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.12)
          }

          ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Style.spacing.sm

            Item {
              Layout.fillWidth: true
              Layout.preferredHeight: sectionBlurb.implicitHeight + Style.spacing.md

              Text {
                id: sectionBlurb
                anchors.left: parent.left
                anchors.right: sectionReset.left
                anchors.rightMargin: Style.spacing.lg
                anchors.verticalCenter: parent.verticalCenter
                text: root.section.blurb
                color: Color.muted
                font.family: Style.fontFamily
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
              }

              PanelActionButton {
                id: sectionReset
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                iconText: "󰕌"
                tooltipText: "Reset this section"
                foreground: Color.popups.text
                visible: root.sectionModified(root.section)
                onClicked: root.resetSection()
              }
            }

            PanelSeparator { foreground: Color.popups.text; Layout.fillWidth: true }

            ListView {
              id: rowsView
              Layout.fillWidth: true
              Layout.fillHeight: true
              clip: true
              model: root.rows
              boundsBehavior: Flickable.StopAtBounds
              currentIndex: root.cursorIndex
              onModelChanged: root.cursorIndex = 0

              delegate: OptionRow {
                required property var modelData
                required property int index

                // A folga da direita é o lugar da barra de rolagem: sem ela o
                // botão de desfazer ficaria embaixo dela.
                width: rowsView.width - Style.spacing.xxl
                spec: modelData
                rowIndex: index
              }

              // Barra de rolagem só quando há o que rolar — numa seção que cabe
              // inteira ela seria um traço sem função.
              Rectangle {
                anchors.right: parent.right
                width: Style.space(3)
                radius: width / 2
                color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.25)
                visible: rowsView.contentHeight > rowsView.height
                height: Math.max(Style.space(24),
                                 rowsView.height * (rowsView.height / Math.max(1, rowsView.contentHeight)))
                y: (rowsView.height - height)
                   * (rowsView.contentY / Math.max(1, rowsView.contentHeight - rowsView.height))
              }
            }
          }
        }

        // Sem serviço no ar não há o que ajustar, e uma trilha de seis seções
        // vazias só faria procurar o defeito nos ajustes em vez de no dock.
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: !root.config

          Text {
            anchors.centerIn: parent
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "The dock is not running. Start the shell and open the settings again."
            color: Color.muted
            font.family: Style.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
        }

        PanelSeparator { foreground: Color.popups.text; Layout.fillWidth: true }

        // --------------------------------------------------------- rodapé
        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: footerText.implicitHeight + Style.spacing.md

          Text {
            id: footerText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "↑↓ kj row · ←→ hl adjust · Tab section · Backspace default · Esc close"
              + "   —   changes apply immediately"
            color: Color.muted
            font.family: Style.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.WordWrap
          }
        }
      }
    }
  }
}
