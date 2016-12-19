//
//  Location.swift
//  OWM
//
//  Created by Igor Voynov on 11.12.16.
//  Copyright © 2016 Igor Voynov. All rights reserved.
//

import Foundation
import RealmSwift

class LocationData: Object {
    dynamic var id = 0
    dynamic var name: String!
    dynamic var country: String!
    
    var current: CurrentData!
    var forecasts = List<ForecastData>()
    var forecastDailies = List<ForecastDailyData>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
