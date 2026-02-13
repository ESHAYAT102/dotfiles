"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivate = exports.activate = void 0;
const vscode = require("vscode");
const commands_1 = require("./commands");
const decorator_1 = require("./decorator");
const configuration_1 = require("./configuration");
function activate({ subscriptions }) {
    const decorator = new decorator_1.Decorator();
    decorator.loadConfig();
    decorator.setActiveEditor(vscode.window.activeTextEditor);
    //
    // Register event handlers
    //
    const changeActiveTextEditor = vscode.window.onDidChangeActiveTextEditor(() => {
        decorator.setActiveEditor(vscode.window.activeTextEditor);
    });
    const changeTextEditorSelection = vscode.window.onDidChangeTextEditorSelection(() => {
        decorator.updateDecorations();
    });
    const changeConfiguration = vscode.workspace.onDidChangeConfiguration((event) => {
        if (event.affectsConfiguration(configuration_1.Settings.Identifier)) {
            decorator.loadConfig();
        }
    });
    //
    // Register commands
    //
    const toggleCommand = vscode.commands.registerCommand(commands_1.Command.ToggleFold, () => {
        decorator.toggleAutoFold();
    });
    subscriptions.push(changeActiveTextEditor);
    subscriptions.push(changeTextEditorSelection);
    subscriptions.push(changeConfiguration);
    subscriptions.push(toggleCommand);
}
exports.activate = activate;
function deactivate({ subscriptions }) {
    subscriptions.forEach((subscription) => subscription.dispose());
}
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map