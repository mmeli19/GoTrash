//
//  TrashMapCell.swift
//  Keep It Clean
//
//  Created by Emmanuel Gyekye Atta-Penkra on 11/2/21.
//

import UIKit

class TrashMapCell: UICollectionViewCell {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var labelView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        parentView.layer.cornerRadius = 15
        parentView.clipsToBounds = true
        
        labelView.layer.cornerRadius = 7.5
    }
}
