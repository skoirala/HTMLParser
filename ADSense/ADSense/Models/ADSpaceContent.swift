
enum ADSpaceContentType: String {
    case image
    case video
    case html
}

public struct ADSpaceViewModel {
    let size: CGSize
    let actionElementSelector: String?
}


public struct ADSpaceContent {
    let id: String
    let type: ADSpaceContentType
    let url: String
    let width: CGFloat
    let height: CGFloat
    let actionElement: String?
    let actionURL: String?
}

public extension ADSpaceContent {
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var proportionalContentSize: CGSize {
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        return CGSize(width: screenWidth, height: ceil(height * screenWidth / width))
    }
}
