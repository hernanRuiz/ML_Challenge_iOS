//
//  Response.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 14/05/2021.
//

import Foundation

class MyResult: Decodable {
    public var title: String?
    public var price: Float?
    public var attributes: [Attributes]
    public var available_quantity: Int?
    public var seller: Seller
    public var thumbnail: String?
    public var address: Address
    
    func MyResult(){
        
    }
}

class Seller: Decodable {
    public var eshop: Eshop?
    public var seller_reputation: SellerReputation
}

class Attributes: Decodable {
    public var id: String?
    public var value_name: String?
}

class SellerReputation: Decodable {
    public var power_seller_status: String?
    public var transactions: SellerTransactions
}

class SellerTransactions: Decodable {
    public var total: Int?
    public var completed: Int?
    public var cancelled: Int?
}

class Eshop: Decodable {
    public var nick_name: String?
}

class Address: Decodable {
    public var state_name: String?
    public var city_name: String?
}

class MyResponse: Decodable {
    public var results: [MyResult]?
    public var status: String?
}
