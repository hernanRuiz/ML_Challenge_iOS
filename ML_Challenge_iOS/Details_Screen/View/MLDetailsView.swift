//
//  MLDetailsView.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 17/05/2021.
//

import Foundation
import UIKit

class MLDetailsView : UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    var cellData: MyResult?
    
    override func viewDidLoad() {
        titleLabel.text = cellData?.title
    }
}
