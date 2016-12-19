//
//  ViewController+OWM.swift
//  OWM
//
//  Created by Igor Voynov on 14.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import UIKit
import RealmSwift

extension DetailViewController: OpenWeatherMapDelegate {
    
    func updateCurrentInfo() {
        let realm = try! Realm()
        if let id = idLocation {
            if let location = realm.objects(LocationData.self).filter("id == \(id)").first {
                self.townLabel.set(text: location.name, size: fontSizeCity, alignment: .center)
                self.country = location.country
            }
            
            for subview in currentView.subviews {
                subview.removeFromSuperview()
            }
            
            if let current = realm.objects(CurrentData.self).filter("idWeather == \(id)").first {
                
                self.detailLabel.set(text: current.desc, size: fontSizeText, alignment: .center)
                let temp = Int(Helpers.convertTemperature(country: self.country, temperature: current.temp))
                self.tempLabel.set(text: String(temp), size: fontSizeTemp, alignment: .center)
                self.tempLabel.font = UIFont.systemFont(ofSize: fontSizeTemp, weight: UIFontWeightUltraLight)
                let tempMin = Int(Helpers.convertTemperature(country: self.country, temperature: current.tempMin))
                let tempMax = Int(Helpers.convertTemperature(country: self.country, temperature: current.tempMax))
                self.currentLine.set(minTemp: String(tempMin), maxTemp: String(tempMax), fontSize: fontSizeText)
                
                let sunrise = Helpers.timeFromUnix(unixTime: current.sunrise)
                let currentSunrise = UIView(frame: CGRect(x: 0, y: 0, width: currentView.bounds.width, height: quarterPartHeight))
                currentSunrise.addLabels(name: "Sunrise:", value: sunrise, fontSize: fontSizeText)
                currentView.addSubview(currentSunrise)

                let sunset = Helpers.timeFromUnix(unixTime: current.sunset)
                let currentSunset = UIView(frame: CGRect(x: 0, y: quarterPartHeight, width: currentView.bounds.width, height: quarterPartHeight))
                currentSunset.addLabels(name: "Sunset:", value: sunset, fontSize: fontSizeText)
                currentView.addSubview(currentSunset)

                let currentHumidity = UIView(frame: CGRect(x: 0, y: quarterPartHeight*2, width: currentView.bounds.width, height: quarterPartHeight))
                currentHumidity.addLabels(name: "Humidity:", value: String(current.humidity), fontSize: fontSizeText)
                currentView.addSubview(currentHumidity)

                let currentPressure = UIView(frame: CGRect(x: 0, y: quarterPartHeight*3, width: currentView.bounds.width, height: quarterPartHeight))
                currentPressure.addLabels(name: "Pressure:", value: String(current.pressure), fontSize: fontSizeText)
                currentView.addSubview(currentPressure)

                let currentSpeed = UIView(frame: CGRect(x: 0, y: quarterPartHeight*4, width: currentView.bounds.width, height: quarterPartHeight))
                currentSpeed.addLabels(name: "Wind speed:", value: "\(current.windSpeed) m/s", fontSize: fontSizeText)
                currentView.addSubview(currentSpeed)

                var direction: String!
                let directions = ["N", "NNE", "NE", "EEN", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N"]
                var k = 0
                for i in stride(from: -M_PI/16, through: 2*M_PI, by: M_PI/8) {
                    if current.windDeg > i * (180/M_PI) {
                        direction = directions[k]
                    }
                    k+=1
                }

                let currentDeg = UIView(frame: CGRect(x: 0, y: quarterPartHeight*5, width: currentView.bounds.width, height: quarterPartHeight))
                currentDeg.addLabels(name: "Wind deg:", value: direction, fontSize: fontSizeText)
                currentView.addSubview(currentDeg)

            }

        }
    }
    
    func updateForecastInfo() {
        let realm = try! Realm()
        if let id = idLocation {
            
            for subview in hourly.subviews {
                subview.removeFromSuperview()
            }
            
            let width: CGFloat = hourly.bounds.width / 6.5
            let h: CGFloat = hourly.bounds.height / 12
            
            let forecasts = realm.objects(ForecastData.self).filter("idWeather == \(id)")
            var i = 0
            for forecast in forecasts {
                
                let cell = UIView(frame: CGRect(x: CGFloat(i)*width, y: 0, width: width, height: hourly.bounds.height))
                
                let hour = Helpers.timeFromUnix(unixTime: forecast.dt).toChar(from: ":")!
                let hourLabel = UILabel(frame: CGRect(x: 0, y: h, width: cell.bounds.width, height: h*2))
                hourLabel.set(text: hour, size: fontSizeText, alignment: .center)
                cell.addSubview(hourLabel)
                
                let iconView = UIImageView(frame: CGRect(x: 0, y: h*4, width: cell.bounds.width, height: h*4))
                iconView.backgroundColor = UIColor.clear
                iconView.image = UIImage(named: forecast.icon)
                iconView.contentMode = .scaleAspectFit
                cell.addSubview(iconView)
                
                let temp = Int(Helpers.convertTemperature(country: self.country, temperature: forecast.temp))
                let tempLabel = UILabel(frame: CGRect(x: 0, y: h*9, width: cell.bounds.width, height: h*2))
                tempLabel.set(text: String(temp), size: fontSizeText, alignment: .center)
                cell.addSubview(tempLabel)
                
                hourly.addSubview(cell)
                
                i+=1
            }
            
            hourly.contentSize = CGSize(width: width * CGFloat(forecasts.count), height: hourly.bounds.height)
        }
    }
    func updateForecastDailyInfo() {
                
        let realm = try! Realm()
        if let id = idLocation {
            
            for subview in days.subviews {
                subview.removeFromSuperview()
            }
            
            let forecasts = realm.objects(ForecastDailyData.self).filter("idWeather == \(id)")
            
            let xOffset = days.bounds.width / 16

            var i = 0
            for forecast in forecasts {
                
                let line = UIView(frame: CGRect(x: xOffset, y: CGFloat(i)*quarterPartHeight, width: days.bounds.width-xOffset*2, height: quarterPartHeight))
                
                let day = Helpers.dayFromUnix(unixTime: forecast.dt)
                let dayLabel = UILabel(frame: CGRect(x: 0, y: 0, width: line.bounds.width / 2, height: line.bounds.height))
                dayLabel.set(text: day, size: fontSizeText, alignment: .left)
                line.addSubview(dayLabel)
                
                let iconView = UIImageView(frame: CGRect(x: line.bounds.width/2-xOffset, y: 0, width: xOffset*2, height: line.bounds.height))
                iconView.backgroundColor = UIColor.clear
                iconView.image = UIImage(named: forecast.icon)
                iconView.contentMode = .scaleAspectFit
                line.addSubview(iconView)
                
                let tempMin = Int(Helpers.convertTemperature(country: self.country, temperature: forecast.tempMin))
                let minLabel = UILabel(frame: CGRect(x: line.bounds.width/2+xOffset, y: 0, width: line.bounds.width/2-xOffset*3, height: line.bounds.height))
                minLabel.set(text: String(tempMin), size: fontSizeText, alignment: .right)
                line.addSubview(minLabel)
                
                let tempMax = Int(Helpers.convertTemperature(country: self.country, temperature: forecast.tempMax))
                let maxLabel = UILabel(frame: CGRect(x: line.bounds.width-xOffset*3, y: 0, width: xOffset*3, height: line.bounds.height))
                maxLabel.set(text: String(tempMax), size: fontSizeText, alignment: .right)
                line.addSubview(maxLabel)
                
                days.addSubview(line)
                
                i+=1
            }
            
            print(days.bounds)
            print(days.frame)
            
        }
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
