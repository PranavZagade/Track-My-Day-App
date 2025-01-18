//
//  LoginView.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 11/29/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var navigateToSignup = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .padding()

                // Email and Password Login
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button("Login with Email") {
                    authManager.loginWithEmail(email: email, password: password) { result in
                        switch result {
                        case .success:
                            isLoggedIn = true
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()

                Button(action: {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        authManager.signInWithGoogle(presenting: rootVC)
                    }
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                        Text("Sign in with Google")
                    }
                    .font(.headline)
                    .padding()
                    .frame(width: 280, height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top)

                Button("Sign Up") {
                    navigateToSignup = true
                }
                .padding()
                .foregroundColor(.blue)

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $isLoggedIn) {
                TaskListView()
            }
            .navigationDestination(isPresented: $navigateToSignup) {
                SignupView()
            }
        }
    }
}

#Preview {
    LoginView().environmentObject(AuthenticationManager())
}
