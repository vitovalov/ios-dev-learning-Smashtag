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
            request.sortDescriptors = [NSSortDescriptor(key: "handle", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and !handle beginswith[c] %@ ", mention!, "M") // filtering by handle of some twitter user so that we won't see his tweets
            
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
            let tweetCount = tweetCountWithMentionBy(twitterUser)
            cell.detailTextLabel?.text = "\(tweetCount) tweet\((tweetCount == 1) ? "" : "s" )"
        }
        
        return cell
    }
    
    private func tweetCountWithMentionBy(_ twitterUser: TwitterUser) -> Int {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest() // making fetch request for number of tweets this twitter user has made with that search term
        
        // we're unwrapping mention! coz if we got down here, surely it won't be nil
        request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", mention!, twitterUser)
        
        // using the same context, twitterUser is in
        return (try? twitterUser.managedObjectContext!.count(for: request)) ?? 0
    }
}













