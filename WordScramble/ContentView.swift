//
//  ContentView.swift
//  WordScramble
//
//  Created by Shreemit on 16/03/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMsg = ""
    @State private var showingError = false
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }

                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
			.navigationTitle(rootWord)
			.onSubmit(addNewWord)
			.onAppear(perform: startGame)
			.alert(errorTitle, isPresented: $showingError) {
				Button("OK", role: .cancel) { }
			} message: {
				Text(errorMsg)
			}
        }
    }

    func addNewWord() {
        let ans = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard ans.count > 0 else { return }

        guard isOriginal(word: ans) else {
            wordError(title: "Word used already", msg: "Be more original")
            return
        }

        guard isPossible(word: ans) else {
            wordError(title: "Word not possible", msg: "You can't spell that word from \(rootWord)!")
            return
        }

        guard isReal(word: ans) else {
            wordError(title: "Word not recognize", msg: "You can't just make them up, you know!")
            return
        }

        withAnimation {
            usedWords.insert(ans, at: 0)
        }
        newWord = ""
    }

    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "hello"
                return
            }
        }
        fatalError("Could not load start.txt")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var temp = rootWord
        for letter in word {
            if let pos = temp.firstIndex(of: letter) {
                temp.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, msg: String) {
        errorTitle = title
        errorMsg = msg
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
