//
//  DetailsViewController.swift
//  Flicks
//
//  Created by Akshat Goyal on 1/26/16.
//  Copyright © 2016 Akshat Goyal. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var mainPoster: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var ratingsView: UIView!

    @IBOutlet weak var ratedImage: UIImageView!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var releaseDate: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollView2: UIScrollView!
    @IBOutlet weak var webView: UIWebView!
    
    var movie : NSDictionary!
    var videoDictionary : [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "flicks.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        let posterBaseUrl = ("http://image.tmdb.org/t/p/w500")
        let posterBaseUrlHigh = ("http://image.tmdb.org/t/p/original")
        
        if let posterPath = movie["poster_path"] as? String {
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            self.mainPoster
                .setImageWithURL(posterUrl!)
        }
        
        let mainPosterPath = movie["backdrop_path"] as! String
        let smallImageRequest = NSURLRequest(URL: NSURL(string: (posterBaseUrl + mainPosterPath))!)
        let largeImageRequest = NSURLRequest(URL: NSURL(string: posterBaseUrlHigh + mainPosterPath)!)
        
        self.posterImageView.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.posterImageView.alpha = 0.0
                self.posterImageView.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.posterImageView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterImageView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterImageView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        })
        
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let ratings = movie["vote_average"] as! Double
        
        let releaseDate = movie["release_date"] as! String
        let adult = movie["adult"] as! Bool
        self.ratingsLabel.text = String(format: "%.1f", ratings)
        self.titleLabel.text = title
        self.overviewLabel.text = overview
        self.overviewLabel.sizeToFit()
        self.releaseDate.text = releaseDate
        
        if adult {
            self.ratedImage.image = UIImage(named: "R.png")
        } else {
            self.ratedImage.image = UIImage(named: "PG13.png")
        }
        
        
        let id = movie["id"] as! Int
        let movieID = String(format: "%d", id)
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieID)/videos?api_key=\(apiKey)")
        print(url)
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.videoDictionary = responseDictionary["results"] as! [NSDictionary]
                            let video = self.videoDictionary[0] 
                            let videoKey = video["key"] as! String
                            let videoUrl = NSURL(string: "https://www.youtube.com/watch?v=\(videoKey)")
                            let myURLRequest : NSURLRequest = NSURLRequest(URL: videoUrl!)
                            self.webView.loadRequest(myURLRequest)
                    }
                }
        })
        task.resume()
        
        
        
        
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        scrollView2.contentSize = CGSize(width: scrollView2.frame.width, height: infoView.frame.origin.y + infoView.frame.size.height)
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
