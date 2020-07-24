//
//  LoginViewModel.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import Foundation
import UIKit

import CryptoKit

extension String {
    // MARK: - Code Smell
    var sha256Value: String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.description //While description would work, its a bad practise because its a method and Apple can chnage its behaviour anytime which would break our code.
    }
}

extension String {
    var isEmail : Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

enum LoginError : Error {
    case invalidInput (LoginViewModel.ErrorAlterViewEntity)
    case passwordPolicy (LoginViewModel.ErrorAlterViewEntity)
    case mandatoryInputMissing (LoginViewModel.ErrorAlterViewEntity)
}

struct LoginViewModel {
    struct LoginViewEntity {
        var username: String?
        var password: String?
    }
    
    struct ErrorAlterViewEntity {
        let title: String
        let message: String
        let actionButtonTitle: String
    }
        
    func titleForLoginButton(forBehaviour behaviour : LoginViewController.Behaviour) -> String {
        switch behaviour {
        case .login:
            return "Login"
        case .register:
            return "Create New Account"
        }
    }
    
    func loginErrorMessageFor(_ error: Error) -> ErrorAlterViewEntity {
        return ErrorAlterViewEntity(title: "Login Error", message: error.localizedDescription, actionButtonTitle: "Okay")
    }
    
    func registrationErrorMessageFor(_ error: Error) -> ErrorAlterViewEntity {
        return ErrorAlterViewEntity(title: "Registration Error", message: error.localizedDescription, actionButtonTitle: "Okay")
    }
    
    func getLandmarkUser(from loginViewEntity: LoginViewEntity, handler: @escaping (Result<LandmarkUser, LoginError>) -> Void) {
        
        guard let username = loginViewEntity.username else {
            let errorEntity = ErrorAlterViewEntity(title: "Mandatory Field Empty", message: "You cannot leave the email blank. Please supply a vaild email which you have access to", actionButtonTitle: "Okay")
            return handler(.failure(.mandatoryInputMissing(errorEntity)))
        }
        
        if !isValidEmail(email: username) {
            let errorEntity = ErrorAlterViewEntity(title: "Incorrect Email", message: "Please enter a vaild email that you can access. It would need verification.", actionButtonTitle: "Okay")
            return handler(.failure(.invalidInput(errorEntity)))
        }
        
        guard let password = loginViewEntity.password else {
            let errorEntity = ErrorAlterViewEntity(title: "Mandatory Field Empty", message: "You cannot leave the password blank. Please supply a vaild and secure password", actionButtonTitle: "Okay")
            return handler(.failure(.mandatoryInputMissing(errorEntity)))
        }
        if !isValidPassword(pass: password) {
            let errorEntity = ErrorAlterViewEntity(title: "Password Policy Voilation", message: "Please supply a vaild and secure password that meets the organisations standards", actionButtonTitle: "Okay")
            return handler(.failure(.passwordPolicy(errorEntity)))
        }
        
        let user = LandmarkUser(email: username, password: password.sha256Value)
        handler(.success(user))
    }
    
    private func isValidPassword( pass: String) -> Bool {
        //Check for the password policy
        return true
    }
    
    private func isValidEmail( email: String) -> Bool {
        //Check for the email
        return email.isEmail
    }
}
