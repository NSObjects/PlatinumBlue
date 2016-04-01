//
//  FeedsTableViewController.swift
//  PlatinumBlue
//
//  Created by 林涛 on 15/12/10.
//  Copyright © 2015年 林涛. All rights reserved.
//

import UIKit

class FeedsTableViewController: UITableViewController {

    var feedItems = [FeedItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let feedItem = self.feedItems[indexPath.row]
        
        cell.textLabel?.text = feedItem.title
        cell.detailTextLabel?.text = feedItem.pubDate
        return cell
    }

   
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         self.performSegueWithIdentifier("showFeedContent", sender: self.feedItems[indexPath.row])
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is FeedContentViewController {
            let contentVc = segue.destinationViewController as! FeedContentViewController
            let feedItem = sender as! FeedItem
            contentVc.feedContent = feedItem.content
        }
    }
   

}
