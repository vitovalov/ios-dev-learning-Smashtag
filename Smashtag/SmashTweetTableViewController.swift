//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by Vito on 26/05/2017.
//  Copyright © 2017 Vitovalov. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController {

    // non private var with defalt value
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        
        updateDatabase(with: newTweets)
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        print("starting db load")
        
        container?.performBackgroundTask({ (context) in // BACKGROUND THREAD
            for twitterInfo in tweets {
                // add tweet
//                let tweet = try? Tweet.findOrCreate(matching: twitterInfo, in: context)
                _ = try? Tweet.findOrCreate(matching: twitterInfo, in: context) // we ignore and not set a var or let. We just want to create it in the database

            }
            
            try? context.save()
            print("done loading db")
        })
        
        printDatabaseStatistics()
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext { // main queue's context
            
            let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
            
            if let tweetCount = (try? context.fetch(request))?.count { // if no predicate, means we want them all
                print("\(tweetCount) tweets")
            }
            
            // better way to do it:
            // making the count on the DB side. Means: if I'm gonna fetch, tell me how many would I get
            if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) {
             print("\(tweeterCount) Twitter users")
            }
        }
    }
}











