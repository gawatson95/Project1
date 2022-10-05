//
//  ViewController.swift
//  Project1
//
//  Created by Grant Watson on 8/24/22.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    var imageViews = [String:Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAppTapped))
        
        performSelector(inBackground: #selector(getImages), with: nil)
        
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "ImageView") as? Data {
            let decoder = JSONDecoder()
            do {
                imageViews = try decoder.decode([String:Int].self, from: savedData)
            } catch {
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func getImages() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        pictures.sort()
        
        DispatchQueue.main.async {
            self.tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        var config = UIListContentConfiguration.cell()
        config.text = pictures[indexPath.row]
        config.secondaryText = "Views: \(imageViews[pictures[indexPath.row]] ?? 0)"
        cell.contentConfiguration = config
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            vc.selectedPictureNumber = indexPath.row + 1
            vc.totalPictures = pictures.count
            navigationController?.pushViewController(vc, animated: true)
        }
        
        let view = (imageViews[pictures[indexPath.row]] ?? 0) + 1
        imageViews.updateValue(view, forKey: pictures[indexPath.row])
        saveViewCount()
        tableView.reloadData()
    }
    
    @objc func shareAppTapped() {
        guard let appURL = URL(string: "https://www.stormchaser.com") else { return }
        
        let vc = UIActivityViewController(activityItems: [appURL], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func saveViewCount() {
        let encoder = JSONEncoder()
        
        if let savedData = try? encoder.encode(imageViews) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "ImageView")
        }
    }
}

