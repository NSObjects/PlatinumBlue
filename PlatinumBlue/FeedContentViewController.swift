//
//  FeedContentViewController.swift
//  PlatinumBlue
//
//  Created by 林涛 on 15/12/10.
//  Copyright © 2015年 林涛. All rights reserved.
//

import UIKit

class FeedContentViewController: UIViewController {
    var feedContent : String?
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.loadHTMLString(self.feedContent!, baseURL: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
