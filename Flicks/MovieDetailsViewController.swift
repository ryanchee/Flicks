//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Ryan Chee on 10/14/16.
//  Copyright © 2016 ryanchee. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    var image: UIImage? = nil
    var movieTitle: String? = nil
    var movieDescription: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        moviePosterImageView.image = image
        movieTitleLabel.text = movieTitle
        movieDescriptionLabel.text = movieDescription
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        movieDescriptionLabel.sizeToFit()
        movieTitleLabel.sizeToFit()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
