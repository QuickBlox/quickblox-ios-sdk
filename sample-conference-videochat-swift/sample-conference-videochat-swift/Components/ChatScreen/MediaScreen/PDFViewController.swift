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
        guard let actionsMenuVC = ScreenFactory().makeActionsMenuOutput() else { return }
        actionsMenuVC.typeActionsMenuVC = .mediaInfo
        actionsMenuVC.modalPresentationStyle = .overFullScreen
        let saveAttachmentAction = MenuAction(title: "Save attachment", action: .saveAttachment) { [weak self] (action) in
            guard let pdfUrl = self?.pdfUrl else {
                return
            }
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
        actionsMenuVC.addAction(saveAttachmentAction)
        
        present(actionsMenuVC, animated: false)
    }
}

extension PDFViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
