//
//  FeedItem.swift
//  PlatinumBlue
//
//  Created by 林涛 on 15/12/8.
//  Copyright © 2015年 林涛. All rights reserved.
//

import UIKit

class FeedItem {
 /// 规定项目作者的电子邮件地址。
    var author : String?
 /// 定义项目所属的一个或多个类别
    var category : String?
 /// 允许项目连接到有关此项目的注释（文件）
    var comments : String?
 /// 允许将一个媒体文件导入一个项中
    //TODO: 这里是个字典，应该是资源文件的URL
    var enclosure : String?
 /// 为项目定义一个唯一的标识符
    var guid : String?
 /// 定义指向此项目的超链接。
    var link : String?
 /// 定义此项目的最后发布日期
    var pubDate : String?
 /// 为此项目指定一个第三方来源
    var Source : String?
 /// 定义此项目的标题
    var title : String?
 /// atom content
    var content : String?
 /// atom summary
    var summary : String?
 /// atom  updated
    var updated : String?
 
    func description() -> String {
        return "\(self.toDictionary())"
    }
    
    func toDictionary()-> NSDictionary {
        let dictionary = NSMutableDictionary()
        if author != nil{
            dictionary["author"] = author
        }
        if category != nil{
            dictionary["category"] = category
        }
        if comments != nil{
            dictionary["comments"] = comments
        }
        if enclosure != nil{
            dictionary["enclosure"] = enclosure
        }
        if link != nil{
            dictionary["link"] = link
        }
        
        if pubDate != nil{
            dictionary["pubDate"] = pubDate
        }
        if Source != nil{
            dictionary["Source"] = Source
        }
        if title != nil{
            dictionary["title"] = title
        }
        if content != nil{
            dictionary["content"] = content
        }
        if summary != nil{
            dictionary["summary"] = summary
        }
        if updated != nil{
            dictionary["updated"] = updated
        }
        
        return dictionary
    }

    
}
