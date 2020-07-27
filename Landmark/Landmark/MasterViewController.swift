//
//  MasterViewController.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


extension Note {
    
    init?(snapshot: DataSnapshot) {
      guard
        let value = snapshot.value as? [String: AnyObject],
        let date = value["timestamp"] as? String,
        let body = value["body"] as? String,
        let email = value["username"] as? String,
        let lat = value["latitude"] as? Double,
        let long = value["longitude"] as? Double else {
        return nil
      }
        
        self.timestamp = date
        self.body = body
        self.username = email
        self.latitude = lat
        self.longitude = long
    }
    
}

extension MasterViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        filterContentForSearchText(text)
    }
}

extension MasterViewController : UISearchControllerDelegate {

    func willPresentSearchController(_ searchController: UISearchController){
        print("\(type(of: self)) \(#function)")
    }

    func didPresentSearchController(_ searchController: UISearchController){
        print("\(type(of: self)) \(#function)")
    }

    func willDismissSearchController(_ searchController: UISearchController){
        print("\(type(of: self)) \(#function)")
    }

    func didDismissSearchController(_ searchController: UISearchController){
        print("\(type(of: self)) \(#function)")
        self.tableView.reloadData()
    }

    func presentSearchController(_ searchController: UISearchController){
        print("\(type(of: self)) \(#function)")
    }
}

class MasterViewController: UITableViewController {

    private var detailViewController: DetailViewController? = nil
    private var objects = [Note]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private var databaseRef: DatabaseReference = Database.database().reference(withPath: "landmark-notes")
    
    public var currentUser: User? {
        didSet {
            DispatchQueue.main.async {
                self.title = self.currentUser?.email
                self.navigationItem.title = self.currentUser?.email
            }
        }
    }
    
    //MARK:- SearchBar Properties
    private var filteredObjects = [Note]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    private var isSearchActive: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let loginButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(loginButtonAction(_:)))
        navigationItem.leftBarButtonItem = loginButton

        let createNote = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeButtonAction(_:)))
        let mapView = UIBarButtonItem(image: UIImage(systemName: "map"), style: .done, target: self, action: #selector(mapButtonAction(_:)))
        navigationItem.rightBarButtonItems = [createNote, mapView]
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        databaseRef.observe(.value) { dataSnapshot in
            var newNotes: [Note] = []
            
            for child in dataSnapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let note = Note(snapshot: snapshot) {
                        newNotes.append(note)
                    } else {
                        print("Error converting data to Note object")
                    }
                }
            }
            self.objects = newNotes
        }
        addSearchController()
    }

    func addSearchController() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type to search"
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredObjects = objects.filter { note -> Bool in
            return (note.username.lowercased().contains(searchText.lowercased()) ||
                note.body.lowercased().contains(searchText.lowercased()))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        currentUser = FirebaseAuth.Auth.auth().currentUser
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
    
    @objc func mapButtonAction(_ sender: Any) {
        let vc: UIViewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapViewController")
        let mapvc = vc as! MapViewController
        mapvc.notes = self.objects
        self.present(vc, animated: true) {
            
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                var object: Note?
                if isSearchActive {
                    object = filteredObjects[indexPath.row]
                } else {
                    object = objects[indexPath.row]
                }
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
        if isSearchActive {
            return filteredObjects.count
        }
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if isSearchActive {
            let object = filteredObjects[indexPath.row]
            cell.textLabel!.text = object.displayTitle
        } else {
            let object = objects[indexPath.row]
            cell.textLabel!.text = object.displayTitle
        }
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

