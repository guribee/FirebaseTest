//
//  TalkTableViewCell.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/24.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit

class TalkTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        commentLabel.layer.masksToBounds = true
        commentLabel.layer.cornerRadius = 5.0
        // Configure the view for the selected state
    }

}
