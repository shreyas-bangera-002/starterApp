//
//  UIView+Constraint.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 15/06/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit

enum Constraint: String {
    case width, height, left, right, top, bottom, centerX, centerY, alignX, alignY
    //, alignTop, alignBottom, alignLeft, alignRight
}

enum ConstraintRelation {
    case equal, greaterThanOrEqual, lesserThanOrEqual
}

struct FlexibleMargin {
    let points: CGFloat
    let relation: ConstraintRelation
}

prefix operator >=
@discardableResult
prefix func >= (points: CGFloat) -> FlexibleMargin {
    return FlexibleMargin(points: points, relation: .greaterThanOrEqual)
}

prefix operator <=
@discardableResult
prefix func <= (points: CGFloat) -> FlexibleMargin {
    return FlexibleMargin(points: points, relation: .lesserThanOrEqual)
}

extension UIView {
    @discardableResult
    func sv(_ subViews: UIView...) -> UIView {
        for sv in subViews {
            addSubview(sv)
            sv.translatesAutoresizingMaskIntoConstraints = false
        }
        return self
    }
    
    @discardableResult
    func stack(_ views: [UIView], axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views.map({ UIView().sv($0) })).then { $0.axis = axis }
        sv(stack)
        return stack
    }
    
    func deactivateConstraints(_ constraint: Constraint) {
        NSLayoutConstraint.deactivate(constraints.filter({ $0.identifier == constraint.rawValue }))
    }
    
    func constraint(_ anchor: NSLayoutDimension,
                    to refAnchor: NSLayoutDimension? = nil,
                    multiplier: CGFloat? = nil,
                    constant: CGFloat = 0,
                    relation: ConstraintRelation = .equal,
                    identifier: Constraint) {
        deactivateConstraints(identifier)
        var constraint: NSLayoutConstraint?
        guard let refAnchor = refAnchor ?? ((identifier == .width) ? superview?.widthAnchor : superview?.heightAnchor) else { return }
        if let multiplier = multiplier {
            switch relation {
            case .equal:
                constraint = anchor.constraint(equalTo: refAnchor, multiplier: multiplier, constant: constant)
            case .greaterThanOrEqual:
                constraint = anchor.constraint(greaterThanOrEqualTo: refAnchor, multiplier: multiplier, constant: constant)
            case .lesserThanOrEqual:
                constraint = anchor.constraint(lessThanOrEqualTo: refAnchor, multiplier: multiplier, constant: constant)
            }
        } else {
            switch relation {
            case .equal:
                constraint = anchor.constraint(equalToConstant: constant)
            case .greaterThanOrEqual:
                constraint = anchor.constraint(greaterThanOrEqualToConstant: constant)
            case .lesserThanOrEqual:
                constraint = anchor.constraint(lessThanOrEqualToConstant: constant)
            }
        }
        constraint?.identifier = identifier.rawValue
        constraint?.isActive = true
    }
    
    func xAnchor(_ constraint: Constraint) -> NSLayoutXAxisAnchor? {
        switch constraint {
        case .left:
            return superview?.leftAnchor
        case .right:
            return superview?.rightAnchor
        case .alignX, .centerX:
            return superview?.centerXAnchor
        default:
            return nil
        }
    }
    
    func yAnchor(_ constraint: Constraint) -> NSLayoutYAxisAnchor? {
        switch constraint {
        case .top:
            return superview?.topAnchor
        case .bottom:
            return superview?.bottomAnchor
        case .alignY, .centerY:
            return superview?.centerYAnchor
        default:
            return nil
        }
    }
    
    func constraint(_ anchor: NSLayoutXAxisAnchor,
                    to refAnchor: NSLayoutXAxisAnchor? = nil,
                    constant: CGFloat = 0,
                    relation: ConstraintRelation = .equal,
                    identifier: Constraint) {
        deactivateConstraints(identifier)
        var constraint: NSLayoutConstraint?
        guard let refAnchor = refAnchor ?? xAnchor(identifier) else { return }
        switch relation {
        case .equal:
            constraint = anchor.constraint(equalTo: refAnchor, constant: constant)
        case .greaterThanOrEqual:
            constraint = anchor.constraint(greaterThanOrEqualTo: refAnchor, constant: constant)
        case .lesserThanOrEqual:
            constraint = anchor.constraint(lessThanOrEqualTo: refAnchor, constant: constant)
        }
        constraint?.identifier = identifier.rawValue
        constraint?.isActive = true
    }
    
    func constraint(_ anchor: NSLayoutYAxisAnchor,
                    to refAnchor: NSLayoutYAxisAnchor? = nil,
                    constant: CGFloat = 0,
                    relation: ConstraintRelation = .equal,
                    identifier: Constraint) {
        deactivateConstraints(identifier)
        var constraint: NSLayoutConstraint?
        guard let refAnchor = refAnchor ?? yAnchor(identifier) else { return }
        switch relation {
        case .equal:
            constraint = anchor.constraint(equalTo: refAnchor, constant: constant)
        case .greaterThanOrEqual:
            constraint = anchor.constraint(greaterThanOrEqualTo: refAnchor, constant: constant)
        case .lesserThanOrEqual:
            constraint = anchor.constraint(lessThanOrEqualTo: refAnchor, constant: constant)
        }
        constraint?.identifier = identifier.rawValue
        constraint?.isActive = true
    }
}

extension UIView {
    @discardableResult
    func width(_ points: CGFloat) -> UIView {
        constraint(widthAnchor, constant: points, identifier: .width)
        return self
    }
    
    @discardableResult
    func width(multiplier: CGFloat, of anchor: NSLayoutDimension? = nil) -> UIView {
        constraint(widthAnchor, to: anchor, multiplier: multiplier, identifier: .width)
        return self
    }
    
    @discardableResult
    func height(_ points: CGFloat) -> UIView {
        constraint(heightAnchor, constant: points, identifier: .height)
        return self
    }
    
    @discardableResult
    func height(multiplier: CGFloat, of anchor: NSLayoutDimension? = nil) -> UIView {
        constraint(heightAnchor, to: anchor, multiplier: multiplier, identifier: .height)
        return self
    }
    
    @discardableResult
    func left(_ points: CGFloat, from anchor: NSLayoutXAxisAnchor? = nil) -> UIView {
        constraint(leftAnchor, constant: points, identifier: .left)
        return self
    }
    
    @discardableResult
    func left(_ flexibleMargin: FlexibleMargin, from anchor: NSLayoutXAxisAnchor? = nil) -> UIView {
        constraint(leftAnchor, to: anchor, constant: flexibleMargin.points, relation: flexibleMargin.relation, identifier: .left)
        return self
    }
    
    @discardableResult
    func right(_ points: CGFloat, from anchor: NSLayoutXAxisAnchor? = nil) -> UIView {
        constraint(rightAnchor, constant: -points, identifier: .right)
        return self
    }
    
    @discardableResult
    func right(_ flexibleMargin: FlexibleMargin, from anchor: NSLayoutXAxisAnchor? = nil) -> UIView {
        constraint(rightAnchor, to: anchor, constant: -flexibleMargin.points, relation: flexibleMargin.relation, identifier: .right)
        return self
    }
    
    @discardableResult
    func top(_ points: CGFloat, from anchor: NSLayoutYAxisAnchor? = nil) -> UIView {
        constraint(topAnchor, constant: points, identifier: .top)
        return self
    }
    
    @discardableResult
    func top(_ flexibleMargin: FlexibleMargin, from anchor: NSLayoutYAxisAnchor? = nil) -> UIView {
        constraint(topAnchor, to: anchor, constant: flexibleMargin.points, relation: flexibleMargin.relation, identifier: .top)
        return self
    }
    
    @discardableResult
    func bottom(_ points: CGFloat, from anchor: NSLayoutYAxisAnchor? = nil) -> UIView {
        constraint(bottomAnchor, constant: -points, identifier: .bottom)
        return self
    }
    
    @discardableResult
    func bottom(_ flexibleMargin: FlexibleMargin, from anchor: NSLayoutYAxisAnchor? = nil) -> UIView {
        constraint(bottomAnchor, to: anchor, constant: -flexibleMargin.points, relation: flexibleMargin.relation, identifier: .bottom)
        return self
    }
    
    @discardableResult
    func centerVertically(_ offset: CGFloat = 0) -> UIView {
        constraint(centerYAnchor, constant: offset, identifier: .centerY)
        return self
    }
    
    @discardableResult
    func centerHorizontally(_ offset: CGFloat = 0) -> UIView {
        constraint(centerXAnchor, constant: offset, identifier: .centerX)
        return self
    }
    
    @discardableResult
    func alignVertically(_ views: UIView...) -> UIView {
        views.forEach { constraint(centerYAnchor, to: $0.centerYAnchor, identifier: .alignY) }
        return self
    }
    
    @discardableResult
    func alignHorizontally(_ views: UIView...) -> UIView {
        views.forEach { constraint(centerXAnchor, to: $0.centerXAnchor, identifier: .alignX) }
        return self
    }
}
