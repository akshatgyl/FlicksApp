//
//  MovieViewController.swift
//  Flicks
//
//  Created by Akshat Goyal on 1/12/16.
//  Copyright © 2016 Akshat Goyal. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UISearchResultsUpdating, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var movies : NSMutableArray = []
    var filteredMovies  = []
    var refresh : UIRefreshControl = UIRefreshControl()
    
    @IBOutlet var searchController: UISearchController!
    @IBOutlet weak var errorView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.dataSource = self
//        tableView.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        
        
        errorView.hidden = true
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if (error != nil) {
                    self.errorView.hidden = false
                }
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            MBProgressHUD.showHUDAddedTo(self.view, animated: true) //starting HUDProgress for api loading
                            NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as! NSMutableArray
                            self.errorView.hidden = true
                            MBProgressHUD.hideHUDForView(self.view, animated: true) // stopping HUDProgress
                            //self.tableView.reloadData()
                            self.collectionView.reloadData()
                    }
                }
        })
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
        //self.tableView.addSubview(refresh)
        self.collectionView.addSubview(refresh)
        
    }
    
    
    
    
    
    
    func refresh(sender:AnyObject) {
        // ... Create the NSURLRequest (myRequest) ...
        
        // Configure session so that completion handler is executed on main UI thread
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                // Reload the tableView now that there is new data
                //self.tableView.reloadData()
                self.collectionView.reloadData()
                // Tell the refreshControl to stop spinning
                self.refresh.endRefreshing()	
        });
        task.resume()
    }

    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        if (filteredMovies.count != 0) {
//            return filteredMovies.count
//        } else {
//            if (searchController.active && searchController.searchBar.text != "") {
//                return 0
//            } else {
//                return movies.count
//            }
//        }
//    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var movie : NSDictionary
        if (filteredMovies.count != 0) {
            movie = filteredMovies[indexPath.row] as! NSDictionary
        } else {
            movie = movies[indexPath.row] as! NSDictionary
        }
        //let title = movie["title"] as! String
        //let overview = movie["overview"] as! String
        
        //        let baseUrl = "http://image.tmdb.org/t/p/w500"
        //        let posterPath = movie["poster_path"] as! String
        
        //        let backdropPath = movie["backdrop_path"] as! String
        //        let backdropUrl = NSURL(string: baseUrl + backdropPath)
        //        let posterUrl = NSURL(string: baseUrl + posterPath)
        
        //let rRated = movie["adult"] as! Bool
        //let ratings = movie["vote_average"] as! Double
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionMovieCell", forIndexPath: indexPath) as! CollectionMovieCell
        
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            //cell.posterView.setImageWithURL(posterUrl!)
            cell.photoPoster.setImageWithURL(posterUrl!)
            cell.photoPoster.alpha = 0
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
                cell.photoPoster.alpha = 1
                }, completion: nil)
        }
        else {
            cell.photoPoster.image = nil
        }
        //cell.titleLabel.text = title
        //cell.overviewLabel.text = overview
//        if (rRated) {
//            cell.ratedImage.image = UIImage(named: "RATED_R.svg.png")
//        } else {
//            cell.ratedImage.image = UIImage(named: "RATED_PG-13.svg.png")
//        }
//        cell.ratingsLabel.text = String(format: "%.1f", ratings)
        //        let imageview = UIImageView()
        //        imageview.setImageWithURL(backdropUrl!)
        //        cell.backgroundView = imageview
        
        //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (filteredMovies.count != 0) {
            return filteredMovies.count
        } else {
            if (searchController.active && searchController.searchBar.text != "") {
                return 0
            } else {
                return movies.count
            }
        }
    }
    
    
    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        var movie : NSDictionary
//        if (filteredMovies.count != 0) {
//            movie = filteredMovies[indexPath.row] as! NSDictionary
//        } else {
//            movie = movies[indexPath.row] as! NSDictionary
//        }
//        let title = movie["title"] as! String
//        let overview = movie["overview"] as! String
//        
////        let baseUrl = "http://image.tmdb.org/t/p/w500"
////        let posterPath = movie["poster_path"] as! String
//
////        let backdropPath = movie["backdrop_path"] as! String
////        let backdropUrl = NSURL(string: baseUrl + backdropPath)
////        let posterUrl = NSURL(string: baseUrl + posterPath)
//        
//        let rRated = movie["adult"] as! Bool
//        let ratings = movie["vote_average"] as! Double
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
//        
//        if let posterPath = movie["poster_path"] as? String {
//            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
//            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
//            cell.posterView.setImageWithURL(posterUrl!)
//            cell.posterView.alpha = 0
//            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
//                cell.posterView.alpha = 1
//                }, completion: nil)
//        }
//        else {
//            cell.posterView.image = nil
//        }
//        cell.titleLabel.text = title
//        cell.overviewLabel.text = overview
//        if (rRated) {
//            cell.ratedImage.image = UIImage(named: "RATED_R.svg.png")
//        } else {
//            cell.ratedImage.image = UIImage(named: "RATED_PG-13.svg.png")
//        }
//        cell.ratingsLabel.text = String(format: "%.1f", ratings)
////        let imageview = UIImageView()
////        imageview.setImageWithURL(backdropUrl!)
////        cell.backgroundView = imageview
//        
//        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//        return cell
//        
//    }
    
    
    
    
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@", searchText)
            let filteredResult = movies.filteredArrayUsingPredicate(searchPredicate)
            if filteredResult.count != 0 {
                filteredMovies = filteredResult
            } else {
                filteredMovies = []
            }
            //tableView.reloadData()
            collectionView.reloadData()
        }
    }
    
    
    
    
    
    
    @IBAction func searchButton(sender: AnyObject) {
        searchController.searchBar.becomeFirstResponder()
        searchController.active = true
        searchController.searchBar.hidden = false
    }
    @IBAction func hideKeyboard(sender: AnyObject) {
        self.searchController.searchBar.resignFirstResponder()
    }
}

//movies with same genre



