
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let songsListViewController = TopSongsListViewController()
        let navigationController = UINavigationController(rootViewController: songsListViewController)
        window.rootViewController = navigationController
        window.backgroundColor = UIColor.whiteColor()
        window.tintColor = UIColor(red: 236.0 / 255.0, green: 82.0 / 255.0, blue: 152.0/255.0, alpha: 1)
        return window
    }()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window?.makeKeyAndVisible()
        return true
    }
}

