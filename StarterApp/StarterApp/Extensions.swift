//
//  Extensions.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 15/06/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit

extension NSObject {
    func inject(_ callback: @escaping () -> Void) {
        _ = NotificationCenter.default
            .addObserver(forName: NSNotification.Name(rawValue: "INJECTION_BUNDLE_NOTIFICATION"),
                         object: nil,
                         queue: nil) { _ in
                            callback()
        }
    }
}

extension Optional {
    var isNil: Bool {
        return self == nil
    }
}

extension Array {
    static var empty: [Element] {
        return [Element]()
    }
    
    func add(_ items: [Element]) -> [Element] {
        var list = self
        list.append(contentsOf: items)
        return list
    }
    func last(_ slice: Int) -> [Element] {
        guard slice <= count else { return .empty }
        return Array(self[count-slice..<count])
    }
}

extension UINavigationController {
    func popToRootViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popToScene(_ scene: UIViewController.Scene, animated: Bool) {
        guard let viewController = viewControllers.filter({ ($0 as? ViewController)?.scene == scene }).last else {
            return
        }
        popToViewController(viewController, animated: animated)
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseId)
    }
    
    func register<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseId)
    }
    
    func dequeueCell<T: UITableViewCell>(_: T.Type, at index: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.reuseId, for: index) as! T
    }
    
    func dequeueCell<T: UITableViewCell & Configurable, U>(_: T.Type, at index: IndexPath, with item: U) -> T where T.T == U {
        return dequeueCell(T.self, at: index).then { $0.configure(item) }
    }
    
    func dequeueHeader<T: UITableViewHeaderFooterView>(_: T.Type) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: T.reuseId) as! T
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseId)
    }
    
    func dequeueCell<T: UICollectionViewCell>(_: T.Type, at index: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.reuseId, for: index) as! T
    }
    
    func dequeueCell<T: UICollectionViewCell & Configurable, U>(_: T.Type, at index: IndexPath, with item: U) -> T where T.T == U {
        return dequeueCell(T.self, at: index).then { $0.configure(item) }
    }
}

extension UIColor {
    static let separatorColor = UIColor.lightGray
}

extension UIView {
    
    static func hSeparator() -> UIView {
        return UIView().then { $0.backgroundColor = .separatorColor; $0.height(1) }
    }
    
    static func vSeparator() -> UIView {
        return UIView().then { $0.backgroundColor = .separatorColor; $0.width(1) }
    }
    
    @discardableResult
    func hStack(_ views: UIView...) -> UIStackView {
        return stack(views, axis: .horizontal)
    }
    
    @discardableResult
    func vStack(_ views: UIView...) -> UIStackView {
        return stack(views, axis: .vertical)
    }
    
    func hide(_ shouldHide: Bool) {
        superview?.isHidden = shouldHide
    }
    
    static func spacer(_ points: CGFloat) -> UIView {
        return UIView().then { $0.width(points) }
    }
    
    func border(_ color: UIColor, width: CGFloat = 1) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    func roundedEdges(_ points: CGFloat) {
        height(points)
        layer.cornerRadius = points/2
        layer.masksToBounds = true
    }
    
    func circle(_ diameter: CGFloat) {
        size(diameter)
        layer.cornerRadius = diameter/2
        layer.masksToBounds = true
    }
    
    @discardableResult
    func size(_ points: CGFloat) -> UIView {
        return width(points).height(points)
    }
    
    @discardableResult
    func centerInContainer() -> UIView {
        return centerVertically().centerHorizontally()
    }
    
    @discardableResult
    func fillContainer() -> UIView {
        return top(0).bottom(0).left(0).right(0)
    }
    
    @discardableResult
    func followEdges(_ view: UIView) -> UIView {
        return left(0, from: view.leftAnchor)
            .right(0, from: view.rightAnchor)
            .top(0, from: view.topAnchor)
            .bottom(0, from: view.bottomAnchor)
    }
    
    func addGesture(_ gestureRecognizer: UIGestureRecognizer) {
        isUserInteractionEnabled = true
        addGestureRecognizer(gestureRecognizer)
    }
}

extension ActionClosurable where Self: UIControl {
    public func on(_ controlEvents: UIControl.Event, closure: @escaping (Self) -> Void) {
        convert(closure: closure, toConfiguration: {
            self.addTarget($0, action: $1, for: controlEvents)
        })
    }
}

extension ActionClosurable where Self: UIButton {
    public func onTap(_ closure: @escaping (Self) -> Void) {
        on(.touchUpInside, closure: closure)
    }
}

public extension ActionClosurable where Self: UIRefreshControl {
    func onValueChanged(closure: @escaping (Self) -> Void) {
        on(.valueChanged, closure: closure)
    }
    
    init(closure: @escaping (Self) -> Void) {
        self.init()
        onValueChanged(closure: closure)
    }
}


extension ActionClosurable where Self: UIGestureRecognizer {
    public func onGesture(_ closure: @escaping (Self) -> Void) {
        convert(closure: closure, toConfiguration: {
            self.addTarget($0, action: $1)
        })
    }
    public init(closure: @escaping (Self) -> Void) {
        self.init()
        onGesture(closure)
    }
}

extension ActionClosurable where Self: UIBarButtonItem {
    public init(title: String, style: UIBarButtonItem.Style, closure: @escaping (Self) -> Void) {
        self.init()
        self.title = title
        self.style = style
        self.onTap(closure)
    }
    public init(image: UIImage?, style: UIBarButtonItem.Style, closure: @escaping (Self) -> Void) {
        self.init()
        self.image = image
        self.style = style
        self.onTap(closure)
    }
    public init(barButtonSystemItem: UIBarButtonItem.SystemItem, closure: @escaping (Self) -> Void) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: nil)
        self.onTap(closure)
    }
    public func onTap(_ closure: @escaping (Self) -> Void) {
        convert(closure: closure, toConfiguration: {
            self.target = $0
            self.action = $1
        })
    }
}

extension ActionClosurable where Self: CADisplayLink {
    static func create(closure: @escaping (Self) -> Void) -> Self {
        return convert(closure: closure, toConfiguration: {
            self.init(target: $0, selector: $1)
        })
    }
}

extension UIFont {
    static let header = UIFont.systemFont(ofSize: 18, weight: .bold)
    static let title = UIFont.systemFont(ofSize: 16, weight: .regular)
}

extension UILabel {
    func multiLine() {
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
    }
    
    func style(_ font: UIFont = .title, color: UIColor = .black, bgColor: UIColor = .clear, alignment: NSTextAlignment = .natural) {
        self.font = font
        textColor = color
        textAlignment = alignment
        backgroundColor = bgColor
    }
}

extension UITextField {
    func style(_ font: UIFont = .title, color: UIColor = .black, bgColor: UIColor = .clear, alignment: NSTextAlignment = .natural) {
        self.font = font
        textColor = color
        textAlignment = alignment
        backgroundColor = bgColor
    }
}

extension UIButton {
    func style(_ text: String = "", imageName: String? = nil, font: UIFont = .title, color: UIColor = .black, bgColor: UIColor = .clear) {
        setTitle(text, for: .normal)
        if let imageName = imageName {
            setImage(UIImage(named: imageName), for: .normal)
        }
        titleLabel?.font = font
        setTitleColor(color, for: .normal)
        backgroundColor = bgColor
    }
}

extension UIStackView {
    func add(_ views: UIView...) {
        views.map({ UIView().sv($0) }).forEach { addArrangedSubview($0) }
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}
