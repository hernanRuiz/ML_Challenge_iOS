//
//  MLSearchView.swift
//  ML_Challenge_iOS
//
//  Created by Hernan Ruiz on 15/05/2021.
//

import Foundation
import UIKit
import os

class MLSearchView : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var viewModel = MLSearchViewModel()
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    @IBOutlet weak var labelError: UILabel!
    var isLoading = false
    var isGoingToAppendMoreData = false
    
    override func viewDidLoad(){
        bind()
        configureView()
        super.viewDidLoad()
    }
    
    //Se habilita o deshabilita el botón de búsqueda según sea o no vacío el campo de búsqueda
    @objc func textChanged(_ textField: UITextField) {
        searchButton.isEnabled = ![searchTextField].contains { $0.text!.isEmpty }
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
    
    private func configureView(){
        //Seteamos en la tabla el uso y altura de mi celda custom
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        tableView.rowHeight = 150.0
        //Seteamos comportamiento del campo de texto y del botón de búsqueda
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        let userDefault = UserDefaults.standard
        
        //Se dispara una búsqueda si recibimos un valor del viewController anterior a este.
        let savedSearchValue = userDefault.string(forKey: "saved_search_value")
        if let value = savedSearchValue {
            searchTextField.text = value
            //se setea límite de 25 registros por llamado a la API
            viewModel.retrieveResults(param: value + "&limit=25")
            labelError.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            searchButton.isEnabled = false
        }
    }
    
    @IBAction func search(){
        if let text = searchTextField.text {
            self.activityIndicator.isHidden = false
            labelError.isHidden = true
            self.tableView.isHidden = true
            self.activityIndicator.startAnimating()
            isLoading = true
            isGoingToAppendMoreData = false
            //se setea límite de 25 registros por llamado a la API
            retrieveResults(param: text + "&limit=25")
        }
    }
    
    private func retrieveResults(param: String){
        viewModel.retrieveResults(param: param)
    }
    
    private func search(offset: String){
        if let text = searchTextField.text {
            isLoading = true
            isGoingToAppendMoreData = true
            //offset setea desde que registro en adelante buscar en el próximo llamado a la API
            retrieveResults(param: text + "&limit=25&offset=" + offset)
        }
    }
    
    //Comportamiento que se muestra al usuario
    private func bind (){
        viewModel.refreshData = { [weak self] () in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
            if let dataArray = self?.viewModel.dataArray {
                if dataArray.isEmpty {
                    self?.logger.log("BUSQUEDA SIN RESULTADOS")
                    //se muestra en pantalla un label con mensaje de que la busqueda no dio resultados
                    self?.labelError.isHidden = false
                    self?.labelError.text = "noResults".localized
                } else if dataArray is [NSError] {
                    //se muestra en pantalla un label con mensaje de Error
                    self?.labelError.isHidden = false
                    self?.labelError.text = "searchError".localized
                } else {
                    self?.isLoading = false
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        if self?.isGoingToAppendMoreData == false {
                            self?.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
                        }
                        self?.tableView.isHidden = false
                    }
                }
            }
        }
    }
    
    //La búsqueda también se puede disparar al presionar la tecla Enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let textToSearch = searchTextField.text {
            if !textToSearch.isEmpty {
                search()
            }
        }
        return true
    }
}


extension MLSearchView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Definimos la celda de mi tabla seteándola como mi celda custom
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        let cellData = viewModel.dataArray[indexPath.row]
        //Armamos las celdas si el array de resultados no es vacío
        if !viewModel.dataArray.isEmpty, !(viewModel.dataArray is [NSError]) {
            let resultCellData = cellData as! MyResult
            //Seteamos en la celda los datos que vienen de la API
            cell.titleLabel?.text = resultCellData.title
            cell.titleLabel?.lineBreakMode = .byWordWrapping
            
            if let index = (resultCellData).attributes.firstIndex(where: { (item) -> Bool in
                return (item).id == "ITEM_CONDITION"}) {
                cell.conditionLabel?.text = resultCellData.attributes[index].value_name
            }
            
            if let price = resultCellData.price {
                let stringPrice = "$ " + String(format: "%.2f", price)
                cell.priceLabel?.text = stringPrice
            }
            
            //Configuramos la imageView y le cargo imagen desde url
            do {
                if let urlString = resultCellData.thumbnail?.replacingOccurrences(of: "http://", with: "https://") {
                    if let url = URL(string: urlString) {
                        let data = try Data(contentsOf: url)
                        cell.imageView?.contentMode = UIView.ContentMode.scaleToFill
                        cell.imageView?.clipsToBounds = true
                        let cellImage : UIImageView = UIImageView()
                        cellImage.contentMode = UIView.ContentMode.scaleAspectFill
                        cellImage.clipsToBounds = true
                        cellImage.image = UIImage(data: data)
                        cell.imageVIew.image = cellImage.image
                        cell.imageVIew.frame = CGRect(x: 0,y: 0,width: 150,height: 100)
                    }
                }
            }
            catch{
                self.logger.log("Error en el procesamiento de imagen via URL")
            }
        }
        
        return cell
    }
    
    //Comunicación con la vista de detalles del producto
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Paginado de la tabla
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let userDefault = UserDefaults.standard
        
        //Se dispara una búsqueda si recibimos un valor del viewController anterior a este.
        let totalResultsCount = userDefault.integer(forKey: "total_results_count")
        let lastElement = viewModel.dataArray.count - 1
        if !isLoading, indexPath.row == lastElement, viewModel.dataArray.count < totalResultsCount {
            search(offset: "25")
        }
    }
    
    //Parámetros que se envían a la vista de Detalles
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? MLDetailsView
        if let index = tableView.indexPathForSelectedRow {
            let myResult: MyResult = viewModel.dataArray[index.row] as! MyResult
            destination?.cellData = myResult
        }
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
