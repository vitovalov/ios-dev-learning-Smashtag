//
//  SmashTweetersTableViewController.swift
//  Smashtag
//
//  Created by Vito on 27/05/2017.
//  Copyright © 2017 Vitovalov. All rights reserved.
//

import UIKit
import CoreData

class SmashTweetersTableViewController: FetchedResultsTableViewController {
    
    // OUR MODEL
    var mention: String? {
        didSet {
            updateUI()
        }
    }
    
    var container: NSPersistentContainer? = // better pass whole container rather than only a context because then you can whatever context you need (in this case we ONLY need VIEW context since we're in UI thread
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    
    var fetchedResultsController: NSFetchedResultsController<TwitterUser>?
    
    
    private func updateUI() {
        
        if let context = container?.viewContext, mention != nil {
            
            let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "handle", ascending: true)]
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", mention!)
            
            fetchedResultsController = NSFetchedResultsController<TwitterUser>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil, // no sections
                cacheName: nil  // we're not caching
            )
            
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterUser Cell", for: indexPath)
        
        if let twitterUser = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = twitterUser.handle
        }
        
        return cell
    }
}













