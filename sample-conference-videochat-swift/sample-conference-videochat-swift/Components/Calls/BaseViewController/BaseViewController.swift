//
//  BaseViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 17.08.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

struct BaseConstant {
    static let hideInterval: TimeInterval = 5.0
}

class BaseViewController: UIViewController {
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy private var containerToolBarView: CallGradientView = {
        let containerToolBarView = CallGradientView(frame: .zero)
        containerToolBarView.backgroundColor = .clear
        return containerToolBarView
    }()
    
    lazy var toolbar: ToolBar = {
        let toolbar = ToolBar(frame: .zero)
        toolbar.backgroundColor = .clear
        toolbar.isTranslucent = true
        return toolbar
    }()
    
    lazy private var topGradientView: CallGradientView = {
        let topGradientView = CallGradientView(frame: .zero)
        topGradientView.backgroundColor = .clear
        return topGradientView
    }()
    
    //MARK: - Internal Properties
    private var toolbarHideTimer: Timer?
    var collectionViewTopConstraint: NSLayoutConstraint!
    private var topGradientViewHeightConstraint: NSLayoutConstraint!
    private var containerToolBarTopConstraint: NSLayoutConstraint!
    
    
    //MARK: - Life Cycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBarWillAppear(true)
        showControls(true)
        setupHideToolbarTimerWithTimeInterval(BaseConstant.hideInterval)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadContent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setupNavigationBarWillAppear(false)
        invalidateHideToolbarTimer()
    }
    
    //MARK: - These methods can be overridden in child controllers
    func configureNavigationBarItems() {
        // configure it if necessary.
    }
    
    func configureToolBar() {
        // configure it if necessary.
    }
    
    
    //MARK - Setup Views
    func setupNavigationBarWillAppear(_ isWillAppear: Bool) {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = isWillAppear
    }
    
    func setupCollectionView() {
       
    }
    
     func configureGUI() {
        view.backgroundColor = .black
        
        // configure it if necessary.
        setupCollectionView()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let topBarHeight = self.navigationController?.navigationBar.frame.height ?? 44.0
        collectionView.contentInset = UIEdgeInsets(top: -topBarHeight, left: 0, bottom: 0, right: 0)
        collectionViewTopConstraint = collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        collectionViewTopConstraint.constant = -topBarHeight
        collectionViewTopConstraint.isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        view.addSubview(containerToolBarView)
        containerToolBarView.translatesAutoresizingMaskIntoConstraints = false
        containerToolBarView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerToolBarView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerToolBarTopConstraint = containerToolBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -126.0)
        containerToolBarTopConstraint.isActive = true
        containerToolBarView.heightAnchor.constraint(equalToConstant: 126.0).isActive = true
        
        containerToolBarView.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.leftAnchor.constraint(equalTo: containerToolBarView.leftAnchor).isActive = true
        toolbar.topAnchor.constraint(equalTo: containerToolBarView.topAnchor).isActive = true
        toolbar.rightAnchor.constraint(equalTo: containerToolBarView.rightAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 96.0).isActive = true
        
        view.addSubview(topGradientView)
        topGradientView.translatesAutoresizingMaskIntoConstraints = false
        topGradientView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topGradientView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topGradientView.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        topGradientViewHeightConstraint = topGradientView.heightAnchor.constraint(equalToConstant: 100.0)
        if let isLandscape = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape {
            print("isLandscape \(isLandscape)")
            topGradientViewHeightConstraint.constant = 56.0
        } else {
            topGradientViewHeightConstraint.constant = 100.0
        }
        
        topGradientViewHeightConstraint.isActive = true
        
        containerToolBarView.setupGradient(firstColor: UIColor.black.withAlphaComponent(0.0), secondColor: UIColor.black.withAlphaComponent(0.7))
        topGradientView.setupGradient(firstColor: UIColor.black.withAlphaComponent(0.7), secondColor: UIColor.black.withAlphaComponent(0.0))
        
        // configure it if necessary.
        configureToolBar()
        
        // configure it if necessary.
        configureNavigationBarItems()
    }
    
    //MARK: - Public Methods
    func reloadContent() {
        collectionView.reloadData()
    }
    
    //MARK: - Hide/Show Controls Methods
    func setupHideToolbarTimerWithTimeInterval(_ timeInterval: TimeInterval) {
        invalidateHideToolbarTimer()
        self.toolbarHideTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                     target: self,
                                                     selector: #selector(hideControls),
                                                     userInfo: nil,
                                                     repeats: false)
    }
    
    @objc private func hideControls() {
        showControls(false)
    }
    
    func showControls(_ isShow: Bool) {
        setupControls(isShow)
    }
    
    func setupControls(_ isShow: Bool) {
        let color: UIColor = isShow == true ? .white : .clear
        if isShow == true, containerToolBarView.isHidden == true {
            setupHideToolbarTimerWithTimeInterval(BaseConstant.hideInterval)
        }
        navigationItem.titleView?.isHidden = !isShow
        navigationItem.leftBarButtonItem?.tintColor = color
        navigationItem.rightBarButtonItem?.tintColor = color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
        topGradientView.isHidden = !isShow
        containerToolBarView.isHidden = !isShow
        containerToolBarTopConstraint.constant = isShow == true ? -126.0 : 0.0
    }
    
    //MARK: - Internal Methods
    func invalidateHideToolbarTimer() {
        if self.toolbarHideTimer != nil {
            self.toolbarHideTimer?.invalidate()
            self.toolbarHideTimer = nil
        }
    }
    
    // MARK: Transition to size
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else {return}
            self.topGradientView.layoutSubviews()
            self.toolbar.layoutSubviews()
            self.reloadContent()
            
            if let isLandscape = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape {
                print("isLandscape \(isLandscape)")
                self.topGradientViewHeightConstraint.constant = 56.0
            } else {
                self.topGradientViewHeightConstraint.constant = 100.0
            }
        })
    }
}

extension BaseViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
