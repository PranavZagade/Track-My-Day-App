//
//  TaskDetailView.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 11/30/24.
//

//
//  TaskDetailView.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 11/30/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

struct TaskDetailView: View {
    let task: Task
    var onTaskUpdated: (Task) -> Void

    @Environment(\.dismiss) var dismiss
    @StateObject private var weatherManager = WeatherManager()
    @State private var region: MKCoordinateRegion
    @State private var isDeleting = false
    @State private var isCompleting = false

    init(task: Task, onTaskUpdated: @escaping (Task) -> Void) {
        self.task = task
        self.onTaskUpdated = onTaskUpdated
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: task.latitude, longitude: task.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
            
                Text(task.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

            
                VStack {
                    if weatherManager.isLoading {
                        Text("Fetching weather...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Weather: \(weatherManager.temperature) | \(weatherManager.condition)")
                            .font(.headline)
                            .padding()
                    }
                }
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                
                Text("Location:")
                    .font(.headline)
                Map(coordinateRegion: $region, annotationItems: [AnnotatedLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: task.latitude, longitude: task.longitude), name: task.name)]) { location in
                    MapPin(coordinate: location.coordinate, tint: .red)
                }
                .frame(height: 200)
                .cornerRadius(10)

 
                Text("Date:")
                    .font(.headline)
                Text(task.dateString)
                    .font(.body)

                Text("Time:")
                    .font(.headline)
                Text(task.time)
                    .font(.body)

                Text("Description:")
                    .font(.headline)
                Text(task.description)
                    .font(.body)

                if !task.completed {
                    Button(action: markAsComplete) {
                        if isCompleting {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                                                   startPoint: .top,
                                                   endPoint: .bottom)
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.green.opacity(0.4), radius: 4, x: 0, y: 2)
                                .padding(.top, 20)
                        } else {
                            Text("Mark as Complete")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                                                   startPoint: .top,
                                                   endPoint: .bottom)
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.green.opacity(0.4), radius: 4, x: 0, y: 2)
                                .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal)
                }

                
                Button(action: deleteTask) {
                    if isDeleting {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.red.opacity(0.4), radius: 4, x: 0, y: 2)
                            .padding(.top, 20)
                    } else {
                        Text("Delete Task")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.red.opacity(0.4), radius: 4, x: 0, y: 2)
                            .padding(.top, 20)
                    }
                }
                .padding(.horizontal)

            }
            .padding()
        }
        .navigationTitle(task.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            weatherManager.fetchWeather(lat: task.latitude, lon: task.longitude) 
        }
    }

    private func markAsComplete() {
        isCompleting = true
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("tasks")
            .document(userID)
            .collection("userTasks")
            .document(task.id)
            .updateData(["completed": true]) { error in
                if let error = error {
                    print("Error marking task as complete: \(error.localizedDescription)")
                } else {
                    var updatedTask = task
                    updatedTask.completed = true
                    onTaskUpdated(updatedTask)
                    dismiss()
                }
                isCompleting = false
            }
    }

    private func deleteTask() {
        isDeleting = true
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("tasks")
            .document(userID)
            .collection("userTasks")
            .document(task.id)
            .delete { error in
                if let error = error {
                    print("Error deleting task: \(error.localizedDescription)")
                } else {
                    dismiss()
                }
                isDeleting = false
            }
    }
}
