//
//  ML_Challenge_iOSTests.swift
//  ML_Challenge_iOSTests
//
//  Created by Hernan Ruiz on 14/05/2021.
//

import XCTest
@testable import ML_Challenge_iOS

class ML_Challenge_iOSTests: XCTestCase {
    
    //La API devuelve una respuesta de error al recibir ciertos símbolos como parámetros de búsqueda
    func testAPI1() {
        let viewModel = MLSearchViewModel()
        viewModel.retrieveResults(param: "´")
        viewModel.refreshData = { () in
            let dataArray: [AnyObject] = viewModel.dataArray
            XCTAssertTrue(dataArray.count == 1) //el array de resultados tiene un solo registro (el error).
        }
    }
    
    //La API devuelve respuesta sin resultados
    func testAPI2() {
        let viewModel = MLSearchViewModel()
        viewModel.retrieveResults(param: "+")
        viewModel.refreshData = { () in
            let dataArray: [AnyObject] = viewModel.dataArray
            XCTAssertTrue(dataArray.count == 0)
        }
    }
    
    //Respuesta normal de la API
    func testAPI3() {
        let viewModel = MLSearchViewModel()
        viewModel.retrieveResults(param: "a")
        viewModel.refreshData = { () in
            let dataArray: [AnyObject] = viewModel.dataArray
            XCTAssertTrue(dataArray.count > 1)
        }
    }
}
