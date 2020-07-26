//
//  LoginViewController.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import UIKit
import CryptoKit
import Firebase

class LoginViewController: UITableViewController {
    
    //MARK: - Code Smell
    //No matter how elegantly you handle the states and behaviours of a view, it should not have multiple behaviours to begin with as it breaks the Single Responsibility Princple. What we're really trying to do here is re-use the view. There are other cleaner ways to do it. I'm just proving a point here
    enum Behaviour {
        case login, register
    }
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginOrRegisterToggle: UISegmentedControl!
    
    private var viewModel: LoginViewModel = LoginViewModel()
    private var presenter: LoginPresenter!
    
    override func viewDidLoad() {
        self.presenter  = LoginPresenter(withController: self)
    }
    
    func dismissSelf() {
        self.dismiss(animated : true) {
            self.presenter = nil
        }
    }
    
    func showAlterView(withViewModel model: LoginViewModel.ErrorAlterViewEntity) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.actionButtonTitle,
                                      style: .default, handler: nil))
        self.present(alert, animated: true)
    }
        
    @IBAction func loginOrRegisterAction(_ sender: UIButton) {
        let user = LoginViewModel.LoginViewEntity(username: usernameField.text, password: passwordField.text)
        presenter.loginOrRegisterButtonClicked(user)
    }
    
    @IBAction func loginOrRegisterToggleAction(_ sender: UISegmentedControl) {
        presenter.loginOrRegisterToggleChanged(sender.selectedSegmentIndex)
    }
    
    func setLoginButtonTitle(_ title: String) {
        self.loginButton.setTitle(title, for: .normal)
        self.loginButton.setNeedsLayout()
    }
}
