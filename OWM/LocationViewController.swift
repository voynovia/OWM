//
//  TableViewController.swift
//  OWM
//
//  Created by Igor Voynov on 14.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import RealmSwift

class LocationViewController: UITableViewController {
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    var searchButton: UIButton!
    
    var weather = OpenWeatherMap()
    
    var locations = [ Array <CityViewModel> ]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    fileprivate struct Storyboard {
        static let Detail = "Detail"
        static let Search = "Search"
    }
    
    var idLocation: Int!
    
    func setLocations() {
        locations.removeAll()
        var cities = [CityViewModel]()
        let realm = try! Realm()
        for current in realm.objects(CurrentData.self) {
            if let city = realm.objects(LocationData.self).filter("id == \(current.idWeather)").first {
                let cityViewModel = CityViewModel()
                cityViewModel.id = current.idWeather
                cityViewModel.name = city.name
                cityViewModel.time = Helpers.timeFromUnix(unixTime: current.dt)
                cityViewModel.temp = Helpers.convertTemperature(country: city.country, temperature: current.temp)
                cities.append(cityViewModel)
            }
        }
        locations.insert(cities, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = false
        super.viewWillAppear(animated)
                
        let imageView = UIImageView(image: #imageLiteral(resourceName: "backgroundImage"))
        imageView.contentMode = .scaleToFill
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
        
        self.tableView.backgroundView = imageView
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight // оценочная высота строки
        tableView.rowHeight = UITableViewAutomaticDimension // автоматическая высота строки
        
        weather.delegate = self
        
        setLocations()
                
//        let realm = try! Realm()
//        if let location = realm.objects(CurrentData.self).first {
//            self.idLocation = location.idWeather
//            self.performSegue(withIdentifier: Storyboard.Detail, sender: nil)
//            //            DispatchQueue.background(background: { self.setLocations() })
//        } else {
//            setLocations()
//        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationvc = segue.destination
        if let navcon = destinationvc as? UINavigationController {
            destinationvc = navcon.visibleViewController ?? destinationvc
        }
        
        if let searchvc = destinationvc as? SearchViewController, segue.identifier == Storyboard.Search {
            searchvc.searchDelegate = self
        }
        
        if let detailvc = destinationvc as? DetailsViewController, segue.identifier == Storyboard.Detail {
            detailvc.idLocation = self.idLocation
        }
        
    }
    
    func searchButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: Storyboard.Search, sender: sender)
    }
    
    func gpsButtonAction(_ sender: UIButton) {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

}

// MARK: - Table view data source
extension LocationViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "City", for: indexPath)
        let location = locations[indexPath.section][indexPath.row]
        if let locationCell = cell as? LocationCell {
            locationCell.location = location
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let location = locations[indexPath.section][indexPath.row]
            // Удаляем из базы данных
            if let id = location.id {
                let realm = try! Realm()
                realm.beginWrite()
                realm.delete(realm.objects(LocationData.self.self).filter("id == \(id)"))
                realm.delete(realm.objects(CurrentData.self.self).filter("idWeather == \(id)"))
                realm.delete(realm.objects(ForecastData.self).filter("idWeather == \(id)"))
                realm.delete(realm.objects(ForecastDailyData.self.self).filter("idWeather == \(id)"))
                try! realm.commitWrite()
            }
            // Удаляем из массива
            locations[indexPath.section].remove(at: indexPath.row)
            tableView.reloadData()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let xOffset = tableView.frame.width / 16
        let control = Control(frame: CGRect(x: xOffset, y: 0, width: tableView.frame.width-xOffset*2, height: 50))
        
        let gpsButton = UIButton(frame: CGRect(x: 0, y: 0, width: xOffset*3, height: control.bounds.height))
        gpsButton.setTitle("➢", for: .normal)
        gpsButton.titleLabel?.font  = UIFont.systemFont(ofSize: 30, weight: UIFontWeightUltraLight)
        gpsButton.setTitleColor(UIColor.white, for: .normal)
        gpsButton.transform = CGAffineTransform(rotationAngle: -45.0*CGFloat(M_PI)/180.0)
        control.addSubview(gpsButton)
        gpsButton.addTarget(self, action: #selector(self.gpsButtonAction(_:)), for: .touchUpInside)
        
        searchButton = UIButton(frame: CGRect(x: tableView.frame.width-xOffset*2, y: 0, width: xOffset*1.5, height: control.bounds.height))
        searchButton.setTitle("⊕", for: .normal)
        searchButton.titleLabel?.font  = UIFont.systemFont(ofSize: 30, weight: UIFontWeightUltraLight)
        searchButton.setTitleColor(UIColor.white, for: .normal)
        control.addSubview(searchButton)
        searchButton.addTarget(self, action: #selector(self.searchButtonAction(_:)), for: .touchUpInside)
        
        return control
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = locations[indexPath.section][indexPath.row]
        self.idLocation = city.id
        self.performSegue(withIdentifier: Storyboard.Detail, sender: nil)
    }
    
    //    // Override to support conditional rearranging of the table view.
    //    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    //        // Return false if you do not want the item to be re-orderable.
    //        return true
    //    }
}

extension LocationViewController: SearchDelegate {
    func searchDidFinish(_ update: Bool) {
        if update {
            setLocations()
        }
    }
}

extension LocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last! as CLLocation
        if  currentLocation.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let coords = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            self.weather.get(geo: coords)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Can't get your location: \(error)")
    }
    
}

extension LocationViewController: OpenWeatherMapDelegate {
    
    func updateCurrentInfo() {
        setLocations()
    }
    
    func updateForecastInfo() {
    }
    func updateForecastDailyInfo() {
    }
    
    func updateForecastsInfo() {
    }
    
    func failure(error: Error) {
        let netwokController = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert )
        let ok = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default)
        netwokController.addAction(ok)
        self.present(netwokController, animated: true)
    }
    
}
