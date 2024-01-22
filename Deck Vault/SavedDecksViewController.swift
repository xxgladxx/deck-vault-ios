import UIKit

class SavedDecksViewController: UIViewController, CardImagesDelegate {
    // ... rest of your code ...

    private var duelModeSwitch: UISwitch!
    private var isDuelModeOn: Bool = false
    
    private var savedDuels: [[String: Any]] = []
    
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()

    var savedDecks: [[String: Any]] = [] {
        didSet {
            updateSavedDecks()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigateToCardImagesViewController()
    }

    func navigateToCardImagesViewController() {
        let cardImagesVC = CardImagesViewController()
        cardImagesVC.delegate = self
        // ... additional setup code or navigation code
    }

    // ... rest of your code ...

    func deckSaved(deck: [String: Any]) {
        // Update your savedDecks array and refresh UI
        savedDecks.append(deck)
        updateSavedDecks()
        print("Deck saved: \(deck)")
    }
    func getSavedDecksURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("saved_decks.json")
    }
    @objc func deleteButtonTapped2() {
        // Clear the saved decks and update UI
        print("DEL TAPPED")
        savedDecks = []
        updateSavedDecks()
        // Clear the content of saved_decks.json
        if let url = getSavedDecksURL() {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
    }
    func loadSavedDuels() {
        if let url = getSavedDuelsURL(),
           let data = try? Data(contentsOf: url),
           let duels = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            savedDuels = duels
            print(savedDuels)
        }
    }

    func getSavedDuelsURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("saved_duels.json")
    }
    @objc private func duelModeSwitchChanged() {
        isDuelModeOn = duelModeSwitch.isOn
        updateSavedDecks()
    }
    
    func loadSavedDecks() {
        if let url = getSavedDecksURL(),
           let data = try? Data(contentsOf: url),
           let decks = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            savedDecks = decks
        }
    }
    
    func setupUI() {
        let backgroundImage = UIImageView(image: UIImage(named: "home.png"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        // Add a delete button at the top
        let deleteButtonContainer = UIView()
        deleteButtonContainer.backgroundColor = .clear
        deleteButtonContainer.layer.cornerRadius = 8.0
        deleteButtonContainer.layer.masksToBounds = true

        view.addSubview(deleteButtonContainer)
        deleteButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        // Adjust the constraints for deleteButtonContainer to take up full width
        NSLayoutConstraint.activate([
            deleteButtonContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            deleteButtonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            deleteButtonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            deleteButtonContainer.widthAnchor.constraint(equalToConstant: 40),
            deleteButtonContainer.heightAnchor.constraint(equalToConstant: 40),
        ])


        let appIconImageView = UIImageView(image: UIImage(named: "logo-circle"))
        appIconImageView.contentMode = .scaleAspectFit
        deleteButtonContainer.addSubview(appIconImageView)

        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appIconImageView.centerXAnchor.constraint(equalTo: deleteButtonContainer.centerXAnchor),
            appIconImageView.centerYAnchor.constraint(equalTo: deleteButtonContainer.centerYAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: 40),
            appIconImageView.heightAnchor.constraint(equalToConstant: 40),
        ])

        // Existing code...

        // Add Duel Mode switch
        duelModeSwitch = UISwitch()
        duelModeSwitch.isOn = false
        duelModeSwitch.addTarget(self, action: #selector(duelModeSwitchChanged), for: .valueChanged)
        deleteButtonContainer.addSubview(duelModeSwitch)
        duelModeSwitch.translatesAutoresizingMaskIntoConstraints = false

        let duelModeLabel = UILabel()
        duelModeLabel.text = "Duel"
        duelModeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        duelModeLabel.textColor = .white
        deleteButtonContainer.addSubview(duelModeLabel)
        duelModeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            duelModeSwitch.leadingAnchor.constraint(equalTo: deleteButtonContainer.leadingAnchor, constant: 8),
            duelModeSwitch.centerYAnchor.constraint(equalTo: deleteButtonContainer.centerYAnchor),

            duelModeLabel.leadingAnchor.constraint(equalTo: duelModeSwitch.trailingAnchor, constant: 8),
            duelModeLabel.centerYAnchor.constraint(equalTo: duelModeSwitch.centerYAnchor),
        ])

        // Remaining code...

        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: deleteButtonContainer.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        loadSavedDecks()
        loadSavedDuels()
        updateSavedDecks()
    }

    @objc func longPressCopyButton(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // Long press detected
            if let copyButton = sender.view as? UIButton {
                let index = copyButton.tag
                guard index < savedDecks.count else {
                    return
                }

                // Change the copy button to a delete button
                copyButton.setImage(UIImage(systemName: "trash"), for: .normal)
                copyButton.removeTarget(self, action: #selector(copyButtonTapped(sender:)), for: .touchUpInside)
                copyButton.addTarget(self, action: #selector(deleteButtonTapped(sender:)), for: .touchUpInside)
            }
        }
    }
    @objc func deleteButtonTapped(sender: UIButton) {
        let index = sender.tag
        guard index < savedDecks.count else {
            return
        }

        // Remove the deck from the array
        savedDecks.remove(at: index)

        // Update UI
        updateSavedDecks()

        // Save the updated array to saved_decks.json
        saveDecksToFile()
    }
    
    // Save decks to saved_decks.json
    private func saveDecksToFile() {
        let decks = savedDecks
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
    func updateSavedDecks() {
        // Remove existing deck views
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        let deck = Deck()
        // Add new deck views
        //print(savedDuels)
        // Add new deck views
        if isDuelModeOn {
            for (index, duelData) in savedDuels.enumerated() {
                if let deckLinks = duelData["deck_links"] as? [String],
                   let cardsArray = duelData["cards"] as? [[String]] {
                    var x = 0
                    for (deckIndex, cards) in cardsArray.enumerated() {
                        let deckView = createDeckView(cards: cards)
                        scrollView.addSubview(deckView)
                        
                        print(cards)
                        
                        // Set constraints for each deck view
                        deckView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            deckView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: CGFloat(index * 480 + deckIndex * 120 + 20)),
                            deckView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                            deckView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
                            deckView.heightAnchor.constraint(equalToConstant: 100),
                        ])
                        
                        // Create a container view below the deck view
                        let containerView = UIView()
                        containerView.backgroundColor = .clear
                        scrollView.addSubview(containerView)
                        
                        // Set constraints for the container view
                        containerView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            containerView.topAnchor.constraint(equalTo: deckView.bottomAnchor, constant: -20),
                            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
                            containerView.heightAnchor.constraint(equalToConstant: 40),
                        ])
                        
                        // Calculate average elixir and 4-card cycle elixir
                        let avgElixir = deck.calculateDeckElixir(cardKeys: cards)
                        let fourCardCycleElixir = deck.calculateFourCardCycleElixir(cardKeys: cards)
                        
                        // Add average elixir icon and label
                        let avgElixirIcon = UIImageView(image: UIImage(named: "elixir.png"))
                        let avgElixirLabel = UILabel()
                        avgElixirLabel.text = String(avgElixir)
                        avgElixirLabel.textColor = .white
                        
                        // Add 4-card cycle elixir icon and label
                        let cycleElixirIcon = UIImageView(image: UIImage(named: "elixir-cycle.png"))
                        let cycleElixirLabel = UILabel()
                        cycleElixirLabel.text = String(fourCardCycleElixir)
                        cycleElixirLabel.textColor = .white
                        
                        // Add copy button
                        let copyButton = UIButton(type: .system)
                        copyButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
                        copyButton.tintColor = .white
                        copyButton.addTarget(self, action: #selector(copyButtonTapped(sender:)), for: .touchUpInside)
                        copyButton.tag = index * 4 + deckIndex // Set a tag to identify which deck's link to copy
                        
                        // Add a long press gesture recognizer to the copy button
                        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCopyButton(sender:)))
                        copyButton.addGestureRecognizer(longPressGesture)
                        
                        // Add a grey line at the bottom
                        let bottomLine = UIView()
                        bottomLine.backgroundColor = .white
                        bottomLine.layer.shadowColor = UIColor.purple.cgColor
                        bottomLine.layer.shadowOpacity = 1.0
                        bottomLine.layer.shadowRadius = 10.0
                        bottomLine.layer.shadowOffset = CGSize(width: 0, height: 0)
                        bottomLine.layer.masksToBounds = false
                        bottomLine.layer.shadowPath = UIBezierPath(rect: bottomLine.bounds).cgPath
                        
                        // Add all components to containerView
                        containerView.addSubview(avgElixirIcon)
                        containerView.addSubview(avgElixirLabel)
                        containerView.addSubview(cycleElixirIcon)
                        containerView.addSubview(cycleElixirLabel)
                        containerView.addSubview(copyButton)

                        // Set constraints for the components within the container view
                        avgElixirIcon.translatesAutoresizingMaskIntoConstraints = false
                        avgElixirLabel.translatesAutoresizingMaskIntoConstraints = false
                        cycleElixirIcon.translatesAutoresizingMaskIntoConstraints = false
                        cycleElixirLabel.translatesAutoresizingMaskIntoConstraints = false
                        copyButton.translatesAutoresizingMaskIntoConstraints = false
                        bottomLine.translatesAutoresizingMaskIntoConstraints = false
                        
                        let iconSize: CGFloat = 20  // Adjust the icon size as needed
                        let lineThickness: CGFloat = 4.5  // Adjust the line thickness as needed
                        
                        NSLayoutConstraint.activate([
                            avgElixirIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                            avgElixirIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                            avgElixirIcon.widthAnchor.constraint(equalToConstant: iconSize),
                            avgElixirIcon.heightAnchor.constraint(equalToConstant: iconSize),
                            
                            avgElixirLabel.leadingAnchor.constraint(equalTo: avgElixirIcon.trailingAnchor, constant: 4),
                            avgElixirLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                            
                            // Adjust the position of the cycleElixirIcon and cycleElixirLabel
                            cycleElixirIcon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -8), // Move slightly left
                            cycleElixirIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                            cycleElixirIcon.widthAnchor.constraint(equalToConstant: iconSize),
                            cycleElixirIcon.heightAnchor.constraint(equalToConstant: iconSize),
                            
                            cycleElixirLabel.leadingAnchor.constraint(equalTo: cycleElixirIcon.trailingAnchor, constant: 4), // Move slightly right
                            cycleElixirLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                            
                            copyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                            copyButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                            copyButton.widthAnchor.constraint(equalToConstant: iconSize + 5), // Increase the size of the copy icon
                            copyButton.heightAnchor.constraint(equalToConstant: iconSize + 5), // Increase the size of the copy icon
                            

                        ])
                        if x==3{
                            containerView.addSubview(bottomLine)
                            NSLayoutConstraint.activate([
                            bottomLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                            bottomLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                            bottomLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                            bottomLine.heightAnchor.constraint(equalToConstant: lineThickness),
                            ])
                        }
                        x = x+1
                    }
                }
            }
            let duelHeight = 140  // Adjust as needed for the total height of each duel and spacing
            let totalDuelHeight = CGFloat(savedDuels.count * 4) * CGFloat(duelHeight)
            print(totalDuelHeight)
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: totalDuelHeight + 20)


        }


        else{
            for (index, deckData) in savedDecks.enumerated() {
                if let cards = deckData["cards"] as? [String] {
                    let deckView = createDeckView(cards: cards)
                    scrollView.addSubview(deckView)
                    
                    // Set constraints for each deck view
                    deckView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        deckView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: CGFloat(index * 120 + 20)),
                        deckView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                        deckView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
                        deckView.heightAnchor.constraint(equalToConstant: 100),
                    ])
                    
                    // Create a container view below the deck view
                    let containerView = UIView()
                    containerView.backgroundColor = .clear
                    scrollView.addSubview(containerView)
                    
                    // Set constraints for the container view
                    containerView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        containerView.topAnchor.constraint(equalTo: deckView.bottomAnchor, constant: -20),
                        containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                        containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
                        containerView.heightAnchor.constraint(equalToConstant: 40),
                    ])
                    
                    // Calculate average elixir and 4-card cycle elixir
                    let avgElixir = deck.calculateDeckElixir(cardKeys: cards)
                    let fourCardCycleElixir = deck.calculateFourCardCycleElixir(cardKeys: cards)
                    // Add average elixir icon and label
                    let avgElixirIcon = UIImageView(image: UIImage(named: "elixir.png"))
                    let avgElixirLabel = UILabel()
                    avgElixirLabel.text = String(avgElixir)
                    avgElixirLabel.textColor = .white
                    
                    // Add 4-card cycle elixir icon and label
                    let cycleElixirIcon = UIImageView(image: UIImage(named: "elixir-cycle.png"))
                    let cycleElixirLabel = UILabel()
                    cycleElixirLabel.text = String(fourCardCycleElixir)
                    cycleElixirLabel.textColor = .white
                    
                    // Add copy button
                    let copyButton = UIButton(type: .system)
                    copyButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
                    copyButton.tintColor = .white
                    copyButton.addTarget(self, action: #selector(copyButtonTapped(sender:)), for: .touchUpInside)
                    copyButton.tag = index // Set a tag to identify which deck's link to copy
                    // Add a long press gesture recognizer to the copy button
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCopyButton(sender:)))
                    copyButton.addGestureRecognizer(longPressGesture)
                    
                    // Add a grey line at the bottom
                    let bottomLine = UIView()
                    bottomLine.backgroundColor = .gray
                    bottomLine.layer.shadowColor = UIColor.purple.cgColor
                    bottomLine.layer.shadowOpacity = 1.0
                    bottomLine.layer.shadowRadius = 10.0
                    bottomLine.layer.shadowOffset = CGSize(width: 0, height: 0)
                    bottomLine.layer.masksToBounds = false
                    bottomLine.layer.shadowPath = UIBezierPath(rect: bottomLine.bounds).cgPath
                    
                    // Add all components to containerView
                    containerView.addSubview(avgElixirIcon)
                    containerView.addSubview(avgElixirLabel)
                    containerView.addSubview(cycleElixirIcon)
                    containerView.addSubview(cycleElixirLabel)
                    containerView.addSubview(copyButton)
                    containerView.addSubview(bottomLine)
                    
                    // Set constraints for the components within the container view
                    avgElixirIcon.translatesAutoresizingMaskIntoConstraints = false
                    avgElixirLabel.translatesAutoresizingMaskIntoConstraints = false
                    cycleElixirIcon.translatesAutoresizingMaskIntoConstraints = false
                    cycleElixirLabel.translatesAutoresizingMaskIntoConstraints = false
                    copyButton.translatesAutoresizingMaskIntoConstraints = false
                    bottomLine.translatesAutoresizingMaskIntoConstraints = false
                    
                    let iconSize: CGFloat = 20  // Adjust the icon size as needed
                    let lineThickness: CGFloat = 0.5  // Adjust the line thickness as needed
                    
                    NSLayoutConstraint.activate([
                        avgElixirIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                        avgElixirIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        avgElixirIcon.widthAnchor.constraint(equalToConstant: iconSize),
                        avgElixirIcon.heightAnchor.constraint(equalToConstant: iconSize),
                        
                        avgElixirLabel.leadingAnchor.constraint(equalTo: avgElixirIcon.trailingAnchor, constant: 4),
                        avgElixirLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        
                        // Adjust the position of the cycleElixirIcon and cycleElixirLabel
                        cycleElixirIcon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -8), // Move slightly left
                        cycleElixirIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        cycleElixirIcon.widthAnchor.constraint(equalToConstant: iconSize),
                        cycleElixirIcon.heightAnchor.constraint(equalToConstant: iconSize),
                        
                        cycleElixirLabel.leadingAnchor.constraint(equalTo: cycleElixirIcon.trailingAnchor, constant: 4), // Move slightly right
                        cycleElixirLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        
                        copyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                        copyButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        copyButton.widthAnchor.constraint(equalToConstant: iconSize + 5), // Increase the size of the copy icon
                        copyButton.heightAnchor.constraint(equalToConstant: iconSize + 5), // Increase the size of the copy icon
                        
                        bottomLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                        bottomLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                        bottomLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                        bottomLine.heightAnchor.constraint(equalToConstant: lineThickness),
                    ])
                }
            }
        // Update content size of the scrollView
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: CGFloat(savedDecks.count * 120 + 20))
        }
    }
        


    @objc func copyButtonTapped(sender: UIButton) {
        let index = sender.tag
        guard index < savedDecks.count, let deckLink = savedDecks[index]["deck_link"] as? String else {
            return
        }

        // Open the associated deck link
        if let url = URL(string: deckLink) {
            UIApplication.shared.open(url)
        }
    }


    func createDeckView(cards: [String]) -> UIView {
        let deckView = UIView()
        deckView.backgroundColor = .clear
        let deck = Deck()

        // Add an inset shadow
        let shadowLayer = CALayer()
        shadowLayer.frame = deckView.bounds
        shadowLayer.cornerRadius = deckView.layer.cornerRadius
        shadowLayer.masksToBounds = false
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 4.0
        shadowLayer.shadowPath = UIBezierPath(roundedRect: deckView.bounds, cornerRadius: deckView.layer.cornerRadius).cgPath
        deckView.layer.addSublayer(shadowLayer)

        // Create a stack view to hold card image views
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        deckView.addSubview(stackView)

        // Set constraints for the stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: deckView.leadingAnchor, constant: 8),
            stackView.topAnchor.constraint(equalTo: deckView.topAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: deckView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: deckView.bottomAnchor, constant: -8),
        ])

        // Add card image views to the stack view
        for (index, cardKey) in cards.enumerated() {
            let cardImageView = UIImageView()

            // Check if the card has available evolutions
            if index == 0, let cardId = deck.cardKeyToId(key: cardKey), deck.availableEvos.contains(cardKey) {
                // Append the evolution number to the image name
                let evoNumber = 1  // You may need to retrieve the correct evolution number based on your data
                let evoImageName = "\(cardKey)-ev\(evoNumber).png"
                cardImageView.image = UIImage(named: "cards/\(evoImageName)")
            } else {
                // Use the default image name
                cardImageView.image = UIImage(named: "cards/\(cardKey).png")
            }

            cardImageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(cardImageView)
        }
        return deckView
    }
    
}
