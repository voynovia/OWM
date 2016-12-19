//
//  ForecastFar.swift
//  OWM
//
//  Created by Igor Voynov on 12.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import Foundation
import RealmSwift

class ForecastDailyData: Object {
    dynamic var idWeather = 0 { didSet { compoundKey = compoundKeyValue() } }
    dynamic var dt = 0 { didSet { compoundKey = compoundKeyValue() } }
    dynamic var temp = 0.0
    dynamic var tempMin = 0.0
    dynamic var tempMax = 0.0
    dynamic var pressure = 0
    dynamic var humidity = 0
    dynamic var windSpeed = 0.0
    dynamic var windDeg = 0.0
    dynamic var icon: String!
    
    open dynamic var compoundKey: String = "0-0"
    override static func primaryKey() -> String? {
        return "compoundKey"
    }
    fileprivate func compoundKeyValue() -> String {
        return "\(idWeather)-\(dt)"
    }
}
