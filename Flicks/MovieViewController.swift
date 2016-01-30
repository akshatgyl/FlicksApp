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
import DGElasticPullToRefresh

class MovieViewController: UIViewController, UISearchResultsUpdating, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var movies : NSMutableArray = []
    var filteredMovies  = []
    var refresh : UIRefreshControl = UIRefreshControl()
    
    @IBOutlet var searchController: UISearchController!
    @IBOutlet weak var errorView: UIView!
    
    var endPoint : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            
            self.flowLayout.scrollDirection = .Vertical
            self.flowLayout.minimumLineSpacing = 0
            self.flowLayout.minimumInteritemSpacing = 0
            self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
            self.errorView.hidden = true
        
        let logo = UIImage(named: "flicks.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            MBProgressHUD.showHUDAddedTo(self.view, animated: true) //starting HUDProgress for api loading
                            NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as! NSMutableArray
                            self.errorView.hidden = true
                            MBProgressHUD.hideHUDForView(self.view, animated: true) // stopping HUDProgress
                            self.collectionView.reloadData()
                    }
                } else {
                    self.errorView.hidden = false
                }
        })
        task.resume()
        
            self.searchController = UISearchController(searchResultsController: nil)
            self.searchController.searchBar.sizeToFit()
            self.tableView.tableHeaderView = self.searchController.searchBar
            self.definesPresentationContext = true
            
            self.searchController.searchResultsUpdater = self
            self.searchController.dimsBackgroundDuringPresentation = false

        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        collectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
            let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(self!.endPoint)?api_key=\(apiKey)")
            let request = NSURLRequest(URL: url!)
            let session = NSURLSession(
                configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                delegate:nil,
                delegateQueue:NSOperationQueue.mainQueue()
            )
            
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                completionHandler: { (data, response, error) in
                    self!.collectionView.reloadData()
                    self!.refresh.endRefreshing()
            });
            task.resume()
            // Do not forget to call dg_stopLoading() at the end
            self?.collectionView.dg_stopLoading()
            }, loadingView: loadingView)
        collectionView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        collectionView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("11")
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@", searchText)
            let filteredResult = movies.filteredArrayUsingPredicate(searchPredicate)
            if filteredResult.count != 0 {
                filteredMovies = filteredResult
            } else {
                filteredMovies = []
            }
            collectionView.reloadData()
        }
    }
    
    
    
    
    @IBAction func searchButton(sender: AnyObject) {
//        searchController.searchBar.becomeFirstResponder()
        searchController.active = true
        searchController.searchBar.hidden = false
        searchController.becomeFirstResponder()
    }
    
//    @IBAction func hideKeyboard(sender: AnyObject) {
//        self.searchController.searchBar.resignFirstResponder()
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! CollectionMovieCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie : NSDictionary
        if (filteredMovies.count != 0) {
            movie = filteredMovies[indexPath!.row] as! NSDictionary
        } else {
            movie = movies[indexPath!.row] as! NSDictionary
        }
        
        let destinationViewController = segue.destinationViewController as! DetailsViewController
        destinationViewController.movie = movie
        
    }
    
    
}

//movies with same genre



