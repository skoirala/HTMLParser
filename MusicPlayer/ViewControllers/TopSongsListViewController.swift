
import UIKit

import ADSense


public class TopSongsListViewController: UIViewController, ADSpaceViewDelegate {
    
    internal var listViewAdapter: TopSongListViewAdapter!
    internal var listView: TopSongListView!
    internal var countrySelectionButton: UIBarButtonItem!
    var selectedCountry = "USA"
    
    var adSpaceView: ADSpaceView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Top Songs"

        createViews()
        setupListViewAdapter()
        listViewAdapter.loadTopSongs(countryIdentifier: Countries[selectedCountry]!)
        
        adSpaceView = ADSpaceView(token: "")
        adSpaceView.delegate = self
        adSpaceView.load(request: ADSpaceRequest(adType:.Banner) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.closeAdSpace()
        })

    }
    
    public func adSpaceViewWillLoad(adSpaceView: ADSpaceView) {
        print("Will load ad")
    }
    
    public func adSpaceViewDidLoad(adSpaceView: ADSpaceView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.listViewAdapter.headerView = adSpaceView
            self.listView.setHeaderSize(size: adSpaceView.size)
            self.listView.reloadData()
        }
    }
    
    public func adSpaceView(adSpaceView: ADSpaceView, didFailWithError error: Error) {
        print("Failed with error \(error)")
    }
    
    func closeAdSpace() {
        UIView.animate(withDuration: 0.5) {
            self.listViewAdapter.headerView = nil
            self.listView.setHeaderSize(size: .zero)
            self.listView.reloadData()
        }
    }

}

// MARK: Private methods

extension TopSongsListViewController {
    
    internal func createViews() {
        
        countrySelectionButton = UIBarButtonItem(title: "Country",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(countrySelectionButtonTapped))
        navigationItem.rightBarButtonItem = countrySelectionButton
        
        listView = TopSongListView()
        listView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listView)
        let constraints = [
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listView.leftAnchor.constraint(equalTo: view.leftAnchor),
            listView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        constraints.forEach { $0.isActive = true }
    }
    
    @objc private func countrySelectionButtonTapped() {
        let countrySelectionViewController = CountrySelectionPopupViewController(selectedCountry: selectedCountry, selection: { [weak self] country in
            self?.selectedCountry = country
            self?.listViewAdapter.reset()
            self?.listView.reloadData()
            self?.listViewAdapter.loadTopSongs(countryIdentifier: Countries[self!.selectedCountry]!)
        })
            
        countrySelectionViewController.popoverPresentationController?.barButtonItem = countrySelectionButton
        present(countrySelectionViewController, animated: true)
    }
    
    
    internal func setupListViewAdapter() {
        listViewAdapter = TopSongListViewAdapter(onChange: {
            self.listView.reloadData()
            }, selection: { song in
                self.showAlbumDetail(song)
        })
        
        listView.delegate = listViewAdapter
        listView.dataSource = listViewAdapter
    }
    
    internal func showAlbumDetail(_ song: Song) {
        let songDetailViewController = AlbumListViewController(song: song)
        navigationController?.pushViewController(songDetailViewController, animated: true)
    }
}
