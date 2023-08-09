import AnytypeCore

protocol PhraseTextValidatorProtocol {
    func validated(prevText: String, text : String) -> String
}

struct PhraseTextValidator: PhraseTextValidatorProtocol {
    
    private enum Constants {
        static let maxWordsCount = 12
        static let maxCharactersPerWordCount = 8
        static let maxCharactersCount = 150
    }
    
    func validated(prevText: String, text : String) -> String {
        let textWithoutNewlines = text.trimmingCharacters(in: .newlines)
        
        guard FeatureFlags.validateRecoveryPhrase else { return textWithoutNewlines }
        
        let whitespacesTextCount = textWithoutNewlines.filter { $0 == " " }.count
        let whitespacesPrevTextCount = prevText.filter { $0 == " " }.count
        
        // if any whitespaces are added / deleted or maxCharactersCount exceeded - we should validate
        guard whitespacesTextCount != whitespacesPrevTextCount ||
                text.count > Constants.maxCharactersCount else {
            return textWithoutNewlines
        }
        
        let rawComponents = textWithoutNewlines.components(separatedBy: .whitespaces)
        
        var suffix = ""
        if rawComponents.count > 1 && (rawComponents.last?.isEmpty ?? false) {
            suffix = " "
        }
        
        let rawWords = rawComponents.filter { $0.isNotEmpty }
        let words = rawWords.prefix(Constants.maxWordsCount).map { word in
            if word.count > Constants.maxCharactersPerWordCount {
                return String(word.prefix(Constants.maxCharactersPerWordCount))
            } else {
                return word
            }
        }
        
        return words.joined(separator: " ") + suffix
    }
    
}

