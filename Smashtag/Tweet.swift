//
//  Tweet.swift
//  Smashtag
//
//  Created by Vito on 26/05/2017.
//  Copyright © 2017 Vitovalov. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Tweet: NSManagedObject {
    
    // throws because we don't know what the caller wants us to do in case of error
    class func findOrCreate(matching twitterInfo: Twitter.Tweet, in context: NSManagedObjectContext) throws -> Tweet {
        
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.identifier)
        // we don't need sortDescriptor because we only get 0 or 1 here
        
        do {
            let matches = try context.fetch(request) // array of tweets
            
            if matches.count > 0 {
                assert(matches.count == 1, "Tweet.findOrCreate -- database inconsistency")
                return matches[0]
            }
            
            
        } catch {
            throw error // rethrow the error that we're catching
        }
        
        let tweet = Tweet(context: context)
        tweet.unique = twitterInfo.identifier
        tweet.text = twitterInfo.text
        tweet.created = twitterInfo.created as NSDate
        tweet.tweeter = try? TwitterUser.findOrCreateTwitterUser(matching: twitterInfo.user, in: context)
        // we could throw if we don't find the tweeter, but for now we just pass
    
        return tweet
    }
}










