//
//  PhotoCellCollectionViewCell.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/18.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit

class PhotoCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoCellImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.systemTeal.cgColor
        self.layer.cornerRadius = 6.0
    }
}
