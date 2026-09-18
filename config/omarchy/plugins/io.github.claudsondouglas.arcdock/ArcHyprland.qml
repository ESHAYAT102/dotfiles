// ArcHyprland — um pedido ao compositor, feito direto no socket dele.
//
// É o que `hyprctl` faz por dentro: abre o socket de pedidos do Hyprland,
// escreve o comando, lê a resposta e fecha. Falar com o socket em vez de
// chamar o binário tira uma coisa do caminho: o executável. Um `hyprctl`
// resolvido pelo PATH é o que estiver primeiro no PATH — e a shell é um
// processo longo, então qualquer diretório gravável que se meta ali na frente
// vira código rodando dentro dela. O socket não tem esse problema: o caminho
// vem do próprio compositor, pela variável de ambiente que ele mesmo põe na
// sessão, e não há binário nenhum a ser trocado.
//
// O protocolo é o do `hyprctl`, sem tradução: `j/` na frente pede JSON,
// `[[BATCH]]` junta vários comandos separados por ` ; `, e `eval` corre Lua
// (config nova). O Hyprland responde e fecha a conexão; a resposta é curta
// (um `ok`, um JSON de uma linha), então o primeiro pedaço lido é a resposta
// inteira, e é este lado que fecha.
//
// Um pedido por vez. Enquanto um está no ar, `busy` é verdadeiro e `send()`
// recusa — quem chama decide o que fazer com o pedido que não coube (ver
// `glassPending` no Arcdock). E se o socket não existir (a shell subiu fora
// do Hyprland) ou a conexão falhar, `failed` sai e nada é executado: sem
// compositor não há o que pedir, e não há para onde recuar.
import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Item {
  id: ipc

  readonly property bool busy: ipc.request !== ""

  property string request: ""
  property string reply: ""

  signal replied(string reply)
  signal failed()

  // Se o pedido de agora chegou a conectar. É o que separa um erro de
  // conexão (o socket não abriu: falha) do fecho do compositor depois de
  // responder (fim normal).
  property bool opened: false

  function send(text) {
    if (ipc.busy) return false
    if (!Hyprland.requestSocketPath) {
      console.warn("arcdock: no Hyprland request socket; not running:", text)
      ipc.failed()
      return false
    }
    ipc.request = text
    ipc.reply = ""
    ipc.opened = false
    sock.connected = true
    return true
  }

  function finish(ok) {
    var text = ipc.reply
    ipc.request = ""
    ipc.reply = ""
    if (ok) ipc.replied(text)
    else ipc.failed()
  }

  Socket {
    id: sock
    path: Hyprland.requestSocketPath
    connected: false

    parser: SplitParser {
      // Sem marcador: cada pedaço lido chega inteiro, como veio do socket.
      splitMarker: ""
      onRead: function (data) {
        ipc.reply += data
        // Fechar daqui, e não esperar o compositor fechar, é o que evita um
        // aviso de "peer closed" no log da shell a cada pedido.
        sock.connected = false
      }
    }

    onConnectionStateChanged: {
      if (sock.connected) {
        ipc.opened = true
        sock.write(ipc.request)
        sock.flush()
      } else if (ipc.busy) {
        // Desconectou depois de responder — ou o compositor fechou antes de
        // dizer qualquer coisa, que é resposta vazia, não erro.
        ipc.finish(true)
      }
    }

    // Um erro *antes* de conectar é o socket que não abriu: o pedido não
    // chegou a sair. Depois de conectado, o "peer closed" do compositor é o
    // fim normal da conversa, e quem o encerra é o desconectar acima.
    onError: function (error) {
      if (!ipc.opened && ipc.busy) {
        console.warn("arcdock: could not reach the Hyprland socket at",
          sock.path, "- error", error, "; not running:", ipc.request)
        ipc.finish(false)
      }
    }
  }
}
