//
//  DogRunViewController.swift
//  PupsAndPlaygrounds
//
//  Created by Missy Allan on 12/7/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import GoogleMaps

class DogRunViewController: UIView, UIViewController, GMSMapViewDelegate {

    
    var location: Dogrun!
    var dogRunProfileView: DogRunViewController!
    var dogReviewTableView: UITableView!
    var currentUser: User?
    var dogReviewsArray: [Review?] = []
    

    
    var dogRunNameLabel: UILabel!
    var dogRunAddressLabel: UILabel!
    var submitReviewButton: UIButton!
    var reviewsView: UIView!
    var reviewsTableView: UIView!
    var dogStreetView: UIView!
    var dogPanoView: GMSPanoramaView!
    var starReviews: StarReview!
    var rating: String?
    var dogNotes: String
    var dogDetailView: UIView!
    var dogNotesView: UIView!
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    convenience init(dogrun: Dogrun) {
        self.init(frame: CGRect.zero)
        location = dogrun
        
        // TODO: call configure() to configure view here
        //TODO:  call constrain() to constrain view objects here
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func configure() {
        
        //TODO:  call calculate average star for location here
        
        
        backgroundColor = UIColor.themeWhite
        
        //configure dogStreetView & dogPanoView
        dogStreetView = UIView()
        dogPanoView = GMSPanoramaView()
        dogPanoView.moveNearCoordinate(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        dogPanoView.layer.cornerRadius = 5
        
        
        //configure dogRunNameLabel 
        dogRunNameLabel = UILabel()
        dogRunNameLabel.font = UIFont.themeMediumThin
        dogRunNameLabel.textColor = UIColor.themeDarkBlue
        dogRunNameLabel.adjustsFontSizeToFitWidth = true
        dogRunNameLabel.numberOfLines = 2
        dogRunNameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        // configure dogRunAddressLabel
        dogRunAddressLabel = UILabel()
        dogRunAddressLabel.font = UIFont.themeMediumLight
        dogRunAddressLabel.textColor = UIColor.themeDarkBlue
        dogRunAddressLabel.adjustsFontSizeToFitWidth = true
        dogRunAddressLabel.numberOfLines = 3
        dogRunAddressLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        
        //configure dogRunTypeIcon 
        
        //if dogrun.isOffLeash = true 
          // display dogRun.offLeash icon 
        // else // 
            // display dogRun.Run icon 
        
    
        
        //configure reviews view 
        reviewsView = UIView()
        
        
        //configure reviews tableview 
        reviewsTableView = UITableView()
        reviewsTableView.rowHeight = 40
        reviewsTableView.backgroundColor = UIColor.themeLightBlue
        reviewsTableView.layer.cornerRadius = 5
        
        //configure submitReviewButton 
        submitReviewButton = UIButton(frame: CGRect(x: 0, y: 0, width:700 , height: 120))
        submitReviewButton.setTitle("Submit a Review", for: .normal)
        submitReviewButton.layer.cornerRadius = 2
        submitReviewButton.titleLabel?.font = UIFont.themeSmallThin
        submitReviewButton.backgroundColor = UIColor.themeRed
        submitReviewButton.setTitleColor(UIColor.themeWhite, for: .normal)
        
    
        
     
    //configure() function finished
    }
    
    
        func constrain() {
            
            //addSubview(nameOfObject)
            // nameOfObject.snp.makeConstraints {
               //leadingMargin
               // topMargin 
               // width 
               // height
            
            addSubview(streetView)
            streetView.snp.makeConstraints {
                $0.top.equalTo(locationProfileImage.snp.bottom)
                $0.height.equalToSuperview().dividedBy(2)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            
            
            
            //streetView
            
            //panoView
            
            //dogAddressLabel
            
            //reviewsView 
            
            //submitReviwButton 
            
            //reviewsTableView
            
            //starReviews
            
            
            
            
       // }
        
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        // constrain() function finsihed
        }
        
            
        
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        
        
        
        
        
        
        
        
    
        
        
        
        
    }
    
    
    
    
    
    
