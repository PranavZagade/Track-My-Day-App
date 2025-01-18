//
//  SignupView.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 11/29/24.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isSignedUp = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()

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

                Button("Sign Up") {
                    authManager.signUpWithEmail(email: email, password: password) { result in
                        switch result {
                        case .success:
                            isSignedUp = true
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

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $isSignedUp) {
                LoginView()
            }
        }
    }
}

#Preview {
    SignupView().environmentObject(AuthenticationManager())
}
