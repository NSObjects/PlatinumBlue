### PlatinumBlue

PlatinumBlue is a swift framework for parsing RSS and Atom web feed,

###Examples
*It is very easy using*

` let bule = PlatinumBlue(urlStr: "http://nshipster.cn/feed.xml")`

 ` bule.parse { (feedInfo : FeedInfo?, feedItems :[FeedItem]?, error : NSError?) -> Void in`
  
      print("\(feedInfo?.description())")
  `}`
        
###License
PlatinumBlue is available under the MIT license. See the LICENSE file for more info.
