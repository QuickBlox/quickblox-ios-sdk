//
//  ExploreVideoViewController.swift
//  livedemo
//
//  Created by Vladyslav Poznyak on 11/13/17.
//  Copyright © 2017 reactoo. All rights reserved.
//

import Foundation
import WebKit

final class ExploreVideoViewController: UITableViewController {
    enum Video: String {
        case itCrowd = "ITCrowd"
        case siliconValley = "SiliconValley"
        
        var title: String {
            switch self {
            case .itCrowd:
                return "IT Crowd"
            case .siliconValley:
                return "Silicon Valley"
            }
        }
    }
    
    let videos = [
        Video.itCrowd,
        Video.siliconValley
    ]
    
    var selectedVideo: URL?
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        let title = videos[indexPath.row].title
        cell.textLabel?.text = title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let path = Bundle.main.path(forResource: videos[indexPath.row].rawValue, ofType: "mp4") {
            selectedVideo = URL(fileURLWithPath: path)
        }
        performSegue(withIdentifier: "unwindToConference", sender: nil)
    }
}
