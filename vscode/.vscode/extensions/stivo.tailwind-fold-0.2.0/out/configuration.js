"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get = exports.set = exports.Settings = void 0;
const vscode = require("vscode");
var Settings;
(function (Settings) {
    Settings["Identifier"] = "tailwind-fold";
    // Functionality
    Settings["AutoFold"] = "autoFold";
    Settings["UnfoldIfLineSelected"] = "unfoldIfLineSelected";
    Settings["SupportedLanguages"] = "supportedLanguages";
    // Visuals
    Settings["FoldStyle"] = "foldStyle";
    Settings["ShowTailwindImage"] = "showTailwindImage";
    Settings["FoldedText"] = "foldedText";
    Settings["FoldedTextColor"] = "foldedTextColor";
    Settings["FoldedTextBackgroundColor"] = "foldedTextBackgroundColor";
    Settings["UnfoldedTextOpacity"] = "unfoldedTextOpacity";
    Settings["FoldLengthThreshold"] = "foldLengthThreshold";
})(Settings = exports.Settings || (exports.Settings = {}));
function set(key, value) {
    vscode.workspace.getConfiguration(Settings.Identifier).update(key, value, true);
}
exports.set = set;
function get(key) {
    return vscode.workspace.getConfiguration(Settings.Identifier).get(key);
}
exports.get = get;
//# sourceMappingURL=configuration.js.map