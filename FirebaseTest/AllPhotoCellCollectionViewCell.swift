//
//  AllPhotoCellCollectionViewCell.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/21.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit

class AllPhotoCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoCellImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 6.0
    }
}
