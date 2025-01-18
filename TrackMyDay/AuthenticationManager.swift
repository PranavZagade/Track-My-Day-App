//
//  AuthenticationManager.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 11/29/24.
//

import Firebase
import GoogleSignIn
import FirebaseAuth
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var user: FirebaseAuth.User? = nil
    @Published var displayName: String = ""

    init() {
        self.user = Auth.auth().currentUser
        self.isAuthenticated = user != nil
        self.displayName = user?.displayName ?? "Guest"
    }

 
    func signInWithGoogle(presenting: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In Error: \(error.localizedDescription)")
                    return
                }

                
                if let authResult = authResult {
                    let authUser = authResult.user

                    DispatchQueue.main.async {
                        self.user = authUser
                        self.displayName = authUser.displayName ?? "Guest"
                        self.isAuthenticated = true
                    }
                }
            }
        }
    }


    func signUpWithEmail(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let authUser = authResult?.user else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to get user"])))
                return
            }

            DispatchQueue.main.async {
                self.user = authUser
                self.displayName = authUser.email ?? "User"
                self.isAuthenticated = true
                completion(.success(()))
            }
        }
    }


    func loginWithEmail(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let authUser = authResult?.user else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to get user"])))
                return
            }

            DispatchQueue.main.async {
                self.user = authUser
                self.displayName = authUser.email ?? "User"
                self.isAuthenticated = true
                completion(.success(()))
            }
        }
    }


    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.user = nil
            self.displayName = "Guest"
        } catch {
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }
}
