
import UIKit


internal class CountrySelectionPopupViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var selection: (String) -> Void
    var selectedCountry: String?
    
    lazy var sortedCountries = { () -> [String] in
        let countriesName = Countries.keys.sorted()
        return countriesName
    }()
    
    public init(selectedCountry: String?, selection: @escaping (String) -> Void) {
        self.selectedCountry = selectedCountry
        self.selection = selection
        
        super.init(style: .plain)
        
        modalPresentationStyle = .popover
        
        let presentationController = self.popoverPresentationController
        presentationController?.permittedArrowDirections = .up
        presentationController?.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCountries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = sortedCountries[indexPath.row]
        
        if let selectedCountry = selectedCountry, selectedCountry == sortedCountries[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: { [weak self] in
            if let weakSelf = self {
                weakSelf.selection(weakSelf.sortedCountries[indexPath.row])
            }
        })
    }
    
}
