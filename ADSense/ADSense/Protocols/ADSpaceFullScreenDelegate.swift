
public protocol ADSpaceFullScreenDelegate: class {
    func fullScreenAdWillLoad(adSpace: ADSpace)
    func fullScreenAd(adSpace: ADSpace, didFailWithError error: Error)
    func fullScreenAdDidLoad(adSpace: ADSpace)
    func fullScreenAdDidClose(adSpace: ADSpace)
}

