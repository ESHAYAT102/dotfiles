// Arcdock — superfície do dock e os slots dos apps abertos.
//
// A superfície é uma PanelWindow ancorada no centro da borda inferior,
// flutuando por cima das janelas. Dentro dela ficam os *slots*: cada app
// aberto ocupa um slot, e a largura do dock é derivada da quantidade deles.
//
// A janela fica de pé o tempo todo, mas nem sempre o dock: com um app ocupando
// a tela inteira a casca desliza para fora e sobra só uma faixa de gatilho na
// borda de baixo, que devolve o dock assim que o ponteiro encosta nela.
//
// Os dois sentidos não têm o mesmo tempo de propósito: voltar é imediato, e
// sair passa por uma carência (ver `hideDelay`) — o dock não pode fugir de
// baixo de um ponteiro que só passou de raspão.
//
// O plugin é `kind: service` porque a janela precisa existir enquanto a shell
// existir — não é algo que se invoca sob demanda como um panel/overlay.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
  id: root

  property var themedIconNames: ({})

  Process {
    id: themedIconScan
    running: true
    command: ["bash", "-lc", "theme=$(gsettings get org.gnome.desktop.interface icon-theme); theme=${theme#\\'}; theme=${theme%\\'}; for root in \"$HOME/.local/share/icons\" /usr/share/icons; do dir=\"$root/$theme\"; [ -d \"$dir\" ] && fd --type f --extension svg --extension png --extension xpm . \"$dir/apps\" \"$dir/apps@2x\" 2>/dev/null; done"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var names = ({})
        var paths = text.split("\n")
        for (var i = 0; i < paths.length; i++) {
          var file = paths[i].split("/").pop()
          var dot = file.lastIndexOf(".")
          if (dot > 0) names[file.slice(0, dot).toLowerCase()] = true
        }
        root.themedIconNames = names
      }
    }
  }

  // Injetado pelo host quando o serviço sobe. O que interessa aqui é o
  // `appLibrary`: ele já mantém o índice nome-do-ícone -> arquivo, com rescan
  // quando um app novo é instalado, então o dock não precisa de índice próprio.
  property var shell: null
  readonly property var appLibrary: root.shell ? root.shell.appLibrary : null

  // Id do plugin, para o dock pedir ao host que abra a *sua* janela de ajustes.
  // Vem do manifesto injetado, e não escrito aqui: `omarchy plugin clone` gera
  // uma cópia com id de outro nome, e um id fixo abriria os ajustes do original.
  property var manifest: null
  readonly property string pluginId: (manifest && manifest.id) ? String(manifest.id) : "io.github.claudsondouglas.arcdock"

  // Os ajustes do usuário. Existe um só, e é nele que a janela de ajustes
  // escreve: o dock lê por binding, então mexer num controle repinta na hora.
  // O alias é o que deixa esse objeto alcançável de fora — a janela de ajustes
  // recebe este serviço injetado pelo host e chega ao `config` por ele.
  readonly property alias config: configModel
  ArcConfig { id: configModel }

  // ------------------------------------------------------------- geometria
  //
  // O dock não tem medida fixa: ela sai da contagem de slots. E o tamanho do
  // slot sai do ícone — o ícone mais a folga em volta —, então mudar o ícone de
  // tamanho reajusta o slot e o dock inteiro sozinho.
  readonly property int iconSize: config.iconSize
  readonly property int iconPadding: Style.space(4)
  readonly property int slotSize: iconSize + iconPadding * 2
  readonly property int slotGap: config.slotGap
  readonly property int dockPadding: config.dockPadding

  // Distância entre o começo de um slot e o do seguinte. É a medida da fileira
  // que a reordenação usa: um passo é o quanto o vizinho recua para abrir
  // espaço, e é ele que converte deslocamento do ponteiro em posições andadas.
  readonly property int slotStep: slotSize + slotGap

  // Único arredondamento do dock: o da casca. Espelha o `decoration:rounding`
  // do Hyprland, então o dock curva junto com as janelas do tema. Slots e botão
  // não têm casca própria, logo não têm raio próprio.
  readonly property int dockRadius: Style.cornerRadius

  // Alcance da penumbra, a partir da borda da casca. Sai do arredondamento
  // dela: a sombra de uma peça é da ordem da curva da peça, então um tema de
  // cantos mais fechados projeta menos. O piso é a folga interna, para um tema
  // de `rounding` zero não ficar sem sombra nenhuma.
  readonly property int shadowExtent: Math.max(root.dockPadding, root.dockRadius)

  // Quanto a penumbra desce, em pixels de tela. Um terço do alcance: o
  // bastante para a base ficar mais assentada que o topo, sem a sombra virar
  // uma segunda peça deslocada por baixo do dock. Sempre para baixo na tela,
  // seja qual for a borda (ver o `ArcShadow`).
  readonly property int shadowDrop: Math.round(root.shadowExtent / 3)

  // ------------------------------------------------------------ o tom da casca
  //
  // O dock nasceu puxando tudo de `Color.popups.*`, e isso resolve o caso em
  // que o dock é mais um painel da shell. Não resolve o caso em que ele é o
  // dock: um tema claro pinta popups claros, e o dock do macOS é escuro *sobre*
  // um desktop claro. A cor da casca não é a mesma pergunta que a cor de um
  // popup, e o ajuste `dockTheme` é onde as duas se separam.
  //
  // Fora de "theme" nada aqui vem do tema — nem o tom, nem a luz, nem a borda.
  // Meio termo não existe: uma borda de tema claro em volta de uma casca escura
  // é justamente a moldura branca que o `ArcGlass` foi escrito para não
  // desenhar. Ou o tom é do tema por inteiro, ou é da escolha por inteiro.
  readonly property bool tintForced: config.dockTheme !== "theme"

  // Os dois tons, medidos e não escolhidos: são o `.arcdock-panel` do ArcDock
  // do GNOME, que é de onde vem a aparência que este ajuste persegue. O escuro
  // é azulado (28/28/32) e não preto — preto puro lê como buraco no wallpaper,
  // não como vidro.
  readonly property color tintBase: config.dockTheme === "dark" ? "#1c1c20"
    : config.dockTheme === "light" ? "#ffffff"
    : Color.popups.background

  // A luz é branca nos dois tons, e não o oposto do tom. Vidro escuro pega a
  // mesma claridade que vidro claro pega — o que muda entre os dois é o corpo
  // atrás dela, não a cor dela. `popups.text` serviria de luz só enquanto o
  // tom viesse do tema; com o tom fixado ele viraria uma luz preta num tema
  // claro, que é sombra desenhada no lugar errado.
  readonly property color tintSheen: root.tintForced ? "#ffffff" : Color.popups.text

  // O assentamento de baixo. Escuro nos dois tons pela mesma razão: é a face
  // que a luz não alcança, e no vidro claro é ele que faz a casca ir de 36%
  // de branco em cima a 20% embaixo em vez de ser um retângulo leitoso.
  readonly property color tintShade: root.tintForced ? "#16161a" : Color.popups.background

  // A tinta dos pontos de estado, como par [em foco, fora de foco].
  //
  // Com o tom vindo do tema, `accent` e `muted` são a resposta certa: o tema
  // escolheu os dois justamente para marcar o ativo e o recuado, e o chão em
  // que eles caem é o mesmo `popups.background` que os acompanha.
  //
  // Com o tom fixado esse acordo se desfaz — o chão passou a ser a escolha do
  // usuário e o `accent` continuou sendo o do tema, que pode ser um azul de
  // tema claro pousado numa casca escura. Então a marca passa a ser branca nos
  // dois casos, com os alfas do ArcDock do GNOME: 92% no vidro escuro, 60% no
  // claro. O claro é mais fraco de propósito — sobre vidro translúcido um
  // ponto opaco lê como furo na casca, e não como marca.
  readonly property var indicatorInk: root.tintForced
    ? (config.dockTheme === "dark"
        ? [Util.alpha("#ffffff", 0.92), Util.alpha("#ffffff", 0.45)]
        : [Util.alpha("#ffffff", 0.60), Util.alpha("#ffffff", 0.35)])
    : [Color.accent, Color.muted]

  // Contorno da casca, resolvido uma vez: além de pintar a borda, é dele que o
  // filete tira a cor, para as duas linhas do dock serem a mesma linha.
  //
  // A espessura de reserva muda com o vidro. Sem ele a borda separa uma casca
  // opaca do que está atrás, e aguenta ser uma linha de peso; com ele a mesma
  // linha vira a moldura de um retângulo translúcido e passa a ser a coisa mais
  // sólida do dock — o vidro pede um fio. É *reserva*: um tema que declare
  // `popups.border-width` continua mandando nos dois casos.
  readonly property var borderSpec: Border.surfaceSpec("popups", "border", root.tintSheen,
    Math.max(1, Style.space(config.glass ? 1 : 2)))

  // A borda que a casca desenha. Fora do vidro é a do tema, sem mais.
  //
  // No vidro ela deixa de ser *cor* e passa a ser *luz*. A cor do tema vem
  // opaca (`popups.border` é uma linha cheia), e numa casca em que todo o resto
  // é translúcido ela fica sendo a única coisa sólida do dock: uma linha
  // desenhada por cima do vidro, que não recebe nada do que passa atrás. Do
  // tema fica só a espessura (ver `borderSpec`); a cor é a luz do vidro
  // (`tintSheen`), a mesma que o `ArcGlass` inclina na face.
  //
  // O modelo é o reflexo de aresta do vidro do macOS: não é um contorno, é um
  // brilho que pega onde a superfície encara a luz. Com a luz vindo de cima à
  // esquerda da tela, o fio é cheio no canto superior esquerdo, vai morrendo
  // ao longo das arestas de cima e da esquerda, some de vez na de baixo e na
  // da direita — e volta, bem mais fraco, no canto oposto, que é a aresta de
  // trás devolvendo a mesma luz. Não há ponta escura: o assentamento da peça
  // é a sombra (ver `ArcShadow`), não uma linha preta desenhada na base.
  //
  // O gradiente corre na diagonal, do canto superior esquerdo ao inferior
  // direito, e as paradas são a curva desse brilho: o de "selecionado" do tema
  // no pico — o mais fraco dos alfas de estado que ainda se lê como linha —,
  // metade dele no reflexo oposto, e zero pelo meio. Diagonal mesmo com o dock
  // nas bordas laterais, pela mesma razão do `ArcGlass`: a luz vem de cima da
  // tela, não da borda em que o dock ancorou.
  //
  // O filete segue com o `borderSpec` chapado: ele corre por dentro da casca,
  // onde não há aresta para pegar luz nenhuma.
  readonly property var shellBorderSpec: config.glass
    ? ({
        color: Util.alpha(root.tintSheen, Style.selectedFillAlpha),
        widths: root.borderSpec.widths,
        gradient: {
          colors: [
            Util.alpha(root.tintSheen, Style.selectedFillAlpha),
            Util.alpha(root.tintSheen, Style.selectedFillAlpha / 2),
            Util.alpha(root.tintSheen, Style.normalFillAlpha),
            Util.alpha(root.tintSheen, 0),
            Util.alpha(root.tintSheen, Style.selectedFillAlpha / 2)
          ],
          angle: 45,
          enabled: true
        }
      })
    : root.borderSpec

  // Fundo da casca. No padrão é o tom de popup do tema, com a alfa que o
  // próprio tema pediu; com o vidro ligado a alfa passa a ser a do ajuste,
  // porque aí ela é a escolha do usuário e não mais a do tema. O menu de
  // contexto parte do mesmo tom, mas sempre cheio (ver o ArcMenu).
  //
  // A borda não segue esta alfa: ela é o limite da casca, e o limite não pode
  // depender de quanto o usuário abriu o vidro. Ela tem a alfa dela (ver
  // `shellBorderSpec`), medida contra os alfas do tema e não contra o ajuste.
  readonly property color surfaceColor: config.glass
    ? Util.alpha(root.tintBase, config.glassOpacity / 100)
    : root.tintBase

  // Como o compositor chama a superfície do dock. Escrito aqui, e não na
  // janela, porque a regra de blur precisa casar exatamente este nome (ver
  // `glassCommand`) — e duas cópias do mesmo texto acabariam discordando.
  readonly property string layerNamespace: "arc-dock"

  // A sombra é outra superfície, com nome próprio (ver a janela dela). O nome
  // fica ao lado deste porque é a regra do vidro que separa os dois: ela casa
  // `^(arc-dock)$` inteiro, e é isso que deixa a sombra de fora do blur.
  readonly property string shadowNamespace: root.layerNamespace + "-shadow"

  // ------------------------------------------------------------------ borda
  //
  // O dock ancora numa das quatro bordas da tela. Daí saem duas perguntas, e o
  // resto da geometria é escrito nos termos delas em vez de em "largura" e
  // "altura": `vertical` diz se a fileira corre de cima para baixo, e
  // `leadingEdge` diz de que lado da janela fica a folga até a borda da tela.
  //
  // Com isso o dock tem *comprimento* (ao longo da borda, cresce com os slots)
  // e *espessura* (atravessando, fixa). Só a janela e as âncoras traduzem os
  // dois de volta para largura e altura.
  readonly property string edge: config.edge
  readonly property bool vertical: root.edge === "left" || root.edge === "right"
  readonly property bool leadingEdge: root.edge === "top" || root.edge === "left"

  // O botão de apps e os filetes são opcionais (ver os ajustes de conteúdo).
  readonly property bool hasLauncher: config.showLauncher

  // A fileira é três grupos: os apps com slot próprio (fixados e abertos), os
  // recentes e o botão. Cada filete só existe quando há grupo dos dois lados
  // dele — senão ele seria um risco solto na ponta do dock — e some junto com a
  // folga que consome.
  readonly property bool hasRecents: root.recentSlots.length > 0
  readonly property bool separatorBeforeRecents: config.showSeparator && slots.length > 0 && root.hasRecents
  readonly property bool separatorBeforeLauncher: config.showSeparator && root.hasLauncher
    && (slots.length > 0 || root.hasRecents)
  readonly property int separatorCount: (root.separatorBeforeRecents ? 1 : 0)
    + (root.separatorBeforeLauncher ? 1 : 0)
  readonly property int separatorThickness: Math.max(1, Style.space(1))
  // Quanto o filete consome da fileira. No vidro ele é um par de linhas (ver
  // `RowFilete`), e o comprimento do dock precisa saber disso: dois filetes com
  // um pixel a mais cada deixariam a casca curta pelo tanto que a fileira
  // cresceu.
  readonly property int separatorSpan: root.separatorThickness * (config.glass ? 2 : 1)

  // O filete atravessa a fileira na altura dos ícones que ele separa: cresce
  // junto com o ícone e continua menor que o slot, então a folga do slot segue
  // sendo a folga da casca e a espessura da fileira não muda.
  readonly property int separatorExtent: iconSize

  readonly property int launcherSize: slotSize

  // Células da fileira: os slots, os recentes, os filetes (os que existem) e o
  // botão. O gap entra entre cada duas células, como a Grid faz.
  readonly property int cellCount: slots.length + root.recentSlots.length
    + root.separatorCount + (hasLauncher ? 1 : 0)

  // O piso de um slot é o que impede o dock de colapsar: com o botão de apps
  // desligado e nenhum app aberto não sobra célula nenhuma, e sem o piso a
  // casca viraria um risco na borda — sem área para o ponteiro reencontrar.
  readonly property int contentLength: Math.max(slotSize,
    (slots.length + root.recentSlots.length) * slotSize
      + root.separatorCount * separatorSpan
      + (hasLauncher ? launcherSize : 0)
      + Math.max(0, cellCount - 1) * slotGap)

  readonly property int dockLength: dockPadding * 2 + contentLength
  readonly property int dockThickness: dockPadding * 2 + slotSize

  // Espelha o `transitionDuration` do ArcSlot (e o do ArcLauncher): a onda
  // atravessa as mesmas células que o realce de ponteiro acende, e um tempo
  // próprio faria a fileira responder em dois ritmos.
  readonly property int rowTransition: 140

  // ------------------------------------------------------------- ampliação
  //
  // A onda: o ícone sob o ponteiro cresce, os vizinhos crescem menos conforme
  // se afastam dele, e a casca se abre ao longo da borda para caber o que
  // cresceu. É o realce de ponteiro de sempre, só que espalhado pela fileira
  // em vez de preso ao slot que está debaixo do cursor.
  //
  // Duas medidas mandam nisso, e as duas são ajuste: o *teto* (quanto o ícone
  // do pico cresce) e o *alcance* (a quantos slots de distância a onda ainda
  // levanta alguma coisa). Todo o resto desta seção é derivado desses dois — o
  // quanto a casca se abre, o quanto cada célula anda, e a folga que a janela
  // precisa reservar de antemão.
  readonly property bool magnifyEnabled: config.magnify

  // O teto como fator. Desligada, a ampliação é a identidade — e é isso que
  // faz o resto da seção zerar sozinho, sem um `if` por medida.
  readonly property real magnifyMax: root.magnifyEnabled ? config.magnifyScale / 100 : 1.0

  // O alcance em pixels. O ajuste conta em slots porque é assim que a onda se
  // lê; quem converte é o passo da fileira, então mudar o tamanho do ícone ou o
  // espaçamento do tema reajusta a onda sozinho.
  readonly property real magnifyReach: Math.max(1, config.magnifyReach * root.slotStep)

  // Quanto o ícone do pico cresce, em pixels. Serve aos dois eixos: ao longo da
  // fileira é o que os vizinhos têm que ceder, e atravessando ela é o quanto o
  // ícone sobe acima de onde repousa.
  readonly property real magnifyGrowth: root.iconSize * (root.magnifyMax - 1)

  // Amplitude do deslocamento: o quanto a fileira se abre por inteiro, com o
  // ponteiro no meio dela. É o crescimento do pico vezes o alcance em slots —
  // a soma do que todos os ícones dentro da onda crescem, já que a curva do
  // peso (ver `magnifyFalloff`) integra exatamente um slot por unidade de
  // alcance.
  readonly property real magnifySpread: root.magnifyGrowth * config.magnifyReach

  // A onda está no ar. Só com o ponteiro sobre a casca: fora dela não há de
  // onde medir distância, e a fileira volta ao repouso.
  //
  // Arrastando ela sai de cena. O arrasto já move os slots (ver `dragOffset`),
  // e duas translações disputando a mesma fileira deixariam o slot pego
  // escorregando de lado enquanto o dedo o segura parado.
  readonly property bool magnifyOn: root.magnifyEnabled && root.dockShown
    && pointerWatch.hovered && !root.dragging

  // Duração das transições da onda. Enquanto ela segue o ponteiro é *zero*: a
  // escala de cada ícone é função de onde o cursor está, e animá-la só a
  // atrasaria — a onda chegaria sempre um pouco depois da mão. Fora disso ela
  // volta ao tempo do realce, que é o que faz a fileira assentar quando o
  // ponteiro vai embora em vez de desabar de uma vez.
  //
  // Escrita, e não ligada por binding, pela mesma razão das curvas do slot: o
  // valor precisa já estar trocado quando a escala nova chegar. Este handler é
  // ligado quando o `root` nasce, antes de qualquer delegate existir, então ele
  // roda antes das ligações que leem `magnifyOn` lá dentro.
  property int magnifyDuration: root.rowTransition

  onMagnifyOnChanged: root.magnifyDuration = root.magnifyOn ? 0 : root.rowTransition

  // Onde o ponteiro está, medido no sistema em que a Grid posiciona as células
  // — o começo da fileira é o zero. A área sensível ao ponteiro começa junto
  // com a casca em repouso (ver `inputArea`), então descontar a folga da casca
  // já converte de uma para a outra.
  readonly property real magnifyPointer: (root.vertical
    ? pointerWatch.point.position.y
    : pointerWatch.point.position.x) - root.dockPadding

  // O peso da onda a uma distância `d` do ponteiro: 1 debaixo dele, 0 na ponta
  // do alcance. Cosseno levantado, e não uma reta: ele chega aos dois extremos
  // com inclinação zero, então a onda não tem quina nem no pico nem na borda do
  // alcance — que é o que separa uma fileira que respira de uma que pula.
  function magnifyFalloff(d) {
    var t = Math.abs(d) / root.magnifyReach
    if (t >= 1) return 0
    return 0.5 * (1 + Math.cos(Math.PI * t))
  }

  // A integral do peso, normalizada para ±0.5 nas pontas do alcance. É ela que
  // diz o quanto cada célula anda: o deslocamento de um ponto é *tudo o que
  // engordou* entre ele e o ponteiro. Sair da integral do mesmo peso que dá a
  // escala é o que garante que ninguém se sobreponha — cada ícone anda
  // exatamente o que os vizinhos entre ele e o cursor cresceram, nem mais nem
  // menos.
  function magnifyRamp(d) {
    var u = d / root.magnifyReach
    if (u >= 1) return 0.5
    if (u <= -1) return -0.5
    return 0.5 * u + Math.sin(Math.PI * u) / (2 * Math.PI)
  }

  // A escala de uma célula centrada em `center`, na coordenada da fileira.
  function magnifyScaleAt(center) {
    if (!root.magnifyOn) return 1.0
    return 1 + (root.magnifyMax - 1) * root.magnifyFalloff(center - root.magnifyPointer)
  }

  // O quanto ela anda ao longo da fileira, já recentrado (ver abaixo).
  function magnifyShiftAt(center) {
    if (!root.magnifyOn) return 0
    return root.magnifySpread * root.magnifyRamp(center - root.magnifyPointer) - root.magnifyRecenter
  }

  // As duas pontas da fileira: é o afastamento entre elas que a casca precisa
  // cobrir, e a média delas que diz o quanto a fileira escorregou.
  readonly property real magnifyStartShift: root.magnifyOn
    ? root.magnifySpread * root.magnifyRamp(-root.magnifyPointer)
    : 0
  readonly property real magnifyEndShift: root.magnifyOn
    ? root.magnifySpread * root.magnifyRamp(root.contentLength - root.magnifyPointer)
    : 0

  // A onda não se abre igual dos dois lados: com o ponteiro numa ponta, quase
  // tudo cresce para o outro lado. Sem esta correção a fileira escorregaria
  // dentro da casca — e a casca, que cresce pelo centro para o dock não sair do
  // meio da tela, ficaria com toda a folga nova de um lado só.
  readonly property real magnifyRecenter: (root.magnifyStartShift + root.magnifyEndShift) / 2

  // O comprimento da casca: o de repouso mais o quanto as duas pontas da
  // fileira se afastaram uma da outra.
  readonly property real shellLength: root.dockLength
    + root.magnifyEndShift - root.magnifyStartShift

  // Onde a casca começa dentro da janela. Ela cresce pelo centro: o layer-shell
  // centra o dock na borda da tela, e uma casca que crescesse por um lado só
  // sairia do meio a cada passada do ponteiro.
  readonly property real shellStart: (root.windowLength - root.shellLength) / 2

  // Folga entre o dock e a borda da tela em que ele ancora.
  readonly property int edgeMargin: config.edgeMargin

  // O comprimento da *janela* ao longo da borda: o dock em repouso mais a
  // reserva máxima que a onda chega a pedir.
  //
  // A casca cresce, a janela não. Cada mudança de tamanho de uma superfície de
  // layer é uma ida e volta com o compositor, e o ponteiro pediria uma por
  // quadro — é a mesma razão pela qual a folga do esconder mora *dentro* da
  // janela em vez de virar margem (ver `margins` na janela do dock). Então a
  // janela nasce com a reserva inteira, transparente, e a casca se abre para
  // dentro dela.
  readonly property int windowLength: root.dockLength + Math.ceil(root.magnifySpread)

  // A folga que o ícone ampliado precisa *acima* da casca, do lado de dentro da
  // tela. O ícone cresce a partir do lado que encosta na borda — assentado,
  // subindo, como no macOS —, então tudo o que ele cresce vai para este lado. A
  // folga do slot e a da casca já absorvem parte; o que passar delas é o que a
  // janela reserva.
  //
  // O contador de notificações entra na conta: ele sai do canto do ícone em
  // `iconPadding` (ver `badge` no ArcSlot) e, no pico, sai escalado junto com
  // ele. Sem somar isso a janela terminava rente ao topo do ícone ampliado e
  // recortava o disco justamente enquanto o app estava sob o ponteiro. Com a
  // onda desligada a parcela é o próprio `iconPadding`, que a folga do slot já
  // absorve — a reserva continua zero.
  readonly property int badgeOverhang: Math.ceil(root.iconPadding * root.magnifyMax)
  readonly property int magnifyHeadroom: Math.max(0,
    Math.ceil(root.magnifyGrowth) + root.badgeOverhang - root.iconPadding - root.dockPadding)

  // A janela cobre o dock, essa folga e a reserva da ampliação: é para dentro
  // dela, e daí para fora da tela, que a casca desliza ao esconder.
  readonly property int windowExtent: root.dockThickness + root.edgeMargin + root.magnifyHeadroom

  // ----------------------------------------------------------------- saída
  //
  // O dock vive numa tela só. Sem um `screen` explícito a PanelWindow cai na
  // primeira saída que o compositor devolve, e essa ordem não é estável entre
  // reinícios num setup com dois monitores — o dock trocaria de tela sozinho.
  //
  // Por padrão a escolha é derivada, e não presa a um nome de saída: vence a
  // tela de maior área, que é a principal do setup. Assim trocar de monitor,
  // desconectar o secundário ou reordenar os cabos não pede ajuste nenhum.
  //
  // Escolher um monitor pelo nome nos ajustes passa por cima disso — mas só
  // enquanto ele estiver ligado. Um nome que não corresponde a saída nenhuma
  // (monitor desconectado, cabo trocado) cai de volta na tela de maior área,
  // porque um dock que some da tela não teria como ser reconfigurado de volta.
  readonly property var dockScreen: {
    var screens = Quickshell.screens || []
    var wanted = config.screenName
    var best = null
    for (var i = 0; i < screens.length; i++) {
      var candidate = screens[i]
      // Saída sem nome ou sem modo ainda é uma tela em processo de subir:
      // entrar na disputa agora elegeria uma tela de área zero.
      if (!candidate || !candidate.name || candidate.width <= 0 || candidate.height <= 0) continue
      if (wanted.length > 0 && candidate.name === wanted) return candidate
      if (!best || candidate.width * candidate.height > best.width * best.height) best = candidate
    }
    return best
  }

  // ------------------------------------------------------------ vidro fosco
  //
  // Translucidez sozinha não é vidro: sem alguém desfocando o que está atrás,
  // o dock só deixaria ver as janelas de trás nítidas através dele. Quem faz o
  // fosco é o compositor, por uma `layerrule` de blur — e ela é pedida daqui, e
  // não deixada a cargo do usuário, porque um ajuste que só funciona depois de
  // editar o `looknfeel.lua` à mão não é um ajuste, é uma dica.
  //
  // A regra é declarada com *nome*: no parser Lua do Hyprland, redeclarar o
  // mesmo nome substitui a regra anterior em vez de empilhar mais uma, e é isso
  // que deixa o ajuste ser desligado (`enabled = false`) sem precisar de um
  // `hyprctl reload` — que levaria junto tudo o mais que o usuário tenha
  // ajustado em tempo de execução.
  readonly property string glassRuleName: root.layerNamespace + "-glass"

  // Piso de alfa que o blur ignora. A janela é maior que a casca — leva a folga
  // até a borda, que é para onde o dock desliza ao esconder —, e sem este piso
  // o compositor desfocaria a área transparente junto: um bloco fosco
  // retangular em volta de um dock de cantos redondos.
  //
  // O valor sai da menor opacidade que o ajuste permite, pela metade: fica
  // acima de zero, então a folga não entra, e abaixo de qualquer alfa que a
  // casca chegue a ter, então a casca sempre entra.
  readonly property real glassIgnoreAlpha: config.limits.glassOpacity[0] / 100 / 2

  // O pedido que põe o compositor no estado do ajuste, no protocolo do socket
  // do Hyprland (ver ArcHyprland). Vazio quer dizer "não há nada a pedir"
  // (ver o caminho legado abaixo).
  //
  // Sem `blur_popups`: o menu de contexto é uma popup desta mesma janela, mas
  // é opaco de propósito (ver `surfaceColor` no ArcMenu), e desfocar o que
  // passa atrás de uma superfície sólida é trabalho que não aparece.
  readonly property string glassCommand: {
    // Ancorado nas duas pontas: o compositor casa a expressão inteira, então
    // sem elas a regra pegaria também a janela de ajustes (`arc-dock-settings`)
    // — que é um cartão de texto, e o texto não se lê sobre um borrão.
    var namespace = "^(" + root.layerNamespace + ")$"
    if (Hyprland.usingLua) {
      return 'eval hl.layer_rule({ name = "' + root.glassRuleName + '"'
        + ', match = { namespace = "' + namespace + '" }'
        + ', blur = true'
        + ', ignore_alpha = ' + root.glassIgnoreAlpha
        + ', enabled = ' + (config.glass ? "true" : "false") + ' })'
    }
    // Config legada (`.conf`): as regras não têm nome, então não há como
    // desfazer uma — só um `hyprctl reload`, que é caro demais para um
    // interruptor. Não precisa: o blur só se vê através de uma casca
    // translúcida, e desligar o vidro devolve a casca ao tom cheio do tema.
    // A regra que sobra deixa de ter o que desfocar.
    if (!config.glass) return ""
    return "[[BATCH]]keyword layerrule blur," + namespace
      + " ; keyword layerrule ignorealpha " + root.glassIgnoreAlpha + "," + namespace
  }

  // Um pedido novo enquanto o anterior ainda está no ar não pode ser perdido:
  // dois cliques seguidos no interruptor deixariam o compositor parado no
  // estado do primeiro. Ele fica marcado e sai quando o anterior termina — e
  // como o comando é lido do ajuste de agora, o que sai é sempre o estado
  // atual, não a fila de gestos.
  property bool glassPending: false

  function applyGlass() {
    if (root.glassCommand === "") return
    if (glassIpc.busy) {
      root.glassPending = true
      return
    }
    root.glassPending = false
    glassIpc.send(root.glassCommand)
  }

  onGlassCommandChanged: root.applyGlass()

  ArcHyprland {
    id: glassIpc
    // O compositor responde `ok` a cada comando que aceitou; qualquer outra
    // coisa é a explicação do que ele recusou, e vale mais no log do que
    // perdida.
    onReplied: function (reply) {
      if (!/^(ok\s*)*$/.test(reply)) {
        console.warn("arcdock: compositor refused the glass rule -", reply.trim())
      }
      if (root.glassPending) root.applyGlass()
    }
    onFailed: if (root.glassPending) root.applyGlass()
  }

  // O blur é do compositor, e ele pode estar desligado inteiro
  // (`decoration:blur:enabled`). Aí a regra é aceita e não faz nada: a casca
  // fica translúcida e nítida, sem nenhuma pista do porquê. A janela de ajustes
  // lê isto para dizer o que falta em vez de deixar o usuário no escuro.
  //
  // O padrão é `true` — enquanto a sondagem não respondeu não há o que avisar,
  // e acusar um blur desligado que talvez esteja ligado é pior que calar.
  property bool compositorBlur: true

  function probeCompositorBlur() {
    blurProbe.send("j/getoption decoration:blur:enabled")
  }

  ArcHyprland {
    id: blurProbe
    onReplied: function (reply) {
      try {
        root.compositorBlur = !!JSON.parse(reply).bool
      } catch (error) {
        root.compositorBlur = true
      }
    }
  }

  // ------------------------------------------------------- sair quando estorva
  //
  // O dock flutua por cima das janelas. Isso é o que se quer enquanto sobra
  // área embaixo, e é exatamente o que atrapalha quando um app tomou a tela
  // inteira — aí ele sai de cena e só volta quando o ponteiro o chama de volta.
  //
  // A verdade vem do workspace ativo da tela do dock, e não da janela em foco:
  // o foco pode estar num diálogo flutuante por cima do app que tomou a tela, e
  // olhando só para o foco o dock continuaria plantado por cima do app.
  // O monitor do Hyprland que corresponde à tela do dock. A escolha é feita por
  // função, e não por binding: `monitorFor` registra a saída no próprio modelo
  // de monitores quando ela ainda não estava lá, então um binding que lesse
  // `Hyprland.monitors` para se manter atualizado se realimentaria — era esse o
  // laço de binding que o Qt acusava e cortava, deixando a escolha pela metade.
  property var dockMonitor: null

  // Reatribuir o mesmo monitor não emite mudança, então o giro que o próprio
  // `monitorFor` provoca ao registrar a saída morre aqui em vez de virar laço.
  function refreshDockMonitor() {
    root.dockMonitor = root.dockScreen ? Hyprland.monitorFor(root.dockScreen) : null
  }

  // Dois caminhos levam a uma escolha nova: a tela vencedora trocar (monitor
  // desconectado, cabo reordenado) e a saída sumir e voltar sem a tela mudar de
  // identidade — o segundo não mexe em `dockScreen`, por isso os dois estão aqui.
  onDockScreenChanged: root.refreshDockMonitor()

  Connections {
    target: Hyprland.monitors
    function onValuesChanged() { root.refreshDockMonitor() }
  }

  readonly property var dockWorkspace: root.dockMonitor ? root.dockMonitor.activeWorkspace : null

  // `hasFullscreen` é verdadeiro nos dois modos de tela cheia do Hyprland —
  // maximizado (`fullscreen 1`) e tela cheia (`fullscreen 2`) —, que é
  // exatamente o conjunto de casos em que o dock estorva.
  readonly property bool screenFilled: !!root.dockWorkspace && root.dockWorkspace.hasFullscreen

  // O Quickshell reconsulta os workspaces nos eventos de janela e de workspace,
  // mas `fullscreen` não está nessa lista: sem este empurrão `hasFullscreen`
  // ficaria congelado no valor da última consulta e o dock nunca se esconderia.
  // Fechar a janela que estava em tela cheia também emite `fullscreen`, então
  // este é o único evento que precisa ser escutado.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!event) return
      // A consulta da geometria das janelas é assunto à parte do resto daqui, e
      // por isso não entra na cadeia abaixo: o mesmo `fullscreen` que reconsulta
      // os workspaces também reacomoda a tela.
      if (root.coveredMode && root.coverageEvents.indexOf(event.name) >= 0) coverageTimer.restart()
      if (event.name === "fullscreen") Hyprland.refreshWorkspaces()
      // Um `hyprctl reload` devolve o compositor ao que está em disco, e a
      // regra do vidro é nossa, de tempo de execução — ela some junto. O
      // `omarchy theme set` faz esse reload no fim, então sem repor a regra
      // aqui o dock perderia o fosco na primeira troca de tema. É também
      // quando o blur pode ter sido ligado ou desligado à mão, e por isso a
      // sondagem vem junto.
      else if (event.name === "configreloaded") {
        root.applyGlass()
        root.probeCompositorBlur()
      }
    }
  }

  // ---------------------------------------------- janela por baixo do dock
  //
  // `hasFullscreen` responde "um app tomou a tela sozinho", que num WM de
  // tiling é só metade da pergunta: dois apps lado a lado ocupam a mesma área e
  // nenhum dos dois está em tela cheia. Quem responde pelos dois é a
  // geometria — o dock estorva quando *qualquer* janela alcança o retângulo em
  // que ele se assenta.
  readonly property bool coveredMode: root.autoHide === "covered"

  // Onde o dock se assenta, nas coordenadas do layout do Hyprland — as mesmas
  // em que as janelas dizem onde estão. A origem vem do monitor do compositor e
  // o tamanho da tela do Qt: cada um é a autoridade da sua metade (o Qt já
  // aplica a rotação da saída; o `at` das janelas conta a partir da origem que
  // o Hyprland conhece).
  //
  // É o retângulo do dock **em repouso**, e não o de agora: medir onde a casca
  // está fecharia um laço — coberto o dock se esconde, escondido ele deixa de
  // estar coberto, e volta só para se esconder de novo no quadro seguinte.
  //
  // E é o retângulo do *dock*, não o da janela: a reserva da ampliação é folga
  // transparente dos dois lados (ver `windowLength`), e medi-la faria uma
  // janela ao lado do dock contar como se estivesse embaixo dele.
  //
  // Aqui comprimento e espessura voltam a ser largura e altura, como nas
  // âncoras da janela: do lado do compositor não existe "a borda do dock".
  readonly property var dockRect: {
    if (!root.dockMonitor || !root.dockScreen) return null
    // A janela ignora zona exclusiva (ver `exclusionMode`), então a folga é
    // medida da borda da tela e não do que a bar reservou.
    var screenLength = root.vertical ? root.dockScreen.height : root.dockScreen.width
    var screenExtent = root.vertical ? root.dockScreen.width : root.dockScreen.height
    var across = root.leadingEdge
      ? root.edgeMargin
      : screenExtent - root.edgeMargin - root.dockThickness
    // O layer-shell centra a superfície ao longo da borda (ver as âncoras da
    // janela do dock), então a posição no outro eixo sai da conta do centro.
    var along = (screenLength - root.dockLength) / 2
    return {
      x: root.dockMonitor.x + (root.vertical ? across : along),
      y: root.dockMonitor.y + (root.vertical ? along : across),
      width: root.vertical ? root.dockThickness : root.dockLength,
      height: root.vertical ? root.dockLength : root.dockThickness
    }
  }

  // Escrito, e não derivado: a geometria de cada janela mora no `lastIpcObject`
  // do toplevel — um mapa que o Quickshell só troca quando a consulta volta —,
  // e o que dispara o recálculo é a chegada desse mapa, não uma dependência que
  // um binding saberia seguir sozinho.
  property bool screenCovered: false

  function recomputeCovered() {
    root.screenCovered = root.computeCovered()
  }

  // A verdade vem do workspace ativo do monitor do dock, pela mesma razão que
  // `screenFilled` (ver acima): o foco pode estar num diálogo flutuante por
  // cima das janelas que cobrem o dock.
  function computeCovered() {
    var rect = root.dockRect
    var workspace = root.dockWorkspace
    if (!root.coveredMode || !rect || !workspace || !workspace.toplevels) return false
    var windows = workspace.toplevels.values
    for (var i = 0; i < windows.length; i++) {
      var data = windows[i] ? windows[i].lastIpcObject : null
      if (!data || !data.at || !data.size) continue
      // Janela agrupada atrás de outra aba está no workspace sem estar em cena.
      // Ela ocupa o mesmo retângulo da que aparece, então contá-la não mudaria
      // nada agora — mas mudaria depois que a de cima saísse do workspace.
      if (data.hidden) continue
      var wx = Number(data.at[0])
      var wy = Number(data.at[1])
      var ww = Number(data.size[0])
      var wh = Number(data.size[1])
      if (!(ww > 0) || !(wh > 0)) continue
      if (wx < rect.x + rect.width && wx + ww > rect.x
        && wy < rect.y + rect.height && wy + wh > rect.y) return true
    }
    return false
  }

  // Mudou a área do dock (borda, folga, um slot a mais), mudou a conta.
  onDockRectChanged: Qt.callLater(root.recomputeCovered)

  onCoveredModeChanged: {
    if (root.coveredMode) coverageTimer.restart()
    // Fora do modo o valor não é lido, mas voltar a ele com a conta velha
    // deixaria o dock decidir por um quadro com o que era verdade antes.
    else root.screenCovered = false
  }

  // Um observador por janela do workspace. O modelo não muda quando só a
  // geometria mudou — abrir uma janela reacomoda as vizinhas sem ninguém entrar
  // ou sair da lista —, então quem avisa que a consulta voltou é o mapa de cada
  // toplevel. O `callLater` junta o pente de avisos de uma consulta só numa
  // conta em vez de uma por janela.
  Instantiator {
    model: root.coveredMode && root.dockWorkspace ? root.dockWorkspace.toplevels : null
    onObjectAdded: function (index, object) { Qt.callLater(root.recomputeCovered) }
    onObjectRemoved: function (index, object) { Qt.callLater(root.recomputeCovered) }

    delegate: QtObject {
      required property var modelData
      readonly property var geometry: modelData ? modelData.lastIpcObject : null
      onGeometryChanged: Qt.callLater(root.recomputeCovered)
    }
  }

  // Os eventos que reacomodam a tela, e por isso pedem consulta nova: abrir e
  // fechar refluem o tiling, mover e (des)flutuar trocam a área da janela,
  // agrupar tira uma de cena, e trocar de workspace ou de monitor troca o
  // conjunto inteiro.
  //
  // A troca de foco fica de fora, por mais tentador que fosse usá-la para pegar
  // o que os outros não pegam: o Hyprland emite `activewindow` junto com cada
  // troca de *título*, e um terminal com relógio no título pediria uma consulta
  // por segundo, para sempre. Foi medido, não suposto.
  readonly property var coverageEvents: ["openwindow", "closewindow", "movewindow",
    "movewindowv2", "changefloatingmode", "fullscreen", "workspace", "workspacev2",
    "focusedmon", "focusedmonv2", "activespecial", "activespecialv2",
    "togglegroup", "moveintogroup", "moveoutofgroup", "pin", "monitoradded",
    "monitorremoved", "configreloaded"]

  // A consulta é uma ida e volta ao compositor, e um gesto só emite vários
  // eventos (mandar uma janela para outro workspace emite `movewindow` e
  // `workspace`, e o alt-tab da shell emite dois `fullscreen` seguidos). O
  // timer junta a rajada numa consulta só.
  Timer {
    id: coverageTimer
    interval: 60
    onTriggered: Hyprland.refreshToplevels()
  }

  // Quando o dock *estorva*, que é a pergunta que o auto-hide responde. São
  // quatro respostas possíveis, e elas diferem só aqui — o resto do esconder é
  // o mesmo caminho para as quatro:
  //
  //   never       nunca estorva; o dock fica plantado, mesmo por cima de um app
  //               em tela cheia.
  //   fullscreen  estorva quando um app ocupa a tela sozinho. É o padrão:
  //               enquanto sobra área embaixo o dock não atrapalha ninguém.
  //   covered     estorva quando alguma janela alcança a área dele — o caso dos
  //               dois apps lado a lado, em que nenhum está em tela cheia.
  //   always      estorva sempre; o dock só existe quando chamado.
  readonly property string autoHide: config.autoHide
  readonly property bool intrusive: root.autoHide === "always"
    || (root.autoHide === "fullscreen" && root.screenFilled)
    || (root.coveredMode && root.screenCovered)

  // A *vontade* de ter o dock em tela, que é o que as condições sabem dizer.
  // Não é a mesma coisa que o dock estar de pé: aparecer é imediato, sumir
  // passa pela carência abaixo.
  //
  // Com o menu de contexto de pé o dock fica: o menu se ancora num slot, e
  // esconder o slot deixaria a popup apontando para o vazio.
  readonly property bool dockWanted: !root.intrusive
    || pointerWatch.hovered
    || root.menuKey.length > 0
    // Com um slot na mão o dock também fica: arrastando, o ponteiro pode
    // escapar da casca sem soltar o botão, e o hover cairia junto — o dock
    // sumiria embaixo do slot que o usuário está movendo.
    || root.dragging

  // Carência do esconder: o ponteiro sair não recolhe o dock na hora. Meio
  // segundo (o padrão) é o bastante para atravessar a faixa de raspão — indo
  // para a borda da tela, ou passando por cima do dock a caminho de outra
  // coisa — sem o dock fugir de baixo do cursor, e curto o bastante para quem
  // realmente saiu não achar que ele travou.
  //
  // A carência vale para *qualquer* motivo de sair, inclusive o app entrar em
  // tela cheia: uma regra só é mais fácil de prever que duas, e meio segundo a
  // mais na saída não estorva ninguém. Voltar, esse sim, nunca espera.
  readonly property int hideDelay: config.hideDelay

  // Escrito, e não derivado: entre a vontade e o estado existe o timer. Começa
  // de pé porque é assim que o dock nasce — se a shell subir com um app já em
  // tela cheia, a carência recolhe logo em seguida.
  property bool dockShown: true

  // Curva do deslize, escrita *antes* de `dockShown` mudar. Um binding em
  // `easing.type` dentro do Behavior chega a ser lido velho no instante da
  // virada (o Behavior dispara com a animação ainda na curva anterior), e a
  // casca sairia de cena com a curva de entrada. Escrito aqui, a ordem é a do
  // código e não a da propagação dos bindings.
  //
  // São dois Behaviors, um por eixo, porque a borda decide em qual deles a
  // casca anda. O parado nunca dispara, então escrever nos dois é mais barato
  // que escolher um a cada virada.
  function setDockShown(shown) {
    var curva = shown ? root.slideInEasing : root.slideOutEasing
    slideX.easing.type = curva
    slideY.easing.type = curva
    root.dockShown = shown
  }

  onDockWantedChanged: {
    if (root.dockWanted) {
      // Encostou na faixa (ou o app largou a tela): o dock volta agora, e a
      // carência que estava correndo morre sem o dock ter se mexido.
      hideTimer.stop()
      root.setDockShown(true)
    } else {
      hideTimer.restart()
    }
  }

  Timer {
    id: hideTimer
    interval: root.hideDelay
    // Quem para o timer é o `onDockWantedChanged`, então chegar até aqui já
    // significa que ninguém segurou o dock durante a carência inteira.
    onTriggered: root.setDockShown(false)
  }

  // A faixa que devolve o dock escondido ocupa a mesma folga que ele deixa
  // entre si e a borda. O ponteiro para na borda da tela, então por mais fina
  // que a folga fique a faixa continua alcançável de um só empurrão.
  //
  // O piso existe para a folga zero: sem ele, quem encostasse a casca na borda
  // ficaria com auto-hide sem faixa nenhuma — o dock sairia de cena e não teria
  // como ser chamado de volta.
  readonly property int revealExtent: Math.max(Style.space(2), root.edgeMargin)

  // Onde a casca fica em cada estado, medido no eixo que atravessa a borda. Em
  // repouso ela fica entre as duas folgas da janela — a que a separa da borda
  // da tela e a que os ícones ampliados usam para subir. Numa borda inicial a
  // primeira vem antes dela e a segunda depois; numa final é o contrário, e é
  // por isso que a reserva da ampliação aparece só neste lado da conta.
  // Escondida, a casca está inteira do lado de fora da tela.
  readonly property real shownOffset: root.leadingEdge ? root.edgeMargin : root.magnifyHeadroom
  readonly property real hiddenOffset: root.leadingEdge ? -root.dockThickness : root.windowExtent
  readonly property real bodyOffset: root.dockShown ? root.shownOffset : root.hiddenOffset

  // O deslize é da mesma família dos realces dos slots, mas percorre a
  // espessura inteira da casca enquanto um ícone anda uns poucos pixels — no
  // tempo do realce (140 ms, ver `transitionDuration` no ArcSlot) o percurso
  // grande sai como um corte seco. Os 40 ms a mais do padrão dão o freio sem
  // virar lentidão. O `Style` não expõe duração de animação, então o padrão
  // mora no ArcConfig e não num token.
  readonly property int slideDuration: config.slideDuration

  // A área que recebe o ponteiro, no mesmo eixo do deslize (ver `inputArea`).
  //
  // Escondido, sobra a faixa de gatilho colada na borda da tela. Na tela, com o
  // esconder armado, a área sensível vai *até* essa mesma borda: parando no fim
  // da casca, o ponteiro que acabou de chamar o dock pela faixa perderia o
  // hover no instante em que a casca subisse, e o dock ficaria piscando. Com o
  // esconder desarmado não há gatilho, e a área volta a ser só a casca — a
  // folga deixa o clique passar para o app embaixo.
  readonly property real inputOffset: root.dockShown
    ? (root.intrusive ? 0 : root.shownOffset)
    : (root.leadingEdge ? 0 : root.windowExtent - root.revealExtent)
  readonly property real inputExtent: root.dockShown
    ? (root.intrusive ? root.windowExtent : root.dockThickness)
    : root.revealExtent

  // O começo da área sensível ao longo da borda: a casca em repouso, centrada
  // na janela. Sem ampliação a reserva é zero e isto é zero também.
  readonly property real inputStart: (root.windowLength - root.dockLength) / 2

  // Mesma ideia das curvas do slot (`hotEasing`/`restEasing`), um grau acima:
  // o percurso é maior, e o cúbico freia mais no fim sem passar do ponto —
  // nada de overshoot, que num painel que encosta na borda vira solavanco.
  // Entrando, a casca arranca e assenta; saindo, ela desencosta devagar, para
  // o dock não ser arrancado da tela no instante em que a carência vence.
  readonly property int slideInEasing: Easing.OutCubic
  readonly property int slideOutEasing: Easing.InOutCubic

  // ---------------------------------------------------------------- modelo
  //
  // Um slot por *app*, não por janela: duas janelas do mesmo appId dividem o
  // mesmo slot (`windows` guarda todas). Um app fixado tem slot mesmo sem
  // janela nenhuma — aí `windows` fica vazia. Cada entrada é
  // { key, name, icon, desktop, windows, active, pinned }.
  property var slots: []

  // Ordem estável dos slots *não fixados*: as chaves na ordem em que os apps
  // apareceram. Fechar uma janela de um app que continua aberto não reordena o
  // dock, e apps novos entram sempre no fim.
  property var slotOrder: []

  // appIds que não identificam app nenhum: o processo desenha janelas de coisas
  // diferentes e manda o mesmo id em todas. É o caso do próprio shell —
  // `FloatingWindow` não expõe `appId`, então qualquer janela de plugin (o player
  // do YouTube Music, por exemplo) chega aqui como "org.quickshell". Agrupar por
  // esse id juntaria todas num slot só, com o ícone do Quickshell; o título é o
  // único identificador que sobra.
  readonly property var opaqueAppIds: ["org.quickshell"]

  function isOpaqueAppId(id) {
    return root.opaqueAppIds.indexOf(String(id || "").trim().toLowerCase()) !== -1
  }

  // Chave de agrupamento. O appId do wlr-toplevel já é o identificador
  // canônico do app; o título entra quando o cliente não manda appId (raro, mas
  // acontece com janelas nativas do XWayland) ou quando o appId é opaco.
  function appKey(toplevel) {
    var id = String((toplevel && toplevel.appId) || "").trim().toLowerCase()
    if (id.slice(-8) === ".desktop") id = id.slice(0, -8)
    var title = String((toplevel && toplevel.title) || "").trim().toLowerCase()
    if (id.length > 0 && !root.isOpaqueAppId(id)) return id
    if (title.length > 0) return id.length > 0 ? title : "title:" + title
    return id.length > 0 ? id : "unknown"
  }

  // Entrada .desktop do app. O appId do toplevel é o que mais se aproxima do
  // id da entrada, e o heuristicLookup do Quickshell já cobre as variações
  // comuns (caixa, sufixos, StartupWMClass) que uma busca por id exato erra.
  function appEntry(toplevel, key) {
    var id = String((toplevel && toplevel.appId) || "").trim()
    var fallbackEntry = null
    // Com appId opaco, procurar por ele acharia sempre a mesma entrada errada
    // (org.quickshell.desktop, que é `NoDisplay` e chama tudo de "Quickshell").
    // O título é o que aponta pra entrada do plugin.
    if (root.isOpaqueAppId(id)) {
      var title = String((toplevel && toplevel.title) || "").trim()
      if (title.length > 0) {
        var byTitle = DesktopEntries.heuristicLookup(title)
        if (byTitle) return byTitle
      }
    } else if (id.length > 0) {
      var byAppId = DesktopEntries.heuristicLookup(id)
      if (byAppId && byAppId.icon) return byAppId
      if (byAppId) fallbackEntry = byAppId

      // Reverse-domain app IDs may resolve first to an iconless URL handler.
      // Try the application-specific segments so a regular desktop entry can
      // supply the app's own icon from hicolor or an absolute icon path.
      var parts = id.split(/[.\/_\-*\s]+/)
      for (var i = parts.length - 1; i >= 0; i--) {
        if (parts[i].length === 0) continue
        var byPart = DesktopEntries.heuristicLookup(parts[i])
        if (byPart && byPart.icon) return byPart
        if (!fallbackEntry && byPart) fallbackEntry = byPart
      }
    }
    // Janelas sem appId caem na chave derivada do título; ainda vale tentar.
    if (String(key || "").indexOf("title:") !== 0) {
      var byKey = DesktopEntries.heuristicLookup(key)
      if (byKey && byKey.icon) return byKey
      if (!fallbackEntry && byKey) fallbackEntry = byKey
    }
    return fallbackEntry
  }

  // Nome do ícone declarado na entrada ("firefox", "org.gnome.Nautilus"...).
  // Fica cru no modelo de propósito: quem resolve para um arquivo é o binding
  // do slot, que assim reavalia sozinho quando o índice da shell é atualizado.
  function appIconName(entry) {
    return entry && entry.icon ? String(entry.icon) : ""
  }

  function fallbackIconName(key) {
    var value = String(key || "").trim().toLowerCase()
    var parts = value.split(/[.\/_\-*\s]+/)
    var ignored = { com: true, org: true, io: true, app: true, dev: true, net: true }
    for (var i = parts.length - 1; i >= 0; i--) {
      if (parts[i].length > 0 && !ignored[parts[i]]) return parts[i]
    }
    return value
  }

  // Nome do ícone -> caminho do arquivo. Sem appLibrary (plugin carregado fora
  // da shell) sobra a busca temática do Qt, que resolve a maioria dos casos.
  function iconSource(name) {
    var value = String(name || "")
    if (value.length === 0) return ""
    if (root.appLibrary) return root.appLibrary.iconSource(value)
    return Quickshell.iconPath(value, true)
  }

  function iconIsFallback(name) {
    var value = String(name || "")
    if (value.length === 0) return false
    return root.themedIconNames[value.toLowerCase()] !== true
  }

  // O ícone do botão de apps. A ordem vai do nome que os temas estilo macOS dão
  // ao Launchpad até os genéricos de "todos os aplicativos", e o primeiro que o
  // tema tiver vence; sem nenhum deles, o `ArcLauncher` desenha o glifo
  // `nf-md-apps` de reserva.
  //
  // Nos temas estilo macOS o desenho é colorido e cheio, e a ponta da fileira
  // passa a ter um ícone com a mesma presença dos apps. É escolha assumida: é
  // esse o ícone que o desktop espera nessa posição, e o botão fica sendo o
  // Launchpad em vez de uma marca própria do dock.
  readonly property var launcherIconNames: ["view-app-grid", "applications-all", "start-here"]

  // A busca aqui é a temática do Qt, e não a do `appLibrary` (ver `iconSource`
  // logo acima): a do `appLibrary` nunca falha — sem achar o nome ela devolve o
  // `application-x-executable` genérico —, e neste caminho falhar é informação.
  // É o que faz a busca passar para o próximo nome e, no fim, deixa o glifo
  // assumir em vez de plantar um ícone de executável na ponta da fileira.
  readonly property string launcherIconSource: {
    for (var i = 0; i < root.launcherIconNames.length; i++) {
      var found = Quickshell.iconPath(root.launcherIconNames[i], true)
      if (String(found).length > 0) return found
    }
    return ""
  }

  // Nome exibível derivado da chave: "org.kde.dolphin" -> "Dolphin".
  function appLabel(key) {
    var parts = String(key || "").split(".")
    var last = parts[parts.length - 1] || key || ""
    if (last.length === 0) return ""
    return last.charAt(0).toUpperCase() + last.slice(1)
  }

  // Uma entrada do modelo, ainda sem janelas: elas entram depois, se houver.
  // Um app fixado e fechado é exatamente o caso em que a lista fica vazia.
  //
  // A entrada .desktop inteira fica guardada, e não só o nome do ícone: é dela
  // que saem as ações do menu de contexto (abrir de novo, e o que o próprio app
  // declara em `Actions`).
  function makeSlot(key, desktop) {
    return {
      key: key,
      name: (desktop && desktop.name) ? String(desktop.name) : appLabel(key),
      icon: appIconName(desktop) || fallbackIconName(key),
      desktop: desktop,
      windows: [],
      active: false,
      pinned: root.pinIndex(key) >= 0
    }
  }

  function rebuildSlots() {
    // Refazer a fileira recria todos os delegates, e o slot que estava debaixo
    // do dedo morre levando junto o grab do ponteiro: o arrasto não teria como
    // terminar, e o dock ficaria com um slot deslocado para sempre. Uma janela
    // pode muito bem abrir no meio do gesto, então o caminho seguro é
    // abandoná-lo — a ordem antiga continua valendo e o usuário arrasta de
    // novo, o que é melhor que gravar uma ordem que ele largou pela metade.
    // (No `finishDrag` o estado já foi limpo antes de `pinned` mudar, então
    // isto não atropela a reordenação que acabou de ser aceita.)
    root.cancelDrag()

    var live = (ToplevelManager.toplevels && ToplevelManager.toplevels.values)
      ? ToplevelManager.toplevels.values : []
    var active = ToplevelManager.activeToplevel

    // 1. Agrupa as janelas vivas por app.
    var byKey = ({})
    var fresh = []
    for (var i = 0; i < live.length; i++) {
      var top = live[i]
      if (!top) continue
      var key = appKey(top)
      var entry = byKey[key]
      if (!entry) {
        entry = makeSlot(key, appEntry(top, key))
        byKey[key] = entry
        fresh.push(key)
      }
      entry.windows.push(top)
      if (active && top === active) entry.active = true
    }

    // 2. Os fixados abrem a fileira, na ordem em que foram fixados. O que está
    // aberto reaproveita a entrada montada acima, com as janelas dele; o que
    // está fechado entra aqui, montado a partir da entrada .desktop guardada.
    var order = []
    for (var p = 0; p < root.pinned.length; p++) {
      var pinKey = root.pinned[p].key
      if (order.indexOf(pinKey) >= 0) continue
      if (!byKey[pinKey]) byKey[pinKey] = makeSlot(pinKey, itemDesktop(root.pinned[p]))
      order.push(pinKey)
    }

    // 3. Depois vêm os abertos que não estão fixados: a ordem antiga para quem
    // continua aberto, e os novos no fim. Como a ordem antiga é preservada,
    // desafixar um app aberto não o faz atravessar o dock — ele fica onde está.
    for (var j = 0; j < slotOrder.length; j++) {
      if (byKey[slotOrder[j]] && order.indexOf(slotOrder[j]) < 0) order.push(slotOrder[j])
    }
    for (var k = 0; k < fresh.length; k++) {
      if (order.indexOf(fresh[k]) < 0) order.push(fresh[k])
    }

    var next = []
    for (var n = 0; n < order.length; n++) next.push(byKey[order[n]])

    root.slotOrder = order
    root.slots = next

    // 4. Os recentes fecham a fileira, na ordem em que foram abertos. Só entra
    // quem ainda não tem slot: `byKey` já é a união dos abertos com os fixados,
    // então basta não estar nele. Um recente cuja entrada .desktop sumiu (o app
    // foi desinstalado) fica de fora em vez de virar um slot em branco.
    var recents = []
    for (var r = 0; r < root.recent.length && recents.length < root.recentCount; r++) {
      var recentKey = root.recent[r].key
      if (byKey[recentKey]) continue
      var recentDesktop = root.itemDesktop(root.recent[r])
      if (!recentDesktop) continue
      recents.push(makeSlot(recentKey, recentDesktop))
    }
    root.recentSlots = recents

    // A fileira nova diz quem ganhou o foco e quem saiu de cena; os dois
    // zeram o contador de notificações (ver a seção `notificações`).
    root.pruneBadges()

    // O app do menu aberto pode ter acabado de sair da fileira (fechou a última
    // janela e não é recente, ou foi desafixado); sem isso o menu ficaria de pé
    // apontando para um slot que já não existe.
    if (menuKey.length > 0 && !byKey[menuKey] && root.recentIndex(menuKey) < 0) closeMenu()

    // Por último, e não junto do agrupamento lá em cima: mexer na fila dos
    // recentes refaz a fileira (`onRecentChanged`), e fazer isso no meio do
    // rebuild deixaria a chamada de dentro terminando primeiro — para a de fora
    // gravar por cima dela a fileira que acabou de ficar velha.
    root.recordOpened(fresh, byKey)
  }

  // --------------------------------------------------------------- fixados
  //
  // Um app fixado ocupa slot mesmo fechado, e o grupo dos fixados abre a
  // fileira. Cada item guardado é { key, entry }: a chave é a mesma que agrupa
  // as janelas — é ela que reconhece o app quando ele abre e evita um segundo
  // slot — e `entry` é o id da entrada .desktop, que é o que desenha o ícone e
  // abre o app enquanto não há janela nenhuma.
  property var pinned: []

  // Reconstruir a fileira é o que faz um fixado aparecer ou sumir, então basta
  // mexer em `pinned`: carregar do disco e fixar pelo menu passam os dois aqui.
  onPinnedChanged: root.rebuildSlots()

  function pinIndex(key) {
    for (var i = 0; i < root.pinned.length; i++) {
      if (root.pinned[i].key === key) return i
    }
    return -1
  }

  // Entrada .desktop de um item guardado — vale para o fixado e para o recente,
  // que têm a mesma forma. O id guardado é a busca exata; o heuristicLookup pela
  // chave cobre o app que renomeou a própria entrada entre versões, que sem isso
  // voltaria como um slot em branco.
  function itemDesktop(item) {
    var id = String((item && item.entry) || "")
    if (id.length > 0) {
      var byId = DesktopEntries.byId(id)
      if (byId) return byId
    }
    return DesktopEntries.heuristicLookup(String((item && item.key) || "")) || null
  }

  // Fixa ou desafixa o app do slot. Fixar exige entrada .desktop: sem ela a
  // chave sozinha não reabre o app nem desenha o ícone dele na próxima sessão,
  // e o fixado voltaria como um slot morto — por isso o menu também só oferece
  // o item quando há entrada.
  function togglePin(entry) {
    if (!entry) return
    var next = root.pinned.slice()
    var at = root.pinIndex(entry.key)
    if (at >= 0) next.splice(at, 1)
    else if (entry.desktop) {
      next.push({ key: entry.key, entry: String(entry.desktop.id || "") })
      // Fixar é tirar o app da fila que se renova sozinha e dar lugar certo a
      // ele. Ficar nas duas listas faria o slot voltar como recente no dia em
      // que ele fosse desafixado — justamente o gesto de tirá-lo do dock.
      root.recent = root.recentWithout(entry.key)
    }
    else return
    root.pinned = next
    root.saveState()
  }

  // -------------------------------------------------------------- recentes
  //
  // Os últimos apps que o usuário abriu e já fechou, na ordem em que ele os
  // abriu. Cada item é { key, entry } como um fixado — o .desktop é o que
  // desenha o ícone e reabre o app quando não há janela nenhuma —, e as duas
  // listas moram no mesmo arquivo de estado.
  //
  // Quem já tem slot não entra: o aberto está no grupo da esquerda, e o fixado
  // tem lugar próprio. Sobra o que o dock oferece de volta — o que você usou há
  // pouco e fechou. Fechar um app é assim o único jeito de vê-lo aqui, e
  // reabrir o tira dali sozinho, sem lista para o usuário administrar.
  property var recent: []

  // Como nos fixados, refazer a fileira é o que faz um recente aparecer ou
  // sumir: carregar do disco e registrar um app aberto passam os dois aqui.
  onRecentChanged: root.rebuildSlots()

  // Os slots dos recentes, montados junto com o resto da fileira (ver
  // `rebuildSlots`). Separado de `slots` porque são dois grupos na tela, com o
  // filete no meio — e porque só os de `slots` se arrastam.
  property var recentSlots: []

  readonly property int recentCount: config.recentCount
  onRecentCountChanged: root.rebuildSlots()

  // O histórico guardado vai até o teto do ajuste, e não até o valor de hoje:
  // baixar "apps recentes" para 2 e voltar para 6 não pode ter jogado fora, no
  // caminho, os apps que o usuário esperava reencontrar.
  readonly property int recentHistoryLimit: config.limits.recentCount[1]

  function recentIndex(key) {
    for (var i = 0; i < root.recent.length; i++) {
      if (root.recent[i].key === key) return i
    }
    return -1
  }

  // A lista sem uma chave. É o caminho de saída dos recentes, e serve aos dois
  // motivos de um app sair dali: ele virou fixado, ou o usuário pediu para
  // tirá-lo pelo menu.
  function recentWithout(key) {
    var next = []
    for (var i = 0; i < root.recent.length; i++) {
      if (root.recent[i].key !== key) next.push(root.recent[i])
    }
    return next
  }

  function forgetRecent(key) {
    var next = root.recentWithout(key)
    if (next.length === root.recent.length) return
    root.recent = next
    root.saveState()
  }

  // Quais apps estavam abertos no rebuild anterior. É a diferença entre este
  // conjunto e o de agora que diz "este app *acabou* de abrir", e só isso mexe
  // na fila. A lista de janelas não serve para essa pergunta: ela chega inteira
  // a cada evento, e reordenaria os recentes a cada janela nova de qualquer
  // outro app.
  //
  // Na primeira volta o conjunto está vazio, então tudo que já estava aberto
  // conta como recém-aberto. Não atrapalha: app aberto não aparece nos
  // recentes, e quando ele fechar o lugar dele na fila é mesmo o de quem estava
  // em uso nesta sessão.
  property var openKeys: ({})

  // Registra os apps que abriram agora, à frente da fila. Sem entrada .desktop
  // não entra — o slot não teria ícone nem como reabrir o app depois, que é a
  // mesma razão de `togglePin` exigir entrada — e fixado também não, que esse
  // já tem lugar.
  function recordOpened(keys, byKey) {
    // Sem a lista do disco em mãos não há fila para mexer. E o conjunto de
    // abertos também não é atualizado aqui: assim o rebuild que a leitura
    // dispara ainda enxerga estes apps como recém-abertos, e a sessão que
    // começou com eles em tela não os perde.
    if (!root.stateAnswered) return

    var nowOpen = ({})
    var opened = []
    for (var i = 0; i < keys.length; i++) {
      nowOpen[keys[i]] = true
      if (!root.openKeys[keys[i]]) opened.push(keys[i])
    }
    root.openKeys = nowOpen
    if (opened.length === 0) return

    var next = root.recent
    for (var j = 0; j < opened.length; j++) {
      var key = opened[j]
      var entry = byKey[key]
      if (!entry || !entry.desktop || root.pinIndex(key) >= 0) continue
      var without = []
      for (var k = 0; k < next.length; k++) {
        if (next[k].key !== key) without.push(next[k])
      }
      // Reabrir um app que já estava na fila é reabri-lo: ele volta para a
      // frente em vez de ganhar uma segunda linha.
      without.unshift({ key: key, entry: String(entry.desktop.id || "") })
      next = without.slice(0, root.recentHistoryLimit)
    }
    if (next === root.recent) return
    root.recent = next
    root.saveState()
  }

  // --------------------------------------------------- reordenar os fixados
  //
  // Arrastar um slot fixado na horizontal muda a ordem do grupo dos fixados.
  // Esse grupo é o prefixo da fileira, na ordem de `pinned` (ver
  // `rebuildSlots`), então reordenar na tela é reordenar `pinned` e mais nada:
  // o `onPinnedChanged` refaz a fileira e o `saveState` grava.
  //
  // Durante o gesto o modelo *não* se mexe. O Repeater come uma lista JS, e
  // trocar essa lista de lugar recria todos os delegates — o slot que está
  // debaixo do dedo morreria junto com o grab do ponteiro, no meio do arrasto.
  // Então enquanto o dedo anda ninguém muda de posição na Row: o slot pego é
  // transladado atrás do ponteiro e os vizinhos abrem espaço com uma
  // translação de um passo. A ordem nova só é escrita no soltar, quando o
  // rebuild já não atrapalha.
  property string dragKey: ""
  property real dragShift: 0

  readonly property bool dragging: root.dragKey.length > 0

  // Limiar que separa clique de arrasto: um quarto do passo, ou seja metade do
  // caminho até a primeira troca — que acontece em meio passo, quando o slot
  // pego já cobre metade do vizinho.
  readonly property int dragThreshold: Math.round(root.slotStep / 4)

  // Onde o slot pego estava e quantos fixados existem. Como os fixados abrem a
  // fileira na ordem de `pinned`, dentro do grupo o índice da fileira e o
  // índice de `pinned` são o mesmo número — o que dispensa uma tradução entre
  // os dois na hora de gravar.
  readonly property int pinnedCount: root.pinned.length
  readonly property int dragFrom: root.dragging ? root.pinIndex(root.dragKey) : -1

  // O quanto o slot pego anda de fato. O ponteiro pode passar da ponta do
  // grupo, mas o slot para na última casa dos fixados: sair dali prometeria
  // uma posição que o modelo não tem como aceitar, já que os fixados são o
  // prefixo da fileira.
  readonly property real dragTravel: {
    if (root.dragFrom < 0) return 0
    var back = -root.dragFrom * root.slotStep
    var ahead = (root.pinnedCount - 1 - root.dragFrom) * root.slotStep
    return Math.max(back, Math.min(ahead, root.dragShift))
  }

  // Para qual casa ele vai: cada passo inteiro de deslocamento vale uma
  // posição, e meio passo já arredonda para a seguinte.
  readonly property int dragTo: {
    if (root.dragFrom < 0) return -1
    return root.dragFrom + Math.round(root.dragTravel / root.slotStep)
  }

  // Translação de cada slot enquanto o gesto acontece: o pego acompanha o
  // ponteiro, e quem está entre a casa de origem e a de destino desliza um
  // passo no sentido contrário para abrir o buraco. Quem está fora desse
  // intervalo fica parado — e todo slot não fixado está fora dele, porque
  // `dragTo` nunca passa do fim do grupo dos fixados.
  function dragOffsetFor(index) {
    if (root.dragFrom < 0) return 0
    if (index === root.dragFrom) return root.dragTravel
    if (index > root.dragFrom && index <= root.dragTo) return -root.slotStep
    if (index < root.dragFrom && index >= root.dragTo) return root.slotStep
    return 0
  }

  function startDrag(entry) {
    if (!entry || !entry.pinned) return
    // O menu se ancora num slot que está prestes a sair do lugar — e com o
    // botão apertado ele não teria como ser usado de qualquer jeito.
    root.closeMenu()
    root.dragKey = entry.key
    root.dragShift = 0
  }

  function moveDrag(shift) {
    if (!root.dragging) return
    root.dragShift = shift
  }

  // Soltar grava a ordem nova. O estado do arrasto é limpo *antes* de mexer em
  // `pinned`, porque essa atribuição refaz a fileira na mesma hora e os slots
  // já precisam nascer sem translação nenhuma.
  //
  // E a atribuição em si espera um giro do laço de eventos: quem chama isto é o
  // `released` do slot, e refazer a fileira ali dentro destruiria o delegate —
  // com o grab do ponteiro em cima dele — no meio do tratador do próprio
  // evento. Um giro depois o evento já terminou, e o `clicked` que vem logo
  // atrás ainda encontra o slot de pé para recusar o clique.
  function finishDrag() {
    var from = root.dragFrom
    var to = root.dragTo
    root.cancelDrag()
    if (from < 0 || to < 0 || from === to) return
    Qt.callLater(function () {
      var next = root.pinned.slice()
      next.splice(to, 0, next.splice(from, 1)[0])
      root.pinned = next
      root.saveState()
    })
  }

  // Arrasto abandonado: ninguém muda de lugar e nada é gravado. É por aqui que
  // um gesto interrompido volta ao normal — ver o `cancelDrag` no começo de
  // `rebuildSlots`.
  function cancelDrag() {
    root.dragKey = ""
    root.dragShift = 0
  }

  // ----------------------------------------------------------------- ações
  //
  // Clique num slot: vai para o app. Com uma janela só, é ativá-la. Com mais de
  // uma, o clique percorre as janelas do app — a seguinte à que está em foco, e
  // a primeira quando o foco está em outro app. O ponto de partida sai do foco
  // atual em vez de um índice guardado aqui: assim abrir ou fechar uma janela no
  // meio do caminho não deixa o dock apontando para uma que já não existe.
  //
  // Sem janela nenhuma o slot é de um app fixado, e aí o clique abre o app —
  // é para isso que o slot dele está ali.
  function activateApp(entry) {
    var windows = (entry && entry.windows) ? entry.windows : []
    if (windows.length === 0) {
      root.launchApp(entry)
      return
    }
    var active = ToplevelManager.activeToplevel
    var current = active ? windows.indexOf(active) : -1
    root.focusWindow(windows[(current + 1) % windows.length])
  }

  // Levar o foco a uma janela. Sob o Hyprland o pedido vai pelo dispatcher
  // `focuswindow`, e não pelo `activate()` do protocolo wlr-foreign-toplevel.
  //
  // Porque o `activate()` não alcança janela minimizada. Minimizar aqui é
  // estacionar a janela fora dos monitores (ver ~/.config/hypr/minimize.lua), e
  // o `activate()` desce no `focusWindow()` do Hyprland, que desiste **calado**
  // com janela que não está desenhada em tela nenhuma — nem evento no socket,
  // nem erro. Era por isso que clicar no ícone de um app minimizado não fazia
  // absolutamente nada, e só o ALT+TAB trazia de volta: ele já usa o
  // dispatcher. O `focuswindow` foca de qualquer lugar.
  //
  // Só o foco, de propósito: onde a janela reaparece é decisão do hook de
  // `window.active` do Hyprland, e não do dock. Assim o clique no ícone e o
  // ALT+TAB devolvem a janela no mesmo lugar. Sem Hyprland (ou sem a janela na
  // lista dele) sobra o `activate()`, que é o caminho portátil.
  function focusWindow(toplevel) {
    if (!toplevel) return
    var hypr = root.hyprToplevel(toplevel)

    if (hypr && hypr.address) {
      // O `address` do Quickshell vem sem o `0x`, e o dispatcher quer com.
      var target = "address:0x" + hypr.address
      Hyprland.dispatch(Hyprland.usingLua
        ? 'hl.dsp.focus({ window = "' + target + '" })'
        : "focuswindow " + target)
      return
    }

    toplevel.activate()
  }

  // A janela do Hyprland que corresponde a um toplevel do protocolo. As duas
  // listas são a mesma coleção vista de dois lados; o `wayland` de cada entrada
  // do Hyprland é o elo.
  function hyprToplevel(toplevel) {
    var list = (Hyprland.toplevels && Hyprland.toplevels.values)
      ? Hyprland.toplevels.values : []
    for (var i = 0; i < list.length; i++) {
      if (list[i] && list[i].wayland === toplevel) return list[i]
    }
    return null
  }

  // Abrir o app. O caminho é o da própria shell (`uwsm-app -- gtk-launch`), e
  // não o `execute()` da entrada: aberto por `execute()` o app nasce filho do
  // processo da shell e morre junto no próximo `omarchy restart shell`, e uma
  // entrada que pede terminal (`Terminal=true`) nem chega a abrir. Fora da
  // shell não há appLibrary, e aí `execute()` é o que sobra.
  function launchApp(entry) {
    var desktop = entry ? entry.desktop : null
    if (!desktop) return
    var id = String(desktop.id || "")
    if (root.appLibrary && id.length > 0) {
      root.appLibrary.launch(id, String(entry.name || id))
      return
    }
    desktop.execute()
  }

  // ------------------------------------------------------ menu de contexto
  //
  // O botão direito num slot abre um menu com o que aquele app oferece. O
  // estado guardado é a *chave* do app, e não a entrada: as entradas são
  // refeitas a cada janela que abre ou fecha, então guardar o objeto deixaria o
  // menu preso a uma cópia velha. Pela chave, o conteúdo do menu acompanha o
  // app enquanto ele está no ar.
  property string menuKey: ""

  // O slot que abriu o menu, para a popup se ancorar nele. Não é limpo no
  // fechamento: a casca ainda leva um instante para sumir, e sem âncora ela
  // sumiria fora de lugar.
  property Item menuAnchorItem: null

  // Nos dois grupos: o recente é um slot como os outros, e sem ele aqui o
  // botão direito num recente marcava a chave mas o menu nunca abria.
  readonly property var menuApp: {
    if (root.menuKey.length === 0) return null
    var rows = root.slots.concat(root.recentSlots)
    for (var i = 0; i < rows.length; i++) {
      if (rows[i].key === root.menuKey) return rows[i]
    }
    return null
  }

  function openMenu(entry, anchorItem) {
    if (!entry) return
    root.menuAnchorItem = anchorItem
    root.menuKey = entry.key
  }

  function closeMenu() {
    root.menuKey = ""
  }

  // Os ids de ação .desktop que querem dizer "abre outra janela desta mesma
  // coisa". Não existe registro oficial dessa lista — cada app escolhe o seu —,
  // então são os que aparecem nos .desktop instalados: `new-window` no
  // Chromium/Brave/Firefox, `window-new` nos apps GTK, e as duas variantes que
  // o resto usa. A comparação é feita sem hífen nem caixa.
  readonly property var newWindowActionIds: [
    "newwindow", "windownew", "opennewwindow", "newemptywindow"
  ]

  function opensNewWindow(action) {
    if (!action) return false
    var id = String(action.id || "").toLowerCase().replace(/[^a-z0-9]/g, "")
    return id.length > 0 && root.newWindowActionIds.indexOf(id) >= 0
  }

  // As linhas do menu, montadas a partir do app. A ordem vai do que *abre*
  // (ações da entrada .desktop) para o que *navega* (as janelas abertas) e
  // termina no que *fecha* — o item destrutivo fica longe do topo, onde o
  // ponteiro chega primeiro.
  function menuItems(entry) {
    var items = []
    if (!entry) return items

    var desktop = entry.desktop
    var windows = entry.windows || []

    items.push({ header: true, label: entry.name })

    var actions = []
    if (desktop) {
      // As ações declaradas pelo app ("Nova janela privativa", "Compor
      // mensagem"...). Vêm antes do genérico porque são as que o próprio app
      // achou que valiam um item de menu.
      var declared = desktop.actions || []
      for (var i = 0; i < declared.length; i++) {
        var action = declared[i]
        var label = String(action.name || "")
        if (label.length === 0) continue
        actions.push({ label: label, run: runner(action) })
      }

      // Abrir outra vez é o que quase todo dock oferece, mas um app que já
      // declara a própria ação de nova janela (Firefox, Brave...) ganharia
      // duas linhas com o mesmo sentido — nesse caso a declarada basta. Num
      // fixado fechado não há "outra vez": a linha é só abrir.
      //
      // Comparar o rótulo resolve pouco: o nome da ação vem no idioma da
      // sessão ("Nova janela" numa sessão pt_BR) e o genérico está escrito aqui
      // em inglês, então dois textos diferentes passavam pelo teste e o menu
      // saía com "New window" e "Nova janela" um em cima do outro. O que casa
      // em qualquer idioma é o *id* da ação, que o .desktop não traduz.
      var generic = windows.length > 0 ? "New window" : "Open"
      var duplicated = false
      for (var a = 0; a < actions.length; a++) {
        if (actions[a].label.toLowerCase() === generic.toLowerCase()) duplicated = true
      }
      if (windows.length > 0) {
        for (var d = 0; d < declared.length; d++) {
          if (root.opensNewWindow(declared[d])) duplicated = true
        }
      }
      if (!duplicated) actions.unshift({ label: generic, run: opener(entry) })
    }

    for (var n = 0; n < actions.length; n++) {
      if (n === 0) items.push({ separator: true })
      items.push(actions[n])
    }

    // Com uma janela só não há o que escolher: o clique no slot já vai nela.
    if (windows.length > 1) {
      items.push({ separator: true })
      var active = ToplevelManager.activeToplevel
      for (var w = 0; w < windows.length; w++) {
        var top = windows[w]
        items.push({
          label: String(top.title || entry.name),
          current: top === active,
          run: activator(top)
        })
      }
    }

    // Fixar é propriedade do dock, não do app: fica no próprio grupo, depois do
    // que o app oferece. Ver `togglePin` para por que só com entrada .desktop.
    if (desktop) {
      items.push({ separator: true })
      items.push({
        label: entry.pinned ? "Unpin from dock" : "Pin to dock",
        run: pinToggler(entry)
      })
    }

    // O slot de um recente é o único que o usuário não pediu — ele apareceu
    // sozinho ao fechar o app —, então é o único que precisa de uma porta de
    // saída. No mesmo grupo do fixar, que é a outra pergunta sobre quem ocupa a
    // fileira. Fixado e aberto não têm o item: o slot deles não vem daqui.
    if (!entry.pinned && windows.length === 0 && root.recentIndex(entry.key) >= 0) {
      items.push({ label: "Remove from recents", run: recentRemover(entry) })
    }

    if (windows.length > 0) {
      items.push({ separator: true })
      items.push({
        label: windows.length > 1 ? "Close all (" + windows.length + ")" : "Close",
        run: closer(windows)
      })
    }

    return items
  }

  // Cada linha carrega a própria ação. Sai mais barato que um `kind` e um
  // switch do outro lado, e o menu não precisa saber o que executa. As fábricas
  // existem para o objeto ficar preso ao seu alvo, e não à variável do laço que
  // criou a linha.
  // As ações declaradas pelo app são as únicas que ficam no `execute()`: elas
  // não têm id de entrada, então não há o que passar ao gtk-launch.
  function runner(target) { return function () { target.execute() } }
  function opener(entry) { return function () { root.launchApp(entry) } }
  function pinToggler(entry) { return function () { root.togglePin(entry) } }
  function recentRemover(entry) { return function () { root.forgetRecent(entry.key) } }
  function activator(toplevel) { return function () { root.focusWindow(toplevel) } }
  function closer(windows) {
    // A lista é a nossa cópia do modelo, então fechar uma janela no meio do
    // caminho não desfaz o laço.
    var targets = windows.slice()
    return function () {
      for (var i = 0; i < targets.length; i++) targets[i].close()
    }
  }

  // O menu de apps é o plugin de primeira parte `omarchy.menu`, na rota "apps"
  // — o mesmo destino de `omarchy menu toggle apps`. Como o dock já recebe a
  // referência da shell, dá para chamar o host direto e poupar o subprocesso
  // do CLI; `toggle` (e não `summon`) para o botão fechar o que ele abriu.
  //
  // O host pode *recusar*, e desde o Omarchy 4.0.3 ele recusa: o `toggle` do
  // sandbox (`PluginShellApi`) só deixa um plugin mexer em si mesmo ou, se ele
  // for a barra ativa, no que a barra controla. O dock não é nem um nem outro,
  // então a chamada devolve `false` sem abrir nada e sem dizer nada. Por isso
  // o retorno é lido: um `false` não é "abriu", é o mesmo caso do plugin
  // rodando fora da shell — o CLI é quem sobra nos dois.
  function openAppMenu() {
    root.closeMenu()
    if (root.shell && typeof root.shell.toggle === "function"
        && root.shell.toggle("omarchy.menu", JSON.stringify({ menu: "apps" }))) return
    Util.execDetached("omarchy-menu toggle apps")
  }

  // A janela de ajustes é o *segundo* ponto de entrada deste mesmo plugin (ver
  // `panel` no manifesto): o host a monta numa superfície própria e injeta nela
  // este serviço, então ela escreve direto no `config` daqui — sem uma segunda
  // cópia dos ajustes para manter em sincronia.
  //
  // `toggle` (e não `summon`) para o botão fechar o que ele abriu, como no menu
  // de apps.
  function openSettings() {
    root.closeMenu()
    if (root.shell && typeof root.shell.toggle === "function") {
      root.shell.toggle(root.pluginId, "{}")
      return
    }
    Util.execDetached("omarchy-shell shell toggle " + Util.shellQuote(root.pluginId) + " '{}'")
  }

  // ------------------------------------------------------- notificações
  //
  // O contador vermelho no canto do ícone, como no dock do macOS. A conta é
  // "notificações que chegaram desde a última vez que o app esteve em foco":
  // uma chega, o número sobe; o app ganha o foco, o número some. É a única
  // leitura que o dock tem como sustentar — no macOS cada app diz o próprio
  // número (mensagens não lidas, e-mails por abrir), e aqui nenhum app fala
  // com o dock.
  //
  // Quem recebe as notificações é o serviço `omarchy.notifications` da shell,
  // e só ele pode: o nome D-Bus do servidor é um só. O dock não sobe um
  // segundo servidor; alcança o da shell por `firstPartyServiceFor` e escuta
  // o mesmo sinal que o serviço escuta. É o sinal *bruto* de propósito — o
  // `popupModel` só recebe o que virou toast, e uma notificação silenciada
  // pelo "não perturbe" não vira, mas é justamente a que o usuário precisa
  // encontrar depois.
  //
  // Contadores por chave de app, reatribuídos inteiros a cada mudança: é a
  // reatribuição que acorda os bindings dos slots; mutar no lugar não acorda.
  property var badges: ({})

  function badgeCountFor(entry) {
    if (!entry || !entry.key) return 0
    var count = root.badges[entry.key]
    return (typeof count === "number" && count > 0) ? count : 0
  }

  // O servidor de notificações da shell. Resolvido por função e timer, e não
  // por binding: `serviceFor` lê um dicionário que a shell muta no lugar, então
  // um binding avaliado antes do serviço subir ficaria nulo para sempre — e a
  // ordem em que os serviços sobem é a ordem das chaves do registro, que este
  // plugin não controla. O timer insiste por alguns segundos e desiste: sem o
  // serviço (desligado no shell.json) não há o que contar.
  property var notificationServer: null

  function findNotificationServer() {
    var service = (root.shell && typeof root.shell.firstPartyServiceFor === "function")
      ? root.shell.firstPartyServiceFor("omarchy.notifications") : null
    if (!service || !service.data) return null
    // O `NotificationServer` é um filho do serviço, sem propriedade que o
    // exponha; o que o identifica entre os filhos é o modelo de notificações
    // que só ele carrega.
    for (var i = 0; i < service.data.length; i++) {
      var child = service.data[i]
      if (child && child.trackedNotifications !== undefined) return child
    }
    return null
  }

  Timer {
    id: notificationProbe
    interval: 500
    repeat: true
    // Vinte batidas são dez segundos, mais do que a shell leva para subir
    // todos os serviços mesmo numa máquina lenta.
    property int attemptsLeft: 20
    running: root.notificationServer === null && attemptsLeft > 0
    // Sem esperar a primeira batida: se o serviço já estiver no ar, esta basta.
    triggeredOnStart: true
    onTriggered: {
      var server = root.findNotificationServer()
      if (server) {
        root.notificationServer = server
        return
      }
      attemptsLeft--
      if (attemptsLeft === 0) console.warn("arcdock: notification service not found; the counter stays off")
    }
  }

  Connections {
    target: root.notificationServer
    function onNotification(notification) { root.noteNotification(notification) }
  }

  // Que slot esta notificação marca. A dica `desktop-entry` é a resposta certa
  // quando vem: é o mesmo id de que a chave do slot é derivada. O nome do app
  // é a reserva, e a comparação é frouxa de propósito ("Slack" contra "slack",
  // "Telegram Desktop" contra "org.telegram.desktop"), pela mesma razão do
  // `omarchy-hyprland-focus-app`: cada app inventa a própria grafia. Sem slot
  // na fileira não há onde contar, e a notificação passa em branco — como no
  // macOS, onde um app fora do dock não tem contador.
  function stripDesktop(value) {
    var id = String(value || "").trim().toLowerCase()
    if (id.slice(-8) === ".desktop") id = id.slice(0, -8)
    return id
  }

  function badgeKeyFor(notification) {
    var rows = root.slots.concat(root.recentSlots)
    var entry = root.stripDesktop(notification ? notification.desktopEntry : "")
    if (entry.length > 0) {
      for (var i = 0; i < rows.length; i++) {
        if (rows[i].key === entry) return rows[i].key
        if (root.stripDesktop(rows[i].desktop ? rows[i].desktop.id : "") === entry) return rows[i].key
      }
    }
    var name = String((notification && notification.appName) || "").trim().toLowerCase()
    if (name.length === 0) return ""
    // A primeira palavra do nome, se tiver corpo: é a que sobrevive na classe
    // da janela ("Google Chrome" -> "google-chrome", "Telegram Desktop" ->
    // "org.telegram.desktop"). Duas letras casariam com qualquer coisa.
    var word = name.split(/[^a-z0-9]+/).filter(function (part) { return part.length >= 3 })[0] || ""
    for (var j = 0; j < rows.length; j++) {
      var row = rows[j]
      if (String(row.name || "").toLowerCase() === name) return row.key
      if (name.indexOf(row.key) >= 0) return row.key
      if (word.length > 0 && row.key.indexOf(word) >= 0) return row.key
    }
    return ""
  }

  function isActiveKey(key) {
    for (var i = 0; i < root.slots.length; i++) {
      if (root.slots[i].key === key) return !!root.slots[i].active
    }
    return false
  }

  function noteNotification(notification) {
    if (!notification) return
    // Transitória é "só o toast": o remetente pediu que ela não ficasse, e um
    // contador que fica é o oposto disso.
    var transient = false
    try { transient = !!notification.transient } catch (error) { transient = false }
    if (transient) return
    var key = root.badgeKeyFor(notification)
    if (key.length === 0) return
    // O app em foco é o que o usuário está olhando: a notificação dele já foi
    // vista no instante em que chegou.
    if (root.isActiveKey(key)) return
    root.bumpBadge(key, 1)
    // O remetente retirou a notificação — o que os apps de chat fazem quando a
    // mensagem foi lida em outro lugar (no telefone, por exemplo). É a única
    // retirada que desconta: fechar o toast, ou ele expirar, não diz que o
    // app foi visto, e o macOS também não desconta por isso.
    notification.closed.connect(function (reason) {
      if (reason === NotificationCloseReason.CloseRequested) root.bumpBadge(key, -1)
    })
  }

  function bumpBadge(key, delta) {
    var next = ({})
    for (var k in root.badges) next[k] = root.badges[k]
    var count = (next[key] || 0) + delta
    if (count > 0) next[key] = count
    else delete next[key]
    root.badges = next
  }

  // O foco limpa, e sair da fileira também: o app ganhou o foco, então o
  // usuário viu o que tinha para ver; o slot sumiu, então não há onde contar.
  function pruneBadges() {
    var rows = root.slots.concat(root.recentSlots)
    var next = ({})
    var changed = false
    for (var key in root.badges) {
      var row = null
      for (var i = 0; i < rows.length; i++) {
        if (rows[i].key === key) { row = rows[i]; break }
      }
      if (row && !row.active) next[key] = root.badges[key]
      else changed = true
    }
    if (changed) root.badges = next
  }

  // `values` muda quando uma janela abre ou fecha; `activeToplevel`, quando o
  // foco troca — os dois mexem no modelo, então os dois disparam o rebuild.
  Connections {
    target: ToplevelManager.toplevels
    function onValuesChanged() { root.rebuildSlots() }
  }

  Connections {
    target: ToplevelManager
    function onActiveToplevelChanged() { root.rebuildSlots() }
  }

  // Um app instalado depois que a shell subiu só ganha entrada .desktop agora;
  // sem isso o slot dele ficaria preso na inicial até a próxima janela abrir.
  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() { root.rebuildSlots() }
  }

  // O filete atravessa a fileira, então ele troca de eixo junto com ela. A Grid
  // o centra na célula (ver o alinhamento da fileira), e por ser menor que um
  // slot ele não muda a espessura dela. É componente porque são dois — um antes
  // dos recentes, outro antes do botão —, e duas cópias abririam espaço para os
  // dois filetes do mesmo dock discordarem.
  component RowFilete: Item {
    id: filete

    width: root.vertical ? root.separatorExtent : root.separatorSpan
    height: root.vertical ? root.separatorSpan : root.separatorExtent

    // O filete é uma célula da fileira como as outras: ele não cresce com a
    // onda — não é um ícone, e um separador que engorda vira uma barra —, mas
    // anda junto. Parado, o ícone que cresceu ao lado passaria por cima dele, e
    // o filete deixaria de separar coisa nenhuma.
    readonly property real rowCenter: root.vertical
      ? filete.y + filete.height / 2
      : filete.x + filete.width / 2

    property real magnifyShift: root.magnifyShiftAt(filete.rowCenter)

    // Mesmo tempo das células que ele separa (ver `magnifyDuration` no dock):
    // zero enquanto a onda segue o ponteiro, o tempo do realce na volta.
    Behavior on magnifyShift {
      NumberAnimation { duration: root.magnifyDuration; easing.type: Easing.OutQuad }
    }

    transform: Translate {
      x: root.vertical ? 0 : filete.magnifyShift
      y: root.vertical ? filete.magnifyShift : 0
    }

    // Duas linhas, e não uma. No vidro a casca não tem cor fixa: ela mostra o
    // que passa por trás, então é clara sobre um fundo de tela claro e escura
    // sobre um escuro — e *nenhuma* cor sozinha se vê nos dois. O filete de uma
    // linha só ou fica duro (cor cheia) ou some (cor com alfa).
    //
    // O par resolve porque as duas cores são as duas pontas da superfície: o
    // texto do popup contrasta com o fundo do popup por definição do tema, seja
    // ele claro ou escuro. Uma das duas sempre aparece, e nenhuma delas precisa
    // ser opaca para isso — que é o mesmo bisel que o macOS usa nos separadores
    // sobre vidro.
    //
    // Fora do vidro a casca tem cor fixa, e aí a borda do tema já se vê: o
    // filete volta a ser a linha única de sempre (ver `lines`).
    readonly property var lines: config.glass
      ? [root.tintSheen, root.tintShade]
      : [root.borderSpec.color]

    // A fileira do dock corre ao longo da borda e o filete a atravessa, então
    // as linhas do par se empilham no sentido em que o filete é fino: uma
    // coluna quando ele deita, uma linha quando ele fica de pé. Uma restrição
    // só, como na fileira (ver a Grid do dock).
    Grid {
      anchors.centerIn: parent
      spacing: 0
      columns: root.vertical ? 1 : -1
      rows: root.vertical ? -1 : 1

      Repeater {
        model: filete.lines

        delegate: Rectangle {
          required property color modelData

          width: root.vertical ? root.separatorExtent : root.separatorThickness
          height: root.vertical ? root.separatorThickness : root.separatorExtent

          // As pontas do filete são onde ele encontra a folga da casca, e uma
          // linha cortada seca ali marca a folga em vez de separar os grupos.
          // O corpo fica cheio e só as pontas se dissolvem — o fade que ia do
          // meio às bordas apagava a linha inteira.
          //
          // A densidade é a do realce de ponteiro, dois degraus abaixo da que
          // a casca usa na aresta iluminada: o filete divide grupos dentro de
          // uma superfície só, e não precisa se anunciar como o limite dela.
          // Tão leve só se sustenta por ser um par — com uma linha só, nesta
          // alfa, o filete some (ver `lines`).
          gradient: Gradient {
            orientation: root.vertical ? Gradient.Horizontal : Gradient.Vertical
            GradientStop { position: 0.0; color: Util.alpha(modelData, 0) }
            GradientStop { position: 0.2; color: Util.alpha(modelData, Style.hoverFillAlpha) }
            GradientStop { position: 0.8; color: Util.alpha(modelData, Style.hoverFillAlpha) }
            GradientStop { position: 1.0; color: Util.alpha(modelData, 0) }
          }
        }
      }
    }
  }

  // ------------------------------------------------------- estado em disco
  //
  // Os fixados e os recentes moram no diretório de estado do Omarchy, junto do
  // que os outros plugins da shell guardam. É estado do usuário, e não cache:
  // uma limpeza de `~/.cache` não pode levar embora a fileira que ele montou.
  //
  // As duas listas ficam no mesmo arquivo porque são a mesma pergunta — quem
  // ocupa a fileira — e porque um app se muda de uma para a outra ao ser
  // fixado: gravá-las juntas é o que impede uma escrita pela metade deixar o
  // app nas duas listas, ou em nenhuma.
  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME")
    || Quickshell.env("HOME") + "/.local/state") + "/omarchy"
  readonly property string statePath: root.stateDir + "/arc-dock.json"

  // A primeira leitura com conteúdo é a que vale. O arquivo é nosso: reler
  // depois de gravar só devolveria o que já está na tela, e uma leitura atrasada
  // chegando depois de um clique desfaria o que o usuário acabou de fixar.
  property bool stateLoaded: false

  // E esta diz que a primeira leitura *respondeu* — com conteúdo, ou dizendo
  // que o arquivo não existe. Antes disso as duas listas estão vazias porque
  // ninguém leu ainda, e não porque o usuário não fixou nada: gravar aí apaga a
  // fileira dele. Enquanto só o clique gravava, a ordem natural bastava; os
  // recentes trouxeram uma escrita que acontece sozinha, no primeiro rebuild,
  // que é antes de qualquer leitura ter voltado.
  property bool stateAnswered: false

  // As duas listas do arquivo têm a mesma forma, e o mesmo saneamento. A chave
  // é normalizada como em `appKey`: gravada de outro jeito, ela nunca casaria
  // com a janela do app e o slot ficaria eternamente vazio. Repetida daria dois
  // slots do mesmo app, e o segundo não teria janela. O teto existe para o
  // arquivo editado à mão não abrir uma fileira sem fim.
  function parseEntries(list, limit) {
    var items = (list && list.length !== undefined) ? list : []
    var cap = (limit === undefined || limit === null) ? items.length : limit
    var out = []
    var seen = ({})
    for (var i = 0; i < items.length && out.length < cap; i++) {
      var item = items[i] || {}
      var key = String(item.key || "").trim().toLowerCase()
      if (key.length === 0 || seen[key]) continue
      seen[key] = true
      out.push({ key: key, entry: String(item.entry || "") })
    }
    return out
  }

  function loadState(raw) {
    if (root.stateLoaded) return
    var text = String(raw || "").trim()
    // Arquivo ainda inexistente ou vazio não é resposta: é a primeira execução,
    // e a leitura seguinte (ver `Component.onCompleted`) ainda pode trazer algo.
    if (text.length === 0) return
    root.stateLoaded = true

    var data = null
    try {
      data = JSON.parse(text)
    } catch (error) {
      console.warn("arcdock: could not read state from", root.statePath, "-", error)
      return
    }

    // Sem teto para os fixados: quantos o usuário quiser, que foi ele quem
    // pediu cada um. Os recentes se acumulam sozinhos, e por isso têm.
    root.pinned = root.parseEntries(data ? data.pinned : null)
    var recents = root.parseEntries(data ? data.recent : null, root.recentHistoryLimit)
    // Um app não pode estar nas duas listas (ver `togglePin`). Se o arquivo
    // disser que está, o fixado é quem manda: foi um pedido explícito.
    var keptRecents = []
    for (var i = 0; i < recents.length; i++) {
      if (root.pinIndex(recents[i].key) < 0) keptRecents.push(recents[i])
    }
    root.recent = keptRecents
  }

  function saveState() {
    if (!root.stateAnswered) return
    stateFile.setText(JSON.stringify({
      version: 1,
      pinned: root.pinned,
      recent: root.recent
    }, null, 2) + "\n")
  }

  FileView {
    id: stateFile
    path: root.statePath
    // Quem escreve aqui é o dock, então não há mudança de fora para acompanhar
    // — e reler depois da própria gravação só reabriria a corrida de `stateLoaded`.
    watchChanges: false
    // O arquivo é curto e reescrito inteiro; sem isso um desligamento no meio da
    // gravação deixaria os fixados pela metade. A gravação cria o diretório
    // se ele ainda não existir (primeira execução) — não há `mkdir` a chamar.
    atomicWrites: true
    // Cala a leitura de um arquivo que ainda não existe — que é a primeira
    // execução, não um erro.
    printErrors: false
    onLoaded: {
      root.loadState(text())
      root.stateAnswered = true
    }
    // Uma leitura que falhou não traz conteúdo — `loadState` nem roda, e a
    // próxima leitura ainda vale —, mas é resposta: o arquivo não existe, que é
    // a primeira execução, e daí em diante gravar já é seguro.
    onLoadFailed: root.stateAnswered = true
    // A gravação é outra história: falhando ela, o fixado que está na tela some
    // no próximo início, e o usuário não teria como saber por quê.
    onSaveFailed: function (error) {
      console.warn("arcdock: could not write state to", root.statePath, "-", error)
    }
  }

  Component.onCompleted: {
    root.rebuildSlots()
    stateFile.reload()
    // A escolha do monitor não é binding (ver `refreshDockMonitor`), então a
    // primeira precisa ser pedida.
    root.refreshDockMonitor()
    // A shell pode ter subido com um app já em tela cheia, e o primeiro evento
    // `fullscreen` só viria quando o usuário saísse dela: sem esta consulta o
    // dock nasceria plantado por cima do app.
    Hyprland.refreshWorkspaces()
    // Pela mesma razão, a geometria das janelas: a shell pode ter subido com a
    // tela já ocupada, e o primeiro evento que reacomodasse alguma coisa viria
    // só quando o usuário mexesse em janela.
    if (root.coveredMode) Hyprland.refreshToplevels()
    // A regra do vidro vive no compositor, e não neste processo: uma sessão
    // anterior com o vidro ligado a deixou lá. Pedi-la já aqui — mesmo com o
    // ajuste desligado, que é o caso em que ela sai — é o que garante que o
    // compositor comece no estado que o arquivo de ajustes descreve.
    root.applyGlass()
    root.probeCompositorBlur()
  }

  // A sombra mora numa janela própria, e não na do dock, por causa do blur: a
  // regra do vidro desfoca tudo o que na superfície passar do piso de alfa (ver
  // `glassIgnoreAlpha`), e uma penumbra acima do piso viraria uma auréola fosca
  // com um limite duro onde a alfa cruza o piso. Abaixo do piso ela caberia na
  // janela do dock, mas aí seria fraca demais para ser sombra.
  //
  // Como a regra casa `^(arc-dock)$` inteiro, um namespace ao lado já fica de
  // fora dela. E a janela do dock segue exatamente a mesma de antes: máscara de
  // ponteiro, faixa de gatilho e âncora do menu não sabem que existe sombra.
  //
  // Declarada *antes* da janela do dock de propósito: duas superfícies na mesma
  // camada do compositor se empilham na ordem em que são criadas, e a sombra
  // tem que ficar por baixo.
  PanelWindow {
    id: shadowWindow
    visible: false
    color: "transparent"
    screen: root.dockScreen

    WlrLayershell.namespace: root.shadowNamespace
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
      bottom: root.edge === "bottom"
      top: root.edge === "top"
      left: root.edge === "left"
      right: root.edge === "right"
    }

    margins {
      top: 0
      bottom: 0
      left: 0
      right: 0
    }

    exclusionMode: ExclusionMode.Ignore

    // A janela do dock mais o alcance da penumbra de cada lado. No eixo que
    // atravessa a borda sobra um alcance só: do outro lado está a borda da
    // tela, e uma sombra que vai para fora dela é cortada, como deve ser.
    //
    // A queda da penumbra pede mais um tanto para baixo na tela — menos com o
    // dock na borda de baixo, onde "para baixo" já é a borda da tela e o que
    // sobra da folga (`edgeMargin`) é o que a sombra tem.
    implicitWidth: root.vertical
      ? root.windowExtent + root.shadowExtent
      : root.windowLength + root.shadowExtent * 2
    implicitHeight: (root.vertical
      ? root.windowLength + root.shadowExtent * 2
      : root.windowExtent + root.shadowExtent)
      + (root.edge === "bottom" ? 0 : root.shadowDrop)

    // Região vazia: a sombra nunca recebe ponteiro. Sem isto ela engoliria o
    // clique numa moldura de `shadowExtent` em volta do dock inteiro.
    mask: Region {}

    // O mesmo deslize da casca, pelo mesmo `bodyOffset` — as duas janelas leem
    // a mesma propriedade, então não há dois estados para sincronizar. O que
    // muda é o começo: nas bordas finais a folga da penumbra vem antes da
    // casca, e nas iniciais ela vem depois, onde a janela já tem sobra.
    Item {
      readonly property real bodyOffset: root.bodyOffset
        + (root.leadingEdge ? 0 : root.shadowExtent)

      // Ao longo da borda este corpo cobre a janela inteira, e quem acompanha a
      // casca é a sombra lá dentro: os Behaviors daqui são os do deslize, e a
      // casca se abrindo com a onda não é deslize nenhum — animá-la no tempo do
      // deslize deixaria a sombra sempre um pouco atrás do dock.
      width: root.vertical ? root.dockThickness : parent.width
      height: root.vertical ? parent.height : root.dockThickness
      x: root.vertical ? bodyOffset : 0
      y: root.vertical ? 0 : bodyOffset

      // Mesma curva e mesmo tempo da casca (ver o corpo do dock): as duas
      // superfícies andam juntas, e um Behavior com outro tempo deixaria a
      // sombra atrás do dock no meio do percurso.
      Behavior on x {
        NumberAnimation { duration: root.slideDuration; easing.type: slideX.easing.type }
      }

      Behavior on y {
        NumberAnimation { duration: root.slideDuration; easing.type: slideY.easing.type }
      }

      // A sombra é do tamanho da casca *de agora*: com a onda no ar a casca se
      // abre, e uma penumbra do tamanho de repouso deixaria as pontas do dock
      // sem apoio.
      ArcShadow {
        x: root.vertical ? 0 : root.shadowExtent + root.shellStart
        y: root.vertical ? root.shadowExtent + root.shellStart : 0
        width: root.vertical ? root.dockThickness : root.shellLength
        height: root.vertical ? root.shellLength : root.dockThickness
        radius: root.dockRadius
        extent: root.shadowExtent
        drop: root.shadowDrop
      }
    }
  }

  PanelWindow {
    id: dockWindow
    color: "transparent"

    // Uma tela só: a maior do setup (ver `dockScreen`).
    screen: root.dockScreen

    WlrLayershell.namespace: root.layerNamespace
    // Top fica acima das janelas normais mas abaixo de overlays (OSD, lock).
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Ancorado numa borda só: o layer-shell centraliza a superfície ao longo
    // dela, então não é preciso calcular a posição no outro eixo.
    //
    // As quatro num bloco só, e não uma por linha: `anchors` é um value type, e
    // escrever `anchors.top:` e `anchors.bottom:` em linhas separadas faz cada
    // atribuição trabalhar sobre uma cópia — a última vence e as outras somem,
    // então o dock reancorava sozinho na primeira reavaliação. É a mesma forma
    // que a bar do Omarchy usa para a posição dela.
    anchors {
      bottom: root.edge === "bottom"
      top: root.edge === "top"
      left: root.edge === "left"
      right: root.edge === "right"
    }

    // A folga é medida da janela, e não margem: é para dentro dela, e daí para
    // fora da tela, que a casca desliza ao esconder. Encolher a superfície a
    // cada quadro pediria uma reconfiguração de layer a cada quadro; mover o
    // conteúdo dentro dela é uma translação e nada mais.
    margins {
      top: 0
      bottom: 0
      left: 0
      right: 0
    }

    // Flutua por cima: não reserva espaço nem empurra as janelas.
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: root.vertical ? root.windowExtent : root.windowLength
    implicitHeight: root.vertical ? root.windowLength : root.windowExtent

    // Sem máscara a janela engoliria o clique em toda a sua área, inclusive na
    // folga e com o dock escondido — bem em cima do app que tomou a tela.
    mask: Region { item: inputArea }

    // O corpo que desliza, no eixo que atravessa a borda (ver `bodyOffset`). O
    // outro eixo é sempre a janela inteira: é ele que corre ao longo da borda.
    Item {
      id: dockBody
      width: root.vertical ? root.dockThickness : parent.width
      height: root.vertical ? parent.height : root.dockThickness
      x: root.vertical ? root.bodyOffset : 0
      y: root.vertical ? 0 : root.bodyOffset

      // Um por eixo: quem anda é o da borda atual, e o outro fica parado num
      // valor constante — Behavior sobre valor que não muda nunca dispara.
      Behavior on x {
        // A curva é mantida pelo `setDockShown`; o valor aqui é só o de
        // partida, para a primeira transição já sair certa.
        NumberAnimation { id: slideX; duration: root.slideDuration; easing.type: root.slideInEasing }
      }

      Behavior on y {
        NumberAnimation { id: slideY; duration: root.slideDuration; easing.type: root.slideInEasing }
      }

      // A casca. Fundo e borda vêm do tema ativo (mesmos tokens dos popups da
      // shell), então trocar de tema com `omarchy theme set` já repinta o dock.
      //
      // Ao longo da borda ela não ocupa a janela inteira: cresce e encolhe com
      // a onda, sempre pelo centro (ver `shellLength`/`shellStart`), e a
      // reserva que sobra dos dois lados é folga transparente da janela.
      BorderSurface {
        id: shellSurface
        x: root.vertical ? 0 : root.shellStart
        y: root.vertical ? root.shellStart : 0
        width: root.vertical ? parent.width : root.shellLength
        height: root.vertical ? root.shellLength : parent.height
        radius: root.dockRadius
        color: root.surfaceColor
        borderSpec: root.shellBorderSpec

        // A luz do vidro, por dentro da borda: a casca já é translúcida e
        // desfocada, e é isto que a faz parecer vidro em vez de um retângulo
        // com alfa. Só existe no modo vidro — sobre o tom cheio do tema não há
        // o que iluminar.
        //
        // Dentro da casca, e não ao lado dela como a fileira: o brilho é a
        // superfície pegando luz, então ele acompanha o comprimento dela. A
        // fileira vem depois, e por isso os ícones ficam por cima do brilho.
        ArcGlass {
          anchors.fill: parent
          anchors.topMargin: shellSurface.borderTop
          anchors.rightMargin: shellSurface.borderRight
          anchors.bottomMargin: shellSurface.borderBottom
          anchors.leftMargin: shellSurface.borderLeft
          radius: Math.max(0, root.dockRadius - shellSurface.borderTop)
          visible: config.glass
          // Sem isto o brilho continuaria saindo do tema enquanto a casca já
          // saiu dele, e a luz de um tema claro apagaria a casca escura por
          // dentro — exatamente onde ela devia estar mais viva.
          tint: root.tintSheen
          shade: root.tintShade
        }

        // Botão direito na casca abre os ajustes. Fica *atrás* da fileira, então
        // um clique num slot continua sendo do app e um clique no botão de apps
        // continua sendo dele — só o que sobra (a folga da casca, os vãos entre
        // os slots) chega aqui.
        //
        // Existe para os ajustes nunca ficarem sem porta de entrada: desligar o
        // botão de apps dentro dos próprios ajustes tiraria o único caminho de
        // volta, e sobraria um dock que só a linha de comando reconfigura.
        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.RightButton
          onClicked: root.openSettings()
        }
      }

      // A fileira mora *fora* da casca, e não dentro dela, embora pinte por
      // cima: a casca muda de comprimento com a onda, e uma fileira centrada
      // nela teria a própria posição dependendo de onde o ponteiro está — que é
      // justamente o que a onda mede a partir da posição das células. O laço
      // se fecharia no primeiro quadro. Centrada no corpo do dock, que tem o
      // comprimento fixo da janela, a fileira fica parada e a casca se abre em
      // volta dela.
      //
      // A ordem de pintura continua sendo a de antes: a casca (com o brilho do
      // vidro e o botão direito dos ajustes) é declarada primeiro, então a
      // fileira segue por cima dela. E como a fileira agora transborda a casca
      // — é assim que o ícone do pico sobe acima dela —, nada no caminho pode
      // recortar: nem o corpo do dock nem a casca usam `clip`.
      //
      // Grid, e não Row: a fileira corre ao longo da borda, e nas bordas
      // laterais isso é de cima para baixo. Uma linha só (ou uma coluna só) é
      // o mesmo layout de antes, e o número de colunas sai da contagem de
      // células — que já conta só as visíveis, como a Grid.
      Grid {
        anchors.centerIn: parent
        spacing: root.slotGap
        // Uma restrição só, e a outra em -1 (que para a Grid é "não fixado",
        // e ela deduz). Fixar as duas faz a Grid conferir `linhas × colunas`
        // contra o número de filhos, e a contagem chega um quadro atrasada a
        // cada app que abre — dava aviso a cada janela nova.
        columns: root.vertical ? 1 : -1
        rows: root.vertical ? -1 : 1
        // O filete é mais estreito que um slot; sem isto ele encostaria no
        // canto da célula em vez de ficar no meio da fileira.
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter

        ArcLauncher {
          visible: root.hasLauncher
          iconInset: root.iconPadding
          iconSource: root.launcherIconSource
          contentInk: root.tintSheen
          width: root.launcherSize
          height: root.launcherSize
          edge: root.edge
          magnifyEnabled: config.magnify
          magnifyMax: root.magnifyMax
          magnifyDuration: root.magnifyDuration
          magnifyScale: root.magnifyScaleAt(rowCenter)
          magnifyShift: root.magnifyShiftAt(rowCenter)
          onActivated: root.openAppMenu()
          onSettingsRequested: root.openSettings()
        }

        RowFilete { visible: root.separatorBeforeLauncher }

        // Sem apps abertos o Repeater não gera nada e a fileira fica só com o
        // botão de apps — que é o que segura o tamanho mínimo do dock.
        Repeater {
          model: root.slots
          delegate: ArcSlot {
            id: slotItem
            required property var modelData
            // A posição na fileira é o que diz se este slot abre espaço para
            // o que está sendo arrastado, e para que lado.
            required property int index
            app: modelData
            menuOpen: root.menuKey.length > 0 && !!modelData && root.menuKey === modelData.key
            // Resolvido aqui, e não dentro do modelo, para o binding depender
            // do índice de ícones da shell e se refazer quando ele mudar.
            iconSource: root.iconSource(modelData ? modelData.icon : "")
            iconArtScale: root.iconIsFallback(modelData ? modelData.icon : "") ? 0.78 : 1.0
            iconInset: root.iconPadding
            width: root.slotSize
            height: root.slotSize
            // A borda do dock diz de que lado ficam os pontos de estado e em
            // que eixo o slot é arrastado.
            edge: root.edge
            indicatorsVisible: config.showIndicators
            indicatorStyle: config.indicatorStyle
            indicatorActive: root.indicatorInk[0]
            indicatorIdle: root.indicatorInk[1]
            contentInk: root.tintSheen
            badgeCount: config.showBadges ? root.badgeCountFor(modelData) : 0
            // A onda: o dock mede a distância entre o ponteiro e o centro
            // desta célula na fileira, e devolve o quanto ela cresce e o quanto
            // ela anda para abrir espaço ao que cresceu ao lado dela.
            magnifyEnabled: config.magnify
            magnifyMax: root.magnifyMax
            magnifyDuration: root.magnifyDuration
            magnifyScale: root.magnifyScaleAt(rowCenter)
            magnifyShift: root.magnifyShiftAt(rowCenter)
            // Só os fixados se reordenam (ver a seção de arrasto no topo).
            draggable: !!modelData && modelData.pinned
            dragThreshold: root.dragThreshold
            // Pela chave, e não pelo índice: a fileira pode se refazer no meio
            // do gesto, e um índice guardado apontaria para outro app.
            dragging: root.dragging && !!modelData && root.dragKey === modelData.key
            dragOffset: root.dragOffsetFor(index)
            onDragStarted: root.startDrag(modelData)
            onDragMoved: function (shift) { root.moveDrag(shift) }
            onDragFinished: root.finishDrag()
            onDragCanceled: root.cancelDrag()
            // O grab do menu inclui a janela do dock, então um clique aqui não
            // o derruba sozinho: quem fecha é este caminho.
            onActivated: {
              root.closeMenu()
              root.activateApp(modelData)
            }
            onMenuRequested: root.openMenu(modelData, slotItem)
          }
        }

        RowFilete { visible: root.separatorBeforeRecents }

        // Os recentes: apps fechados, que o dock oferece de volta pelo tempo
        // em que continuam recentes (ver a seção `recentes`). São slots como
        // os outros, sem o que só o grupo da esquerda tem — não há janela
        // para o ponto marcar, e arrastar reordena os fixados, que estão do
        // outro lado do filete.
        Repeater {
          model: root.recentSlots
          delegate: ArcSlot {
            id: recentItem
            required property var modelData
            app: modelData
            menuOpen: root.menuKey.length > 0 && !!modelData && root.menuKey === modelData.key
            iconSource: root.iconSource(modelData ? modelData.icon : "")
            iconInset: root.iconPadding
            width: root.slotSize
            height: root.slotSize
            edge: root.edge
            indicatorsVisible: config.showIndicators
            indicatorStyle: config.indicatorStyle
            indicatorActive: root.indicatorInk[0]
            indicatorIdle: root.indicatorInk[1]
            contentInk: root.tintSheen
            badgeCount: config.showBadges ? root.badgeCountFor(modelData) : 0
            magnifyEnabled: config.magnify
            magnifyMax: root.magnifyMax
            magnifyDuration: root.magnifyDuration
            magnifyScale: root.magnifyScaleAt(rowCenter)
            magnifyShift: root.magnifyShiftAt(rowCenter)
            draggable: false
            onActivated: {
              root.closeMenu()
              root.activateApp(modelData)
            }
            onMenuRequested: root.openMenu(modelData, recentItem)
          }
        }

      }
    }

    // A área que recebe o ponteiro, e a mesma que vira máscara da janela.
    // Fica por cima de tudo de propósito: o HoverHandler é passivo — não
    // aceita botão nem acusa o evento de hover —, então os slots continuam
    // recebendo clique e realce, e mesmo assim o dock enxerga o ponteiro
    // enquanto ele está sobre um slot. Sem isso o dock sumiria debaixo do
    // dedo do usuário no primeiro slot que ele encostasse.
    //
    // A posição e a espessura saem de `inputOffset`/`inputExtent`; aqui só se
    // traduz o eixo de volta para largura e altura.
    //
    // Ao longo da borda ela cobre o dock *em repouso*, e não a janela inteira:
    // a reserva da ampliação é folga transparente de cada lado, e deixá-la na
    // máscara faria o dock engolir o clique numa faixa vazia ao lado dele. Como
    // a casca só cresce com o ponteiro dentro dela, o que fica de fora da área
    // sensível é o que o ponteiro nunca alcança sem antes sair do dock — e sair
    // do dock é o que devolve a casca ao tamanho de repouso. Sem ampliação a
    // reserva é zero, e esta é a janela inteira como sempre foi.
    //
    // É também o sistema de coordenadas em que a onda mede a distância até o
    // ponteiro (ver `magnifyPointer`), e é por começar junto com a casca que
    // essa conta é só descontar a folga da casca.
    Item {
      id: inputArea
      x: root.vertical ? root.inputOffset : root.inputStart
      y: root.vertical ? root.inputStart : root.inputOffset
      width: root.vertical ? root.inputExtent : root.dockLength
      height: root.vertical ? root.dockLength : root.inputExtent

      HoverHandler {
        id: pointerWatch

        // Redimensionar um split à mão é o único gesto de janela que não emite
        // evento nenhum, e a conta da cobertura ficaria velha até o gesto
        // seguinte. Encostar no dock (ou sair dele) é justamente quando ela vai
        // ser lida, então é aqui que ela é pedida de novo — em vez de uma
        // sondagem por tempo correndo a sessão inteira.
        onHoveredChanged: if (root.coveredMode) coverageTimer.restart()
      }
    }
  }

  // O menu vive fora da PanelWindow porque é outra superfície: a janela do dock
  // mal comporta o dock e a folga de baixo, e recortaria qualquer coisa
  // desenhada acima dele. Existe uma só, reaproveitada por todos os slots — o
  // que muda é a âncora e o conteúdo.
  ArcMenu {
    anchorItem: root.menuAnchorItem
    // O menu nasce do lado de dentro da tela, então a borda do dock é o que
    // decide para que lado ele abre.
    edge: root.edge
    items: root.menuApp ? root.menuItems(root.menuApp) : []
    open: root.menuApp !== null
    onTriggered: function (item) {
      root.closeMenu()
      item.run()
    }
    onDismissed: root.closeMenu()
  }
}
