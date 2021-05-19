//
//  MLDetailsView.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 17/05/2021.
//

import Foundation
import UIKit
import os

class MLDetailsView : UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerReputationLevelLabel: UILabel!
    @IBOutlet weak var sellerTotalTransactionsLabel: UILabel!
    @IBOutlet weak var sellerCompletedTransactionsLabel: UILabel!
    @IBOutlet weak var sellerCanceledTransactionsLabel: UILabel!
    @IBOutlet weak var sellerLocationLabel: UILabel!
    
    var cellData: MyResult?
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    
    override func viewDidLoad() {
        configureView()
    }
    
    private func configureView(){
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.text = cellData?.title
        
        let sellerName = cellData?.seller.eshop?.nick_name
        sellerNameLabel.text = sellerName != nil ? sellerName : "-"
        
        let sellerReputation = cellData?.seller.seller_reputation?.power_seller_status
        sellerReputationLevelLabel.text = sellerReputation != nil ? sellerReputation : "-"
        
        if let sellerLocationState = cellData?.address.state_name, let sellerLocationCity = cellData?.address.city_name {
            sellerLocationLabel.text = sellerLocationCity + ", " + sellerLocationState
        }
        
        if let totalTransactions = cellData?.seller.seller_reputation?.transactions?.total {
            sellerTotalTransactionsLabel.text = String(totalTransactions)
        }
        
        if let completedTransactions = cellData?.seller.seller_reputation?.transactions?.completed {
            sellerCompletedTransactionsLabel.text = String(completedTransactions)
        }
        
        if let canceledTransactions = cellData?.seller.seller_reputation?.transactions?.canceled {
            sellerCanceledTransactionsLabel.text =  String(canceledTransactions)
        }
        
        if let stock = cellData?.available_quantity {
            stockLabel.text = String(stock)
        }
        
        if let price = cellData?.price {
            let stringPrice = "$ " + String(format: "%.2f", price)
            priceLabel.text = stringPrice
        }
        
        if let index = cellData?.attributes.firstIndex(where: { (item) -> Bool in
            return (item).id == "ITEM_CONDITION"}) {
            conditionLabel.text = cellData?.attributes[index].value_name
        }
        
        //Configuramos la imageView y le cargo imagen desde url
        do {
            if let urlString = cellData?.thumbnail?.replacingOccurrences(of: "http://", with: "https://") {
                if let url = URL(string: urlString) {
                    let data = try Data(contentsOf: url)
                    productImage.contentMode = UIView.ContentMode.scaleToFill
                    productImage.clipsToBounds = true
                    let cellImage : UIImageView = UIImageView()
                    cellImage.contentMode = UIView.ContentMode.scaleAspectFill
                    cellImage.clipsToBounds = true
                    cellImage.image = UIImage(data: data)
                    if let resultImage = cellImage.image {
                        setImage(image: resultImage)
                    }
                }
            }
        }
        catch{
            self.logger.log("Error en el procesamiento de imagen via URL")
        }
    }
    
    func setImage(image: UIImage) {
            productImage.image = image
            let screenSize = UIScreen.main.bounds.size

            let imageAspectRatio = image.size.width / image.size.height
            let screenAspectRatio = screenSize.width / screenSize.height

            if imageAspectRatio > screenAspectRatio {
                widthConstraint.constant = min(image.size.width, screenSize.width)
                heightConstraint.constant = widthConstraint.constant / imageAspectRatio
            }
            view.layoutIfNeeded()
        }
}


