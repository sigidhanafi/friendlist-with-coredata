//
//  ViewController.swift
//  FriendList
//
//  Created by Sigit on 29/04/21.
//

import CoreData
import UIKit

class ViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private var friends = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFriends()
    }
    
    private func setupView() {
        // screen title
        title = "Friend List"
        
        // background
        view.backgroundColor = .white
        
        // add table view
        view.addSubview(tableView)
        
        // set constrain
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    private func setupNavigation() {
        // adding add button on the right bar button item
        let addBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addFriend))
        navigationItem.rightBarButtonItem = addBarButtonItem
        
        // set navigation color
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1921568627, green: 0.2078431373, blue: 0.231372549, alpha: 1)
        navigationController?.navigationBar.shadowImage = UIImage(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12), size: CGSize(width: 1, height: 0.3))
        
        // set title attribute
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1921568627, green: 0.2078431373, blue: 0.231372549, alpha: 1).withAlphaComponent(0.96)]
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
    }
    
    @objc private func addFriend() {
        let alert = UIAlertController(title: "Add Friend", message: "Add the name of your friend, then save it to the list!", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            guard let textField = alert.textFields?.first,
                  let name = textField.text else { return }
    
            self.saveFriend(name: name)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func alertDeleteFriend(_ index: IndexPath) {
        let alert = UIAlertController(title: "Delete Friend", message: "Delete the name of your friend permanently?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.deleteFriend(index)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func saveFriend(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            friends.append(person)
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
    }
    
    private func fetchFriends() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            friends = try managedContext.fetch(fetchRequest)
        } catch {
            print("Could not fetch. \(error), \(error.localizedDescription)")
        }
    }
    
    private func deleteFriend(_ index: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let data = self.friends[index.row]
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(data)
        
        do {
            _ = try managedContext.save()
            friends.remove(at: index.row)
            tableView.reloadData()
        } catch {
            print("Could not delete. \(error), \(error.localizedDescription)")
        }
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let friend = self.friends[indexPath.row]
        let name = friend.value(forKeyPath: "name")
        cell.textLabel?.text = name as? String
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        alertDeleteFriend(indexPath)
    }
}

extension UIImage {
    // init to set color and size
    public convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}


