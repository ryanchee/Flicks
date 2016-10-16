//
//  ViewController.swift
//  Flicks
//
//  Created by Ryan Chee on 10/12/16.
//  Copyright © 2016 ryanchee. All rights reserved.
//

import UIKit
import MBProgressHUD


class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate {

    @IBOutlet var tapGestureView: UIView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var moviesTableView: UITableView!
    
    var responseData: NSArray? = nil
    var originalData: NSArray? = nil
    var moviesArray: [MovieInfo] = []
    var pageNumber: Int = 1
    var networkIsGood: Bool = false
    let searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 345, height: 20))
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    var endpoint = "now_playing"

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        let refreshControl = UIRefreshControl()
        searchBar.placeholder = "Search"
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        moviesTableView.delegate = self
        //self.searchBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NowPlayingViewController.dismissKeyboard)))
        refreshControl.addTarget(self, action: #selector(refreshData(refreshControl:)), for: UIControlEvents.valueChanged)
        moviesTableView.insertSubview(refreshControl, at: 0)
        loadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = moviesTableView.dequeueReusableCell(withIdentifier: "com.ryanchee.exampleCell") as! MyCell
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.orange
        cell.selectedBackgroundView = selectedBackgroundView
        cell.contentView.backgroundColor = UIColor(red: 255, green: 197, blue: 108, alpha: 1)
        //cell.contentView.backgroundColor = UIColor(red: 255, green: 197, blue: 108, alpha: 1)
        if moviesArray.count > 0 {
            cell.customTextLabel?.text = moviesArray[indexPath.row].original_title
            if moviesArray[indexPath.row].poster_path != nil {
                if let url = URL(string: "https://image.tmdb.org/t/p/w500\(moviesArray[indexPath.row].poster_path!)") {
                    cell.moviePosterImage.contentMode = .scaleAspectFill
                    cell.moviePosterImage.setImageWith(url)
                    let urlRequest = URLRequest(url: url)
                    cell.moviePosterImage.setImageWith(urlRequest, placeholderImage: nil, success: { (urlRequest, imageResponse, image) in
                        // imageResponse will be nil if the image is cached
                        if imageResponse != nil {
                            print("Image was NOT cached, fade in image")
                            cell.moviePosterImage.alpha = 0.0
                            cell.moviePosterImage.image = image
                            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                cell.moviePosterImage.alpha = 1.0
                            })
                        } else {
                            print("Image was cached so just update the image")
                            cell.moviePosterImage.image = image
                        }
                        }, failure: { (urlRequest, imageResponse, error) in
                            
                    })
                }
            }
            cell.movieDescriptionLabel.text = moviesArray[indexPath.row].overview
            cell.movieDescriptionLabel.sizeToFit()
            cell.customTextLabel.sizeToFit()
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var filteredMovies: [MovieInfo] = []
        moviesArray = getMoviesArray()
        for movie in moviesArray {
            let input = searchBar.text!
            if ((movie.original_title?.lowercased().range(of: input.lowercased())) != nil) {
                    //add to array here and update view
                    filteredMovies.append(movie)
                    print("\(searchBar.text)")
                    print("here: \(movie.original_title)")
                    print("filteredMovies.count: \(filteredMovies.count)")
            }
        }
        if searchBar.text == "" {
            moviesArray = getMoviesArray()
            moviesTableView.reloadData()
        } else {
            moviesArray = filteredMovies
            moviesTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("asdfaSD")
        moviesArray = getMoviesArray()
        moviesTableView.reloadData()
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let scrollViewContentHeight = moviesTableView.contentSize.height
//        let scrollOffsetThreshold = scrollViewContentHeight - moviesTableView.bounds.size.height
//        if(scrollView.contentOffset.y > scrollOffsetThreshold) {
//        //    loadData()
//        }
//    }
    
    func refreshData(refreshControl: UIRefreshControl) {
        pageNumber = 1
        MBProgressHUD.showAdded(to: moviesTableView, animated: true)
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)&page=\(pageNumber)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { [unowned self] (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    if let resultsArray = responseDictionary.value(forKeyPath: "results") as? NSArray {
                        self.responseData = resultsArray
                        print("response data size: \(self.responseData!.count)")
                        if self.networkIsGood == false {
                            UIView.animate(withDuration: 2.0, animations: {
                                self.networkErrorView.transform = CGAffineTransform(translationX: 0.0, y: -64.0)
                            })
                            self.networkIsGood = true
                        }
                        self.moviesArray = self.getMoviesArray()
                        self.moviesTableView.reloadData()
                        refreshControl.endRefreshing()
                        MBProgressHUD.hide(for: self.moviesTableView, animated: true)
                    }
                }
            } else {
                self.networkIsGood = false
                UIView.animate(withDuration: 1.0, animations: {
                    self.networkErrorView.transform = CGAffineTransform(translationX: 0.0, y: 64.0)
                })
            }
        });
        task.resume()
    }
    
    func loadData() {
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)&page=\(pageNumber)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { [unowned self] (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    if let resultsArray = responseDictionary.value(forKeyPath: "results") as? NSArray {
                        self.responseData = resultsArray
                        print("response data size: \(self.responseData!.count)")
                        if self.networkIsGood == false {
                            UIView.animate(withDuration: 2.0, animations: {
                                self.networkErrorView.transform = CGAffineTransform(translationX: 0.0, y: -64.0)
                            })
                            self.networkIsGood = true
                        }
                        self.pageNumber += 1
                        self.moviesArray = self.getMoviesArray()
                        self.moviesTableView.reloadData()
                    }
                }
            } else {
                self.networkIsGood = false
                UIView.animate(withDuration: 1.0, animations: {
                    self.networkErrorView.transform = CGAffineTransform(translationX: 0.0, y: 64.0)
                })
            }
        });
        task.resume()
    }
    
    func getMoviesArray() -> [MovieInfo] {
        var moviesArray: [MovieInfo] = []
        if let count = self.responseData?.count {
            for i in stride(from: 0, to: count, by: 1) {
                if let test = responseData?[i] as? NSDictionary {
                    let movie = MovieInfo(movie: test)
                        moviesArray.append(movie)
                }
            }
        }
        return moviesArray
    }
    
//    func dismissKeyboard() {
////        searchBar.resignFirstResponder()
////        tapGestureView.resignFirstResponder()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MovieDetailsViewController
        if let index = moviesTableView.indexPath(for: sender as! MyCell){
            if let cell = moviesTableView.cellForRow(at: index) as? MyCell {
                if let image = cell.moviePosterImage.image {
                    destinationVC.image = image
                    destinationVC.movieDescription = cell.movieDescriptionLabel.text
                    destinationVC.movieTitle = cell.customTextLabel.text
                }
            }
        }
    }
    
}


class MyCell: UITableViewCell {
    
    @IBOutlet weak var customTextLabel: UILabel!
    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    
}
