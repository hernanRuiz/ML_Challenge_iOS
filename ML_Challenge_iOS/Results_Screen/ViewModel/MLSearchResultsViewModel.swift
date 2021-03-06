//
//  MLSearchViewModel.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 14/05/2021.
//

import Foundation

class MLSearchViewModel {
    let api = MLApi.init()
    var refreshData = {() -> () in }
    var lastParam = ""
    
    var dataArray: [AnyObject] = [] {
        didSet {
            refreshData()
        }
    }
    
    func retrieveResults(param: String){
        if param.contains("offset") {
            //La consulta viene con parámetro offset => se agregan los nuevos resultados a los que ya teníamos
            appendNewResults(param: param)
        } else {
            //No hay offset en los parámetros, se reemplza el contenido del array de resultados
            callApi(param: param, false)
        }
    }
    
    func appendNewResults(param: String) {
        callApi(param: param, true)
    }
    
    func callApi(param: String, _ loadMore: Bool){
        api.callMLApi(param: param) { [weak self] (error, result) in
            if let data = result {
                //Cargo el array con los resultados de la búsqueda, esto dispara el refresh de la tabla para mostrarlos
                if let resultData = data.results{
                    let userDefaultStore = UserDefaults.standard
                    userDefaultStore.set(data.paging?.total, forKey: "total_results_count")
                    if loadMore == true {
                        self?.dataArray.append(contentsOf: resultData)
                    } else {
                        self?.dataArray = resultData
                    }
                }
            } else if error != nil {
                //Si vuelve de la API una respuesta de error o si falla la comunicación con la API y result es nil, cargo el array con un error, esto dispara que el viewController correspondiente muestre un label con mensaje de error
                var array : [NSError] = []
                if let errorData = error {
                    array.append(errorData)
                    self?.dataArray = array
                }
            }
        }
    }
}
