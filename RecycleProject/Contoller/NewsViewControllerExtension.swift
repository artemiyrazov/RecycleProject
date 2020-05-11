//
//	NewsViewControllerExtension.swift
// 	RecycleProject
//

import UIKit
import Firebase

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yy"
        return df
    }
    
    
    private func configureCell (cell: NewsTableViewCell, for indexPath: IndexPath) {
        
        let newsItem = news[indexPath.row]
        
        cell.titleLabel.text = newsItem.title
        cell.authorLabel.text = newsItem.publisher
        cell.bodyLabel.text = "В Москве стартует проект об экологии и разумном потреблении «Экоразговор». В рамках проекта жители города смогут посмотреть онлайн-лекции в течение мая" // newsItem.annotation
        cell.dateLabel.text = dateFormatter.string(from: newsItem.date)
        
        
        let maxSize: Int64 = 1 * 1024 * 1024
        DispatchQueue.global().async {
            Storage.storage().reference(forURL: newsItem.imageUrlString).getData(maxSize: maxSize) { (data, error) in
                guard let imageData = data,
                    error == nil else {
                        print(error!.localizedDescription)
                        return
                }
                DispatchQueue.main.async {
                    cell.newsImage.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        configureCell(cell: cell, for: indexPath)
        return cell
        
    }
    
    
    
}
