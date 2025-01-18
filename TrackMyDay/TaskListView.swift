//
//  TaskListView.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 10/30/24.
//

import SwiftUI
import FirebaseFirestore

struct TaskListView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var tasks: [Task] = []
    @State private var navigateToAddTask = false

    var body: some View {
        NavigationStack {
            VStack {

                Text("Welcome, \(authManager.displayName)!")
                    .font(.headline)
                    .padding(.top)

                
                if tasks.isEmpty {
                    Text("No tasks yet. Add a task to get started!")
                        .padding()
                } else {
                    List {
                        Section(header: Text("To-Do")) {
                            ForEach(tasks.filter { !$0.completed }) { task in
                                NavigationLink(destination: TaskDetailView(task: task, onTaskUpdated: { updatedTask in
                                    updateTask(updatedTask)
                                })) {
                                    HStack {
                                        categoryIcon(for: task.category)
                                        VStack(alignment: .leading) {
                                            Text(task.name)
                                                .font(.headline)
                                            Text("Date: \(task.dateString)")
                                            Text("Time: \(task.time)")
                                        }
                                    }
                                }
                            }
                        }

                        Section(header: Text("Completed")) {
                            ForEach(tasks.filter { $0.completed }) { task in
                                NavigationLink(destination: TaskDetailView(task: task, onTaskUpdated: { updatedTask in
                                    updateTask(updatedTask)
                                })) {
                                    HStack {
                                        categoryIcon(for: task.category)
                                        VStack(alignment: .leading) {
                                            Text(task.name)
                                                .font(.headline)
                                                .strikethrough()
                                                .foregroundColor(.gray)
                                            Text("Date: \(task.dateString)")
                                            Text("Time: \(task.time)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Today's Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Task") {
                        navigateToAddTask = true
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        authManager.signOut()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToAddTask) {
                AddTaskView()
            }
            .onAppear {
                fetchTasks()
            }
        }
    }

    private func updateTask(_ updatedTask: Task) {
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            tasks[index] = updatedTask
        }
    }

    private func fetchTasks() {
        guard let userID = authManager.user?.uid else { return }

        let db = Firestore.firestore()
        db.collection("tasks").document(userID).collection("userTasks").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching tasks: \(error.localizedDescription)")
                return
            }

            if let documents = snapshot?.documents {
                self.tasks = documents.compactMap { doc -> Task? in
                    let data = doc.data()
                    return Task(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        time: data["time"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        category: data["category"] as? String ?? "Other",
                        latitude: data["latitude"] as? Double ?? 0.0,
                        longitude: data["longitude"] as? Double ?? 0.0,
                        completed: data["completed"] as? Bool ?? false
                    )
                }
            }
        }
    }

    private func categoryIcon(for category: String) -> some View {
        switch category {
        case "Personal":
            return Image(systemName: "star.fill").foregroundColor(.red)
        case "Work":
            return Image(systemName: "star.fill").foregroundColor(.green)
        case "School":
            return Image(systemName: "star.fill").foregroundColor(.blue)
        case "Other":
            return Image(systemName: "star.fill").foregroundColor(.orange)
        default:
            return Image(systemName: "star.fill").foregroundColor(.gray)
        }
    }
}

#Preview {
    TaskListView().environmentObject(AuthenticationManager())
}
