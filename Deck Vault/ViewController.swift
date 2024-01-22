import UIKit
import GoogleMobileAds // Import the Google Mobile Ads framework

class ViewController: UIViewController {
    var bannerView: GADBannerView!

    let deck = Deck()

    lazy var appIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo-circle"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var viewCardImagesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.9)
        button.layer.cornerRadius = 8.0
        button.addTarget(self, action: #selector(showCardImages), for: .touchUpInside)
        return button
    }()

    lazy var showSavedDuelsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Saved Duels", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        button.layer.cornerRadius = 8.0
        button.addTarget(self, action: #selector(showSavedDuels), for: .touchUpInside)
        return button
    }()

    
    lazy var showSavedDecksButton: UIButton = {
        let button = UIButton()
        button.setTitle("Saved", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .purple
        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.9)
        button.layer.cornerRadius = 8.0
        button.addTarget(self, action: #selector(showSavedDecks), for: .touchUpInside)
        return button
    }()

    let cardKeysLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Instantiate the banner with the desired ad size
        bannerView = GADBannerView(adSize: GADAdSizeFullWidthPortraitWithHeight(50))
        bannerView.backgroundColor = UIColor.red // Set a color that stands out


        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Replace with your actual ad unit ID
        bannerView.rootViewController = self
        bannerView.rootViewController = self
        
        setupUI()
    }

    func setupUI() {
        // Set background image
        let backgroundImage = UIImageView(image: UIImage(named: "home.png"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        appIconImageView.layer.shadowColor = UIColor.purple.cgColor
        appIconImageView.layer.shadowRadius = 10.0
        appIconImageView.layer.shadowOpacity = 1.0
        appIconImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        // Your existing code for appIconImageView
        view.addSubview(appIconImageView)
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appIconImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            appIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: 240),
            appIconImageView.heightAnchor.constraint(equalToConstant: 240),
        ])

        // Add a + button
        let addButton = UIButton()
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        addButton.layer.cornerRadius = 8.0
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        // Your existing code for viewCardImagesButton
        view.addSubview(viewCardImagesButton)
        viewCardImagesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewCardImagesButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20),
            viewCardImagesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewCardImagesButton.widthAnchor.constraint(equalToConstant: 120),
            viewCardImagesButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        // Your existing code for showSavedDecksButton
        view.addSubview(showSavedDecksButton)
        showSavedDecksButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showSavedDecksButton.topAnchor.constraint(equalTo: viewCardImagesButton.bottomAnchor, constant: 20),
            showSavedDecksButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showSavedDecksButton.widthAnchor.constraint(equalToConstant: 120),
            showSavedDecksButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    // ####DUELS
        view.addSubview(showSavedDuelsButton)
        showSavedDuelsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showSavedDuelsButton.topAnchor.constraint(equalTo: showSavedDecksButton.bottomAnchor, constant: 20),
            showSavedDuelsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showSavedDuelsButton.widthAnchor.constraint(equalToConstant: 120),
            showSavedDuelsButton.heightAnchor.constraint(equalToConstant: 44),
        ])
// ######
        
        let adContainerView = UIView()
        adContainerView.backgroundColor = .clear // Set the background color as needed
        adContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adContainerView)

        NSLayoutConstraint.activate([
            adContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            adContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            adContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            adContainerView.heightAnchor.constraint(equalToConstant: 100), // Adjust the height as needed
        ])

        adContainerView.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])



        // Request the banner ad
        let request = GADRequest()
        bannerView.load(request)
    }
    @objc func addButtonTapped() {
        // Handle "+" button tap
        let addInputVC = AddInputViewController()
        addInputVC.delegate = self
        present(addInputVC, animated: true, completion: nil)
    }

    @objc func showCardImages() {
        let cardImagesVC = CardImagesViewController()
        present(cardImagesVC, animated: true, completion: nil)
    }
    @objc func showSavedDuels() {
        let savedDuelsVC = SavedDuelsViewController()

        present(savedDuelsVC, animated: true, completion: nil)
    }

    @objc func showSavedDecks() {
        let savedDecksVC = SavedDecksViewController()
        savedDecksVC.savedDecks = loadSavedDecks()
        present(savedDecksVC, animated: true, completion: nil)
    }

    func loadSavedDecks() -> [[String: Any]] {
        // Implement code to load saved_decks.json contents here
        // For simplicity, I'm providing a sample implementation assuming saved_decks.json is in the app bundle
        if let path = Bundle.main.path(forResource: "saved_decks", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            return json
        }
        return []
    }
    func loadSavedDuels() -> String{
        return "OK"
    }

    // Get the file URL for saved_duels.json
    private func getSavedDuelsURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("saved_duels.json")
    }
}
extension ViewController: AddInputDelegate {
    func didSaveInput(_ input: String) {
        // Handle the saved input
        print("Saved Input: \(input)")
        // You can do something with the saved input, like updating your model or UI.
    }
}
