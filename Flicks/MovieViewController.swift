//
//  MovieViewController.swift
//  Flicks
//
//  Created by Akshat Goyal on 1/12/16.
//  Copyright © 2016 Akshat Goyal. All rights reserved.
//

import UIKit
import AFNetworking

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    var movies : [NSDictionary]?
    var filteredMovies : [NSDictionary]?
    var refresh : UIRefreshControl = UIRefreshControl()
    
    
    @IBOutlet weak var loadingState: UIActivityIndicatorView!
    @IBOutlet var searchController: UISearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                print(error)
                if (error != nil) {
                    let alertController = UIAlertController(title: "Network Error", message:
                        "There is a problem with your network connection!", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
        });
        task.resume()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        
        self.refresh = UIRefreshControl()
        self.refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refresh.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresh)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        loadingState.hidden = false
        loadingState.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        loadingState.stopAnimating()
        loadingState.hidden = true
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        filterContent(searchText!)
        tableView.reloadData()
        
    }
    
    func refresh(sender:AnyObject)
    {
        self.tableView.reloadData()
        refresh.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchController.active) {
            return filteredMovies!.count
        }
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let movie : NSDictionary
        if (searchController.active) {
            movie = filteredMovies![indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
//        let backdropPath = movie["backdrop_path"] as! String
        
//        let backdropUrl = NSURL(string: baseUrl + backdropPath)
        let posterUrl = NSURL(string: baseUrl + posterPath)
        
        let rRated = movie["adult"] as! Bool
        let ratings = movie["vote_average"] as! Double
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        cell.posterView.setImageWithURL(posterUrl!)
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        if (rRated) {
            cell.ratedImage.image = UIImage(named: "RATED_R.svg.png")
        } else {
            cell.ratedImage.image = UIImage(named: "RATED_PG-13.svg.png")
        }
        cell.ratingsLabel.text = String(format: "%.1f", ratings)
//        let imageview = UIImageView()
//        imageview.setImageWithURL(backdropUrl!)
//        cell.backgroundView = imageview
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
        
    }
    
    func filterContent(searchText : String, scope: String = "Title") {
        
        self.filteredMovies = self.movies?.filter({( movieList : NSDictionary) -> Bool in
        
            let Field = (scope == "Title")
            let searchTitle = movieList["title"] as! String!
            let stringMatch = searchTitle.rangeOfString(searchText)
            return Field && (stringMatch != nil)
            
        })

    }
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        self.filterContent(searchString!, scope: "Title")
        return true
    }
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContent((self.searchController?.searchBar.text)!, scope: "Title")
        return true
    }

}





