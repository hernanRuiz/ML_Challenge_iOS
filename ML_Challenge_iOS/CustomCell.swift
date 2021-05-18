//
//  CustomCell.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 17/05/2021.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var imageVIew: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
