import UIKit

protocol CardImagesDelegate: AnyObject {
    func deckSaved(deck: [String: Any])
}
protocol DeleteSortingViewDelegate: AnyObject {
    func sortButtonTapped()
}

class DeleteSortingView: UIView {
    weak var delegate: DeleteSortingViewDelegate?
    let sortButton: UIButton = {
        let button = UIButton()
        // Add any setup for the sort button
        return button
    }()
    let sortLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.0)
        return label
    }()
    let sortIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.up.arrow.down"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    let deleteButton: UIButton = {
        let button = UIButton()
        // Add any setup for the delete button
        return button
    }()

    let deleteIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "trash"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()


    
    var deleteAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func updateSortLabel(with criteria: String) {
        sortLabel.text = "By \(criteria.capitalized)"
    }

    private func setupUI() {

        
        addSubview(sortButton)
        sortButton.addSubview(sortIcon)

        addSubview(deleteButton)
        deleteButton.addSubview(deleteIcon)

        sortButton.translatesAutoresizingMaskIntoConstraints = false
        sortIcon.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sortIcon.leadingAnchor.constraint(equalTo: sortButton.leadingAnchor, constant: 16),
            sortIcon.centerYAnchor.constraint(equalTo: sortButton.centerYAnchor),

            sortButton.topAnchor.constraint(equalTo: topAnchor),
            sortButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            sortButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            sortButton.trailingAnchor.constraint(equalTo: centerXAnchor),

            deleteIcon.trailingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: -16),
            deleteIcon.centerYAnchor.constraint(equalTo: deleteButton.centerYAnchor),

            deleteButton.topAnchor.constraint(equalTo: topAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: centerXAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        addSubview(sortLabel)
        sortLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sortLabel.leadingAnchor.constraint(equalTo: sortIcon.trailingAnchor, constant: 8),
            sortLabel.centerYAnchor.constraint(equalTo: sortButton.centerYAnchor),
        ])
        
        // Set clear background color for the entire view
        backgroundColor = .clear
        let shadowLayer = CALayer()
        shadowLayer.frame = bounds
        shadowLayer.cornerRadius = layer.cornerRadius
        shadowLayer.masksToBounds = false
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 4.0
        shadowLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.addSublayer(shadowLayer)
        

        
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        addBottomGlow()
    }

    private func addBottomGlow() {
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.white.cgColor
        borderLayer.frame = CGRect(x: 0, y: bounds.height - 2, width: bounds.width, height: 2)
        borderLayer.borderWidth = 2.0 // Set the desired border width
        borderLayer.borderColor = UIColor.white.cgColor // Set the desired border color
        layer.addSublayer(borderLayer)
    }


    
    @objc private func sortButtonTapped() {
        // Handle sort button tap
        print("Sort Button Tapped")
        delegate?.sortButtonTapped()
    }


    @objc private func deleteButtonTapped() {
        deleteAction?()
        print("Delete Button Tapped")
    }
}

class CardImagesViewController: UIViewController, DeleteSortingViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteSortingView.delegate = self
        title = "Card Images"
        setupUI()
        sortCards()
    }
    let deck = Deck()
    var currentSortingCriteria = "elixir"
    var selectedChampion: String?
    @objc internal func sortButtonTapped() {
        // Toggle between sorting criteria and sort the cards
        currentSortingCriteria = (currentSortingCriteria == "elixir") ? "rarity" : "elixir"
        sortCards()

        // Update the label text
        deleteSortingView.updateSortLabel(with: currentSortingCriteria)
    }


    
    var sortedCardKeys: [String] = [] {
        didSet {
            updateCardSelection()
        }
    }

    // ... existing code ...

    private func sortCards() {
        //deck.updateCardInformation()
        deck.loadCards()
        let sortedKeys: [String]

        switch currentSortingCriteria {
        case "elixir":
            sortedKeys = deck.cards.sorted { $0.elixir < $1.elixir }.map { $0.key }
        case "rarity":
            // Assuming rarity values are in the order: "Common", "Rare", "Epic", "Legendary"
            let rarityOrder: [String] = ["Common", "Rare", "Epic", "Legendary", "Champion"]
            sortedKeys = deck.cards.sorted {
                guard let index1 = rarityOrder.firstIndex(of: $0.rarity),
                      let index2 = rarityOrder.firstIndex(of: $1.rarity) else {
                    return false
                }
                return index1 < index2
            }.map { $0.key }
        default:
            // Default case, in case unexpected sorting criteria is provided
            sortedKeys = []
        }

        sortedCardKeys = sortedKeys
        updateCardSelection()
        deleteSortingView.updateSortLabel(with: currentSortingCriteria)
    }


    
    var selectedCardOrder: [String] = Array(repeating: "ucard", count: 8) {
        didSet {
            updateSelectedCardsView()
            updateCardSelection()
        }
    }

    lazy var cardImagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardImageCollectionViewCell.self, forCellWithReuseIdentifier: "CardImageCell")
        return collectionView
    }()

    lazy var selectedCardsView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12.0
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2.5
        view.layer.borderColor = UIColor.clear.cgColor
        
        // Add an inset shadow
        let shadowLayer = CALayer()
        shadowLayer.frame = view.bounds
        shadowLayer.cornerRadius = view.layer.cornerRadius
        shadowLayer.masksToBounds = false
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 4.0
        shadowLayer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
        view.layer.addSublayer(shadowLayer)
        
        return view
    }()

    lazy var deleteSortingView: DeleteSortingView = {
        let view = DeleteSortingView()
        view.isUserInteractionEnabled = true
        view.deleteAction = { [weak self] in
            self?.deleteSelectedCards()
        }
        return view
    }()
    
    lazy var centerButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "button.png"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        return button
    }()
    weak var delegate: CardImagesDelegate?
        



    func setupUI() {

            let backgroundImage = UIImageView(image: UIImage(named: "home.png"))
            backgroundImage.contentMode = .scaleAspectFill
            backgroundImage.frame = view.bounds
            view.addSubview(backgroundImage)
            view.sendSubviewToBack(backgroundImage)

        cardImagesCollectionView.backgroundColor = .clear
        view.addSubview(cardImagesCollectionView)
        cardImagesCollectionView.translatesAutoresizingMaskIntoConstraints = false

        selectedCardsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedCardsView)

        deleteSortingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteSortingView)

        centerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerButton)
        centerButton.addTarget(self, action: #selector(saveDeckButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Card Images Collection View
            // Card Images Collection View
            cardImagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 180),

            cardImagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardImagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardImagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Selected Cards View
            selectedCardsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            selectedCardsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            selectedCardsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            selectedCardsView.heightAnchor.constraint(equalToConstant: 100),

            // Delete Sorting View
            deleteSortingView.topAnchor.constraint(equalTo: selectedCardsView.bottomAnchor, constant: 8),
            deleteSortingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            deleteSortingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            deleteSortingView.heightAnchor.constraint(equalToConstant: 40),

            // Center Button
            centerButton.centerXAnchor.constraint(equalTo: deleteSortingView.centerXAnchor),
            centerButton.centerYAnchor.constraint(equalTo: deleteSortingView.centerYAnchor),
            centerButton.widthAnchor.constraint(equalToConstant: 120),
            centerButton.heightAnchor.constraint(equalToConstant: 60),
            
        ])
        updateSelectedCardsView()
    }


    private func updateButtonVisibility() {
        centerButton.isEnabled = selectedCardOrder.filter { $0 != "ucard" }.count == 8
    }
    @objc func deleteSelectedCards() {
        selectedCardOrder = Array(repeating: "ucard", count: 8)
        updateSelectedCardsView()
        
    }

    @objc func doneButtonTapped() {
        print("8 Cards Done")
    }

    @objc func saveDeckButtonTapped() {
        // Get the selected card keys
        let selectedCardKeys = selectedCardOrder.filter { $0 != "ucard" }

        // Check if there are exactly 8 cards selected
        guard selectedCardKeys.count == 8 else {
            print("Please select exactly 8 cards.")
            return
        }

        // Generate the deck link
        let deckLink = deck.cardsToDecklink(cards: selectedCardKeys)

        // Create a new deck dictionary
        let newDeck: [String: Any] = [
            "deck_link": deckLink,
            "cards": selectedCardKeys
        ]

        // Load existing decks from saved_decks.json
        var existingDecks = loadSavedDecks()

        // Append the new deck to the existing decks array
        existingDecks.append(newDeck)

        // Save the updated decks array to saved_decks.json
        saveDecks(existingDecks)

        // Notify the delegate about the saved deck
        delegate?.deckSaved(deck: newDeck)
        print(newDeck)

        // Show a popup indicating that the deck is saved successfully
        showDeckSavedPopup()

        // Clear the selected cards
        selectedCardOrder = Array(repeating: "ucard", count: 8)
        updateSelectedCardsView()
    }

    private func showDeckSavedPopup() {
        let alertController = UIAlertController(
            title: "Deck Saved",
            message: "Your deck has been saved successfully.",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }





    // Load existing decks from saved_decks.json
    private func loadSavedDecks() -> [[String: Any]] {
        if let url = getSavedDecksURL(),
           let data = try? Data(contentsOf: url),
           let decks = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            return decks
        } else {
            return []
        }
    }

    // Save decks to saved_decks.json
    private func saveDecks(_ decks: [[String: Any]]) {
        if let url = getSavedDecksURL(),
           let data = try? JSONSerialization.data(withJSONObject: decks, options: .prettyPrinted) {
            do {
                try data.write(to: url)
                print("Decks saved successfully.")
            } catch {
                print("Error saving decks: \(error)")
            }
        }
    }


    // Get the file URL for saved_decks.json
    private func getSavedDecksURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("saved_decks.json")
    }

    private func updateSelectedCardsView() {
        selectedCardsView.subviews.forEach { $0.removeFromSuperview() }
        updateButtonVisibility()
        for (index, cardKey) in selectedCardOrder.enumerated() {
            let imageView = UIImageView()

            // Check if the card has available evolutions
            if index == 0, let cardId = deck.cardKeyToId(key: cardKey), deck.availableEvos.contains(cardKey) {
                // Append the evolution number to the image name
                let evoNumber = 1  // You may need to retrieve the correct evolution number based on your data
                let evoImageName = "\(cardKey)-ev\(evoNumber).png"
                imageView.image = UIImage(named: "cards/\(evoImageName)")
            } else {
                // Use the default image name
                imageView.image = UIImage(named: "cards/\(cardKey).png")
            }

            imageView.contentMode = .scaleAspectFit
            selectedCardsView.addSubview(imageView)
        }

        let stackView = UIStackView(arrangedSubviews: selectedCardsView.subviews)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 4.0

        selectedCardsView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: selectedCardsView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: selectedCardsView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: selectedCardsView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: selectedCardsView.bottomAnchor),
        ])
    }


    private func updateCardSelection() {
        cardImagesCollectionView.reloadData()
    }
    
    
}

extension CardImagesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedCardKeys.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardImageCell", for: indexPath) as! CardImageCollectionViewCell
        let cardKey = sortedCardKeys[indexPath.item]
        let isSelected = selectedCardOrder.contains(cardKey)
        cell.configure(with: UIImage(named: "cards/\(cardKey).png"), isSelected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let cellWidth = (collectionViewWidth - 32.0) / 5.0
        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cardKey = sortedCardKeys[indexPath.item]
        print(cardKey)

        // Check if the selected card is a Champion
        let isChampion = deck.cards.first { $0.key == cardKey }?.rarity == "Champion"

        // Check if the selected card is already in the selected cards
        let isCardSelected = selectedCardOrder.contains(cardKey)

        // Check if a Champion is already selected
        let isChampionAlreadySelected = selectedCardOrder.contains { key in
            key != "ucard" && deck.cards.first { $0.key == key }?.rarity == "Champion"
        }

        // If the selected card is a Champion and is already selected, deselect it
        if isChampion && isCardSelected && isChampionAlreadySelected {
            if let index = selectedCardOrder.firstIndex(of: cardKey) {
                selectedCardOrder[index] = "ucard"
            }
        } else if isChampion && selectedCardOrder.contains(where: { $0 != "ucard" && $0 == cardKey }) {
            // If the selected card is a Champion and is already in the selected cards, deselect it
            if let index = selectedCardOrder.firstIndex(of: cardKey) {
                selectedCardOrder[index] = "ucard"
            }
        } else if isChampion && isChampionAlreadySelected {
            // If a Champion is already selected and a different Champion is clicked, show an alert
            showChampionSelectionAlert()
        } else {
            // Your existing logic for selecting/deselecting cards
            if isCardSelected {
                if let index = selectedCardOrder.firstIndex(of: cardKey) {
                    selectedCardOrder[index] = "ucard"
                }
            } else {
                if let index = selectedCardOrder.firstIndex(of: "ucard") {
                    selectedCardOrder[index] = cardKey
                }
            }
        }

        // Update the selected cards view
        updateSelectedCardsView()
    }



    private func selectCard(_ cardKey: String) {
        // Your existing logic for selecting/deselecting cards
        if selectedCardOrder.contains(cardKey) {
            if let index = selectedCardOrder.firstIndex(of: cardKey) {
                selectedCardOrder[index] = "ucard"
            }
        } else {
            if let index = selectedCardOrder.firstIndex(of: "ucard") {
                selectedCardOrder[index] = cardKey
            }
        }

        // Update the selected cards view
        updateSelectedCardsView()
    }

    private func showChampionSelectionAlert() {
        let alertController = UIAlertController(
            title: "Champion Selection",
            message: "Only one Champion card can be selected at a time.",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }


}
