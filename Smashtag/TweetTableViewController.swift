//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Vito on 25/05/2017.
//  Copyright © 2017 Vitovalov. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    private var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            print(tweets)
        }
    }
    
    var searchText: String? {
        didSet {
            searchTextField?.text =  searchText
            searchTextField?.resignFirstResponder()
            lastTwitterRequest = nil // if hashtag changes, we invalidate the last so that it not tries to get new version of the previous request
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText // this VC's title
        }
    }
    
    // gonna return the request matching the search text
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            //            return Twitter.Request(search: query, count: 100)
            return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)
        }
        return nil
    }
    
    // not private so that subclasses can override it
    func insertTweets(_ newTweets: [Twitter.Tweet]) {
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        // if lastTwitterRequest has newer version, use that, if not, make another request
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            //            request.fetchTweets { newTweets in
            //                self.tweets.insert(newTweets, at: 0) // memory leak because user could exit this VC while the call hasn't completed yet (CLOSURE INSIDE VC)
            //            }
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest {
                        self?.insertTweets(newTweets)
                    }
                    self?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        searchText = "#stanford"
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension // uses AUTOlayout with help of estimatedHeight
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl)
    {
        searchForTweets()
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    // delegate method from UITextFieldDelegate. Gets called when return button is sent
    /*
     Asks the delegate if the text field should process the pressing of the return button.
     The text field calls this method whenever the user taps the return button
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField { // make sure we point to our textField in case one day we add more
            searchText = searchTextField.text
        }
        
        return true // do what you normally do
    }
    
    // MARK: - UITableDataSource methods Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        
        //        cell.textLabel?.text = tweet.text
        //        cell.detailTextLabel?.text = tweet.user.name
        //
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count-section)" // every pull will be with named header
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
