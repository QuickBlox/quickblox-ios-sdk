//
//  PDFViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 12/12/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import PDFKit

@available(iOS 11.0, *)
class PDFViewController: UIViewController {
    private let pdfUrl: URL
    private let document: PDFDocument!
    private var pdfView = PDFView()
    
    init(pdfUrl: URL) {
        self.pdfUrl = pdfUrl
        self.document = PDFDocument(url: pdfUrl)
        pdfView.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        let saveAttachmentAction = UIAction(title: "Save attachment") { [weak self]  action in
            guard let self = self else { return }
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent(self.pdfUrl.lastPathComponent)
            try? FileManager.default.removeItem(at: destinationURL)
            do {
                try FileManager.default.copyItem(at: self.pdfUrl, to: destinationURL)
                self.showAnimatedAlertView(nil, message: "Saved!")
            } catch let error {
                self.showAnimatedAlertView(nil, message: "Save error")
                debugPrint("[PDFViewController] Copy Error: \(error.localizedDescription)")
            }
        }
        let menu = UIMenu(title: "", children: [saveAttachmentAction])
        let infoItem = UIBarButtonItem(image: UIImage(named: "moreInfo"),
                                                    menu: menu)
        navigationItem.rightBarButtonItem = infoItem
        infoItem.tintColor = .white
        
        view.backgroundColor = .black
        
        view.addSubview(pdfView)
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pdfView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        pdfView.backgroundColor = .black
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
    }
    
    
    //MARK: - Actions
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
}
