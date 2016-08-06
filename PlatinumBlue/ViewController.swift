//
//  ViewController.swift
//  PlatinumBlue
//
//  Created by 林涛 on 15/12/8.
//  Copyright © 2015年 林涛. All rights reserved.
//

import UIKit

class ViewController: UIViewController,PlatinumBlueDelegate {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var feeds = NSMutableArray()
    var feedItems = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        let rss = ["http://adad184.com/atom.xml",
                   "http://beyondvincent.com/atom.xml",
                   "http://blog.leichunfeng.com/atom.xml",
                   "http://blog.sunnyxx.com/atom.xml",
                   "http://blog.txx.im/atom.xml",
                   "http://blog.xcodev.com/atom.xml",
                   "http://casatwy.com/feeds/all.atom.xml",
                   "http://kittenyang.com/rss",
                   "http://msching.github.io/atom.xml",
                   "http://nathanli.cn/feed/",
                   "http://onevcat.com/atom.xml",
                   "http://swift.gg/atom.xml",
                   "http://swifter.tips/feed.xml",
                   "http://wufawei.com/feed"]
        
    
        
        for url in rss {
            let blue = PlatinumBlue(urlStr: url)
            blue.parse()
            blue.delegate = self
        }
        
       // self.activityIndicatorView.startAnimating()
        
//        blue.parse { (feedinfo:FeedInfo?, error:NSError?) in
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.activityIndicatorView.stopAnimating()
//                if error == nil {
//                    self.feeds.addObject(feedinfo!);
//                    self.tableView.reloadData()
//                }
//            })
//        }
        
    }

    func platinumBlue(platinumBlue:PlatinumBlue,parsedFeedInfo:FeedInfo?,error:NSError?) {
        //self.activityIndicatorView.stopAnimating()
        if error == nil {
            if let feed = parsedFeedInfo {
                self.feeds.addObject(feed);
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is FeedsTableViewController {
            let feedInfo:FeedInfo = sender as! FeedInfo
            let feedsTVC = segue.destinationViewController as! FeedsTableViewController
            feedsTVC.feedItems = feedInfo.feedItems!
            feedsTVC.title = feedInfo.title
        }
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let feedItem:FeedInfo = self.feeds[indexPath.row] as! FeedInfo
        cell.textLabel?.text = feedItem.title
        cell.detailTextLabel?.text = feedItem.pubDate
        
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showFeeds", sender: self.feeds[indexPath.row])
    }
}

