"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FoldedDecorationType = exports.UnfoldedDecorationType = void 0;
const vscode_1 = require("vscode");
const Config = require("./configuration");
const configuration_1 = require("./configuration");
const path = require("path");
const fs = require("fs");
const svgPath = path.resolve(__dirname, "../images/tailwindicon.svg");
const svgContent = fs.readFileSync(svgPath, "utf8");
function generateScaledSVGPath() {
    const fontSize = vscode_1.workspace.getConfiguration("editor").get("fontSize");
    const scaleFactor = 0.9;
    const width = fontSize * scaleFactor;
    const height = fontSize * scaleFactor;
    const resizedSVGContent = svgContent
        .replace(/width=".*?"/, `width="${width}"`)
        .replace(/height=".*?"/, `height="${height}"`);
    const svgBase64 = Buffer.from(resizedSVGContent).toString("base64");
    const svgDataURI = `data:image/svg+xml;base64,${svgBase64}`;
    return vscode_1.Uri.parse(svgDataURI);
}
function UnfoldedDecorationType() {
    return vscode_1.window.createTextEditorDecorationType({
        rangeBehavior: vscode_1.DecorationRangeBehavior.ClosedOpen,
        opacity: Config.get(configuration_1.Settings.UnfoldedTextOpacity).toString() ?? "1",
    });
}
exports.UnfoldedDecorationType = UnfoldedDecorationType;
function FoldedDecorationType() {
    return vscode_1.window.createTextEditorDecorationType({
        before: {
            contentIconPath: Config.get(configuration_1.Settings.ShowTailwindImage) === true ? generateScaledSVGPath() : undefined,
            backgroundColor: Config.get(configuration_1.Settings.FoldedTextBackgroundColor) ?? "transparent",
            margin: "0 0 0 -5px",
        },
        after: {
            contentText: Config.get(configuration_1.Settings.FoldedText) ?? "class",
            backgroundColor: Config.get(configuration_1.Settings.FoldedTextBackgroundColor) ?? "transparent",
            color: Config.get(configuration_1.Settings.FoldedTextColor) ?? "#7cdbfe7e",
        },
        textDecoration: "none; display: none;",
    });
}
exports.FoldedDecorationType = FoldedDecorationType;
//# sourceMappingURL=decorations.js.map