import UIKit

protocol AddInputDelegate: AnyObject {
    func didSaveInput(_ input: String)
}

class AddInputViewController: UIViewController, UITextFieldDelegate{
    weak var delegate: AddInputDelegate?
    var savedDecks: [[String: Any]] = []  // Declare savedDecks as an instance property
    private var duelModeSwitch: UISwitch!

    private var deckTextFields: [UITextField] = []
    private var inputTextField: UITextField!

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "button.png"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0
        button.isEnabled = false // Initially disable the save button
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    // Add this UITextFieldDelegate method to dismiss the keyboard when the "Return" key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // Add this method to dismiss the keyboard when tapping outside the text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImage = UIImageView(image: UIImage(named: "home.png"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        let deleteButtonContainer = UIView()
        deleteButtonContainer.backgroundColor = .clear
        deleteButtonContainer.layer.cornerRadius = 8.0
        deleteButtonContainer.layer.masksToBounds = true

        view.addSubview(deleteButtonContainer)
        deleteButtonContainer.translatesAutoresizingMaskIntoConstraints = false
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
        
        // Add deck link input field
        inputTextField = UITextField()
        inputTextField.placeholder = "Enter deck link"
        inputTextField.borderStyle = .roundedRect
        inputTextField.backgroundColor = UIColor.darkGray
        inputTextField.layer.cornerRadius = 8.0
        inputTextField.layer.masksToBounds = true
        inputTextField.textColor = .black
        inputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        view.addSubview(inputTextField)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        // Add "Save" button
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Center inputTextField horizontally and vertically
            inputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Place saveButton below inputTextField with some space
            saveButton.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 120),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    @objc private func duelModeSwitchChanged() {
         if duelModeSwitch.isOn {
             // Remove existing UI
             inputTextField.removeFromSuperview()
             saveButton.removeFromSuperview()

             // Add new input fields for Duel Mode
             for i in 1...4 {
                 let deckTextField = UITextField()
                 deckTextField.placeholder = "Enter deck \(i)"
                 deckTextField.borderStyle = .roundedRect
                 deckTextField.backgroundColor = UIColor.darkGray
                 deckTextField.layer.cornerRadius = 8.0
                 deckTextField.layer.masksToBounds = true
                 deckTextField.textColor = .black
                 deckTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                 deckTextField.translatesAutoresizingMaskIntoConstraints = false
                 deckTextField.delegate = self
                 view.addSubview(deckTextField)

                 deckTextFields.append(deckTextField)

                 NSLayoutConstraint.activate([
                     // Center deckTextField horizontally and add vertical spacing between them
                     deckTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                     deckTextField.topAnchor.constraint(equalTo: duelModeSwitch.bottomAnchor, constant: CGFloat(80 * i)),
                     deckTextField.widthAnchor.constraint(equalToConstant: 200),
                     deckTextField.heightAnchor.constraint(equalToConstant: 44),
                 ])
             }

             // Add "Save" button for Duel Mode
             view.addSubview(saveButton)
             saveButton.translatesAutoresizingMaskIntoConstraints = false

             NSLayoutConstraint.activate([
                 // Place saveButton below the last deckTextField with some space
                 saveButton.topAnchor.constraint(equalTo: deckTextFields.last!.bottomAnchor, constant: 20),
                 saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 saveButton.widthAnchor.constraint(equalToConstant: 120),
                 saveButton.heightAnchor.constraint(equalToConstant: 44),
             ])
         } else {
             // Restore original UI
             for deckTextField in deckTextFields {
                 deckTextField.removeFromSuperview()
             }
             deckTextFields.removeAll()

             view.addSubview(inputTextField)
             view.addSubview(saveButton)
             inputTextField.translatesAutoresizingMaskIntoConstraints = false
             saveButton.translatesAutoresizingMaskIntoConstraints = false

             NSLayoutConstraint.activate([
                 // Center inputTextField horizontally and vertically
                 inputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 inputTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                 // Place saveButton below inputTextField with some space
                 saveButton.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 20),
                 saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 saveButton.widthAnchor.constraint(equalToConstant: 120),
                 saveButton.heightAnchor.constraint(equalToConstant: 44),
             ])
         }
     }
    private func saveDuelsToFile(deckLinks: [String]) {
        // Initialize a Deck instance
        let deck = Deck()

        // Create arrays to store deck links and cards
        var deckLinksArray: [String] = []
        var cardsArray: [[String]] = []

        // Iterate through each deck link
        for deckLink in deckLinks {
            // Extract card keys for the current deck link
            if let strippedDeckLink = stripDeckLink(input: deckLink),
               let cardKeys = deck.decklinkToCards(from: strippedDeckLink) {
                // Convert card IDs to card keys using the cardIdToKey function
                let convertedCardKeys = cardKeys.compactMap { deck.cardIdToKey(cardId: Int($0) ?? 0) }

                // Append the deck link to the array
                deckLinksArray.append(strippedDeckLink)
                // Append the converted card keys to the cards array
                cardsArray.append(convertedCardKeys)
            } else {
                // Handle the case where either stripDeckLink or decklinkToCards returns nil
                print("Debug: Invalid deck link or cards could not be extracted for \(deckLink)")
                continue
            }
        }
        var existingDecks = loadSavedDuels()
        // Create a dictionary with deck_links and cards
        let duelsInfo: [String: Any] = [
            "deck_links": deckLinksArray,
            "cards": cardsArray
        ]
        existingDecks.append(duelsInfo)
        // Save the duels info to the file
        saveDuels(existingDecks)
        showPopup(message: "Duel decks saved successfully!")
    }



    private func saveDuels(_ duels: [[String: Any]]) {
        if let url = getSavedDuelsURL(),
           let data = try? JSONSerialization.data(withJSONObject: duels, options: .prettyPrinted) {
            do {
                try data.write(to: url)
                print("Duels saved successfully.")
            } catch {
                print("Error saving duels: \(error)")
            }
        }
    }

    // Get the file URL for saved_duels.json
    private func getSavedDuelsURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("saved_duels.json")
    }

    private func loadSavedDuels() -> [[String: Any]] {
        if let url = getSavedDuelsURL(),
           let data = try? Data(contentsOf: url),
           let duels = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            return duels
        } else {
            return []
        }
    }

    private func showDuelsPopup(message: String) {
        let alertController = UIAlertController(
            title: "Common Cards Detected!",
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
    @objc private func saveButtonTapped() {
        let deck = Deck()
        if duelModeSwitch.isOn{
            let result = deck.analyzeDecks(deckLinks: deckTextFields.compactMap { $0.text })
            if result != "DUEL"{
                showDuelsPopup(message: result)
            }
            else{
                saveDuelsToFile(deckLinks: deckTextFields.compactMap { $0.text } )
            }
            for textField in deckTextFields {
                textField.text = nil
            }

        }
        else{
            guard let deckLink = inputTextField.text, !deckLink.isEmpty else {
                // Handle invalid URL
                showPopup(message: "Invalid Link")
                return
            }
            
            // Strip the input to extract the URL
            if let strippedDeckLink = stripDeckLink(input: deckLink) {
                print("Debug: Modified URL: \(strippedDeckLink)")
                
                // Extract card keys from the modified URL
                guard let cardKeys = deck.decklinkToCards(from: strippedDeckLink) else {
                    // Handle invalid deck link
                    print("Debug: Invalid deck link or cards could not be extracted.")
                    showPopup(message: "Invalid Deck Link or Cards")
                    return
                }
                
                // Create a new deck link
                let newDeckLink = deck.cardsIDToDecklink(cards: cardKeys)
                
                print("Debug: New Deck Link: \(newDeckLink)")
                
                // Save the deck to the file
                saveDeckToFile(deckLink: newDeckLink, cardKeys: cardKeys)
                
                // Show "Deck Saved Successfully" popup
                showPopup(message: "Deck Saved Successfully")
            } else {
                // Handle invalid URL
                showPopup(message: "Invalid Link")
                print("Debug: Invalid URL. Input: \(deckLink)")
            }
            inputTextField.text = nil
            dismiss(animated: true, completion: nil)
        }
    }

    private func stripDeckLink(input: String) -> String? {
        // Strip the input to extract the URL
        if let startIndex = input.range(of: "https:") {
            let decklink = String(input[startIndex.lowerBound..<input.endIndex])
            
            // Find the position of "&" in the decklink
            if let ampersandIndex = decklink.firstIndex(of: "&") {
                // Extract the substring from the beginning up to "&"
                return String(decklink[..<ampersandIndex])
            }
        }
        
        // Return nil if "https:" is not found or "&" is not found
        return nil
    }


    func saveDeckToFile(deckLink: String, cardKeys: [String]) {
        // Initialize a Deck instance
        let deck = Deck()

        // Convert card IDs to card keys using the cardIdToKey function
        let convertedCardKeys = cardKeys.compactMap { deck.cardIdToKey(cardId: Int($0) ?? 0) }

        // Load existing decks from file (if any)
        var existingDecks = loadSavedDecks()
            // Create a new deck entry
            print(convertedCardKeys)
            print(deckLink)
            let deckInfo: [String: Any] = [
                "deck_link": deckLink,
                "cards": convertedCardKeys
            ]

            // Append the new deck to the existing decks
            existingDecks.append(deckInfo)

            // Save the updated decks array to the file
            saveDecks(existingDecks)

        
    }
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

    private func loadSavedDecks() -> [[String: Any]] {
        if let url = getSavedDecksURL(),
           let data = try? Data(contentsOf: url),
           let decks = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            return decks
        } else {
            return []
        }
    }



    @objc private func textFieldDidChange(_ textField: UITextField) {
        if duelModeSwitch.isOn {
            // Enable/disable the save button based on whether all input fields have text
            let allFieldsHaveText = deckTextFields.allSatisfy { !$0.text!.isEmpty }
            saveButton.isEnabled = allFieldsHaveText
        } else {
            // Enable/disable the save button based on whether the input field has text
            saveButton.isEnabled = !(textField.text?.isEmpty ?? true)
        }
    }

    func showPopup(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
