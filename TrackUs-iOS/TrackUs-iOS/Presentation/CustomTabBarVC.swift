//
//  CustomTabBarVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit

final class CustomTabBarVC: UITabBarController {
    private lazy var mainButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        btn.backgroundColor = .mainBlue
        btn.setTitle("RUN!", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.layer.cornerRadius = 18
        btn.layer.shadowPath = UIBezierPath(roundedRect: btn.bounds, cornerRadius: btn.layer.cornerRadius).cgPath
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 3, height: 3)
        btn.layer.shadowOpacity = 0.4
        btn.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private let mainBtnWidth: CGFloat = 48
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        addTabItems()
        setupMainButton()
    }
    
    func setupMainButton() {
        self.tabBar.addSubview(mainButton)
        mainButton.frame = CGRect(x: (Int(self.tabBar.bounds.width) / 2) - (Int(mainBtnWidth) / 2), y: -18, width: 48, height: 48)
    }
    
    func addTabItems() {
        let homeVC = UINavigationController(rootViewController: RunningHomeVC())
        let mateVC = UINavigationController(rootViewController: RunningMateVC())
        let chatVC = UINavigationController(rootViewController: MyChatListVC())
        let profileVC = UINavigationController(rootViewController: MyProfileVC())
        
        homeVC.title = "러닝"
        mateVC.title = "메이트"
        chatVC.title = "채팅 목록"
        profileVC.title = "마이페이지"
        
        self.setViewControllers([homeVC, mateVC, chatVC, profileVC], animated: false)
        self.modalPresentationStyle = .fullScreen
        self.tabBar.backgroundColor = .white
        
        guard let items = self.tabBar.items else { return }
        items[0].image = UIImage(resource: .runTabbarIcon)
        
        items[1].image = UIImage(resource: .mateTabbarIcon)
        items[1].titlePositionAdjustment = UIOffset(horizontal: -CGFloat(mainBtnWidth / 2), vertical: 0)
        
        items[2].image = UIImage(resource: .chattingTabbarIcon)
        items[2].titlePositionAdjustment = UIOffset(horizontal: CGFloat(mainBtnWidth / 2), vertical: 0)
        items[3].image = UIImage(resource: .profileTabbarIcon)
    }
    
    @objc func mainButtonTapped() {
        print(#function)
    }
}
