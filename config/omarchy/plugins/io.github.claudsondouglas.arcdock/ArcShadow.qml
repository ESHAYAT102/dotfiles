// ArcShadow — a penumbra que assenta a casca na tela.
//
// É uma pilha de anéis de um pixel, e não um borrão por baixo da casca. O
// miolo precisa ficar vazio: a casca de vidro deixa passar o que está atrás
// dela, inclusive a própria sombra, e um retângulo escuro embaixo escureceria
// o vidro em vez de erguê-lo. Anéis crescem para fora e só pintam o que
// sobra da silhueta.
//
// A pilha inteira desce um tanto (ver `drop`): é sombra *projetada*, de uma
// luz que vem de cima da tela, e não um halo igual em volta. É isso que
// assenta a peça — o macOS não desenha linha escura na base do vidro, ele
// deixa a sombra fazer esse trabalho. Com a queda os anéis de dentro entrariam
// na silhueta da casca por cima, e o vidro os mostraria; a máscara recorta a
// silhueta da pilha, e o miolo volta a ficar vazio.
//
// A cor sai de `menu.scrim` — o tom com que o tema escurece o que está atrás
// de uma superfície dele —, mas não a densidade dele: o scrim existe para
// apagar a tela inteira atrás de um modal, e a sombra de uma peça pousada é
// outra ordem de grandeza. A densidade é a do `pressedFillAlpha`, que é o
// quanto o tema escurece uma superfície de perto. Assim a penumbra continua
// saindo do tema, e um tema claro ou escuro a ajusta junto.
import QtQuick
import QtQuick.Effects
import qs.Commons

Item {
  id: shadow

  // Raio da casca. Cada anel curva um pixel a mais que o de dentro, então as
  // curvas correm paralelas à da casca em vez de irem fechando.
  property real radius: 0

  // Até onde a penumbra chega, medido a partir da borda da casca. Também é a
  // contagem de anéis: um por pixel percorrido.
  property int extent: 0

  // Quanto a pilha desce, em pixels. Sempre para baixo na tela, seja qual for
  // a borda em que o dock ancorou (ver o cabeçalho). Zero devolve o halo
  // simétrico, e dispensa a máscara.
  property int drop: 0

  // O tom da penumbra: a cor de escurecimento do tema na densidade com que ele
  // escurece de perto (ver o cabeçalho). É deste alfa que sai o do anel colado
  // à casca — metade dele, pelo perfil de borrão —, e dele saem os de fora.
  property color tone: Util.alpha(Color.menu.scrim, Style.pressedFillAlpha)

  // A pilha, do tamanho da penumbra inteira: a casca mais o alcance e a queda
  // de cada lado. Precisa ter esse tamanho porque a camada só captura o que
  // cabe na caixa do item — anel que transbordasse seria cortado pela máscara
  // antes de ser cortado pela tela.
  Item {
    id: stack

    readonly property int reach: shadow.extent + shadow.drop

    anchors.centerIn: parent
    width: shadow.width + reach * 2
    height: shadow.height + reach * 2

    layer.enabled: shadow.drop > 0
    layer.effect: MultiEffect {
      maskEnabled: true
      maskInverted: true
      maskSource: cutout
    }

    Repeater {
      model: shadow.extent

      delegate: Rectangle {
        required property int index

        // Distância deste anel até a casca, em pixels.
        readonly property int step: index + 1

        // Perfil de silhueta borrada, e não de rampa saindo do tom cheio. Duas
        // coisas vêm daí, e são as duas que separam penumbra de contorno:
        //
        // A borda da casca é o *meio* do borrão, não o começo dele — metade do
        // tom, portanto. Um anel com a alfa cheia colado na casca lê como uma
        // linha escura desenhada em volta, que é exatamente o que uma sombra
        // não é.
        //
        // E a queda é gaussiana, de desvio igual a meio alcance: a penumbra
        // existe ao longo do alcance inteiro em vez de se concentrar nos
        // primeiros pixels, e chega à ponta com uns 2% do tom — pouco o
        // bastante para o fim dela não se ver.
        readonly property real falloff: {
          var t = step / shadow.extent
          var sigma = 0.5
          return 0.5 * Math.exp(-(t * t) / (2 * sigma * sigma))
        }

        anchors.centerIn: parent
        anchors.verticalCenterOffset: shadow.drop
        width: shadow.width + step * 2
        height: shadow.height + step * 2
        radius: shadow.radius + step

        // Só o contorno: é o que deixa o miolo vazio (ver o cabeçalho).
        color: "transparent"
        border.width: 1
        border.color: Util.alpha(shadow.tone, shadow.tone.a * falloff)
        antialiasing: true
      }
    }
  }

  // A silhueta da casca, no quadro da pilha, para a máscara recortar. Fica na
  // cena — fonte de textura fora da cena não é desenhada — mas o `hideSource`
  // a tira da tela: só a textura importa.
  Item {
    id: silhouette
    anchors.centerIn: parent
    width: stack.width
    height: stack.height

    Rectangle {
      anchors.centerIn: parent
      width: shadow.width
      height: shadow.height
      radius: shadow.radius
      color: "#ffffff"
      antialiasing: true
    }
  }

  ShaderEffectSource {
    id: cutout
    sourceItem: silhouette
    hideSource: true
    visible: false
  }
}
