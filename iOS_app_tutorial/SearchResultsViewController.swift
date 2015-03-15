//
//  ViewController.swift
//  iOS_app_tutorial
//
//  Created by Dean Silfen on 3/9/15.
//  Copyright (c) 2015 LazyBits LLC. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {

    @IBOutlet var appsTableView : UITableView?

    var albums = [Album]()
    var tableData = []
    var api : APIController?
    var imageCache = [String : UIImage]()
    
    let kCellIdentifier: String = "SearchResultCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api!.searchItunesFor("Angry Birds")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
        let rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        let cellText: String? = rowData["trackName"] as? String
        cell.textLabel?.text = cellText
        cell.imageView?.image = UIImage(named: "Blank52")

        let formattedPrice: NSString = rowData["formattedPrice"] as NSString
        let urlString: NSString = rowData["artworkUrl60"] as NSString
        
        var image = self.imageCache[urlString]
        if ( image == nil ) {
            var imgURL: NSURL? = NSURL(string: urlString)
            
            // Download NSDATA of image
            let request: NSURLRequest = NSURLRequest(URL: imgURL!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!,error: NSError!) -> Void in
                if ( error == nil ) {
                    image = UIImage(data: data)
                    
                    // CACHE RULES EVERYTHING AROUND ME
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    cellToUpdate.imageView?.image = image
                }
            })
        }
        
        cell.detailTextLabel?.text = formattedPrice
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        let cellText: String? = rowData["trackName"] as? String
        cell.textLabel?.text = cellText
        cell.imageView?.image = UIImage(named: "bank52")
        
        
        var name: String = rowData["trackName"] as String
        var formattedPrice: String = rowData["formattedPrice"] as String
        
        var alert: UIAlertView = UIAlertView()
        alert.title = name
        alert.message = formattedPrice
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    func didRecieveAPIResults(results: NSDictionary) {
        var resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.tableData = resultsArr
            self.appsTableView!.reloadData()
        })
    }
}

