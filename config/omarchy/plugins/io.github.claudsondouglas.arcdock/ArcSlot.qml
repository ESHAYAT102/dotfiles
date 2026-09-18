// ArcSlot — um slot do dock.
//
// O slot é o *espaço* reservado a um app — aberto, ou fixado e fechado — e o
// conteúdo dele é o ícone do app. A inicial do nome continua no arquivo como
// último recurso: apps sem entrada .desktop (ou com um ícone que não existe no
// tema) ainda precisam de alguma marca no slot.
//
// O slot não desenha casca nenhuma: fundo e contorno já são da casca do dock,
// e repeti-los por app só empilharia uma moldura em volta de cada ícone. O que
// carrega o estado são os *pontos* ao lado do ícone, do lado que encosta na
// borda da tela — um ponto por janela aberta (até o teto), e na cor do tema
// quando o app está em foco. Um fixado sem janela nenhuma fica sem ponto, que é
// o que diz que ele está fechado.
//
// O contador de notificações é a outra marca, e mora no canto de cima à
// direita do ícone, como no dock do macOS: um disco vermelho com o número de
// notificações que o app recebeu desde a última vez que esteve em foco. Quem
// conta é o dock; o slot só desenha o número que recebe, e some com ele em
// zero.
//
// Todo ícone é desenhado em opacidade cheia, em foco ou não: apagar os que não
// estão em foco só deixava a fileira irregular, e quem diz o foco já é o ponto.
// Sem casca e sem opacidade para variar, a resposta ao ponteiro é o ícone
// crescer um pouco — um gesto, não uma segunda marca de foco.
//
// Clicar no slot vai para o app, e o botão direito pede o menu de contexto.
// Quem sabe *qual* janela ativar e *o que* o menu oferece é o dock; aqui só se
// avisa que o slot foi acionado.
//
// Arrastar ao longo da fileira reordena os fixados. O slot só mede o gesto e
// conta o que aconteceu; quem decide para onde ele vai — e o que isso significa
// na ordem gravada — continua sendo o dock. Qual eixo é "ao longo da fileira"
// vem da borda em que o dock está ancorado.
import QtQuick
import qs.Commons

Item {
  id: slot

  signal activated()
  signal menuRequested()

  // O gesto passou do limiar e virou arrasto; daí em diante `dragMoved` conta
  // o deslocamento acumulado desde o aperto, e `dragFinished` pede para gravar.
  // `dragCanceled` é o gesto que morreu sem conclusão (o grab do ponteiro caiu).
  signal dragStarted()
  signal dragMoved(real shift)
  signal dragFinished()
  signal dragCanceled()

  // Entrada do modelo montado pelo Arcdock:
  // { key, name, icon, desktop, windows, active, pinned }.
  property var app: null

  // A borda em que o dock está ancorado. O slot precisa dela para duas coisas:
  // saber de que lado desenhar os pontos de estado — sempre o lado que encosta
  // na borda da tela, que é para onde o olho já vai — e em que eixo medir o
  // arrasto, já que numa borda lateral a fileira corre de cima para baixo.
  property string edge: "bottom"
  readonly property bool vertical: slot.edge === "left" || slot.edge === "right"

  // Caminho do ícone já resolvido pelo dock (file:// ou vazio).
  property string iconSource: ""
  property real iconArtScale: 1.0

  readonly property bool active: !!(app && app.active)
  readonly property string appName: (app && app.name) ? app.name : ""
  readonly property int windowCount: (app && app.windows) ? app.windows.length : 0

  // Folga entre a borda do slot e o ícone. Quem manda é o dock (o slot é
  // dimensionado a partir dela); o valor aqui é só o padrão.
  property int iconInset: Style.space(4)

  // Lado da caixa do ícone: o slot menos a folga dos dois lados. Fica aqui
  // porque não é só o `Image` que precisa dele — a ampliação do hover também
  // se mede a partir desta caixa.
  readonly property int iconExtent: Math.max(1, Math.min(slot.width, slot.height) - slot.iconInset * 2)

  // Diâmetro do ponto de estado. Sai do próprio `iconInset`: é ele que abre a
  // faixa entre o ícone e a borda do slot, então um ponto desse tamanho
  // preenche a faixa sem invadir o ícone nem escapar do slot. O piso existe só
  // para o ponto não sumir num tema de espaçamento muito apertado.
  property int indicatorSize: Math.max(3, iconInset)

  // Folga entre dois pontos, derivada do próprio ponto: metade do diâmetro
  // separa sem soltar, e a fileira acompanha o tamanho do ponto sozinha.
  readonly property int indicatorGap: Math.max(1, Math.round(indicatorSize / 2))

  // Teto de pontos, e só vale no estilo "dots". Uma janela mostra um ponto,
  // duas ou mais mostram dois: o que interessa é "tem mais de uma", não a
  // contagem exata — e uma fileira que crescesse sem limite estouraria a
  // largura do slot.
  property int maxIndicators: 2

  // Que marca o slot usa para dizer "aberto". Três respostas para a mesma
  // pergunta, e a diferença entre elas é o que a marca *conta*:
  //
  // - "dot": nada. Um ponto diz que o app está aberto e para por aí, que é o
  //   que o dock do macOS faz — quantas janelas são já está no menu do slot.
  // - "dots": as janelas, até o teto acima. A contagem passa a caber no
  //   relance, ao custo de a marca mudar de largura enquanto o app é usado.
  // - "bar": nada também, mas com um traço no lugar do ponto. É a marca mais
  //   visível das três, para quem perde o ponto num ícone claro.
  property string indicatorStyle: "dot"

  readonly property bool indicatorIsBar: slot.indicatorStyle === "bar"

  // Desligar os pontos nos ajustes deixa o dock só com os ícones. É uma perda
  // consciente: sem eles um fixado fechado fica igual a um app aberto, e o
  // foco deixa de ter marca. Quem escolhe isso quer a fileira limpa.
  property bool indicatorsVisible: true

  // Sem janela não há ponto: é assim que um fixado e fechado se distingue de um
  // aberto, sem precisar de uma segunda marca só para ele.
  readonly property int indicatorCount: {
    if (!slot.indicatorsVisible || slot.windowCount <= 0) return 0
    // Só "dots" conta janelas; os outros dois marcam presença, e presença não
    // tem plural.
    if (slot.indicatorStyle === "dots") return Math.min(slot.maxIndicators, slot.windowCount)
    return 1
  }

  // O comprimento da marca no eixo da fileira. O ponto é redondo e cai no
  // próprio diâmetro; o traço se estica sobre o ícone — cerca de um terço
  // dele, que é o quanto se lê como sublinhado sem virar uma segunda borda.
  // O piso em dois diâmetros existe para o traço continuar sendo um traço num
  // ícone pequeno, em vez de um ponto meio gordo.
  readonly property int indicatorLength: slot.indicatorIsBar
    ? Math.max(slot.indicatorSize * 2, Math.round(slot.iconExtent * 0.34))
    : slot.indicatorSize

  // Em foco os pontos vão para a cor de destaque do tema (`accent`, a mesma que
  // a shell usa para marcar o item ativo); fora de foco recuam para `muted`, o
  // tom que o tema reserva justamente para isso.
  //
  // São propriedades, e não constantes: com o tom da casca fixado pelo ajuste
  // `dockTheme` o tema deixa de descrever o chão em que o ponto é pintado, e
  // quem monta o slot passa o par que enxerga nesse chão (ver `indicatorInk`
  // no Arcdock). O padrão continua sendo o tema, para o slot montado sem
  // ninguém dizer nada seguir se parecendo com o resto da shell.
  property color indicatorActive: Color.accent
  property color indicatorIdle: Color.muted

  // A tinta do que o slot desenha por conta própria — hoje só a inicial que
  // substitui um ícone que não resolveu. Segue a mesma regra da marca: padrão
  // do tema, sobrescrita por quem monta quando o tom da casca foi fixado. Sem
  // isso, um dock escuro num tema claro escreveria a inicial em preto sobre
  // preto, e o app sem ícone sumiria da fileira em vez de aparecer sem ícone.
  property color contentInk: Color.popups.text

  readonly property color indicatorColor: slot.active ? slot.indicatorActive : slot.indicatorIdle

  // O menu de contexto deste slot está aberto. Enquanto ele está no ar o slot
  // fica aceso como se estivesse sob o ponteiro: o cursor foi para o menu, mas
  // o assunto continua sendo este app.
  property bool menuOpen: false

  // Sob o ponteiro (ou com o menu deste slot no ar), o conteúdo é ampliado.
  // Arrastando conta como estar sob o ponteiro mesmo que ele escape da caixa
  // do slot: é a mesma ampliação de sempre, e não uma segunda marca.
  readonly property bool hot: pointer.containsMouse || slot.menuOpen || slot.dragging

  // Teto da ampliação. Numa fileira de ícones do mesmo tamanho, o olho lê a
  // diferença de escala do vizinho muito antes de ela ficar grande: 5% já
  // separa o ícone sob o ponteiro dos outros, e daí para cima o realce vira
  // salto e desloca a leitura da fileira inteira.
  readonly property real hotScaleMax: 1.05

  // Quanto o ícone cresce sob o ponteiro. A medida continua saindo da folga
  // que ele já tem: com este fator cada lado avança um *quarto* do
  // `iconInset`, então o ícone nem chega perto da borda do slot, e um tema que
  // aperte ou abra o espaçamento reajusta o gesto sozinho — até o teto.
  //
  // O quarto (e não a metade de antes) é o que mantém a derivação viva: com o
  // espaçamento padrão, metade do `iconInset` por lado dá exatamente os 10%
  // que o teto agora recusa, e o gesto ficaria preso no teto em vez de sair
  // da folga.
  readonly property real hotScale: Math.min(slot.hotScaleMax, 1 + slot.iconInset / (slot.iconExtent * 2))

  // Duração das transições do slot (ampliação, cor do ponto e o vizinho
  // abrindo espaço num arrasto): curta o bastante para acompanhar o ponteiro
  // sem virar animação, e longa o bastante para a curva ter onde acontecer —
  // abaixo disso qualquer easing se parece com um corte. O `slideDuration` do
  // Arcdock espelha este valor, um degrau acima por causa do percurso maior.
  readonly property int transitionDuration: 140

  // As curvas do gesto. Linear é o que fazia o realce parecer mecânico: a
  // velocidade não muda em ponto nenhum, então o movimento começa e termina de
  // supetão. Indo, o ícone arranca e assenta (`OutQuad`); voltando ao repouso
  // ele sai devagar (`InOutQuad`), porque a volta não é resposta a nada — é o
  // ponteiro tendo ido embora, e não pode ser mais chamativa que a ida.
  readonly property int hotEasing: Easing.OutQuad
  readonly property int restEasing: Easing.InOutQuad

  // A curva depende do sentido, e um binding em `easing.type` dentro de um
  // Behavior chega a ser lido velho justamente na virada — o Behavior dispara
  // com a animação ainda na curva anterior, e a volta sai com a curva da ida.
  // Escrita aqui, ela precede o `scale` que dispara a animação.
  onHotChanged: {
    contentGrowth.easing.type = slot.hot ? slot.hotEasing : slot.restEasing
  }

  // ------------------------------------------------------------- contador
  //
  // Notificações que chegaram e ainda não foram vistas, contadas pelo dock
  // (ver a seção `notificações` no Arcdock). Zero é "sem marca".
  property int badgeCount: 0

  // A cor do disco é o `urgent` do tema — o vermelho que o `colors.toml`
  // reserva para "isto pede atenção", o mesmo que a barra usa no workspace
  // urgente. A tinta do número é branca em qualquer tema, e é propriedade só
  // para quem monta poder trocar: o chão dela é o próprio vermelho, que não
  // acompanha o tom da casca, então não há tema a seguir aqui.
  property color badgeColor: Color.urgent
  property color badgeInk: "#ffffff"

  // O diâmetro do disco, em relação ao ícone: pouco mais de um terço, que é a
  // proporção do dock do macOS (um disco de 22 px sobre o ícone de 64). Escala
  // com o ícone e não com a fonte porque é uma marca *sobre* o ícone, e
  // precisa manter a mesma presença em qualquer tamanho de dock; o piso na
  // fonte base é só para o número continuar legível num ícone pequeno.
  readonly property int badgeSize: Math.max(Style.fontPx(1.0), Math.round(slot.iconExtent * 0.36))

  // ------------------------------------------------------------ ampliação
  //
  // A onda do dock (ver a seção `ampliação` no Arcdock): o ícone sob o ponteiro
  // cresce, os vizinhos crescem menos, e cada um anda o bastante para caber o
  // que o outro engordou. Quem calcula é o dock — é ele que sabe onde o
  // ponteiro está na fileira —, e aqui só se aplica o resultado.
  //
  // Ligada, ela toma o lugar do realce de ponteiro: o ícone sob o cursor já é o
  // que mais cresce, e somar os dois gestos seria marcar duas vezes a mesma
  // coisa.
  property bool magnifyEnabled: false

  // O teto, como fator. Não entra na escala — quem manda nela é o
  // `magnifyScale` —, mas é dele que sai o tamanho em que o ícone é
  // decodificado.
  property real magnifyMax: 1.0

  // A escala que a onda pede para este slot; 1 fora do alcance dela.
  property real magnifyScale: 1.0

  // O quanto este slot anda ao longo da fileira.
  property real magnifyShift: 0

  // Duração das transições da onda, ditada pelo dock: zero enquanto ela segue o
  // ponteiro (a escala é função de onde ele está, e animá-la só a atrasaria), o
  // tempo do realce quando ela sai de cena. Vem de fora, e não de um binding
  // daqui, pela mesma razão das curvas acima: a ordem importa, e o valor
  // precisa já estar trocado quando a escala nova chegar.
  property int magnifyDuration: slot.transitionDuration

  // O centro do slot ao longo da fileira, no sistema em que a Grid o posiciona.
  // É o que o dock precisa para medir a distância até o ponteiro.
  readonly property real rowCenter: slot.vertical
    ? slot.y + slot.height / 2
    : slot.x + slot.width / 2

  // A escala do conteúdo. O maior dos dois gestos vence, em vez de um modo
  // escolher o outro: com a onda no ar ela já é maior que o realce em todo slot
  // que o ponteiro alcança, e nos que ela não alcança sobra o realce — que é o
  // que mantém o slot aceso quando o menu dele está aberto e o ponteiro já foi
  // para dentro do menu.
  readonly property real contentScale: Math.max(slot.magnifyScale,
    slot.hot ? slot.hotScale : 1.0)

  // O maior tamanho que o ícone chega a ocupar, para o decode não borrar nele.
  readonly property real contentScaleMax: Math.max(slot.hotScaleMax,
    slot.magnifyEnabled ? slot.magnifyMax : 1.0)

  // De onde o conteúdo cresce. Sem ampliação é do centro, para o ícone se
  // manter alinhado com o ponto embaixo dele e com os vizinhos da fileira.
  //
  // Com ela o ícone fica *assentado e sobe*, como no macOS: o lado que encosta
  // na borda da tela fica parado e todo o crescimento vai para o lado de
  // dentro. São duas coisas de uma vez — o ponto de estado continua onde
  // estava, e o ícone cresce para o único lado em que a janela reservou folga
  // para ele (ver `magnifyHeadroom` no Arcdock).
  readonly property int contentOrigin: {
    if (!slot.magnifyEnabled) return Item.Center
    if (slot.edge === "top") return Item.Top
    if (slot.edge === "left") return Item.Left
    if (slot.edge === "right") return Item.Right
    return Item.Bottom
  }

  // Mesmo tempo e mesma curva da escala: o slot que cresce e o vizinho que sai
  // da frente são o mesmo gesto, e separá-los em dois tempos desmontaria a onda.
  Behavior on magnifyShift {
    NumberAnimation { duration: slot.magnifyDuration; easing.type: slot.hotEasing }
  }

  // ------------------------------------------------------------- arrastar
  //
  // Só os fixados se reordenam: os demais são ordenados pela ordem em que os
  // apps apareceram, e aí não há ordem do usuário para mexer.
  property bool draggable: false

  // Deslocamento a partir do qual o gesto deixa de ser clique. Vem do dock,
  // que é quem conhece o passo da fileira — daqui não dá para derivar "quando
  // o slot chega perto do vizinho".
  property int dragThreshold: 0

  // Este é o slot que está sendo arrastado. Quem decide é o dock, pela chave
  // do app: assim a resposta continua certa mesmo que a fileira se refaça.
  property bool dragging: false

  // Translação do slot ao longo da fileira, calculada pelo dock para todo mundo
  // — tanto para quem acompanha o ponteiro quanto para quem abre espaço. É um
  // número só porque o dock raciocina em "passos na fileira"; qual eixo isso é
  // na tela se decide aqui, pela borda.
  property real dragOffset: 0

  // O slot arrastado anda colado no dedo, então não pode ser animado; os
  // vizinhos é que se rearranjam, e aí vale a mesma duração curta do resto.
  Behavior on dragOffset {
    enabled: !slot.dragging
    // Sempre a curva da ida, nos dois sentidos: abrir espaço e voltar ao lugar
    // são o mesmo movimento visto de dois lados, e o vizinho precisa sair da
    // frente com a mesma pressa com que o slot pego chega.
    NumberAnimation { duration: slot.transitionDuration; easing.type: slot.hotEasing }
  }

  // O quanto o slot está deslocado ao longo da fileira, somados os dois motivos
  // que o deslocam: o arrasto e a onda. Eles não convivem (a onda sai de cena
  // durante um arrasto), mas somá-los é o que deixa a volta de um acontecer
  // enquanto o outro já começou.
  readonly property real rowOffset: slot.dragOffset + slot.magnifyShift

  // Translação, e não `x`/`y`: quem manda na posição dos filhos é a Grid do
  // dock, e escrever nela brigaria com o layout. A transform passa por cima do
  // posicionamento sem desfazer a fileira nem mexer nas medidas de que a
  // janela é derivada — nem no `rowCenter`, que é o que a onda mede.
  transform: Translate {
    x: slot.vertical ? 0 : slot.rowOffset
    y: slot.vertical ? slot.rowOffset : 0
  }

  // O slot pego passa por cima dos vizinhos que ele atravessa. Fora do
  // arrasto, quem manda é a escala: o ícone ampliado é o que mais cresce e o
  // que mais invade o vizinho, e precisa ficar por cima dele — do contrário o
  // contador, que sai pelo canto do ícone, some atrás de um ícone cujo PNG
  // pinta a margem (o do Ghostty vem com uma moldura clara). Um Grid pinta
  // os filhos na ordem, então sem isto o da direita sempre venceria.
  z: slot.dragging ? 2 : slot.contentScale

  // Fallback: a inicial do nome do app, só enquanto não há ícone na tela.
  readonly property string initial: appName.length > 0 ? appName.charAt(0).toUpperCase() : ""

  // A caixa do ícone. É ela que cresce sob o ponteiro e na onda — e não o
  // `Image` sozinho — porque o contador mora no canto dela e precisa crescer
  // junto, do mesmo ponto de origem: escalado por conta própria ele sairia do
  // canto do ícone no primeiro quadro da ampliação.
  Item {
    id: content
    anchors.centerIn: parent
    width: slot.iconExtent
    height: slot.iconExtent
    transformOrigin: slot.contentOrigin
    scale: slot.contentScale
    // A curva é mantida pelo `onHotChanged` e a duração pelo dock; os valores
    // aqui são só os de partida.
    Behavior on scale {
      NumberAnimation { id: contentGrowth; duration: slot.magnifyDuration; easing.type: slot.hotEasing }
    }

    Image {
      id: icon
      anchors.centerIn: parent
      width: parent.width * slot.iconArtScale
      height: parent.height * slot.iconArtScale
      // Ícone quadrado por convenção, mas os que não são não podem distorcer.
      fillMode: Image.PreserveAspectFit
      // Decodifica em pixels físicos: em HiDPI um decode no tamanho lógico
      // deixaria os ícones PNG borrados. O fator do hover entra na conta
      // porque é esse o maior tamanho que o ícone chega a ocupar —
      // decodificar já nele evita o PNG borrar justamente quando o ponteiro o
      // amplia.
      sourceSize.width: Math.round(width * slot.contentScaleMax * Screen.devicePixelRatio)
      sourceSize.height: Math.round(height * slot.contentScaleMax * Screen.devicePixelRatio)
      source: slot.iconSource
      asynchronous: true
      // Só aparece quando de fato carregou — enquanto carrega ou se falhar, o
      // slot mostra a inicial em vez de um vazio.
      visible: status === Image.Ready
    }

    // A inicial faz as vezes do ícone, e por morar na mesma caixa responde ao
    // ponteiro do mesmo jeito que ele.
    Text {
      anchors.centerIn: parent
      visible: !icon.visible && slot.initial.length > 0
      text: slot.initial
      color: slot.contentInk
      font.family: Style.fontFamily
      font.pixelSize: Style.font.heading
    }

    // O contador. No canto de cima à direita do ícone, e sempre nele, em
    // qualquer borda do dock: é onde o olho aprendeu a procurá-lo. Ele avança
    // sobre o ícone e sai dele pelo canto em `iconInset` — a folga que o slot
    // já reserva em volta do ícone —, então cobre o mínimo do desenho sem
    // passar da caixa do slot.
    Rectangle {
      id: badge

      readonly property bool shown: slot.badgeCount > 0

      // Entra com um pulo (`OutBack`, passa do tamanho e assenta), que é o que
      // faz um número que acabou de chegar se anunciar; sai recuando com a
      // curva de repouso do slot, sem chamar atenção para o que já foi visto.
      // Escrita no handler, e não em binding, pela razão do `onHotChanged`:
      // a curva precisa estar trocada antes de a escala que a usa mudar.
      onShownChanged: badgePop.easing.type = badge.shown ? Easing.OutBack : slot.restEasing

      x: parent.width - width + slot.iconInset
      y: -slot.iconInset
      // Um disco com um dígito; com mais, um comprimido que cresce só na
      // largura, com a folga de meio disco em volta do número.
      width: Math.max(slot.badgeSize, badgeLabel.implicitWidth + Math.round(slot.badgeSize / 2))
      height: slot.badgeSize
      radius: height / 2
      // O disco não é chapado: um degradê curto, mais claro em cima, é o que
      // o faz parecer um botão assentado sobre o ícone em vez de um adesivo —
      // a mesma luz que a casca do dock recebe (ver `tintSheen` no Arcdock).
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.lighter(slot.badgeColor, 1.18) }
        GradientStop { position: 1.0; color: slot.badgeColor }
      }
      // Um fio escuro e translúcido em volta é o que descola o disco de um
      // ícone que também seja vermelho, sem o anel branco de adesivo; a
      // espessura sai do próprio disco para o fio continuar fio quando o
      // ícone cresce.
      border.width: Math.max(1, Math.round(slot.badgeSize / 14))
      border.color: Util.alpha("#000000", 0.22)

      // A sombra: o mesmo disco um pixel abaixo, escuro e translúcido, pintado
      // antes do resto. É o que dá ao contador o assentamento que o disco do
      // macOS tem sobre o ícone, e desaparece com ele.
      Rectangle {
        z: -1
        anchors.fill: parent
        anchors.topMargin: Math.max(1, Math.round(slot.badgeSize / 10))
        radius: parent.radius
        color: Util.alpha("#000000", 0.28)
      }

      transformOrigin: Item.Center
      scale: badge.shown ? 1 : 0
      visible: scale > 0
      Behavior on scale {
        NumberAnimation { id: badgePop; duration: slot.transitionDuration; easing.type: Easing.OutBack }
      }

      Text {
        id: badgeLabel
        anchors.centerIn: parent
        text: slot.badgeCount
        color: slot.badgeInk
        font.family: Style.fontFamily
        font.bold: true
        // Pouco menos de dois terços da altura do disco: é o que deixa folga
        // em cima e embaixo para o disco continuar redondo em volta do número.
        font.pixelSize: Math.max(1, Math.round(slot.badgeSize * 0.62))
      }
    }
  }

  // Os pontos de estado. A fileira fica centrada no slot e colada na borda que
  // encosta na borda da tela — embaixo num dock de baixo, à esquerda num dock à
  // esquerda. A faixa que sobra desse lado do ícone é exatamente a folga do
  // `iconInset`, então os pontos ficam *fora* do ícone sem precisar de margem
  // própria nem de espessura extra no dock.
  //
  // A Grid cresce a partir do centro conforme o número de pontos, então o
  // conjunto continua centrado com um ou com dois — e ela também é o que faz a
  // dupla se enfileirar no eixo certo: atravessada em relação à fileira do
  // dock, para dois pontos nunca disputarem o comprimento do slot.
  // Posição calculada, e não âncoras: um lado depende da borda e o outro é
  // sempre o centro, e âncoras condicionais teriam que declarar as quatro de
  // uma vez — o que o Qt recusa como combinação inválida antes mesmo de olhar
  // qual delas está ativa.
  Grid {
    id: indicators
    x: slot.vertical
      ? (slot.edge === "left" ? 0 : slot.width - width)
      : Math.round((slot.width - width) / 2)
    y: slot.vertical
      ? Math.round((slot.height - height) / 2)
      : (slot.edge === "top" ? 0 : slot.height - height)
    spacing: slot.indicatorGap
    // Uma restrição só; a outra fica em -1, que para a Grid é "deduza". Ver o
    // mesmo cuidado na fileira do Arcdock.
    columns: slot.vertical ? 1 : -1
    rows: slot.vertical ? -1 : 1

    Repeater {
      model: slot.indicatorCount

      Rectangle {
        // O traço se estica no eixo da fileira, e não no da espessura: num dock
        // vertical ele é um traço em pé, sob a mesma lógica de "sublinha o
        // ícone pelo lado em que o dock encostou".
        width: slot.vertical ? slot.indicatorSize : slot.indicatorLength
        height: slot.vertical ? slot.indicatorLength : slot.indicatorSize
        // O menor dos dois lados: no ponto isso é o raio de sempre, no traço é
        // o que fecha as duas pontas em meia-lua em vez de deixá-las quadradas.
        radius: Math.min(width, height) / 2
        color: slot.indicatorColor
        // Mesma duração e mesma curva da ampliação: trocar o foco acende o
        // ponto no ritmo em que o resto do dock se mexe, e não no seu próprio.
        Behavior on color {
          ColorAnimation { duration: slot.transitionDuration; easing.type: slot.hotEasing }
        }
      }
    }
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    hoverEnabled: true
    // Slot sem app é espaço morto: nada a ativar, nada a sinalizar no cursor.
    // Com o slot na mão o cursor fecha, que é o que diz "isto está pego".
    cursorShape: slot.dragging
      ? Qt.ClosedHandCursor
      : (slot.app ? Qt.PointingHandCursor : Qt.ArrowCursor)
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    // Onde o botão foi apertado, no eixo da fileira e em coordenadas do slot.
    property real pressAt: 0

    // O gesto já passou do limiar. Fica de pé até o próximo aperto porque
    // quem o consulta é o `clicked`, que só chega depois do `released`.
    property bool moved: false

    // A coordenada que interessa é a do eixo em que a fileira corre; a do outro
    // eixo é o quanto a mão saiu de linha, e não conta para a reordenação.
    function along(mouse) {
      return slot.vertical ? mouse.y : mouse.x
    }

    onPressed: function (mouse) {
      // Um segundo botão apertado no meio de um arrasto não zera o gesto em
      // curso — é ele que vai ser ignorado, e não o contrário.
      if (slot.dragging) return
      pointer.moved = false
      if (mouse.button === Qt.LeftButton) pointer.pressAt = pointer.along(mouse)
    }

    onPositionChanged: function (mouse) {
      if (!slot.draggable || !(pointer.pressedButtons & Qt.LeftButton)) return

      // O slot inteiro anda com o gesto, então a coordenada do ponteiro já vem
      // descontada da translação: sem somá-la de volta o deslocamento se
      // comeria a cada quadro e o slot nunca sairia do lugar. É a translação
      // *inteira* que volta, e não só a do arrasto — nos primeiros quadros do
      // gesto a onda ainda está saindo de cena, e o que sobrou dela também está
      // descontado da coordenada.
      var shift = pointer.along(mouse) + slot.rowOffset - pointer.pressAt

      if (!pointer.moved) {
        // Abaixo do limiar o ponteiro ainda está sobre o slot que apertou:
        // um tremor de mão não pode reordenar a fileira.
        if (Math.abs(shift) < slot.dragThreshold) return
        pointer.moved = true
        // O deslocamento passa a contar daqui. Sem reancorar, o slot saltaria
        // de uma vez o tamanho do limiar no instante em que ele é cruzado.
        pointer.pressAt = pointer.along(mouse)
        slot.dragStarted()
        return
      }
      slot.dragMoved(shift)
    }

    // Quem carrega o slot é o botão esquerdo, então é o soltar dele que grava.
    onReleased: function (mouse) {
      if (mouse.button === Qt.LeftButton && pointer.moved) slot.dragFinished()
    }

    // O grab caiu sem soltar (outra superfície roubou o ponteiro): o gesto não
    // chegou ao fim, então nada é gravado.
    onCanceled: {
      if (pointer.moved) {
        pointer.moved = false
        slot.dragCanceled()
      }
    }

    onClicked: function (mouse) {
      if (!slot.app) return
      // Com um arrasto em curso o slot não atende a mais nada — nem ao menu do
      // botão direito. E um gesto que virou arrasto já se resolveu no soltar:
      // deixá-lo cair aqui também abriria o app que o usuário só queria mover.
      if (slot.dragging || pointer.moved) return
      if (mouse.button === Qt.RightButton) slot.menuRequested()
      else slot.activated()
    }
  }
}
