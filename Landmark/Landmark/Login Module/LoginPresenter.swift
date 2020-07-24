//
//  LoginPresenter.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import Foundation
import FirebaseAuth

struct LoginPresenter {
        
    private var interactor: LoginInteractor = LoginInteractor()
    //private var router: LoginRouter = LoginRouter()
    weak var controller : LoginViewController?
    
    private var viewModel: LoginViewModel = LoginViewModel()
    
    private var currentBehaviour: LoginViewController.Behaviour = .register {
        didSet {
            self.loginViewBehaviourChanged()
        }
    }
    
    init(withController controller: LoginViewController) {
        self.controller = controller
    }
    
    mutating func loginOrRegisterToggleChanged(_ selection: Int) {
        self.currentBehaviour = (selection == 0) ? .register : .login
    }
    
    func loginOrRegisterButtonClicked(_ viewEntity: LoginViewModel.LoginViewEntity) {
        viewModel.getLandmarkUser(from: viewEntity, handler: { result in
            switch result {
            case .success(let user):
                self.performLoginButtonAction(forUser: user)
            case .failure(let error):
                print(error)
                switch error {
                case .invalidInput(let errorEntity):
                    self.controller?.showAlterView(withViewModel: errorEntity)
                case .mandatoryInputMissing(let errorEntity):
                    self.controller?.showAlterView(withViewModel: errorEntity)
                case .passwordPolicy(let errorEntity):
                    self.controller?.showAlterView(withViewModel: errorEntity)
                }
            }
        })
    }
    
    private func performLoginButtonAction(forUser user: LandmarkUser) {
        switch currentBehaviour {
        case .login:
            attemptToLoginUser(withCredentials: user)
        case .register:
            attemptToRegisterNewUser(withCredentials: user)
        }
    }
    
    private func attemptToLoginUser(withCredentials user: LandmarkUser) {
        interactor.loginUser(withUser: user) { result in
            switch result {
            case .success(let user):
                let vc = self.controller?.presentingViewController?.children.first
                if let myvc: MasterViewController = (vc?.children.first as? MasterViewController) {
                    myvc.currentUser = user.user
                }
                self.controller?.dismissSelf()
            case .failure(let error):
                let e = self.viewModel.loginErrorMessageFor(error)
                self.controller?.showAlterView(withViewModel: e)
            }
        }
    }
    
    private func attemptToRegisterNewUser(withCredentials user: LandmarkUser) {
        interactor.registerNewUser(withUser: user) { result in
            switch result {
            case .success(let user):
                let vc = self.controller?.presentingViewController?.children.first
                if let myvc: MasterViewController = (vc?.children.first as? MasterViewController) {
                    myvc.currentUser = user.user
                }
                
                self.controller?.dismissSelf()
            case .failure(let error):
                let e = self.viewModel.registrationErrorMessageFor(error)
                self.controller?.showAlterView(withViewModel: e)
            }
        }
    }
    
    private func loginViewBehaviourChanged() {
        let title = viewModel.titleForLoginButton(forBehaviour: currentBehaviour)
        DispatchQueue.main.async {
            self.controller?.setLoginButtonTitle(title)
        }
    }
}
