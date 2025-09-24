# Spell Check

A simple spell checker that runs offline.

## Help

* [Bugs](https://github.com/solomonkinard/public/issues/new?title=Spell%20Check%3A%20)
* [Documentation](https://docs.google.com/document/d/1_kC67Dm8p6UeiayYqqw_wUkDuumiWrS3EFsEuwpupNc/edit?usp=sharing)

## Basics

* Quick fix for common misspellings.
* Ignore words with anything other than lowercase letters.
* Add or remove words from your custom dictionary with included commands.
* Qualified words that end in a comma or period are considered.

## Advanced

* Import or export your custom dictionary.
* View unrecognized words as warnings in the Problems panel tab.
* List all unrecognized words in a dropdown menu.
* Forget words that you don't like so that they appear as problems.

## Commands

- **Spell Check: Add to user dictionary**
  - Add a custom word to my dictionary.
  - spell-check.addToUserDictionary
- **Spell Check: Forget word**
  - Forget a word so that it's no longer valid by any means.
  - spell-check.removeFromUserDictionary
- **Spell Check: Export user dictionary**
  - Export my words to a new and untitled document.
  - spell-check.exportUserDictionary
- **Spell Check: Import user dictionary (append)**
  - Import my words from the active document to my dictionary.
  - spell-check.importUserDictionary
- **Spell Check: List unknown words in the document**
  - Show a menu with the unknown words in the current file.
  - spell-check.commands.listUnknownWords
- **Spell Check: List custom words saved by you**
  - Show my saved words in a menu for possible deletion.
  - spell-check.commands.listCustomWords
- **Spell Check: List forgotten words**
  - Show words that have been intentionally removed and forgotten.
  - spell-check.commands.listForgottenWords