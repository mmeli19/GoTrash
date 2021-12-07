//
//  MapVC.swift
//  Keep It Clean
//
//  Created by Emmanuel Gyekye Atta-Penkra on 10/26/21.
//

import UIKit
import MapKit
import PopupDialog

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var trashCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        mapView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 200, right: 10)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "TrashMapCell", bundle: nil), forCellWithReuseIdentifier: "TrashMapCell")
    }

    func render(){
        if !isViewLoaded { return }
        let coordinate = CLLocationCoordinate2D(latitude: mainVC.location!.coordinate.latitude, longitude: mainVC.location!.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(mapView.userLocation)
//        setPin(with: coordinate)
    }
    
    func setPin(with coordinate: CLLocationCoordinate2D, title: String?, subTitle: String?){
        let pin = MKPointAnnotation()
        pin.title = title
        pin.subtitle = subTitle
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        render()
        collectionView.reloadData()
        mainVC.trashes.forEach { trash in
            setPin(with: CLLocationCoordinate2D(latitude: trash.latitude, longitude: trash.longitude), title: "Trash", subTitle: nil)
        }
        trashCountLabel.text = "\(mainVC.trashes.count) Trash Around You"
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "trash-bag")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "trash-bag")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        annotationView?.image = UIImage(named: "garbage-bag")
        annotationView?.frame.size = CGSize(width: 20, height: 20)

        return annotationView
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainVC.trashes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrashMapCell", for: indexPath) as! TrashMapCell
        let trash = mainVC.trashes[indexPath.row]
        cell.imageView.image = trash.image
        
        let coordinate₀ = CLLocation(latitude: trash.latitude, longitude: trash.longitude)
        let coordinate₁ = mainVC.location!
        
        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        cell.label.text = "\(distanceInMeters.rounded(toPlaces: 2)) meters"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 175, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let trash = mainVC.trashes[indexPath.row]
        
        // Create the dialog
        let popup = PopupDialog(title: nil, message: nil, image: trash.image)

        popup.addButton(DefaultButton(title: "Trash Cleared!", dismissOnTap: false) {
            mainVC.trashes.remove(at: indexPath.row)
            mainVC.clearedTrashes = mainVC.clearedTrashes + 1
            mainVC.saveProgress()
            popup.dismiss(nil)
            self.viewDidAppear(true)
            Actions.showAlert(self, style: .alert, title: "Thank you!", message: "You now have \(mainVC.calcPoints()) points with Go Trash", actions: [
                UIAlertAction(title: "Great!", style: .default, handler: nil)
            ])
        })

        // Present dialog
        present(popup, animated: true, completion: nil)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
