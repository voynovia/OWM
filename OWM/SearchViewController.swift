//
//  SearchViewController.swift
//  OWM
//
//  Created by Igor Voynov on 14.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import MBProgressHUD

protocol SearchDelegate {
    func searchDidFinish(_ update: Bool)
}

class SearchViewController: UITableViewController, UITextFieldDelegate {
    
    var hud = MBProgressHUD() // индикатор загруженности
    
    var searchDelegate: SearchDelegate? // делегат для ответа
    var weather = OpenWeatherMap()
    
    var cities = [ Array<LocationData> ]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            cities.removeAll() // удаляю все города
            searchForCities() // поиск новых городов
            title = searchText // устанавливаем заголовок
        }
    }
    
    var currentList = [CurrentData]()
    
    fileprivate func searchForCities() {
        if let query = searchText, !query.isEmpty {
            self.activityIndicator() // включаем индикатор
            weather.find(text: query)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = false
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let imageView = UIImageView(image: #imageLiteral(resourceName: "backgroundImage"))
        imageView.contentMode = .scaleToFill
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
        
        self.tableView.backgroundView = imageView
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weather.delegateFind = self
    }
    
    func activityIndicator() {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Loading"
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        if searchDelegate != nil {
            searchDelegate?.searchDidFinish(false)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // отписываемся от First Responder
        searchText = textField.text // устанавливаем строку поиска текстом, который ввел пользователь
        return true
    }
    
}

// Table view data source
extension SearchViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "City", for: indexPath)
        let city = cities[indexPath.section][indexPath.row]
        if let cityCell = cell as? SearchCell {
            cityCell.city = city
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = cities[indexPath.section][indexPath.row]
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(location, update: true) // записываем в базу выбранное местопложение
        for current in self.currentList.filter({ $0.idWeather == location.id }) {
            realm.add(current, update: true) // записываем текущую погоду
        }
        try! realm.commitWrite()
        
        if searchDelegate != nil {
            searchDelegate?.searchDidFinish(true)
        }
        self.dismiss(animated: true, completion: nil)
    }

}

extension SearchViewController: OpenWeatherMapFindDelegate {
    
    internal func findCurrentInfo(locationList: [LocationData], currentList: [CurrentData]) {
        self.currentList = currentList
        self.cities.insert(locationList, at: 0)
        self.hud.hide(animated: true) // Скрываем индикатор
    }
    
    func failure(error: Error) {
        self.hud.hide(animated: true) // Скрываем индикатор
        let netwokController = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert )
        let ok = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default)
        netwokController.addAction(ok)
        self.present(netwokController, animated: true)
    }
    
}
