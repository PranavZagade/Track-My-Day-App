//
//  AddTaskView.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 11/29/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import CoreLocation

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var taskName = ""
    @State private var taskDate = Date()
    @State private var taskTime = Date()
    @State private var taskDescription = ""
    @State private var selectedCategory = "Personal"
    @State private var searchQuery = ""
    @State private var selectedLocation: AnnotatedLocation?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.415, longitude: -111.909), 
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var errorMessage = ""

    @ObservedObject private var searchCompleter = LocationSearchCompleter()
    @StateObject private var locationManager = LocationManager()

    let categories = ["Personal", "Work", "School", "Other"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Task Name", text: $taskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                DatePicker("Date", selection: $taskDate, displayedComponents: .date)
                    .padding(.horizontal)

                DatePicker("Time", selection: $taskTime, displayedComponents: .hourAndMinute)
                    .padding(.horizontal)

                TextField("Description", text: $taskDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 0) {
                    TextField("Search Location", text: $searchQuery)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .onChange(of: searchQuery) { newValue in
                            searchCompleter.updateQuery(query: newValue)
                        }

                    if !searchCompleter.results.isEmpty {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(searchCompleter.results.prefix(5), id: \.title) { result in
                                    Button(action: {
                                        selectSuggestion(result)
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(result.title)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                if !result.subtitle.isEmpty {
                                                    Text(result.subtitle)
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: "mappin.circle")
                                                .foregroundColor(.blue)
                                                .imageScale(.large)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                        .shadow(color: Color(.black).opacity(0.1), radius: 3, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 900)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }

                }


                Map(coordinateRegion: $region, annotationItems: selectedLocation != nil ? [selectedLocation!] : []) { location in
                    MapPin(coordinate: location.coordinate, tint: .red)
                }
                .frame(height: 200)
                .cornerRadius(10)
                .padding(.horizontal)

                Button("Save Task") {
                    saveTask()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Add Task")
            .onAppear {
                updateToCurrentLocation()
            }
        }
    }

    private func updateToCurrentLocation() {
        if let currentLocation = locationManager.currentLocation {
            region.center = currentLocation.coordinate
        }
    }

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = suggestion.title

        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                errorMessage = "Error fetching location: \(error.localizedDescription)"
                return
            }

            if let mapItem = response?.mapItems.first {
                let coordinate = mapItem.placemark.coordinate
                selectedLocation = AnnotatedLocation(id: UUID(), coordinate: coordinate, name: mapItem.name ?? suggestion.title)
                region.center = coordinate
                searchQuery = mapItem.name ?? suggestion.title
            }
        }
    }

    private func saveTask() {
        guard let userID = authManager.user?.uid else { return }
        guard !taskName.isEmpty, !taskDescription.isEmpty, let location = selectedLocation else {
            errorMessage = "Please fill out all fields and select a location."
            return
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let db = Firestore.firestore()
        let taskData: [String: Any] = [
            "name": taskName,
            "date": Timestamp(date: taskDate),
            "time": formatter.string(from: taskTime),
            "description": taskDescription,
            "category": selectedCategory,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]

        db.collection("tasks")
            .document(userID)
            .collection("userTasks")
            .addDocument(data: taskData) { error in
                if let error = error {
                    errorMessage = "Error saving task: \(error.localizedDescription)"
                } else {
                    dismiss()
                }
            }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch location: \(error.localizedDescription)")
    }
}

struct AnnotatedLocation: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let name: String
}
