//
//  ViewController.swift
//  Keep It Clean
//
//  Created by Emmanuel Gyekye Atta-Penkra on 10/21/21.
//

import CoreLocation
import UIKit

var mainVC = MainVC()

class MainVC: UIPageViewController {
    
    let mapVC = MapVC()
    let cameraVC = CameraVC()
    let accountVC = AccountVC()
    
    var controllers: [UIViewController] = []
    var currentIndex: Int {
        guard let vc = viewControllers?.first else { return 0 }
        return controllers.firstIndex(of: vc) ?? 0
    }
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    var trashes = [Trash]()
    var clearedTrashes = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mainVC = self
        
        controllers.append(contentsOf: [mapVC, cameraVC, accountVC])
        
        delegate = self
        dataSource = self
        
        changeView(to: 1)
        loadProgress()
    }
    
    func changeView(to index: Int){
        setViewControllers([controllers[index]], direction: currentIndex < index ? .forward : .reverse, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpLocation()
    }
    
    func setUpLocation(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func saveProgress(){
        let trashData = trashes.reduce(into: [[String: Any]]()) { result, trash in
            guard let imageStr = getStringImage(image: trash.image) else { return }
            result.append([
                "imageStr" : imageStr,
                "latitude": trash.latitude,
                "longitude": trash.longitude
            ])
        }
        
        Actions.saveInfo(key: "trashes", value: trashData)
        Actions.saveInfo(key: "clearedTrashes", value: clearedTrashes)
    }
    
    func loadProgress(){
        guard let trashes = Actions.getInfo(key: "trashes") as? [[String: Any]], let clearedTrashes = Actions.getInfo(key: "clearedTrashes") as? Int else { return }
        
        self.trashes = trashes.reduce(into: [Trash](), { trashes, trash in
            guard let image = getImage(from: trash["imageStr"] as! String) else { return }
            trashes.append(Trash(image: image, latitude: trash["latitude"] as! Double, longitude: trash["longitude"] as! Double))
        })
        self.clearedTrashes = clearedTrashes
    }
    
    func getStringImage(image: UIImage) -> String? {
        guard let str = image.jpegData(compressionQuality: 1)?.base64EncodedString(options: .endLineWithLineFeed) else {
            return nil
        }
        
        return str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    func getImage(from strBase64: String) -> UIImage? {
        let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        return decodedimage
    }
    
    func calcPoints() -> String {
        var points = 0
        points += 3 * mainVC.trashes.count
        points += 10 * mainVC.clearedTrashes
        return String(points)
    }
}

extension MainVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(where: { $0 == viewController }), index > 0 {
            return controllers[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(where: { $0 == viewController }), index < (controllers.count - 1) {
            return controllers[index + 1]
        }
        return nil
    }
}

extension MainVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            self.location = location
            mapVC.render()
        }
    }
}
