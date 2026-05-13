import { writeFileSync } from "node:fs"
import { resolveActiveTheme } from "./theme"
import type { Action } from "./types"
import { userSizing } from "./userConfig"

// Builds the display-popup flags from sizing config: -B + body style if no
// border, -b/-s/-S triplet otherwise. Theme is resolved here so popup
// colors match the palette without the caller needing to know about it.
function popupFlags(): string {
  const sizing = userSizing()
  const theme = resolveActiveTheme(undefined)
  const popupBorder = sizing.popupBorder ?? "none"
  const bodyStyle = sizing.popupBodyStyle ?? `bg=${theme.panel}`
  if (popupBorder === "none") return `-B -s '${bodyStyle}'`
  const borderStyle = sizing.popupBorderStyle ?? `fg=${theme.accent},bg=default`
  return `-b ${popupBorder} -s '${bodyStyle}' -S '${borderStyle}'`
}

// Encodes an Action into the line the bash wrapper reads after the popup
// closes. Two prefixes:
//   tmux:<cmd>   → wrapper runs `tmux <cmd>`
//   shell:<cmd>  → wrapper runs the shell command directly
// `palette` is sugar for "open another palette via run-shell -b".
// `run` executes inline (no dispatch needed).
function encodeAction(action: Action): string | null {
  if ("tmux" in action) return `tmux:${action.tmux}`
  if ("shell" in action) return `shell:${action.shell}`
  if ("popup" in action) return `tmux:display-popup -E ${popupFlags()} -h 80% -w 80% ${action.popup}`
  if ("palette" in action) {
    const bin = process.env.TMUX_PALETTE_BIN ?? "tmux-palette"
    return `tmux:run-shell -b '${bin} ${action.palette}'`
  }
  return null
}

export function dispatchToFile(action: Action, cmdFile: string | undefined): void {
  const encoded = encodeAction(action)
  if (encoded && cmdFile) writeFileSync(cmdFile, encoded)
}
