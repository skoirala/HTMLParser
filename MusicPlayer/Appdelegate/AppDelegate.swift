
import UIKit

import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? =  UIWindow(frame: UIScreen.main.bounds)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSessionCategoryPlayback)
        
        let songsListViewController = TopSongsListViewController()
        let navigationController = UINavigationController(rootViewController: songsListViewController)
        window?.rootViewController = navigationController
        window?.backgroundColor = UIColor.white
        window?.tintColor = UIColor(red: 236.0 / 255.0, green: 82.0 / 255.0, blue: 152.0/255.0, alpha: 1)
        window?.makeKeyAndVisible()
        return true
    }
}

