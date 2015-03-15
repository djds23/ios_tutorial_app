//
//  APIController.swift
//  iOS_app_tutorial
//
//  Created by Dean Silfen on 3/9/15.
//  Copyright (c) 2015 LazyBits LLC. All rights reserved.
//

import Foundation

class APIController {
    
    var delegate: APIControllerProtocol
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }

    func searchItunesFor(searchTerm: String) {
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music&entity=album"
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: { data, response, error -> Void in
                println("Task Completed")
                if (error != nil) {
                    println(error.localizedDescription)
                }
                var err: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                if (err != nil) {
                    println("JSON Error \(err?.localizedDescription)")
                }
                let results: NSArray = jsonResult["results"] as NSArray
                self.delegate.didRecieveAPIResults(jsonResult)
            })
            task.resume()
        }
    
    }
}

protocol APIControllerProtocol {
    func didRecieveAPIResults(results: NSDictionary)
    
    
}

