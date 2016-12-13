//
//  UserProfileViewController.swift
//  PupsAndPlaygrounds
//
//  Created by William Robinson on 11/21/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class UserProfileViewController: UIViewController {
  
  // MARK: Properties
  lazy var userProfileView = UserProfileView()
  lazy var imagePicker = UIImagePickerController()
  
  let containerVC = (UIApplication.shared.delegate as? AppDelegate)?.containerViewController
  let store = DataStore.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
    constrain()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  
    userProfileView.reviewsTableView.reloadData()
  }
  
  override func viewDidLayoutSubviews() {
    userProfileView.layer.sublayers?.first?.frame = userProfileView.bounds
    userProfileView.profileButton.layer.cornerRadius = userProfileView.profileButton.frame.width / 2
  }
  
  // MARK: Setup
  private func configure() {
    navigationItem.title = "Profile"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutButtonTouched))
    
    userProfileView.profileButton.addTarget(self, action: #selector(profileButtonTouched), for: .touchUpInside)
    
    userProfileView.reviewsTableView.delegate = self
    userProfileView.reviewsTableView.dataSource = self
    userProfileView.reviewsTableView.register(UserReviewTableViewCell.self, forCellReuseIdentifier: "userReviewCell")
    
    NotificationCenter.default.addObserver(self, selector: #selector(finishedSaving), name: Notification.Name("savedProfilePhoto"), object: nil)
  }
  
  private func constrain() {
    view.addSubview(userProfileView)
    userProfileView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    view.layoutIfNeeded()
  }
  
  // MARK: Display User Information
  func displayUserInfo() {
    DispatchQueue.main.async {
      if let profilePhoto = self.store.user?.profilePhoto {
        self.userProfileView.profileButton.setImage(profilePhoto, for: .normal)
      } else {
        self.userProfileView.profileButton.setImage(#imageLiteral(resourceName: "AddPhoto"), for: .normal)
      }
      
      if let firstName = self.store.user?.firstName, let lastName = self.store.user?.lastName {
        self.userProfileView.userNameLabel.text = "\(firstName) \(lastName)"
      }
      
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: Display User Reviews
  func displayUserReviews() {
    DispatchQueue.main.async {
      self.userProfileView.reviewsTableView.reloadData()
    }
  }
  
  // MARK: Photo Saved Successfully
  func finishedSaving() {
    DispatchQueue.main.async {
      self.userProfileView.savingView.isHidden = true
      self.userProfileView.savingActivityIndicator.stopAnimating()
    }
  }
  
  // MARK: Action Methods
  func profileButtonTouched() {
    let alert = UIAlertController(title: "Update Profile Photo", message: nil, preferredStyle: .actionSheet)
    
    let cameraRoll = UIAlertAction(title: "Camera roll", style: .default) { _ in
      if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        
        self.present(self.imagePicker, animated: true, completion: nil)
      }
    }
    
    let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { _ in
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        self.imagePicker.cameraCaptureMode = .photo
        self.imagePicker.allowsEditing = true
        
        self.present(self.imagePicker, animated: true, completion: nil)
      }
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(cameraRoll)
    alert.addAction(takePhoto)
    alert.addAction(cancel)
    
    present(alert, animated: true, completion: nil)
  }
  
  func logOutButtonTouched() {
    do {
      try FIRAuth.auth()?.signOut()
    } catch {
      print("error signing user out")
    }
    
    containerVC?.childVC = LoginViewController()
    containerVC?.childVC?.view.layoutIfNeeded()
    containerVC?.setup(forAnimation: .slideUp)
  }
}

// MARK: UIImagePickerControllerDelegate and UINavigationControllerDelegate
extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    store.user?.profilePhoto = info[UIImagePickerControllerEditedImage] as? UIImage
    
    if let profilePhoto = store.user?.profilePhoto {
      userProfileView.profileButton.setImage(profilePhoto, for: .normal)
    }
    
    userProfileView.savingActivityIndicator.startAnimating()
    userProfileView.savingView.isHidden = false
    
    self.dismiss(animated: true, completion: nil)
    
    FIRClient.saveProfilePhoto {
      NotificationCenter.default.post(name: Notification.Name("savedProfilePhoto"), object: nil)
    }
  }
}

// MARK: UITableViewDelegate and UITableViewDataSource
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let count = store.userReviews?.count else {
      return 0
    }
    
    return count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "userReviewCell", for: indexPath) as? UserReviewTableViewCell else {
      print("error unwrapping cell in user review table view")
      return UITableViewCell()
    }
  
    cell.review = store.userReviews?[indexPath.row]
    
    if let locationID = store.userReviews?[indexPath.row].locationID {
      FIRClient.getLocation(with: locationID) {
        cell.locationNameLabel.text = $0?.name
      }
    }

    return cell
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    guard let userID = store.userReviews?[indexPath.row].userID,
      let reviewID = store.userReviews?[indexPath.row].reviewID,
      let locationID = store.userReviews?[indexPath.row].locationID,
      let reviewComment = store.userReviews?[indexPath.row].comment else {
        print("trouble casting reviewComment")
        return nil
    }
    
    if userID == store.user?.uid {
      let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
        self.store.userReviews?.remove(at: indexPath.row)
        
        FIRClient.deleteReview(userID: userID, reviewID: reviewID, locationID: locationID) {
          let alert = UIAlertController(title: "Success", message: "You have deleted this comment", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
          
          self.present(alert, animated: true, completion: nil)
        }
      }
      
      delete.backgroundColor = UIColor.themeCoral
      
      return [delete]
    }
    
    let flag = UITableViewRowAction(style: .destructive, title: "Flag") { action, indexPath in
      self.store.userReviews?.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      
      FIRClient.flagReviewWith(unique: reviewID, locationID: locationID, comment: reviewComment, userID: userID) {
        let alert = UIAlertController(title: "Success!", message: "You have flagged this comment for review", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
      }
    }
    
    flag.backgroundColor = UIColor.themeSunshine
    
    return [flag]
  }
}





