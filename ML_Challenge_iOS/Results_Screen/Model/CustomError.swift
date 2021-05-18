//
//  CustomError.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 15/05/2021.
//

import Foundation

struct CustomError: Decodable{
    var message: String?
    var error: String?
    var status: Int?
    var cause: [String]?
}
