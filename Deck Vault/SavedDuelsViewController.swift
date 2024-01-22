import UIKit

class SavedDuelsViewController: UIViewController {
    var savedDuels: [[String: Any]] = []

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedDuels()
    }
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Delete File", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 8.0
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    private func deleteSavedDuelsFile() {
        if let savedDuelsURL = getSavedDuelsURL(), FileManager.default.fileExists(atPath: savedDuelsURL.path) {
            do {
                try FileManager.default.removeItem(at: savedDuelsURL)
                print("saved_duels.json deleted successfully.")
            } catch {
                print("Error deleting saved_duels.json: \(error)")
            }
        } else {
            print("saved_duels.json does not exist.")
        }
    }

    // Add this UIButton to your UI, and set up constraints in your viewDidLoad or setupUI method.
    // ...

    @objc private func deleteButtonTapped() {
        deleteSavedDuelsFile()
        // You might want to update your UI or perform other actions after deleting the file.
    }
    func setupUI() {
        // Customize the UI, e.g., set background color, add subviews, etc.
        view.backgroundColor = .white

        // Add the delete button
        view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            deleteButton.widthAnchor.constraint(equalToConstant: 120),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        // Add the text view
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }


    func loadSavedDuels() {
        if let url = getSavedDuelsURL(),
           let data = try? Data(contentsOf: url),
           let jsonString = String(data: data, encoding: .utf8) {
            textView.text = jsonString
        } else {
            textView.text = "No saved duels found."
        }
    }

    // Get the file URL for saved_duels.json
    private func getSavedDuelsURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("saved_duels.json")
    }
}
