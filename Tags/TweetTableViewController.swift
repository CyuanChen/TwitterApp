//
//  TweetTableViewController.swift
//  TwitterApp
//
//  Created by PeterChen on 2016/9/19.
//  Copyright © 2016年 PeterChen. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    var tweets = [[Tweet]]()
    
    var searchText: String? = "apple" {
        didSet {
            self.lastSuccessfulRequest = nil
            self.searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl?)
    {
        if let searchText = searchText {
            if let request = nextRequestToAttempt {
                // off the main queue
                request.fetchTweets({ (newTweets) -> Void in
                    
                    // succesfully fetched some new tweets
                    // go back to the main queue
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // do UI stuff here
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            sender?.endRefreshing()
                        }
                        
                    })
                })
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    func refresh()
    {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    // MARK: - View Controller Lifecycle
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return .LightContent
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.estimatedRowHeight = 231
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // change status bar into white
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black

        refresh()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetWithImage = "TweetWithImage"
        static let TweetWithoutImage = "TweetWithoutImage"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let tweet = tweets[indexPath.section][indexPath.row]
        if tweet.media.first?.url != nil {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetWithImage, forIndexPath: indexPath) as! TweetTableViewCell
            cell.tweet = tweet
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetWithoutImage, forIndexPath: indexPath) as! TweetTableViewCell
            cell.tweet = tweet
            return cell
        }
        
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }


}























