//
//  MarvelController.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 06/07/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit
import Stevia
import ViewAnimator
import Arrow
import then

extension UIColor {
    static let plantBG = #colorLiteral(red: 0.9255588055, green: 0.9253922701, blue: 0.9339988828, alpha: 1)
    static let plantColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
    static let favBG = #colorLiteral(red: 0.6310636401, green: 0.7705437541, blue: 0.6404860616, alpha: 1)
    static let light = #colorLiteral(red: 0.1521505713, green: 0.2935601175, blue: 0.2960677743, alpha: 1)
    static let temp = #colorLiteral(red: 0.2951364517, green: 0.443002224, blue: 0.4495908618, alpha: 1)
    static let water = UIColor.temp
}

enum MarvelApi: ApiType {
    case characters
    
    var endpoint: String {
        switch self {
        case .characters:
            return "/v1/public/characters"
        }
    }
}

class Character: ModelType {
    
    required init() {}
    
    var id = -1
    var name = ""
    var imagePath = ""
    var imageExtension = ""
    var comicsPage = ""
    var thumbnail: String {
        return imagePath + "." + imageExtension
    }
    var isFav: Bool = false
    var favImage: String {
        return isFav ? "favorite" : "unfavorite"
    }
    var favTint: UIColor {
        return isFav ? .red : .black
    }
    
    func deserialize(_ json: JSON) {
        id <-- json["id"]
        name <-- json["name"]
        imagePath <-- json["thumbnail.path"]
        imageExtension <-- json["thumbnail.extension"]
        comicsPage <-- json["comics.collectionURI"]
    }
    
    static func fetch() -> Promise<[Character]> {
        return Api.service(MarvelApi.characters)
    }
}

class CharacterViewModel {
    static var onUpdate: (([Character]) -> Void)?
    private var data: [Character] {
        didSet {
            CharacterViewModel.onUpdate?(data)
        }
    }
    private var original = [Character]()
    
    init() {
        data = original
        Character.fetch().then { [weak self] in
            self?.original = $0
            self?.data = $0
        }
    }

    func query(_ text: String?) {
        guard let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            data = original
            return
        }
        data = original.filter { $0.name.lowercased().contains(text.lowercased()) }
    }
}

class MarvelCharacterController: ViewController {
    
    let viewModel = CharacterViewModel()
    
    lazy var tableView = TableView<String,Character>().then { table in
        table.separatorStyle = .none
        table.register(CharacterCell.self)
        table.configureCell = { $0.dequeueCell(CharacterCell.self, at: $1, with: $2) }
        table.didSelect = { [weak self] in self?.navigate(to: .characterDetail($2), transition: .push) }
        CharacterViewModel.onUpdate = {
            table.update(items: [$0])
            table.animate(animations: [AnimationType.from(direction: .bottom, offset: 80)], duration: 1)
        }
    }
    
    override func render() {
        registerKeyboardNotifications()
        let bgImage = UIImageView().then {
            $0.style("marvel", mode: .scaleAspectFit, radius: 40, bgColor: #colorLiteral(red: 0.5070544481, green: 0.04280054569, blue: 0.0001473282318, alpha: 1))
            $0.isUserInteractionEnabled = true
        }
        let textfield = TextField(left: 16, cursorColor: .white).then {
            $0.clearButtonMode = .whileEditing
            $0.style(color: .white, bgColor: UIColor.black.withAlphaComponent(0.3))
            $0.attributedPlaceholder = .text("Search", font: .title(18), color: #colorLiteral(red: 0.6574715376, green: 0.7316547036, blue: 0.734709084, alpha: 1))
            $0.on(.editingChanged) { [weak self] in
                self?.viewModel.query($0.text)
            }
        }
        view.sv(bgImage.sv(textfield), tableView)
        bgImage.top(44).left(10).right(10).heightEqualsWidth()
        textfield.top(70%).left(20).right(20).roundedEdges(50)
        tableView.left(25).right(10).bottom(0)
        tableView.Top == textfield.Bottom + 20
    }
    
    override func configureUI() {
//        tableView.reloadData()
//        tableView.scrollToRow(at: .init(row: 0, section: 0), at: .none, animated: false)
    }
    
    override func keyboardChanged(_ height: CGFloat) {
        tableView.contentInset.bottom = height
    }
}

class CharacterCell: TableViewCell, Configurable {
    
    let bgView = UIView().then {
        $0.roundCorners([.layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 20)
        $0.backgroundColor = .plantBG
    }
    
    let characterImageView = UIImageView().then { $0.style() }
    
    let titleLabel = Label().then { $0.style(font: .header(24), color: .plantColor) }
    
    lazy var favButton = UIButton().then {
        $0.onTap { [weak self] in
            guard let character = self?.character else { return }
            character.isFav.toggle()
            $0.image(character.favImage, tint: character.favTint)
            $0.animate(animations: [AnimationType.zoom(scale: character.isFav ? 1.5 : 1)], duration: 1)
        }
    }
    
    var character: Character!
    
    override func render() {
        sv(bgView.sv(characterImageView, titleLabel, favButton))
        bgView.top(0).left(0).right(0).bottom(20).height(200)
        characterImageView.fill()
        titleLabel.left(20).bottom(20)
        favButton.size(30).top(20).left(20)
    }
    
    func configure(_ item: Character) {
        character = item
        titleLabel.text = item.name
        characterImageView.load(item.thumbnail)
        characterImageView.hero.id = "\(item.id)"
        favButton.image(item.favImage, tint: item.favTint)
    }
}

class CharacterDetailController: ViewController {
    
    let character: Character
    
    lazy var back = UIButton().then {
        $0.style(imageName: "back")
        $0.onTap { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    lazy var characterImageView = UIImageView().then {
        $0.style(character.thumbnail,mode: .scaleAspectFill)
        $0.hero.id = "\(character.id)"
        $0.layer.cornerRadius = 8
    }
    
    lazy var collectionView = CollectionView<Any,String>(.horizontal, animator: .snap, widthFactor: 0.5).then {
        $0.contentInset.left = 20
        $0.register(CharacterCollectionCell.self)
        $0.configureCell = { $0.dequeueCell(CharacterCollectionCell.self, at: $1, with: $2) }
        $0.update(.empty, items: [["Comics", "Series", "Stories"]])
        $0.animate(animations: [AnimationType.from(direction: .right, offset: 80)], delay: 0.5, duration: 1)
    }
    
    init(_ character: Character) {
        self.character = character
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func render() {
        view.vStack(characterImageView, collectionView).top(20).fill()
        view.sv(back)
        back.size(30).top(60).left(40)
        characterImageView.fill(20).heightEqualsWidth()
        collectionView.bottom(50).fill()
    }
}
//class PlantDetailController: ViewController {
//
//    let pageControl = UIPageControl().then {
//        $0.numberOfPages = 3
//        $0.pageIndicatorTintColor = .gray
//        $0.currentPageIndicatorTintColor = .white
//    }
//
//    lazy var back = UIButton().then {
//        $0.style(imageName: "back")
//        $0.onTap { [weak self] _ in
//            self?.navigationController?.popViewController(animated: true)
//        }
//    }
//
//    let share = UIButton().then {
//        $0.style(imageName: "share")
//    }
//
//    let detailView = UIView().then {
//        $0.backgroundColor = .white
//        $0.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 40)
//    }
//
//    lazy var titleLabel = UILabel().then {
//        $0.style(plant.name, font: .header(30), color: .plantColor)
//    }
//
//    lazy var favButton = UIButton().then {
//        $0.style(bgColor: .favBG)
//        $0.layer.cornerRadius = 13
//        let fav = UIImageView().then { $0.style(plant.favImage, tint: plant.favTint) }
//        $0.sv(fav)
//        fav.size(30).centerInContainer()
//        $0.onTap { [weak self] _ in
//            guard let plant = self?.plant else { return }
//            plant.isFav.toggle()
//            fav.style(plant.favImage, tint: plant.favTint)
//            fav.animate(animations: [AnimationType.zoom(scale: plant.isFav ? 1.5 : 1)], duration: 1)
//        }
//    }
//
//    lazy var descLabel = UILabel().then { $0.style(plant.desc, font: .title(18), color: .plantColor, isMultiLine: true) }
//
//    lazy var imageCarousel = CollectionView<Any,String>(.horizontal, animator: .cube).then {
//        $0.isPagingEnabled = true
//        $0.register(PlantImageCell.self)
//        $0.configureCell = { $0.dequeueCell(PlantImageCell.self, at: $1, with: $2) }
//        $0.didScrollToIndex = { [weak self] in self?.pageControl.currentPage = $0.row }
//        $0.update(List.dataSource(sections: .empty, items: [Array(repeating: plant.image, count: 3)]))
//        $0.animate(animations: [AnimationType.zoom(scale: 0.3)], delay: 0.5)
//    }
//
//    lazy var collectionView = CollectionView<Any,String>(.horizontal, animator: .none, width: 200).then {
//        $0.contentInset.left = 20
//        $0.register(PlantCollectionCell.self)
//        $0.configureCell = { $0.dequeueCell(PlantCollectionCell.self, at: $1, with: $2) }
//        $0.update(List.dataSource(sections: .empty, items: [""]))
//        $0.animate(animations: [AnimationType.from(direction: .right, offset: 80)], delay: 0.3)
//    }
//
//    var plant: Plant!
//
//    convenience init(_ plant: Plant) {
//        self.init()
//        self.plant = plant
//    }
//
//    override func render() {
//        let tips = UILabel().then { $0.style("Tips", font: .medium(18), color: .plantColor) }
//        view.sv(imageCarousel, detailView, favButton, pageControl, back, share)
//        detailView.vStack(titleLabel, descLabel, tips, collectionView).fillContainer()
//        imageCarousel.top(44).left(10).right(10).heightEqualsWidth()
//        detailView.left(10).right(10).bottom(0)
//        tips.height(40).left(20).fill()
//        collectionView.height(240).bottom(20).fill()
//        imageCarousel.Bottom == detailView.Top + 40
//        back.size(24).top(60).left(30)
//        share.size(30).top(60).right(30)
//        titleLabel.top(20).left(20).right(20).bottom(0)
//        descLabel.left(20).right(20).top(10).bottom(0)
//        favButton.size(52).right(10%)
//        favButton.Bottom == detailView.Top + 22
//        pageControl.centerHorizontally()
//        pageControl.Bottom == detailView.Top - 10
//    }
//}

class CharacterCollectionCell: CollectionViewCell, Configurable {

    let card = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
    }

    let titleLabel = UILabel().then { $0.style(font: .title(16)) }

    override func render() {
        sv(card.sv(titleLabel))
        card.fillContainer(10)
        titleLabel.left(20).bottom(20)
    }

    func configure(_ item: String) {
        titleLabel.text = item
    }
}

//class PlantImageCell: CollectionViewCell, Configurable {
//    
//    lazy var plantImageView = UIImageView().then {
//        let overlay = UIView().then { $0.backgroundColor = UIColor.black.withAlphaComponent(0.1) }
//        $0.sv(overlay)
//        overlay.fillContainer()
//        $0.style(mode: .scaleAspectFit)
//        $0.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 30)
//    }
//    
//    override func render() {
//        sv(plantImageView)
//        plantImageView.fill()
//    }
//    
//    func configure(_ item: String) {
//        plantImageView.image(item)
//    }
//}
