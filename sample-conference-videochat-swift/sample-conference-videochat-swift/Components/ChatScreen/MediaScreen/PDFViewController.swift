//
//  PDFViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 12/12/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import PDFKit
import SVProgressHUD

@available(iOS 11.0, *)
class PDFViewController: UIViewController {
    
    private lazy var infoItem = UIBarButtonItem(image: UIImage(named: "moreInfo"),
                                                style: .plain,
                                                target: self,
                                                action:#selector(didTapInfo(_:)))
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
        
        navigationItem.rightBarButtonItem = infoItem
        infoItem.tintColor = .white
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
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
    
    @objc private func didTapInfo(_ sender: UIBarButtonItem) {
        let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        guard let popVC = chatStoryboard.instantiateViewController(withIdentifier: "ChatPopVC") as? ChatPopVC else {
            return
        }
        popVC.actions = [.SaveAttachment]
        popVC.modalPresentationStyle = .popover
        let chatPopOverVc = popVC.popoverPresentationController
        chatPopOverVc?.delegate = self
        chatPopOverVc?.barButtonItem = infoItem
        chatPopOverVc?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popVC.selectedAction = { [weak self] selectedAction in
            guard let _ = selectedAction else {
                return
            }
            self?.saveFile()
        }
        present(popVC, animated: false)
    }
    
    private func saveFile() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(pdfUrl.lastPathComponent)
        try? FileManager.default.removeItem(at: destinationURL)
        do {
            try FileManager.default.copyItem(at: pdfUrl, to: destinationURL)
            SVProgressHUD.showSuccess(withStatus: "Saved!")
        } catch let error {
            SVProgressHUD.showError(withStatus: "Save error")
            print("Copy Error: \(error.localizedDescription)")
        }
    }
}

extension PDFViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
