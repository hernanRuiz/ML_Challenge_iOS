//
//  MLApi.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 14/05/2021.
//

import Foundation
import Alamofire
import os

class MLApi {
    let baseUrl = "https://api.mercadolibre.com"
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    
    func callMLApi(param: String, callback: @escaping (_ error: NSError?, _ results: MyResponse?) -> Void) -> Void {
        let url = baseUrl + "/sites/MLA/search?q="
        AF.request(url + param.replacingOccurrences(of: " ", with: "%20")).response { [weak self] response in
            switch response.result {
                //El success se dispara cuando la API responde, puede ser con respuesta correcta o de error.
                case .success(let data):
                    do {
                        if let myData = data {
                            let myResponse = try JSONDecoder().decode(MyResponse.self, from: myData)
                            if myResponse.results != nil {
                                callback(nil, myResponse)
                            } else {
                                if let domain = self?.baseUrl {
                                    let nsError = NSError(domain: domain, code: 0, userInfo: nil)
                                    self?.logger.log("API_ERROR: results = nil")
                                    callback(nsError, nil)
                                }
                            }
                        }
                    } catch {
                        //Si no puedo parsear la respuesta como correcta, intento parsearla como respuesta de error.
                        do{
                            if let myData = data {
                                let errorResponse = try JSONDecoder().decode(CustomError.self, from: myData)
                                if errorResponse.message != nil {
                                    let userInfo: [String: Any] = [
                                        "message" : errorResponse.message as Any,
                                        "error" : errorResponse.error as Any,
                                        "cause" : errorResponse.cause as Any
                                    ]
                                    if let domain = self?.baseUrl {
                                        let nsError = NSError(domain: domain, code: errorResponse.status ?? 0, userInfo: userInfo)
                                        self?.logger.log("ERROR = \(nsError.code),  \(nsError.userInfo.description)")
                                        callback(nsError, nil)
                                    }
                                } else {
                                    if let domain = self?.baseUrl {
                                        let nsError = NSError(domain: domain, code: 0, userInfo: nil)
                                        self?.logger.log("API_ERROR: EXC_BAD_ACCESS, results y error = nil")
                                        callback(nsError, nil)
                                    }
                                }
                            }
                        } catch let error {
                            self?.logger.log("ERROR = \(error.localizedDescription)")
                            callback(error as NSError, nil)
                        }
                    }
                    
                case .failure(let error):
                    //Falla en la comunicación con la API, no se puede resolver la consulta.
                    if let errorDescription = error.errorDescription {
                        self?.logger.log("API_ERROR = \(errorDescription)")
                    }
                    callback(error as NSError, nil)
            }
        }
    }
}
