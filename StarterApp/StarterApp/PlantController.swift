//
//  PlantController.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 06/07/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit
import Stevia
import ViewAnimator

extension UIColor {
    static let plantBG = #colorLiteral(red: 0.9255588055, green: 0.9253922701, blue: 0.9339988828, alpha: 1)
    static let plantColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
    static let favBG = #colorLiteral(red: 0.6310636401, green: 0.7705437541, blue: 0.6404860616, alpha: 1)
    static let light = #colorLiteral(red: 0.1521505713, green: 0.2935601175, blue: 0.2960677743, alpha: 1)
    static let temp = #colorLiteral(red: 0.2951364517, green: 0.443002224, blue: 0.4495908618, alpha: 1)
    static let water = UIColor.temp
}

enum Criteria: String {
    case light, temp = "temperature", water
    
    var value: String {
        return rawValue.capitalized
    }
    
    var image: String {
        return rawValue
    }
}

enum PlantType: String, CaseIterable {
    case monstera, suculents, ferns
    
    var name: String {
        return rawValue.capitalized
    }
    
    var image: String {
        return rawValue
    }
    
    var desc: String {
        switch self {
        case .monstera:
            return "Monstera deliciosa, the ceriman, is a species of flowering plant native to tropical forests of southern Mexico, south to Panama."
        case .suculents:
            return "In botany, succulent plants, also known as succulents, are plants that have some parts that are more than normally thickened and fleshy, usually to retain water in arid climates or soil conditions."
        case .ferns:
            return "A fern is a member of a group of vascular plants (plants with xylem and phloem) that reproduce via spores and have neither seeds nor flowers."
        }
    }
    
    var temperature: String {
        switch self {
        case .monstera:
            return "18-25°C"
        case .suculents:
            return "35-40°F"
        case .ferns:
            return "15–24°C"
        }
    }
    
    var light: String {
        switch self {
        case .monstera, .suculents:
            return "Diffused"
        case .ferns:
            return "Bright"
        }
    }
    
    var water: String {
        switch self {
        case .monstera:
            return "Minimal"
        case .suculents:
            return "Soaked"
        case .ferns:
            return "Moist"
        }
    }
}

class Plant {
    let name: String
    let image: String
    let desc: String
    let temperature: String
    let light: String
    let water: String
    var isFav: Bool = false
    var favImage: String {
        return isFav ? "favorite" : "unfavorite"
    }
    var favTint: UIColor {
        return isFav ? .red : .black
    }
    var nourishment: [PlantNourishment] {
        return [
            (.temp, .temp, temperature),
            (.light, .light, light),
            (.water, .water, water)
        ]
    }
    
    init(name: String, image: String, desc: String, temperature: String, light: String, water: String) {
        self.name = name
        self.image = image
        self.desc = desc
        self.temperature = temperature
        self.light = light
        self.water = water
    }
}

typealias PlantNourishment = (color: UIColor, criteria: Criteria, value: String)

class PlantViewModel {
    static var update: (() -> Void)?
    private(set) var data: [Plant] {
        didSet {
            PlantViewModel.update?()
        }
    }
    private let original = PlantType.allCases.map { Plant(name: $0.name, image: $0.image, desc: $0.desc, temperature: $0.temperature, light: $0.light, water: $0.water) }
    
    init() {
        data = original
    }
    
    func query(_ text: String?) {
        guard let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            data = original
            return
        }
        data = original.filter { $0.name.lowercased().contains(text.lowercased()) }
    }
}

class PlantController: ViewController {
    
    let viewModel = PlantViewModel()
    
    lazy var tableView = TableView<String,Plant>().then {
        $0.separatorStyle = .none
        $0.register(PlantCell.self)
        $0.configureCell = { $0.dequeueCell(PlantCell.self, at: $1, with: $2) }
        $0.didSelect = { [weak self] in self?.navigate(to: .plantDetail($2), transition: .push) }
        $0.update(List.dataSource(sections: .empty, items: [viewModel.data]))
    }
    
    override func render() {
        registerKeyboardNotifications()
        let bgImage = UIImageView().then {
            $0.style("leaves", radius: 40)
            $0.isUserInteractionEnabled = true
        }
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        let textfield = TextField(left: 16, color: .black).then {
            $0.attributedPlaceholder = .text("Search", font: .title(18), color: #colorLiteral(red: 0.6574715376, green: 0.7316547036, blue: 0.734709084, alpha: 1))
            $0.on(.editingChanged) { [weak self] in
                self?.viewModel.query($0.text)
            }
        }
        let label = Label().then { $0.style("Flower\nSchool", font: .header(40), color: .white, isMultiLine: true) }
        view.sv(bgImage.sv(label, blur, textfield), tableView)
        bgImage.top(44).left(10).right(10).heightEqualsWidth()
        label.Leading == textfield.Leading
        label.Bottom == textfield.Top - 20
        blur.top(60%).left(20).right(20).roundedEdges(50)
        textfield.followEdges(blur)
        tableView.left(25).right(10).bottom(0)
        tableView.Top == textfield.Bottom + 20
        PlantViewModel.update = { [weak self] in
            guard let `self` = self else { return }
            self.tableView.update(List.dataSource(sections: .empty, items: [self.viewModel.data]))
        }
    }
    
    override func configureUI() {
        tableView.reloadData()
        tableView.scrollToRow(at: .init(row: 0, section: 0), at: .none, animated: false)
    }
    
    override func keyboardChanged(_ height: CGFloat) {
        tableView.contentInset.bottom = height
    }
}

class PlantCell: TableViewCell, Configurable {
    
    let bgView = UIView().then {
        $0.roundCorners([.layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 20)
        $0.backgroundColor = .plantBG
    }
    
    let plantImageView = UIImageView().then { $0.style() }
    
    let titleLabel = Label().then { $0.style(font: .header(24), color: .plantColor) }
    
    lazy var favButton = UIButton().then {
        $0.onTap { [weak self] in
            guard let plant = self?.plant else { return }
            plant.isFav.toggle()
            $0.image(plant.favImage, tint: plant.favTint)
            $0.animate(animations: [AnimationType.zoom(scale: plant.isFav ? 1.5 : 1)], duration: 1)
        }
    }
    
    var plant: Plant!
    
    override func render() {
        sv(bgView.sv(favButton, plantImageView, titleLabel))
        bgView.top(0).left(0).right(0).bottom(20).height(200)
        plantImageView.width(50%).top(0).right(0).bottom(0)
        titleLabel.left(20).bottom(20)
        favButton.size(30).top(20).left(20)
    }
    
    func configure(_ item: Plant) {
        plant = item
        titleLabel.text = item.name
        plantImageView.image(item.image)
        favButton.image(item.favImage, tint: item.favTint)
    }
}

class PlantDetailController: ViewController {
    
    let pageControl = UIPageControl().then {
        $0.numberOfPages = 3
        $0.pageIndicatorTintColor = .gray
        $0.currentPageIndicatorTintColor = .white
    }
    
    lazy var back = UIButton().then {
        $0.style(imageName: "back")
        $0.onTap { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    let share = UIButton().then {
        $0.style(imageName: "share")
    }
    
    let detailView = UIView().then {
        $0.backgroundColor = .white
        $0.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 40)
    }
    
    lazy var titleLabel = UILabel().then {
        $0.style(plant.name, font: .header(30), color: .plantColor)
    }
    
    lazy var favButton = UIButton().then {
        $0.style(bgColor: .favBG)
        $0.layer.cornerRadius = 13
        let fav = UIImageView().then { $0.style(plant.favImage, tint: plant.favTint) }
        $0.sv(fav)
        fav.size(30).centerInContainer()
        $0.onTap { [weak self] _ in
            guard let plant = self?.plant else { return }
            plant.isFav.toggle()
            fav.style(plant.favImage, tint: plant.favTint)
            fav.animate(animations: [AnimationType.zoom(scale: plant.isFav ? 1.5 : 1)], duration: 1)
        }
    }
    
    lazy var descLabel = UILabel().then { $0.style(plant.desc, font: .title(18), color: .plantColor, isMultiLine: true) }
    
    lazy var imageCarousel = CollectionView<Any,String>(.horizontal, animator: .cube).then {
        $0.isPagingEnabled = true
        $0.register(PlantImageCell.self)
        $0.configureCell = { $0.dequeueCell(PlantImageCell.self, at: $1, with: $2) }
        $0.didScrollToIndex = { [weak self] in self?.pageControl.currentPage = $0.row }
        $0.update(List.dataSource(sections: .empty, items: [Array(repeating: plant.image, count: 3)]))
        $0.animate(animations: [AnimationType.zoom(scale: 0.3)], delay: 0.5)
    }
    
    lazy var collectionView = CollectionView<Any,PlantNourishment>(.horizontal, animator: .none, width: 200).then {
        $0.contentInset.left = 20
        $0.register(PlantCollectionCell.self)
        $0.configureCell = { $0.dequeueCell(PlantCollectionCell.self, at: $1, with: $2) }
        $0.update(List.dataSource(sections: .empty, items: [plant.nourishment]))
        $0.animate(animations: [AnimationType.from(direction: .right, offset: 80)], delay: 0.3)
    }
    
    var plant: Plant!
    
    convenience init(_ plant: Plant) {
        self.init()
        self.plant = plant
    }
    
    override func render() {
        let tips = UILabel().then { $0.style("Tips", font: .medium(18), color: .plantColor) }
        view.sv(imageCarousel, detailView, favButton, pageControl, back, share)
        detailView.vStack(titleLabel, descLabel, tips, collectionView).fillContainer()
        imageCarousel.top(44).left(10).right(10).heightEqualsWidth()
        detailView.left(10).right(10).bottom(0)
        tips.height(40).left(20).fill()
        collectionView.height(240).bottom(20).fill()
        imageCarousel.Bottom == detailView.Top + 40
        back.size(24).top(60).left(30)
        share.size(30).top(60).right(30)
        titleLabel.top(20).left(20).right(20).bottom(0)
        descLabel.left(20).right(20).top(10).bottom(0)
        favButton.size(52).right(10%)
        favButton.Bottom == detailView.Top + 22
        pageControl.centerHorizontally()
        pageControl.Bottom == detailView.Top - 10
    }
}

class PlantCollectionCell: CollectionViewCell, Configurable {
    
    let card = UIView().then { $0.layer.cornerRadius = 8 }
    
    let image = UIImageView().then {
        $0.style(mode: .scaleAspectFit)
        $0.animate(animations: [AnimationType.rotate(angle: 360)], delay: 0.3, duration: 1)
    }
    
    let criteriaLabel = UILabel().then { $0.style(font: .title(16), color: UIColor.white.withAlphaComponent(0.5)) }
    
    let valueLabel = UILabel().then { $0.style(font: .header(24), color: .white) }
    
    override func render() {
        sv(card.sv(image, criteriaLabel, valueLabel))
        card.fillContainer(10)
        image.size(44).top(20).left(10)
        criteriaLabel.left(20).right(10)
        valueLabel.left(20).right(10).bottom(10)
        criteriaLabel.Bottom == valueLabel.Top - 4
    }
    
    func configure(_ item: PlantNourishment) {
        card.backgroundColor = item.color
        image.image(item.criteria.image)
        criteriaLabel.text = item.criteria.value
        valueLabel.text = item.value
    }
}

class PlantImageCell: CollectionViewCell, Configurable {
    
    lazy var plantImageView = UIImageView().then {
        let overlay = UIView().then { $0.backgroundColor = UIColor.black.withAlphaComponent(0.1) }
        $0.sv(overlay)
        overlay.fillContainer()
        $0.style(mode: .scaleAspectFit)
        $0.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 30)
    }
    
    override func render() {
        sv(plantImageView)
        plantImageView.fill()
    }
    
    func configure(_ item: String) {
        plantImageView.image(item)
    }
}
