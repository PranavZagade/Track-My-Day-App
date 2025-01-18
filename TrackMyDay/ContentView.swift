//
//  ContentView.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 10/30/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Track My Day")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                NavigationLink(destination: TaskListView()) {
                    Text("Get Started")
                        .font(.headline)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    ContentView()
}
