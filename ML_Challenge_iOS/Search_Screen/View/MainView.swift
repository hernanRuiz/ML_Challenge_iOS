//
//  MainView.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 15/05/2021.
//

import Foundation
import UIKit

class MainView : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    let api = MLApi.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton.isEnabled = false
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    }
    
    //Se habilita o deshabilita el botón de búsqueda según sea o no vacío el campo de búsqueda
    @objc func textChanged(_ textField: UITextField) {
        searchButton.isEnabled = ![searchTextField].contains { $0.text!.isEmpty }
    }
    
    //Comunicación con la pantalla de resultados pasando parámetro de búsqueda
    @IBAction func goToResultsView(){
        if let textToSearch = searchTextField.text {
            let userDefaultStore = UserDefaults.standard
            userDefaultStore.set(textToSearch, forKey: "saved_search_value")
            performSegue(withIdentifier: "goToResults", sender: self)
        }
    }
    
    //Se restringen caracteres especiales en el campo de búsqueda
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        let alphaNumericRegEx = "[a-zA-Z0-9 ]+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicate.evaluate(with: string)
    }
    
    //La búsqueda también se puede disparar al presionar la tecla Enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let textToSearch = searchTextField.text {
            if !textToSearch.isEmpty {
                goToResultsView()
            }
        }
        return true
    }

}
