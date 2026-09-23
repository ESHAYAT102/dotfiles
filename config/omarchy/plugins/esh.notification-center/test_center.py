#!/usr/bin/env python3
"""Run on Omarchy: isolated notification bus and temporary notification storage."""
import os
import json
import time
from pathlib import Path
import shutil
import subprocess
import tempfile

repo = Path(__file__).resolve().parent
with tempfile.TemporaryDirectory(prefix="notification-center-test-") as temporary:
    root = Path(temporary)
    for source in [*repo.glob("*.qml"), *repo.glob("*.js")]:
        shutil.copy(source, root / source.name)
    # Drive hover explicitly below; the user's real pointer must not affect timing.
    service_file = root / "Service.qml"
    service_file.write_text(service_file.read_text().replace(
        "id: hoverArea", "id: hoverArea; enabled: false").replace(
        "readonly property int normalDuration: 8000", "readonly property int normalDuration: 1200"))
    for name in ("Commons", "Ui"):
        (root / name).symlink_to(Path("/usr/share/omarchy/shell") / name)
    (root / "bin").mkdir()
    for source in (repo / "bin").iterdir():
        if not source.is_file():
            continue
        target = root / "bin" / source.name
        target.write_text(source.read_text().replace(
            "~/.local/state/omarchy/omapager", str(root / "state")
        ).replace("~/.config/omarchy/omapager", str(root / "config")))
        target.chmod(0o755)
    store = root / "bin" / "omapager-store"
    archived = {"key": "archived", "ts": time.time(), "summary": "Restored history"}
    subprocess.run([str(store), "put"], input=json.dumps(archived), text=True, check=True)
    subprocess.run([str(store), "close", "archived", "expired"], check=True)
    (root / "shell.qml").write_text('''import QtQuick
import Quickshell
import Quickshell.Io
import "Store.js" as Store
ShellRoot {
  Service { id: service; fetchIcons: false }
  BarWidget {} // Compile and instantiate the center UI too.
  Process { id: sender; command: ["notify-send", "-a", "Center test", "-t", "0", "--action=default=Open",
      "Verification code", "Your verification code is 123456"]
    stdout: StdioCollector { onStreamFinished: actionResult = text.trim() }
  }
  property string actionResult: ""
  property int step: 0
  property string key: ""
  function check(ok, message) { if (!ok) throw new Error(message) }
  Timer {
    interval: 1000; running: true; repeat: true
    onTriggered: {
      step++
      if (step === 1) {
        check(service.centerModel.count === 1, "history not restored")
        check(service.rowIndexFor("archived") < 0, "history replayed as popup")
        for (var i = 0; i < 205; i++)
          service.remember(Store.normalise({key: "limit" + i, ts: Date.now()/1000 + i}))
        check(service.centerModel.count === 200, "center not bounded")
        check(service.centerModel.get(0).key === "limit204", "history not newest first")
        service.clearCenter()
        service.centerOpen = true
        sender.running = true
      }
      if (step === 3) {
        check(service.centerModel.count === 1, "arrival missing")
        key = String(service.centerModel.get(0).key)
        check(service.centerModel.get(0).code === "123456", "code detection")
        check(service.rowIndexFor(key) >= 0, "popup expired while center open")
        service.centerOpen = false
      }
      if (step === 6) {
        check(service.rowIndexFor(key) < 0, "popup failed to expire")
        check(service.centerModel.count === 1, "expiry lost history")
        check(!!service.refs[key], "expiry destroyed sender action")
        service.activate(key)
        service.dismissCenter(key)
        check(service.centerModel.count === 0, "dismiss failed")
        service.remember(Store.normalise({key: key, ts: Date.now()/1000}))
        check(service.centerModel.count === 0, "dismissed row resurrected")
        service.setDoNotDisturb(true)
        service.setCodesBypassQuiet(false)
      }
      if (step === 7) {
        check(actionResult === "default", "expired center click did not reach sender: " + actionResult)
        sender.running = true
      }
      if (step === 8) {
        check(service.centerModel.count === 1, "muted notification not recorded")
        key = String(service.centerModel.get(0).key)
        check(service.rowIndexFor(key) < 0, "muted notification became popup")
        check(!!service.refs[key], "DND destroyed sender action")
        actionResult = ""
        service.activate(key)
        service.setDoNotDisturb(false)
        service.pointerIn = true
        service.commit(function() { service.expanded = true })
      }
      if (step === 9) {
        check(actionResult === "default", "DND center click did not reach sender: " + actionResult)
        sender.running = true
      }
      if (step === 10) {
        check(service.centerModel.count === 2, "live and muted rows not merged")
        var newest = String(service.centerModel.get(0).key)
        check(service.rowIndexFor(newest) >= 0, "hover hid the incoming popup")
        check(service.held.length === 0, "hover queued the incoming popup")
        service.pointerIn = false
        service.commit(function() { service.expanded = false })
        service.clearCenter()
        check(service.centerModel.count === 0, "clear failed")
        // A queued showRow must not undo Clear all.
        var row = Store.normalise({key: "pending", ts: Date.now()/1000})
        service.remember(row)
        service.showRow(row)
        service.clearCenter()
      }
      if (step === 11) {
        check(service.centerModel.count === 0, "clear raced with queued arrival")
        check(service.rowIndexFor("pending") < 0, "cleared popup resurrected")
        check(Object.keys(service.refs).length === 0, "clear leaked sender callbacks")
        console.log("CENTER_RUNTIME_OK")
        Qt.quit()
      }
    }
  }
}
''')
    result = subprocess.run(
        ["dbus-run-session", "--", "quickshell", "-p", str(root / "shell.qml")],
        env={**os.environ, "QT_QPA_PLATFORM": "wayland", "QT_ACCESSIBILITY": "0"},
        capture_output=True, text=True, timeout=20,
    )
    log = result.stdout + result.stderr
    assert result.returncode == 0 and "CENTER_RUNTIME_OK" in log, log
    assert "ERROR:" not in log and "Error: " not in log and "WARN scene:" not in log, log
    for directory in ("live", "history"):
        assert not list((root / "state" / directory).glob("*.json")), directory
    print("Passed: real notifications, code detection, pause/expiry, arrivals during hover, DND history, dismissal, clear races, and empty persistent store.")
