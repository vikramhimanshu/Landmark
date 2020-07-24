//
//  MasterViewController.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import UIKit
import FirebaseAuth.FIRUser

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Note]()
    
    public var currentUser: User? {
        didSet {
            DispatchQueue.main.async {
                self.title = self.currentUser?.email
                self.navigationItem.title = self.currentUser?.email
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let loginButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(loginButtonAction(_:)))
        navigationItem.leftBarButtonItem = loginButton

        let createNote = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeButtonAction(_:)))
        navigationItem.rightBarButtonItem = createNote
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc func loginButtonAction(_ sender: UIBarButtonItem) {
        let vc: UIViewController = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        self.present(vc, animated: true) {
            
        }
    }
    
    @objc func composeButtonAction(_ sender: Any) {
        let vc: UIViewController = UIStoryboard(name: "CreateNote", bundle: nil).instantiateViewController(withIdentifier: "CreateNoteViewController")
        self.present(vc, animated: true) {
            
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = objects[indexPath.row]
        cell.textLabel!.text = object.text
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

