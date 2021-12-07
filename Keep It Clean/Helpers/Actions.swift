//
//  Actions.swift
//  Keep It Clean
//
//  Created by Emmanuel Gyekye Atta-Penkra on 11/9/21.
//

import Foundation
import UIKit
//import Kingfisher

class Actions {
    
    static func getInfo(key: String) -> Any? {
        if USER_INFO[key] != nil {
            return USER_INFO[key]
        } else {
            let value = UserDefaults.standard.object(forKey: key)
            USER_INFO[key] = value
            return value
        }
    }
    
    static func saveInfo(key: String, value: Any){
        USER_INFO[key] = value
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func removeInfo(key: String){
        USER_INFO[key] = nil
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func removeAll(){
        USER_INFO = [:]
        UserDefaults.standard
            .removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    static func storeImage(urlString: String, image: UIImage){
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)
        
        let data = image.jpegData(compressionQuality: 0.5)
        ((try? data?.write(to: url)) as ()??)
        
        var dict = UserDefaults.standard.object(forKey: "imageCache") as? [String: String]
        if dict == nil {
            dict = [String: String]()
        }
        
        dict![urlString] = path
        UserDefaults.standard.set(dict, forKey: "imageCache")
    }
    
    static func showImage(urlString: String, imageView: UIImageView, _default: UIImage? = UIImage(named: "broken-image"), completion: (() -> Void)? = nil){
        let url = URL(string: urlString)
//        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
//        imageView.kf.indicatorType = .activity
//        imageView.kf.setImage(
//            with: url,
//            placeholder: _default,
//            options: [
//                .processor(processor),
//                .scaleFactor(UIScreen.main.scale),
//                .transition(.fade(1)),
//                .cacheOriginalImage
//            ]) { result in
//            completion?()
//        }
    }
    
    static func getImage(urlString: String, error: (() -> Void)? = nil, completion: @escaping ((UIImage) -> Void)){
        guard let url = URL.init(string: urlString) else {
            print("Error: Invalid URL String")
            return
        }
//        let resource = ImageResource(downloadURL: url)
        
//        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
//            switch result {
//            case .success(let value):
//                completion(value.image)
//            case .failure(let err):
//                error?()
//                print("Error: \(err)")
//            }
//        }
    }
    
    static func isValidEmail(_ emailStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    static func showAlert(_ view: UIViewController, style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction], showCancel: Bool = false, cancellable: Bool = true){
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        if showCancel {
            alert.addAction(cancelAlertBtn())
        }
        alert.view.tintColor = UIColor(named: "Primary")
        view.presentedViewController?.dismiss(animated: true, completion: nil)
        view.present(alert, animated: true) {
            if cancellable {
//                alert.view.superview?.isUserInteractionEnabled = true
//                alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlert(sender:))))
            }
        }
    }
    
    @objc
    static func dismissAlert(sender: UITapGestureRecognizer){
        sender.view?.removeFromSuperview()
    }
    
    static func cancelAlertBtn() -> UIAlertAction {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        return cancelAction
    }
    
    static func deepLink(_ view: UIViewController, urlString: String, failedStr: String, name: String, again: Bool){
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else if again {
            deepLink(view, urlString: failedStr, failedStr: "", name: name, again: false)
        }else {
            Actions.showAlert(view, style: .alert, title: "Cannot open \(name). Please make sure it is installed", message: "", actions: [UIAlertAction(title: "Okay", style: .default, handler: nil)])
        }
    }
    
    static func ordinalNumberFormat(_ num: Int) -> String {
        var ending: String?

        let ones = num % 10
        var tens = floor(Double(num / 10))
        tens = Double(Int(tens) % 10)
        if tens == 1 {
            ending = "th"
        } else {
            switch ones {
                case 1:
                    ending = "st"
                case 2:
                    ending = "nd"
                case 3:
                    ending = "rd"
                default:
                    ending = "th"
            }
        }
        return "\(num)\(ending ?? "")"
    }
    
    static func getUserCountry() -> String? {
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            return countryCode.lowercased()
            }
        return nil
    }

    static func getPhoneExt() -> String {
        switch getUserCountry() {
        case "us", "um": return "+1"
        case "gh": return "+233"
        case "ng": return "+234"
        case "jm": return "+1876"
        default: return "+"
        }
    }
}
