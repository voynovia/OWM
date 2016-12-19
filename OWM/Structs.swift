//
//  Helpers.swift
//  OWM
//
//  Created by Igor Voynov on 12.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import Foundation

struct Helpers {
    
    static func convertTemperature(country: String, temperature: Double) -> Double {
        if country == "US" {
            return round((temperature - 273.15*1.8)+32)
        } else {
            return round(temperature - 273.15)
        }
    }
    
    static func timeFromUnix(unixTime: Int) -> String {
        let timeInSecond = TimeInterval(unixTime)
        let weatherDate = Date(timeIntervalSince1970: timeInSecond)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:MM"
        return dateFormatter.string(from: weatherDate as Date)
    }
    
    static func dayFromUnix(unixTime: Int) -> String {
        let timeInSecond = TimeInterval(unixTime)
        let weatherDate = Date(timeIntervalSince1970: timeInSecond)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eeee"
        return dateFormatter.string(from: weatherDate as Date)
    }
    
}
