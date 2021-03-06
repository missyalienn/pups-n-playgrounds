//
//  DogRunViewController.swift
//  PupsAndPlaygrounds
//
//  Created by Missy Allan on 12/7/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import GoogleMaps


class DogRunViewController: UIViewController, GMSMapViewDelegate {
    
    let currentUser = DataStore.shared.user
    var dogrunID: String?
    var dogrun: Location?
    var dogRunProfileView: DogRunProfileView!
    var dogReviewsTableView: UITableView!
    var reviewsArray: [Review?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let unwrappedLocationID = dogrunID else { print("trouble unwrapping location ID"); return }
        print("location ID is \(dogrunID)")
        print("DOG RUN REVIEWS ARRAY START = \(reviewsArray.count)")
        
        FIRClient.getLocation(with: unwrappedLocationID) { (firebaseLocation) in
            self.dogrun = firebaseLocation
            print("DOG RUN REVIEWS ARRAY IDS FIREBASE = \(self.dogrun?.reviewIDs.count)")

            if let dogrunReviewsIDs = self.dogrun?.reviewIDs {
                for reviewID in dogrunReviewsIDs {
                    FIRClient.getReview(with: reviewID, completion: { (firebaseReview) in
                        
                        self.reviewsArray.append(firebaseReview)
                        self.dogRunProfileView.dogReviewsTableView.reloadData()
                        
                    })
                }
            }
            self.configure()

        }

    }
//
//
//    override func viewDidLayoutSubviews() {
//        
//        dogRunProfileView.dogDetailView.layer.addSublayer(CustomBorder(.bottom, UIColor.lightGray, 0.5, dogRunProfileView.dogDetailView.frame))
//        
//        dogRunProfileView.dogNotesView.layer.addSublayer(CustomBorder(.bottom, UIColor.lightGray, 0.5, dogRunProfileView.dogNotesView.frame))
//        
//        dogRunProfileView.dogTypeView.layer.addSublayer(CustomBorder(.trailing, UIColor.lightGray, 0.5, dogRunProfileView.dogTypeView.frame))
//        
//        view.layoutIfNeeded()
//        
//    }
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Setup ReviewVC Child
    
    func writeReview() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        tabBarController?.tabBar.isUserInteractionEnabled = false
        
        print("CLICKED REVIEW BUTTON")
        let childVC = ReviewViewController()
        childVC.location = dogrun
        childVC.reviewDelegate = self
        
        addChildViewController(childVC)
        
        view.addSubview(childVC.view)
        childVC.view.snp.makeConstraints {
            childVC.edgesConstraint = $0.edges.equalToSuperview().constraint
        }
        childVC.didMove(toParentViewController: self)
        
        view.layoutIfNeeded()
    }
    
    
    func configure() {
    
        
        guard let unwrappedDogRun = dogrun as? Dogrun else { print("error unwrapping dogrun"); return }
        self.dogRunProfileView = DogRunProfileView(dogrun: unwrappedDogRun)
        
        let color1 = UIColor(red: 34/255.0, green: 91/255.0, blue: 102/255.0, alpha: 1.0)
        let color2 = UIColor(red: 141/255.0, green: 191/255.9, blue: 103/255.0, alpha: 1.0)
        
        let backgroundGradient = CALayer.makeGradient(firstColor: color1, secondColor: color2)
        
        backgroundGradient.frame = view.frame
        self.view.layer.insertSublayer(backgroundGradient, at: 0)

        
        dogReviewsTableView = dogRunProfileView.dogReviewsTableView
        dogRunProfileView.dogReviewsTableView.delegate = self
        dogRunProfileView.dogReviewsTableView.dataSource = self
        dogRunProfileView.dogReviewsTableView.register(LocationReviewTableViewCell.self, forCellReuseIdentifier: "dogReviewCell")
        dogRunProfileView.dogReviewsTableView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        self.view.addSubview(dogRunProfileView)
        dogRunProfileView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dogRunProfileView.dogRunNameLabel.text = dogrun?.name
        dogRunProfileView.dogRunAddressLabel.text = dogrun?.address
        
        
        dogRunProfileView.dogNotesLabel.text = unwrappedDogRun.notes
        
        if unwrappedDogRun.notes == "" {
            dogRunProfileView.dogNotesLabel.text = "This dogrun has no notes yet."
        }
        
        
        if unwrappedDogRun.isOffLeash == true {
            dogRunProfileView.dogTypeLabel.text = "Off-Leash"
        }else{
            dogRunProfileView.dogTypeLabel.text = "Run"
        }
        
        if FIRAuth.auth()?.currentUser?.isAnonymous == false {
            self.dogRunProfileView.submitReviewButton.addTarget(self, action: #selector(writeReview), for: .touchUpInside)
        } else {
            self.dogRunProfileView.submitReviewButton.addTarget(self, action: #selector(anonymousReviewerAlert), for: .touchUpInside)
        }
        
        
    }
    
    func anonymousReviewerAlert() {
        let alert = UIAlertController(title: "Woof! Only users can submit reviews 🐶", message: "Head to profile to set one up!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func flagButtonTouched(sender: UIButton) {
        
        let cellContent = sender.superview!
        let cell = cellContent.superview! as! UITableViewCell
        let indexPath = dogRunProfileView.dogReviewsTableView.indexPath(for: cell)
        
        if let flaggedReview = reviewsArray[(indexPath?.row)!] {
            
            FIRClient.flagReviewWith(unique: flaggedReview.reviewID, locationID: flaggedReview.locationID, comment: flaggedReview.comment, userID: flaggedReview.userID) {
                let alert = UIAlertController(title: "Success!", message: "You have flagged this comment for review", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                    FIRClient.getVisibleReviews { reviews in
                        self.reviewsArray = reviews
                        self.dogRunProfileView.dogReviewsTableView.reloadData()
                    }
                })
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension DogRunViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogReviewCell", for: indexPath) as! LocationReviewTableViewCell
        
        if let currentReview = reviewsArray[indexPath.row] {
            cell.review = currentReview
            cell.backgroundColor = UIColor.clear
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        guard let userID = reviewsArray[indexPath.row]?.userID else { print("trouble casting userID");return [] }
        guard let reviewID = reviewsArray[indexPath.row]?.reviewID else { print("trouble casting reviewID");return [] }
        guard let locationID = reviewsArray[indexPath.row]?.locationID else { print("trouble casting locationID");return [] }
        guard let reviewComment = reviewsArray[indexPath.row]?.comment else { print("trouble casting reviewComment"); return [] }
        
                print("REVIEW USER ID = \(userID) AND CURRENT USER UID = \(currentUser?.uid)")
        if userID == currentUser?.uid {
            
            
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                
                self.reviewsArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                FIRClient.deleteReview(userID: userID, reviewID: reviewID, locationID: locationID) {
                    
                    let alert = UIAlertController(title: "Success!", message: "You have flagged this comment for review", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                        FIRClient.getVisibleReviews { reviews in
                            self.reviewsArray = reviews
                            self.dogRunProfileView.dogReviewsTableView.reloadData()
                        }
                    })
                }
            }
            delete.backgroundColor = UIColor.themeCoral
            return [delete]
            
        } else {
            
            let flag = UITableViewRowAction(style: .destructive, title: "Flag") { (action, indexPath) in
                
                self.reviewsArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                FIRClient.flagReviewWith(unique: reviewID, locationID: locationID, comment: reviewComment, userID: userID) {
                    let alert = UIAlertController(title: "Success!", message: "You have flagged this comment for review", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                        FIRClient.getVisibleReviews { reviews in
                            self.reviewsArray = reviews
                            self.dogRunProfileView.dogReviewsTableView.reloadData()
                        }
                    })
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            flag.backgroundColor = UIColor.themeSunshine
            return [flag]
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    
}



extension DogRunViewController: AddReviewProtocol {
    func addReview(with newReview: Review?) {
        reviewsArray.append(newReview)
    }
    
    func updateRating(with newRating: Float) {
        dogRunProfileView.starReviews.value = newRating
    }
}



