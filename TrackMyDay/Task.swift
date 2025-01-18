//
//  Task.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 11/30/24.
//
import Foundation
import FirebaseFirestore

struct Task: Identifiable {
    var id: String
    var name: String
    var date: Date
    var time: String
    var description: String
    var category: String 
    var latitude: Double
    var longitude: Double
    var completed: Bool

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
