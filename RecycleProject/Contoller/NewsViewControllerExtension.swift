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
        
        let newsItem = news[indexPath.section]
        
        cell.newsImageView.image = nil
        cell.titleLabel.text = newsItem.title
        cell.publisherLabel.text = newsItem.publisher
        cell.annotationLabel.text = newsItem.annotation
        cell.dateLabel.text = dateFormatter.string(from: newsItem.date)
        
        FirebaseService.downloadImage(urlString: newsItem.imageUrlString) { data in
            DispatchQueue.main.async {
                cell.newsImageView.image = UIImage(data: data)
            }
        }
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }

    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        configureCell(cell: cell, for: indexPath)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentNewsItem = news[indexPath.section]
        performSegue(withIdentifier: "NewsItemSegue", sender: self)
        
    }
    
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        news.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
//        configureCell(cell: cell, for: indexPath)
//        return cell
//
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        currentNewsItem = news[indexPath.row]
//        performSegue(withIdentifier: "NewsItemSegue", sender: self)
//
//    }
    
}
