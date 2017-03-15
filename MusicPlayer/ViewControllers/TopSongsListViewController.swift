
import UIKit

import ADSense


public class TopSongsListViewController: UIViewController, ADSpaceDelegate, ADSpaceFullScreenDelegate {
    
    internal var listViewAdapter: TopSongListViewAdapter!
    internal var listView: TopSongListView!
    internal var countrySelectionButton: UIBarButtonItem!
    var selectedCountry = "USA"
    var selectedSong: Song?
    
    var adSpace: ADSpace!
    var adSpaceView: UIView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Top Songs"

        createViews()
        setupListViewAdapter()
        listViewAdapter.loadTopSongs(countryIdentifier: Countries[selectedCountry]!)
        
        adSpace = ADSpace()
        adSpace.delegate = self
        adSpace.fullScreenAdDelegate = self
        adSpace.load(adType: .banner)
    }
    
    public func adSpaceWillLoad(adSpace: ADSpace) {
        print("Will load ad")
    }
    
    public func adSpace(adSpace: ADSpace,
                        didLoadView view: UIView,
                        contentSize: CGSize) {
        self.listViewAdapter.headerView = view
        self.listView.setHeaderSize(size: contentSize)
        self.listView.reloadData()
    }
    
    public func adSpace(adSpace: ADSpace, didFailWithError error: Error) {
        
    }
    
    public func adSpace(adSpace: ADSpace, willCloseView view: UIView) {
        closeAdSpace()
    }
    
    public func fullScreenAdWillLoad(adSpace: ADSpace) {
        
    }
    
    public func fullScreenAd(adSpace: ADSpace, didFailWithError error: Error) {
        
    }
    
    public func fullScreenAdDidLoad(adSpace: ADSpace) {
        ProgressView.hideFrom(view: view.window!)
    }
    
    public func fullScreenAdDidClose(adSpace: ADSpace) {
        guard let selectedSong = selectedSong else { return }
        let songDetailViewController = AlbumListViewController(song: selectedSong)
        navigationController?.pushViewController(songDetailViewController, animated: true)

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
        ProgressView.showIn(view: view.window!)
        selectedSong = song
        adSpace.load(adType: .interstitial(in: self))
    }
}
