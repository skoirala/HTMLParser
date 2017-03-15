
public protocol ADSpaceDelegate: class {
    func adSpaceWillLoad(adSpace: ADSpace)
    func adSpace(adSpace: ADSpace, didFailWithError error: Error)
    func adSpace(adSpace: ADSpace, didLoadView: UIView, contentSize: CGSize)
    func adSpace(adSpace: ADSpace, willCloseView view: UIView)
}

