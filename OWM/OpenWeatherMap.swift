//
//  OpenWeatherMap.swift
//  OWM
//
//  Created by Igor Voynov on 11.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON
import RealmSwift

protocol OpenWeatherMapDelegate {
    func updateCurrentInfo() // текущая погода
    func updateForecastInfo() // прогноз по часам
    func updateForecastDailyInfo() // прогноз по дням
    func updateForecastsInfo() // все данные получены
    func failure(error: Error)
}

protocol OpenWeatherMapFindDelegate {
    func findCurrentInfo(locationList: [LocationData], currentList: [CurrentData]) // передаем то что нашли
    func failure(error: Error)
}

class OpenWeatherMap {
    
    let weatherAppId = "f265c3098988a206bfee7187471fbfc1"
    let weatherURL = "http://api.openweathermap.org/data/2.5/"
    
    var delegate: OpenWeatherMapDelegate!
    
    var delegateFind: OpenWeatherMapFindDelegate!
    var findCurrentList = [CurrentData]()
    var findLocationList = [LocationData]()
    
    let forecastsGroup =  DispatchGroup()
    
    var durationAccord: [Duration: String] = [
        .current: "weather",
        .forecast: "forecast",
        .forecastDaily: "forecast/daily"
    ]
    
    var durationCurrent = Duration.current
    
    func get(id: Int) {
        let params = ["appid": weatherAppId, "id": String(id)]
        requestCurrent(parameters: params)
    }

    func get(city: String) {
        let params = ["appid": weatherAppId, "q": city]
        requestCurrent(parameters: params)
    }
    
    func get(zip: String) {
        let params = ["appid": weatherAppId, "zip": zip]
        requestCurrent(parameters: params)
    }

    func get(geo: CLLocationCoordinate2D) {
        let params = ["appid": weatherAppId, "lat": String(geo.latitude), "lon": String(geo.longitude)]
        requestCurrent(parameters: params)
    }
    
    func requestCurrent(parameters: [String:String]) {
        if let duration = self.durationAccord.first(where: { $0.key == Duration.current }) {
            Alamofire.request(weatherURL+duration.value, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success:
                    if let result = response.result.value {
                        let json = SwiftyJSON.JSON(result)
                        self.processCurrent(currentJSON: json)
                        DispatchQueue.main.async {
                            // выводим на экран текущую погоду
                            self.delegate.updateCurrentInfo()
                            // запрашиваем прогнозы
                            self.requsetForecasts(parameters: parameters)
                            self.forecastsGroup.notify(queue: DispatchQueue.main, execute: {
                                // выводим на экран прогнозы
                                self.delegate.updateForecastsInfo()
                            })
                        }
                    }
                case .failure(let error):
                    self.delegate.failure(error: error)
                }
            }
        }
    }
    
    func requsetForecasts(parameters: [String:String]) {
        for duration in Duration.forecasts {
            if let duration = self.durationAccord.first(where: { $0.key == duration}) {
                self.forecastsGroup.enter()
                Alamofire.request(weatherURL+duration.value, parameters: parameters).responseJSON { response in
                    switch response.result {
                    case .success:
                        if let result = response.result.value {

                            let json = SwiftyJSON.JSON(result)
                            
//                            if json["cod"].intValue != 200 {
//                                print("message:", json["message"].stringValue)
//                                return
//                            }

                            switch duration.key {
                            case .forecast: self.processForecast(weatherJSON: json)
                            case .forecastDaily: self.processForecastDaily(weatherJSON: json)
                            default: break
                            }
                            DispatchQueue.main.async {
                                switch duration.key {
                                case .forecast: self.delegate.updateForecastInfo()
                                case .forecastDaily: self.delegate.updateForecastDailyInfo()
                                default: break
                                }
                            }
                        }
                    case .failure(let error):
                        self.delegate.failure(error: error)
                    }
                    self.forecastsGroup.leave()
                }

            }
        }
    }
    
    func processCurrent(currentJSON: JSON) {
        let realm = try! Realm()
        
        let windJSON = currentJSON["wind"]
        let sysJSON = currentJSON["sys"]
        let mainJSON = currentJSON["main"]
        let country = sysJSON["country"].stringValue
        let weatherJSON = currentJSON["weather"][0]
        
        let current = CurrentData()
        current.idWeather = currentJSON["id"].intValue
        current.dt = currentJSON["dt"].intValue
        current.sunrise = sysJSON["sunrise"].intValue
        current.sunset = sysJSON["sunset"].intValue
        current.humidity = mainJSON["humidity"].intValue
        current.pressure = mainJSON["pressure"].intValue
        current.temp = mainJSON["temp"].doubleValue
        current.tempMin = mainJSON["temp_min"].doubleValue
        current.tempMax = mainJSON["temp_max"].doubleValue
        current.windSpeed = windJSON["speed"].doubleValue
        current.windDeg = windJSON["deg"].doubleValue
        current.icon = weatherJSON["icon"].stringValue
        current.desc = weatherJSON["description"].stringValue
        
        try! realm.write {
            realm.add(current, update: true)
        }
        
        let location = LocationData()
        location.id = currentJSON["id"].intValue
        location.name = currentJSON["name"].stringValue
        location.country = country
        location.current = current
        try! realm.write {
            realm.add(location, update: true)
        }
    }
    
    func processForecast(weatherJSON: JSON) {
        let realm = try! Realm()
        let cityJSON = weatherJSON["city"]
        let listJSON = weatherJSON["list"].arrayValue
        let id = cityJSON["id"].intValue
        if let weather = realm.objects(LocationData.self).filter("id == \(id)").first {
            realm.beginWrite()
            for item in listJSON {
                let mainJSON = item["main"]
                let windJSON = item["wind"]
                let weatherJSON = item["weather"][0]
                let forecast = ForecastData()
                forecast.idWeather = id
                forecast.dt = item["dt"].intValue
                forecast.temp = mainJSON["temp"].doubleValue
                forecast.tempMin = mainJSON["temp_min"].doubleValue
                forecast.tempMax = mainJSON["temp_max"].doubleValue
                forecast.pressure = mainJSON["pressure"].intValue
                forecast.humidity = mainJSON["humidity"].intValue
                forecast.windSpeed = windJSON["speed"].doubleValue
                forecast.windDeg = windJSON["deg"].doubleValue
                forecast.icon = weatherJSON["icon"].stringValue
                realm.add(forecast, update: true)
                weather.forecasts.append(forecast)
            }
            try! realm.commitWrite()
        }
    }
    
    func processForecastDaily(weatherJSON: JSON) {
        let realm = try! Realm()
        let cityJSON = weatherJSON["city"]
        let listJSON = weatherJSON["list"].arrayValue
        let id = cityJSON["id"].intValue
        if let weather = realm.objects(LocationData.self).filter("id == \(id)").first {
            realm.beginWrite()
            for item in listJSON {
                let tempJSON = item["temp"]
                let weatherJSON = item["weather"][0]
                let forecastDaily = ForecastDailyData()
                forecastDaily.idWeather = id
                forecastDaily.dt = item["dt"].intValue
                forecastDaily.temp = tempJSON["day"].doubleValue
                forecastDaily.tempMin = tempJSON["min"].doubleValue
                forecastDaily.tempMax = tempJSON["max"].doubleValue
                forecastDaily.pressure = item["pressure"].intValue
                forecastDaily.humidity = item["humidity"].intValue
                forecastDaily.windSpeed = item["speed"].doubleValue
                forecastDaily.windDeg = item["deg"].doubleValue
                forecastDaily.icon = weatherJSON["icon"].stringValue
                realm.add(forecastDaily, update: true)
                weather.forecastDailies.append(forecastDaily)
            }
            try! realm.commitWrite()
        }
    }
    
}

// get names of the cities
extension OpenWeatherMap {
    
    func find(text: String) {
        let params = ["appid": weatherAppId, "q": text, "type": "like", "sort": "population", "cnt": "15"]
        findRequest(parameters: params)
    }
    
    func findRequest(parameters: [String:String]) {
        Alamofire.request(weatherURL+"find", parameters: parameters).responseJSON { response in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    let json = SwiftyJSON.JSON(result)
                    self.findProcess(json: json)
                    DispatchQueue.main.async {
                        // передаем информацию
                        self.delegateFind.findCurrentInfo(locationList: self.findLocationList, currentList: self.findCurrentList)
                    }
                }
            case .failure(let error):
                self.delegateFind.failure(error: error)
            }
        }
    }
    
    func findProcess(json: JSON) {
        let listJSON = json["list"].arrayValue
        for item in listJSON {
            
            let windJSON = item["wind"]
            let sysJSON = item["sys"]
            let mainJSON = item["main"]
            let country = sysJSON["country"].stringValue
            let weatherJSON = item["weather"][0]
            
            let current = CurrentData()
            current.idWeather = item["id"].intValue
            current.dt = item["dt"].intValue
            current.sunrise = sysJSON["sunrise"].intValue
            current.sunset = sysJSON["sunset"].intValue
            current.humidity = mainJSON["humidity"].intValue
            current.pressure = mainJSON["pressure"].intValue
            current.temp = mainJSON["temp"].doubleValue
            current.tempMin = mainJSON["temp_min"].doubleValue
            current.tempMax = mainJSON["temp_max"].doubleValue
            current.windSpeed = windJSON["speed"].doubleValue
            current.windDeg = windJSON["deg"].doubleValue
            current.icon = weatherJSON["icon"].stringValue
            current.desc = weatherJSON["description"].stringValue
            findCurrentList.append(current)
            
            let location = LocationData()
            location.id = item["id"].intValue
            location.name = item["name"].stringValue
            location.country = country
            location.current = current
            findLocationList.append(location)
        }
    }
}
