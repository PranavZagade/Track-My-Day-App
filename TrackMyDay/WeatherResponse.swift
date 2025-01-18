//
//  WeatherResponse.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 11/29/24.
//

import Foundation

struct WeatherResponse: Decodable {
    let current: CurrentWeather
}

struct CurrentWeather: Decodable {
    let temp_c: Double
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
}

