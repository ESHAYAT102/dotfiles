// ArcMenu — o menu de contexto de um slot.
//
// É uma PopupWindow própria, e não um Item dentro do dock: a janela do dock
// tem exatamente o tamanho do dock, então qualquer coisa desenhada lá dentro
// seria recortada. Uma popup é uma superfície separada, que o compositor
// posiciona por cima e ainda encaixa na tela sozinho quando o menu nasce perto
// de uma borda.
//
// Aqui só mora a aparência: as linhas chegam prontas em `items`, montadas pelo
// Arcdock, e o que este arquivo devolve é "acionaram esta linha". Assim a
// política (o que um app oferece) fica num lugar só.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

PopupWindow {
  id: menu

  // O slot que abriu o menu: dele saem a janela âncora e a posição.
  property Item anchorItem: null

  // A borda em que o dock está ancorado. O menu sempre abre para *dentro* da
  // tela, ou seja, para o lado oposto a ela: num dock de baixo ele sobe, num
  // dock à esquerda ele vai para a direita. Abrir sempre para cima deixaria o
  // menu de um dock de topo cobrindo o próprio dock.
  property string edge: "bottom"
  readonly property bool vertical: menu.edge === "left" || menu.edge === "right"

  // Linhas prontas, em ordem. Três formas:
  //   { header: true, label }   — o nome do app, sem interação
  //   { separator: true }       — o filete entre grupos
  //   { label, current, run }   — a linha acionável
  property var items: []

  property bool open: false

  // Acionaram uma linha. Quem executa e fecha é o dock.
  signal triggered(var item)
  // O grab caiu (clique fora): o menu deve sumir.
  signal dismissed()

  readonly property var anchorWindow: anchorItem ? anchorItem.QsWindow.window : null
  readonly property var menuScreen: anchorWindow ? anchorWindow.screen : null

  // ------------------------------------------------------------- métricas
  //
  // A folga interna da casca é a mesma folga horizontal da linha, então o
  // texto recua da borda exatamente o dobro dela e não há um segundo número
  // para manter em sincronia.
  readonly property int padding: Style.spacing.lg
  readonly property int rowHeight: Style.spacing.popupRowHeight
  readonly property int separatorHeight: Style.spacing.lg

  // Distância entre o menu e o dock: um passo e meio da folga interna da casca
  // (`xxl`, 12 px no padrão). Descolado o bastante para as duas superfícies não
  // se lerem como uma só, e ainda vindo de um token, então um tema de
  // espaçamento maior afasta as duas junto.
  readonly property int gap: Style.spacing.xxl

  readonly property int radius: Style.cornerRadius
  // Mesma regra concêntrica do slot dentro do dock: o raio da linha é o da
  // casca menos a folga entre as duas, e as curvas correm paralelas.
  readonly property int rowRadius: Math.max(0, radius - padding)

  // Contorno do tema, na reserva cheia. O dock afina a dele para um fio quando
  // está de vidro, porque ali uma linha de peso seria a única coisa sólida de
  // uma casca translúcida (ver `borderSpec` no Arcdock); aqui a casca é sólida,
  // e a borda volta a ser o que separa duas superfícies opacas.
  readonly property var borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border,
    Math.max(1, Style.space(2)))

  // Altura que a casca consome fora do conteúdo. Calculada do spec, e não lida
  // do BorderSurface: o card preenche a janela, então ler dele para dimensionar
  // a janela fecharia um laço de binding.
  readonly property real verticalInset: padding * 2 + Border.top(borderSpec) + Border.bottom(borderSpec)

  // Teto de altura: a tela menos a folga de cada ponta. Um app com muitas
  // janelas rola dentro do menu em vez de crescer para fora da tela.
  readonly property real availableHeight: menuScreen ? Math.max(rowHeight, menuScreen.height - gap * 2) : 0

  color: "transparent"
  // A casca some com fade, e a janela precisa ficar de pé até o fade acabar.
  visible: open || card.opacity > 0

  implicitWidth: Style.spacing.dropdownWidth
  implicitHeight: {
    var desired = rows.implicitHeight + menu.verticalInset
    return Math.round(menu.availableHeight > 0 ? Math.min(desired, menu.availableHeight) : desired)
  }

  // Fecha ao clicar fora. Enquanto o grab está de pé o clique só chega às
  // janelas listadas; o dock entra na lista para que clicar noutro slot troque
  // o menu em vez de só fechá-lo.
  HyprlandFocusGrab {
    active: menu.open
    windows: menu.anchorWindow ? [menu, menu.anchorWindow] : [menu]
    onCleared: menu.dismissed()
  }

  // O menu nasce encostado no slot pelo lado de dentro da tela e centrado nele
  // no outro eixo. `mapFromItem` não é reativo, então a conta é refeita a cada
  // ancoragem — e também quando a altura muda, que é o que acontece quando o app
  // abre ou fecha uma janela com o menu no ar.
  function reposition() {
    var target = menu.anchorItem
    var window = menu.anchorWindow
    if (!target || !window) return

    // Deslocamento a partir do canto do slot, no sistema dele. No eixo da
    // borda o menu se descola pelo `gap`; no outro, ele se centra no slot.
    var dx = menu.vertical
      ? (menu.edge === "left" ? target.width + menu.gap : -menu.implicitWidth - menu.gap)
      : target.width / 2 - menu.implicitWidth / 2
    var dy = menu.vertical
      ? target.height / 2 - menu.implicitHeight / 2
      : (menu.edge === "top" ? target.height + menu.gap : -menu.implicitHeight - menu.gap)

    var point = window.contentItem.mapFromItem(target, dx, dy)
    menuAnchor.rect.x = Math.round(point.x)
    menuAnchor.rect.y = Math.round(point.y)
  }

  onImplicitHeightChanged: menu.reposition()
  onEdgeChanged: menu.reposition()

  anchor {
    id: menuAnchor
    window: menu.anchorWindow
    // O ponto calculado é o canto superior esquerdo, e o menu cresce dali para
    // baixo e para a direita. Slide deixa o compositor empurrar o menu para
    // dentro da tela quando o slot está numa das pontas do dock.
    adjustment: PopupAdjustment.Slide
    edges: Edges.Top | Edges.Left
    gravity: Edges.Bottom | Edges.Right
    rect.width: 1
    rect.height: 1

    onAnchoring: menu.reposition()
  }

  BorderSurface {
    id: card
    anchors.fill: parent
    // Opaco, mesmo com o vidro do dock ligado, e é de propósito: a casca do dock
    // carrega ícones, que se leem por cima de qualquer coisa, e o menu é uma
    // folha de texto, em que cada rótulo disputaria contraste com o que passa
    // atrás. Aqui a leitura vale mais que a continuidade de material. O tom é o
    // mesmo `popups` dos outros menus da shell, então quem manda continua
    // sendo o tema.
    color: Color.popups.background
    radius: menu.radius
    borderSpec: menu.borderSpec
    padding: menu.padding
    opacity: menu.open ? 1.0 : 0.0

    Behavior on opacity {
      NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    Flickable {
      anchors.fill: parent
      anchors.topMargin: card.contentTopInset
      anchors.rightMargin: card.contentRightInset
      anchors.bottomMargin: card.contentBottomInset
      anchors.leftMargin: card.contentLeftInset
      contentWidth: width
      contentHeight: rows.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      // Só rola quando de fato transborda; caso contrário um arrasto acidental
      // deslocaria um menu que cabe inteiro.
      interactive: contentHeight > height

      Column {
        id: rows
        width: parent.width

        Repeater {
          model: menu.items

          delegate: Item {
            id: row
            required property var modelData

            readonly property bool separator: !!modelData.separator
            readonly property bool header: !!modelData.header
            // Cabeçalho e filete são rótulo e moldura: não há o que acionar.
            readonly property bool actionable: !separator && !header

            width: rows.width
            implicitHeight: separator ? menu.separatorHeight : menu.rowHeight

            // Mesmo filete que separa os apps do launcher dentro do dock: a
            // cor da borda da casca, a mesma linha dividindo por dentro.
            Rectangle {
              visible: row.separator
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: menu.padding
              anchors.rightMargin: menu.padding
              anchors.verticalCenter: parent.verticalCenter
              height: Math.max(1, Style.space(1))
              color: menu.borderSpec.color
            }

            Rectangle {
              visible: row.actionable && pointer.containsMouse
              anchors.fill: parent
              radius: menu.rowRadius
              color: Util.alpha(Color.popups.text, Style.hoverFillAlpha)
            }

            Text {
              visible: !row.separator
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: menu.padding
              anchors.rightMargin: menu.padding
              text: String(row.modelData.label || "")
              elide: Text.ElideRight
              font.family: Style.fontFamily
              // O cabeçalho nomeia o app e recua no tom de fundo do tema; a
              // linha da janela em foco é a única marcada, e no mesmo `accent`
              // que o ponto do slot já usa para dizer "em foco".
              font.pixelSize: row.header ? Style.font.bodySmall : Style.font.body
              color: row.header
                ? Color.muted
                : (row.modelData.current ? Color.accent : Color.popups.text)
            }

            MouseArea {
              id: pointer
              anchors.fill: parent
              enabled: row.actionable
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: menu.triggered(row.modelData)
            }
          }
        }
      }
    }
  }
}
