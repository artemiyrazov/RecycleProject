//
//	SettingsTableViewController.swift
// 	RecycleProject
//

import UIKit

protocol SettingsTableViewControllerDelegate {
    func changeRegion(newRegion: Region)
    func changeFavoritePublishers(newPublishers: [Publisher])
}

class SettingsTableViewController: UITableViewController, SettingsTableViewControllerDelegate {

    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernamePlaceholderLabel: UILabel!
    @IBOutlet weak var regionPlaceholderLabel: UILabel!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    private let colorThemeSection = 3
    private var initialColorThemeIndexPath: IndexPath {
        return IndexPath(row: UserDefaults.standard.overridedUserInterfaceStyle.rawValue, section: colorThemeSection)
    }
    
    @IBAction func notificationsSwitchValueChanged(_ sender: UISwitch) {
        
        if notificationsSwitch.isOn {
            UserDefaults.standard.setNotificationsEnabled(value: true)
            print("Notifications enabled")
        } else {
            UserDefaults.standard.setNotificationsEnabled(value: false)
            print("Notifications disabled")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = UserDefaults.standard.getUsername()
        usernamePlaceholderLabel.text = UserDefaults.standard.getUsername()
        regionPlaceholderLabel.text = UserDefaults.standard.getRegion()?.name
        notificationsSwitch.setOn(UserDefaults.standard.isNotificationsEnabled(), animated: false)
    }
    
    func changeRegion(newRegion: Region) {
        UserDefaults.standard.setRegion(value: newRegion)
        regionPlaceholderLabel.text = newRegion.name
    }
    
    func changeFavoritePublishers(newPublishers: [Publisher]) {
        UserDefaults.standard.setFavoritePublishers(value: newPublishers)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "regionSegue":
            guard let regionVC = segue.destination as? RegionViewController else { return }
            regionVC.delegate = self
        default:
            guard let publisherVC = segue.destination as? PublisherViewController else { return }
            publisherVC.delegate = self
        }
        
    }
    
    
    //MARK: - Work with table
    
    private func removeCheckmarks(except exceptedRow: Int) {
        for i in 0..<tableView.numberOfRows(inSection: colorThemeSection) {
            if i != exceptedRow {
                tableView.cellForRow(at: IndexPath(row: i, section: colorThemeSection))?.accessoryType = .none
            }
        }
    }
    
    private func changeColorTheme(row: Int) {
        guard let scene = self.view.window?.windowScene?.delegate as? SceneDelegate else { return }
        
        switch UIStyle(rawValue: row) {
        case .unspecified:
            scene.changeUIStyle(UIStyle: .unspecified)
        case .light:
            scene.changeUIStyle(UIStyle: .light)
        case .dark:
            scene.changeUIStyle(UIStyle: .dark)
        default:
            break
        }
    }
    
    private func showNameChangeAlertController () {
        let alert = UIAlertController(title: "Новое имя", message: "Введи новое имя:", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.textFields?.first?.tintColor = UIColor(named: "CustomTabBarTintColor")
        alert.addAction(UIAlertAction(title: "Отменить", style: .destructive))
        let saveAction = UIAlertAction(title: "Сохранить", style: .cancel, handler: { [weak self] _ in
            guard let self = self,
                let newUsername = alert.textFields?.first?.text,
                newUsername != "" else { return }
            UserDefaults.standard.setUsername(value: newUsername)
            DispatchQueue.main.async {
                self.usernameLabel.text = UserDefaults.standard.getUsername()
                self.usernamePlaceholderLabel.text = UserDefaults.standard.getUsername()
            }
        })
        saveAction.setValue(UIColor(named: "CustomTabBarTintColor"), forKey: "titleTextColor")
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    private func configureThemeSectionCells(at indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        changeColorTheme(row: indexPath.row)
        removeCheckmarks(except: indexPath.row)
    }
    
    func configureProfileSectionCells(at indexPath: IndexPath) {
        switch ProfileSection(rawValue: indexPath.row) {
        case .usernameCell:
            showNameChangeAlertController()
        case .regionCell:
            performSegue(withIdentifier: "regionSegue", sender: self)
        case .publishersCell:
            performSegue(withIdentifier: "publishersSegue", sender: self)
        default:
            break
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch TableViewSections(rawValue: indexPath.section) {
        case .profileSection:
            configureProfileSectionCells(at: indexPath)
        case .colorThemeSection:
            configureThemeSectionCells(at: indexPath)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == initialColorThemeIndexPath {
            cell.accessoryType = .checkmark
        }
    }
}