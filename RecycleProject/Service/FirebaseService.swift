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

class FirebaseService {
    
    static func downloadImage (urlString: String, completionHandler: @escaping(_ imageData: UIImage)->()) {
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completionHandler(cachedImage)
        } else {
            let maxSize: Int64 = 1 * 1024 * 1024
            
            DispatchQueue.global().async {
                Storage.storage().reference(forURL: urlString).getData(maxSize: maxSize) { (data, error) in
                    guard let imageData = data,
                        error == nil else {
                            print(error!.localizedDescription)
                            return
                    }
                    guard let image = UIImage(data: imageData) else { return }
                    imageCache.setObject(image, forKey: urlString as NSString)
                    DispatchQueue.main.async {
                        completionHandler(image)
                    }
                }
            }
        }
    }
    
    static func getData<T: genericFirebaseDataProtocol> (collectionPath: String, completionHandler: @escaping(_ data: [T])->()) {
        DispatchQueue.global().async {
            Firestore.firestore().collection(collectionPath).getDocuments { (snapshot, error) in
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
