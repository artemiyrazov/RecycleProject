//
//	FirebaseImageService.swift
// 	RecycleProject
//

import UIKit
import Firebase

protocol genericFirebaseDataProtocol {
    init?(documentSnapshot: QueryDocumentSnapshot)
}

var imageCache = NSCache<NSString, UIImage>()
let maxSize: Int64 = 5 * 1024 * 1024 // 5 MB

class FirebaseService {
    
    static func getData<T: genericFirebaseDataProtocol>(collectionPath: String, filterBy: String? = nil, filterArray: [String]? = nil, completionHandler: @escaping(_ data: [T])->()) {
        
        var query: Query
        
        if let filterBy = filterBy, let filterArray = filterArray {
            if filterArray.isEmpty {
                let result: [T] = []
                completionHandler(result)
                return
            }
            query = Firestore.firestore().collection(collectionPath).whereField(filterBy, in: filterArray)
        } else {
            query = Firestore.firestore().collection(collectionPath)
        }
        
        DispatchQueue.global().async {
            query.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot,
                    error == nil else {
                        print(error!.localizedDescription)
                        return
                }
                
                var data: [T] = []
                for document in snapshot.documents {
                    if let dataItem = T(documentSnapshot: document) {
                        data.append(dataItem)
                    } else {
                        print("Some problem with init this document: \(document.documentID)")
                    }
                }
                DispatchQueue.main.async {
                    completionHandler(data)
                }
            }
        }
    }
}

class UIImageViewFromFirebase: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUsingUrlString(urlString: String) {
        
        imageUrlString = urlString
        
        guard let url = URL(string: urlString) else { return }
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async {
                guard let imageToCache = UIImage(data: data!) else { return }
                
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                
                imageCache.setObject(imageToCache, forKey: urlString as NSString)
            }
            
        }).resume()
    }
    
}
