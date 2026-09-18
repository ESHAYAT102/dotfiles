// ArcGlass — o que separa uma casca translúcida de uma peça de vidro.
//
// Blur e alfa dão o fundo: dá para ver através, e o que está atrás sai fosco.
// O que falta é a luz: vidro de verdade clareia em cima e assenta embaixo.
// Sem isso a casca lê como um retângulo cinza com o fundo aparecendo através.
//
// Só a face mora aqui. O fio de luz da aresta é a própria borda da casca (ver
// `shellBorderSpec` no Arcdock): já houve um segundo fio por dentro dela, e as
// duas linhas somadas no topo eram justamente a moldura dura que o vidro não
// tem. Uma aresta, uma linha.
//
// Tudo aqui é vertical, inclusive com o dock ancorado na esquerda ou na
// direita. É a única coisa do plugin que não se escreve em comprimento e
// espessura, e de propósito: a luz vem de cima da tela, não da borda em que o
// dock encostou.
//
// Mora *por dentro* da borda da casca — quem monta passa o raio já descontado
// (ver `radius`). Um brilho por cima da borda apagaria justamente a linha que
// diz onde a casca começa.
import QtQuick
import qs.Commons

Item {
  id: glass

  // Raio da casca menos a espessura da borda dela: quem monta é que sabe de
  // quanto é essa borda em cada lado, e as duas curvas correm paralelas —
  // mesma regra concêntrica do slot dentro do dock.
  property real radius: 0

  // A cor da luz e a do assentamento. Saem do tema por padrão (a mesma família
  // de popup que pinta a casca), e são propriedades porque o menu de contexto
  // é a mesma superfície vista de outro ângulo.
  property color tint: Color.popups.text
  property color shade: Color.popups.background

  // A face. O meio é transparente de propósito: o que a casca já pintou é o
  // vidro, e isto aqui só inclina a luz nele. Alfa cheia em qualquer das duas
  // pontas apagaria o fundo desfocado, que é o ponto do modo vidro.
  Rectangle {
    anchors.fill: parent
    radius: glass.radius
    gradient: Gradient {
      GradientStop { position: 0.0; color: Util.alpha(glass.tint, Style.normalFillAlpha) }
      GradientStop { position: 0.5; color: Util.alpha(glass.tint, 0) }
      GradientStop { position: 1.0; color: Util.alpha(glass.shade, Style.normalFillAlpha) }
    }
  }
}
