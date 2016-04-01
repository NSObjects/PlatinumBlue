//
//  PlatinumBlue.swift
//  PlatinumBlue
//
//  Created by 林涛 on 15/12/7.
//  Copyright © 2015年 林涛. All rights reserved.
//

import UIKit
import Ji

protocol PlatinumBlueDelegate:NSObjectProtocol {
    func platinumBlue(platinumBlue:PlatinumBlue,parsedFeedInfo:FeedInfo?,error:NSError?)
}

class PlatinumBlue: NSObject,NSURLSessionDelegate {
    
    enum ParseType {
        case ParseTypeFull
        case ParseTypeItemsOnly
        case ParseTypeInfoOnly
    }
    
    enum FeedType {
        case FeedTypeUnknown
        case FeedTypeRSS
        case FeedTypeRSS1
        case FeedTypeAtom
    }
    
    var parseTimeOut = 30.0
    let ErrorCodeNotInitiated = 2040
    let ErrorCodeConnectionFailed = 2041
    let ErrorCodeFeedParsingError = 2042
    let ErrorCodeFeedValidationError = 2043
    
    
    var feedType:FeedType = .FeedTypeUnknown
    
    weak var delegate:PlatinumBlueDelegate?
    
    private var request:NSURLRequest
    private var URL:NSURL
    
    var parsing:Bool = false
    
    init(url :NSURL) {
        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: parseTimeOut)
        request.setValue("PlatinumBlue", forHTTPHeaderField: "User-Agent")
        self.request = request
        self.URL = url
    }
 
    /**
     通过一个RSS源路径初始化PlatinumBlue
     
     - parameter urlStr: 源路径
     
     - returns:
     */
    convenience init(urlStr :String) {
        
        print("Rss Web site is : \(urlStr)")
        
        let url:NSURL = NSURL(string: urlStr)!
        self.init(url:url);
        //TODO:
        
    }
   
    /**
     解析源的xml数据，将channle和item的信息分别存在feedInfo 和feedItems数组中
     
     - parameter completionHandler: 解析完成后通过这个闭包返回channle和items里面的信息
     
     - returns: 解析成功或失败
     */
    func parse(completionHandler: (FeedInfo?, NSError?) -> Void?)->Bool {
        if self.parsing {
            let userInfo = [NSLocalizedDescriptionKey:"Parsing error"]
            let error = NSError(domain: "PlatinumBlue Parsing", code: ErrorCodeFeedParsingError, userInfo: userInfo)
            delegate?.platinumBlue(self, parsedFeedInfo: nil, error: error)
            completionHandler(nil,error)
            return false
        }
        
        self.parsing = true
        //TODO: //FIXME:
        self.sendRequest(completionHandler)
        return true
    }
    
    func parse() {
        self.parse { (feedInfo:FeedInfo?, error:NSError?) -> Void? in
            dispatch_async(dispatch_get_main_queue(), { 
                self.delegate?.platinumBlue(self, parsedFeedInfo: feedInfo, error: nil)
            })
            
        }
    }

    func sendRequest(completionHandler: (FeedInfo?, NSError?) -> Void?) {
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        let task = session.dataTaskWithURL(self.URL) { (date: NSData?, response:NSURLResponse?,error:NSError?) -> Void in
            if let error = error {
                print("\(error.localizedDescription)")
            }
            
            self.startParsing(date, textEncodingName: response?.textEncodingName,completionHandler: completionHandler)
        }
       
        task.resume()
    }

    func startParsing( data : NSData! ,textEncodingName : String?,completionHandler: (FeedInfo?, NSError?) -> Void?) {
        guard let _:NSData = data else {
            return
        }
        var parseData = data
        if textEncodingName?.lowercaseString != "utf-8" {
            parseData = self.convertUnknownEncoding(data, encodingName: textEncodingName)
        }
        
        if let parseData = parseData where parseData.length > 0 {
            let xmlDoc = Ji(xmlData: parseData)
            
            if (xmlDoc == nil) {
                let userInfo = [NSLocalizedDescriptionKey:"Can't Parse this feed \(self.URL)"]
                
                let error = NSError(domain: "PlatinumBlue Parsing", code: ErrorCodeFeedParsingError, userInfo: userInfo)
                completionHandler(nil,error)
            }
            
            if self.feedType == .FeedTypeUnknown {
                switch xmlDoc!.rootNode!.tagName!.lowercaseString {
                case "rss":
                    self.feedType = .FeedTypeRSS
                    self.convertRSSType(xmlDoc, completionHandler: completionHandler)
                case "rdf:RDF":
                    self.feedType = .FeedTypeRSS1
                    self.convertRSS1Type(xmlDoc, completionHandler: completionHandler)
                case "feed":
                    self.feedType = .FeedTypeAtom
                    self.convertAtomType(xmlDoc, completionHandler: completionHandler)
                default:
                    print("\(xmlDoc?.rootNode?.tagName)")
                    let userInfo = [NSLocalizedDescriptionKey:"XML document is not a valid web feed document \n\(self.URL)"]
                    let error = NSError(domain: "PlatinumBlue Parsing", code: ErrorCodeFeedParsingError, userInfo: userInfo)
                    completionHandler(nil,error)
                }
            }
           
        } else {
            print("解析失败")
        }
    }
    
    func convertRSSType(xmlDoc : Ji! ,completionHandler: (FeedInfo?, NSError?) -> Void?) {
        
        let channel = xmlDoc?.rootNode?.firstChildWithName("channel")
        let children = channel?.childrenWithName("item")
        
        let feedInfo = FeedInfo()
        feedInfo.title = channel?.firstChildWithName("title")?.content
        feedInfo.feedDescription = channel?.firstChildWithName("description")?.content
        feedInfo.link = channel?.firstChildWithName("link")?.content
        feedInfo.language = channel?.firstChildWithName("language")?.content
        feedInfo.lastBuildDate = channel?.firstChildWithName("lastBuildDate")?.content
        feedInfo.pubDate = channel?.firstChildWithName("pubDate")?.content
        feedInfo.copyright = channel?.firstChildWithName("copyright")?.content
        feedInfo.webMaster = channel?.firstChildWithName("webMaster")?.content
        feedInfo.managingEditor = channel?.firstChildWithName("managingEditor")?.content
        
        var feedItems = [FeedItem]();
        for node:JiNode in children! {
            let feedItem = FeedItem()
            feedItem.title = node.firstChildWithName("title")?.content
            feedItem.content = node.firstChildWithName("description")?.content
            feedItem.author = node.firstChildWithName("author")?.content
            feedItem.pubDate = node.firstChildWithName("pubDate")?.content
            feedItem.link = node.firstChildWithName("link")?.content
            feedItem.guid = node.firstChildWithName("guid")?.content
            feedItem.category = node.firstChildWithName("category")?.content
            feedItems.append(feedItem)
        }
        
        feedInfo.feedItems = feedItems;
        print("解析成功")
        completionHandler(feedInfo,nil)
        
    }
    
    func convertRSS1Type(xmlDoc : Ji! ,completionHandler: (FeedInfo?, NSError?) -> Void?) {
        let channel = xmlDoc?.rootNode?.firstChildWithName("rdf:RDF")
        let children = channel?.childrenWithName("item")
        
        let feedInfo = FeedInfo()
        feedInfo.title = channel?.firstChildWithName("title")?.content
        feedInfo.feedDescription = channel?.firstChildWithName("description")?.content
        feedInfo.link = channel?.firstChildWithName("link")?.content
        feedInfo.language = channel?.firstChildWithName("language")?.content
        feedInfo.lastBuildDate = channel?.firstChildWithName("lastBuildDate")?.content
        feedInfo.pubDate = channel?.firstChildWithName("pubDate")?.content
        feedInfo.copyright = channel?.firstChildWithName("copyright")?.content
        feedInfo.webMaster = channel?.firstChildWithName("webMaster")?.content
        feedInfo.managingEditor = channel?.firstChildWithName("managingEditor")?.content
        
        var feedItems = [FeedItem]();
        for node:JiNode in children! {
            let feedItem = FeedItem()
            feedItem.title = node.firstChildWithName("title")?.content
            feedItem.summary = node.firstChildWithName("description")?.content
            feedItem.author = node.firstChildWithName("author")?.content
            feedItem.pubDate = node.firstChildWithName("pubDate")?.content
            feedItem.link = node.firstChildWithName("link")?.content
            feedItem.guid = node.firstChildWithName("guid")?.content
            feedItem.category = node.firstChildWithName("category")?.content
            feedItems.append(feedItem)
        }
        feedInfo.feedItems = feedItems;
        print("解析成功")
        completionHandler(feedInfo,nil)
    }
    
    func convertAtomType(xmlDoc : Ji! ,completionHandler: (FeedInfo?, NSError?) -> Void?) {
        //let feed = xmlDoc?.rootNode?.firstChild
        let children:[JiNode]? = xmlDoc?.rootNode?.childrenWithName("entry")

        
        let feedInfo = FeedInfo()
        feedInfo.updated = xmlDoc?.rootNode?.firstChildWithName("updated")?.content
        feedInfo.title = xmlDoc?.rootNode?.firstChildWithName("title")?.content
        feedInfo.subtitle = xmlDoc?.rootNode?.firstChildWithName("subtitle")?.content
        feedInfo.feedDescription = xmlDoc?.rootNode?.firstChildWithName("description")?.content
        feedInfo.link = xmlDoc?.rootNode?.firstChildWithName("link")?.content
        feedInfo.managingEditor = xmlDoc?.rootNode?.firstChildWithName("author")?.firstChildWithName("email")?.content
        feedInfo.author = xmlDoc?.rootNode?.firstChildWithName("author")?.firstChildWithName("name")?.content
        
        var feedItems = [FeedItem]();
        for node:JiNode in children! where children?.count > 0 {
            let feedItem = FeedItem()
            feedItem.title = node.firstChildWithName("title")?.content
            feedItem.summary = node.firstChildWithName("summary")?.content
            feedItem.author = node.firstChildWithName("contributor")?.firstChildWithName("name")?.content
            feedItem.pubDate = node.firstChildWithName("published")?.content
            feedItem.updated = node.firstChildWithName("updated")?.content
            feedItem.link = node.firstChildWithName("link")?.content
            feedItem.guid = node.firstChildWithName("id")?.content
            feedItem.category = node.firstChildWithName("category")?.content
            feedItem.content = node.firstChildWithName("content")?.content
            feedItems.append(feedItem)
        }
         feedInfo.feedItems = feedItems;
        print("解析成功")
        
         completionHandler(feedInfo,nil)
    }
    
    func convertUnknownEncoding(data : NSData!,encodingName :String?) ->NSData? {
        
        var string:NSString?
        var nsEncoding:UInt = 0
        
        if ((encodingName?.isEmpty) != nil) {
            let cfEncoding:CFStringEncoding = CFStringConvertIANACharSetNameToEncoding(encodingName as! CFString)
            
            if cfEncoding != kCFStringEncodingInvalidId {
                nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
            }
            
            if nsEncoding != 0 {
                string = NSString(data: data, encoding: nsEncoding)
            }
            
        }
        
        if ((string?.length) == nil) {
            string = NSString(data: data, encoding:NSUTF8StringEncoding)
            if ((string?.length) == nil) {
                string = NSString(data: data, encoding:NSISOLatin1StringEncoding)
                if ((string?.length) == nil) {
                    string = NSString(data: data, encoding:NSMacOSRomanStringEncoding)
                }
            }
            
        }
        
        if ((string?.length) != nil) {
            if (string!.hasPrefix("<?xml")) {
                let a = string?.rangeOfString("?>")
                if a?.location != NSNotFound {
                    let xlmDec:NSString = NSString(string: (string?.substringToIndex((a?.location)!))!)
                    
                    if xlmDec.rangeOfString("encoding=\"UTF-8\"", options: .CaseInsensitiveSearch).location == NSNotFound {
                        let b = xlmDec.rangeOfString("encoding=\"")
                        
                        if b.location != NSNotFound {
                            let s = b.location + b.length
                            let c = xlmDec.rangeOfString("\"", options: .CaseInsensitiveSearch, range: NSMakeRange(s, xlmDec.length - s))
                            if c.location != NSNotFound {
                                let temp = string?.stringByReplacingCharactersInRange(NSMakeRange(b.location, c.location + c.length - b.location), withString: "encoding=\"UTF-8\"")
                                string = temp
                            }
                            
                            
                        }
                        
                    }
                }
            }
        }
        
        if ((string?.length) != nil) {
            let tempData:NSData = (string?.dataUsingEncoding(NSUTF8StringEncoding))!
            return tempData
        }
        
        return nil
    }
    
    
}



