//
//  ErrorViewModel.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 25/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import UIKit

struct ErrorViewEntity {
    let title: String
    let message: String
    let actionButtonTitle: String = "Okay"
}

struct ErrorViewPresenter {
    weak var controller: UIViewController?
    
    init(withController controller: UIViewController) {
        self.controller = controller
    }
    
    func showAlterView(withViewModel model: ErrorViewEntity) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.actionButtonTitle,
                                      style: .default, handler: nil))
        DispatchQueue.main.async {
            self.controller?.present(alert, animated: true)
        }
    }
}

//struct ErrorViewModel {
//    
//}
