//
//  Extensions.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 15/06/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit
import Stevia

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
    
//    func popToScene(_ scene: UIViewController.Scene, animated: Bool) {
//        guard let viewController = viewControllers.filter({ ($0 as? ViewController)?.scene == scene }).last else {
//            return
//        }
//        popToViewController(viewController, animated: animated)
//    }
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
    
    @discardableResult
    func stack(_ views: [UIView], axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views.map({ UIView().sv($0) })).then { $0.axis = axis }
        sv(stack)
        return stack
    }
    
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
    static func header(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    static func title(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
}

extension UILabel {
    func multiLine() {
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
    }
    
    func style(_ text: String = "", font: UIFont = .title(14), color: UIColor = .black, bgColor: UIColor = .clear, alignment: NSTextAlignment = .natural, isMultiLine: Bool = false) {
        self.text = text
        self.font = font
        textColor = color
        textAlignment = alignment
        backgroundColor = bgColor
        if isMultiLine {
            multiLine()
        }
    }
}

extension UITextField {
    func style(_ font: UIFont = .title(14), color: UIColor = .black, bgColor: UIColor = .clear, alignment: NSTextAlignment = .natural) {
        self.font = font
        textColor = color
        textAlignment = alignment
        backgroundColor = bgColor
    }
    
    func leftPadding(_ value: CGFloat) {
        leftView = .init(frame: .init(x: 0, y: 0, width: value, height: frame.height))
        leftViewMode = .always
    }
    
    func rightPadding(_ value: CGFloat) {
        rightView = .init(frame: .init(x: 0, y: 0, width: value, height: frame.height))
        rightViewMode = .always
    }
}

extension UIButton {
    func style(_ text: String = "", imageName: String? = nil, font: UIFont = .title(14), color: UIColor = .black, bgColor: UIColor = .clear) {
        setTitle(text, for: .normal)
        if let imageName = imageName {
            setImage(UIImage(named: imageName), for: .normal)
        }
        titleLabel?.font = font
        setTitleColor(color, for: .normal)
        backgroundColor = bgColor
    }
    
    func image(_ name: String, tint: UIColor? = nil) {
        if let tint = tint {
            setImage(UIImage(named: name)?.withRenderingMode(.alwaysTemplate), for: .normal)
            tintColor = tint
        } else {
            image(name)
        }
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

extension UIBezierPath {
    convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGSize = .zero, topRightRadius: CGSize = .zero, bottomLeftRadius: CGSize = .zero, bottomRightRadius: CGSize = .zero){
        
        self.init()
        
        let path = CGMutablePath()
        
        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        if topLeftRadius != .zero{
            path.move(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }
        
        if topRightRadius != .zero{
            path.addLine(to: CGPoint(x: topRight.x-topRightRadius.width, y: topRight.y))
            path.addCurve(to:  CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height), control1: CGPoint(x: topRight.x, y: topRight.y), control2:CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height))
        } else {
            path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
        }
        
        if bottomRightRadius != .zero{
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y-bottomRightRadius.height))
            path.addCurve(to: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y), control1: CGPoint(x: bottomRight.x, y: bottomRight.y), control2: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y))
        } else {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
        }
        
        if bottomLeftRadius != .zero{
            path.addLine(to: CGPoint(x: bottomLeft.x+bottomLeftRadius.width, y: bottomLeft.y))
            path.addCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height), control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y), control2: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height))
        } else {
            path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
        }
        
        if topLeftRadius != .zero{
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y+topLeftRadius.height))
            path.addCurve(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y) , control1: CGPoint(x: topLeft.x, y: topLeft.y) , control2: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }
        
        path.closeSubpath()
        cgPath = path
    }
}

extension UIView {
    func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    func roundCorners(_ corners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: CGFloat = 0) {
        layer.maskedCorners = corners
        layer.cornerRadius = radius
    }
}

extension UIImageView {
    func style(_ name: String = "", mode: UIView.ContentMode = .scaleAspectFill, tint: UIColor? = nil, radius: CGFloat = 0, bgColor: UIColor = .clear) {
        contentMode = mode
        if let tint = tint {
            image = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
            tintColor = tint
        } else {
            image(name)
        }
        layer.cornerRadius = radius
        layer.masksToBounds = true
        backgroundColor = bgColor
    }
}

extension NSAttributedString {
    static func text(_ text: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: [.font : font, .foregroundColor: color])
    }
}
