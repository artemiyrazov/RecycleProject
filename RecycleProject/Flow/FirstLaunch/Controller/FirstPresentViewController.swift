//
//	FirstLaunchViewController.swift
// 	RecycleProject
//

import UIKit

class FirstPresentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        //TODO: Networking checking
        
        FirebaseService.getData(collectionPath: "Publishers") { (data: [Publisher]) in
            UserDefaults.standard.setFavoritePublishers(value: data)
        }
    }

}