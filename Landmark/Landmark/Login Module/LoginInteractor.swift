//
//  LoginInteractor.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

struct FirebaseAuthError : Error {
    var domain: String?
    var userInfo: String?
    var code: Int?
}

enum FirebaseError : Error {
    case registrationError(FirebaseAuthError)
    case loginError(FirebaseAuthError)
}

struct LoginInteractor {
        
    func registerNewUser(withUser user: LandmarkUser, handler: @escaping (Result<FirebaseAuth.AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: user.email, password: user.password) { authResult, error in
            
            if let err = error {
                return handler(.failure(err))
            }
            
            guard let authRes = authResult else {
                return handler(.failure(error!))
            }
            handler(.success(authRes))
        }
    }
        
    func loginUser(withUser user: LandmarkUser, handler: @escaping (Result<FirebaseAuth.AuthDataResult, Error>) -> Void) {
            Auth.auth().signIn(withEmail: user.email, password: user.password) { authResult, error in
                
                if let err = error {
                    return handler(.failure(err))
                }
                
                guard let authRes = authResult else {
                    return handler(.failure(error!))
                }
                handler(.success(authRes))
            }
        }
}
