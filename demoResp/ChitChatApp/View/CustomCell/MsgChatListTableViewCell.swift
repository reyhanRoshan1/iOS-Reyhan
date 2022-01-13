//
//  MsgChatListTableViewCell.swift
//  ChitChatApp
//
//  Created by TechCenter on 16/01/21.
//  Copyright © 2021 Surinder. All rights reserved.
//

import UIKit

class MsgChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMsgCount: LabelCustom!
    @IBOutlet weak var lblLastUpdate: UILabel!
    @IBOutlet weak var lblLastMsg: UILabel!
    @IBOutlet weak var lblUserFrndName: UILabel!
    @IBOutlet weak var imgUserFrnd: ImageCustom!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
