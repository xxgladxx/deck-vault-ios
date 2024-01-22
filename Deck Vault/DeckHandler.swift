import Foundation

struct Card: Codable {
    let name: String
    let id: Int
    let key: String
    let elixir: Int
    let rarity: String
}

class Deck {
    var cards: [Card] = []
    let card_w = 302
    let card_h = 363
    let card_ratio: Double
    let card_thumb_scale = 0.5
    let card_thumb_w: Int
    let card_thumb_h: Int
    let availableEvos = [ "skeletons", "knight", "firecracker", "mortar", "barbarians", "royal-recruits", "bats", "royal-giant", "archers", "ice-spirit", "valkyrie"]
    
    init() {
        card_ratio = Double(card_w) / Double(card_h)
        card_thumb_w = Int(Double(card_w) * card_thumb_scale)
        card_thumb_h = Int(Double(card_h) * card_thumb_scale)
        loadCards()
    }
    
    func loadCards() {
        if let url = Bundle.main.url(forResource: "cards", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase  // Handle snake_case keys
                let cardData = try decoder.decode([String: [Card]].self, from: data)
                cards = cardData["card_data"] ?? []
                print("JSON file loaded successfully")
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("Error loading JSON file")
        }
    }
    
    func decklinkToCards(from input: String) -> [String]? {
        guard let deckStartIndex = input.range(of: "deck=")?.upperBound else {
            return nil
        }
        
        let deckSubstring = input[deckStartIndex...]
        let components = deckSubstring.components(separatedBy: CharacterSet(charactersIn: ";&"))
        
        var extractedNumbers: [String] = []
        
        // Iterate through the components and add them to the array
        for component in components {
            // Filter out non-numeric characters
            let numbers = component.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
            // Add the filtered numbers to the array
            if !numbers.isEmpty {
                extractedNumbers.append(numbers)
            }
        }
        
        // Check if the array is not empty before returning
        return extractedNumbers.isEmpty ? nil : extractedNumbers
    }
    
    
    var validCardKeys: [String] {
        return cards.map { $0.key }
    }
    
    func cardIdToKey(cardId: Int) -> String? {
        return cards.first { $0.id == cardId }?.key
    }
    
    func cardKeyToId(key: String) -> Int? {
        return cards.first { $0.key == key }?.id
    }
    
    
    
    func cardsIDToDecklink(cards: [String]) -> String {
        let cardIds = cards
        let deckLink = cardIds.map { String($0) }.joined(separator: ";")
        return "clashroyale://copyDeck?deck=\(deckLink)"
    }
    
    func cardsToDecklink(cards: [String]) -> String {
        let cardIds = cards.compactMap { cardKeyToId(key: $0) }
        let deckLink = cardIds.map { String($0) }.joined(separator: ";")
        return "clashroyale://copyDeck?deck=\(deckLink)"
    }
    
    func calculateDeckElixir(cardKeys: [String]) -> String {
        let totalElixir = cardKeys.compactMap { key in
            cards.first { $0.key == key }?.elixir
        }.reduce(0, +)
        
        let cardCount = cardKeys.count
        let averageElixir = cardCount > 0 ? Double(totalElixir) / Double(cardCount) : 0.0
        
        
        return String(format: "%.1f", averageElixir)
    }
    
    func calculateFourCardCycleElixir(cardKeys: [String]) -> Int {
        let sortedElixirs = cardKeys.compactMap { key in
            cards.first { $0.key == key }?.elixir
        }.sorted()
        
        let fourCardCycleElixir = sortedElixirs.prefix(4).reduce(0, +)
        return fourCardCycleElixir
    }
    func newdecklinkToCards(from input: String) -> [String]? {
        guard let deckStartIndex = input.range(of: "deck=")?.upperBound else {
            return nil
        }
        
        let deckSubstring = input[deckStartIndex...]
        let components = deckSubstring.components(separatedBy: ";")

        // Filter out non-numeric characters and remove empty components
        let extractedNumbers = components.compactMap { component in
            let numbers = component.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return numbers.isEmpty ? nil : numbers
        }

        return extractedNumbers.isEmpty ? nil : extractedNumbers
    }

    private func stripDeckLink(input: String) -> String {
        // Strip the input to extract the URL
        if let startIndex = input.range(of: "https:") {
            let decklink = String(input[startIndex.lowerBound..<input.endIndex])
            
            // Find the position of "&" in the decklink
            if let ampersandIndex = decklink.firstIndex(of: "&") {
                // Extract the substring from the beginning up to "&"
                return String(decklink[..<ampersandIndex])
            }
            
            // Return the entire decklink if "&" is not found
            return decklink
        }
        
        // Return the input if "https:" is not found
        return input
    }
    
    func analyzeDecks(deckLinks: [String]) -> String {
        var decks: [[String]] = []
        
        for deckLink in deckLinks {
            let strippedDeckLink = stripDeckLink(input: deckLink)
            
            if let cardKeys = newdecklinkToCards(from: strippedDeckLink) {
                var keys = [String]()
                for cardKey in cardKeys {
                    if let cardId = Int(cardKey),
                       let cardName = cardIdToKey(cardId: cardId) {
                        keys.append(cardName)
                    }
                }
                decks.append(keys)
            } else {
                print("Invalid Deck Link:", deckLink)
                return "Invalid Deck Link"
            }
        }
        
        // Find common cards among decks
        var commonCards: [String: [Int]] = [:]
        
        for (index, deck) in decks.enumerated() {
            for cardKey in deck {
                if commonCards[cardKey] == nil {
                    commonCards[cardKey] = [index]
                } else {
                    commonCards[cardKey]?.append(index)
                }
            }
        }
        
        // Check for cards common in at least two decks
        let commonCardKeys = commonCards.filter { $0.value.count >= 2 }.keys
        
        if commonCardKeys.isEmpty {
            return "DUEL"
        } else {
            var resultString = ""
            
            for commonCardKey in commonCardKeys {
                if let cardName = cardKeyToName(key: commonCardKey) {
                    let deckIndexes = commonCards[commonCardKey]!
                    let deckNames = deckIndexes.map { "Deck \($0 + 1)" }.joined(separator: ", ")
                    resultString += "\(cardName): in \(deckNames)\n"
                } else {
                    let deckIndexes = commonCards[commonCardKey]!
                    let deckNames = deckIndexes.map { "Deck \($0 + 1)" }.joined(separator: ", ")
                    resultString += "\(commonCardKey): in \(deckNames)\n"
                }
            }
            
            return resultString
        }
    }

    func cardKeyToName(key: String) -> String? {
        return cards.first { $0.key == key }?.name
    }


}
