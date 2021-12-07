//
//  AccountVC.swift
//  Keep It Clean
//
//  Created by Emmanuel Gyekye Atta-Penkra on 10/26/21.
//

import UIKit
import PopupDialog

class AccountVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reportedL: UILabel!
    @IBOutlet weak var clearedL: UILabel!
    @IBOutlet weak var pointsL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(longPressedGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        reloadInfo()
    }
    
    func reloadInfo(){
        reportedL.text = String(mainVC.trashes.count)
        clearedL.text = String(mainVC.clearedTrashes)
        
        pointsL.text = mainVC.calcPoints()
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }

        let p = gestureRecognizer.location(in: collectionView)

        if let indexPath = collectionView?.indexPathForItem(at: p) {
            confirmDelete(at: indexPath)
        }
    }
    
    func confirmDelete(at indexPath: IndexPath){
        Actions.showAlert(self, style: .alert, title: "Delete this image?", message: nil, actions: [
            UIAlertAction(title: "Yes, Delete", style: .default, handler: { [weak self] _ in
                self?.viewWillAppear(true)
                mainVC.trashes.remove(at: indexPath.row)
            }),
            Actions.cancelAlertBtn()
        ])
    }
}

extension AccountVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageView.image = mainVC.trashes[indexPath.row].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainVC.trashes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.size.width / 3) - 3, height: (view.frame.size.width / 3) - 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let trash = mainVC.trashes[indexPath.row]
        
        // Create the dialog
        let popup = PopupDialog(title: nil, message: nil, image: trash.image)

        popup.addButton(DefaultButton(title: "Delete", dismissOnTap: false) {
//            popup.present(pickerC, animated: true, completion: nil)
            self.confirmDelete(at: indexPath)
        })

        // Present dialog
        present(popup, animated: true, completion: nil)
    }
}
