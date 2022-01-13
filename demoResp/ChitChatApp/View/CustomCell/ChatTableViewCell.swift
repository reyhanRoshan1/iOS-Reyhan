//
//  ChatTableViewCell.swift
//  Footsii
//
//  Created by webastral on 9/17/18.
//  Copyright © 2018 webastral. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var lblReciever: UILabel!
    @IBOutlet weak var imgReciever: ImageCustom!
    @IBOutlet weak var lblSender: UILabel!
    
    @IBOutlet weak var imgSenderUpload: UIImageView!
    @IBOutlet weak var imgRecieverUpload: UIImageView!
    @IBOutlet weak var imgSenderMov: UIImageView!
    @IBOutlet weak var imgRecieverMov: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
