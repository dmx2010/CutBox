//
//  SearchView.swift
//  CutBox
//
//  Created by Jason Milkins on 24/3/18.
//  Copyright © 2018 ocodo. All rights reserved.
//

import Foundation
import Cocoa
import RxSwift
import RxCocoa

@available(OSX 10.12.2, *)
extension NSTouchBarItem.Identifier {
    static let favoritesToggle = NSTouchBarItem.Identifier("info.ocodo.cutbox.touchBar.searchPreview.favoritesToggle")
    static let searchToggle = NSTouchBarItem.Identifier("info.ocodo.cutbox.TouchBar.SearchPreview.searchToggle")
}

@available(OSX 10.12.2, *)
extension SearchAndPreviewView: NSTouchBarDelegate {

    override func makeTouchBar() -> NSTouchBar? {
        let mainBar = NSTouchBar()
        mainBar.delegate = self
        mainBar.defaultItemIdentifiers = [.favoritesToggle, .searchToggle]
        mainBar.principalItemIdentifier = .searchToggle
        return mainBar
    }

    @objc func toggleSearch() {
        self.events.onNext(.toggleSearchMode)
    }

    @objc func toggleFavorites() {
        self.events.onNext(.toggleSearchScope)
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .searchToggle:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(title: "Search Mode", target: self, action: #selector(toggleSearch))
            button.alternateImage = #imageLiteral(resourceName: "magnitude.png")
            button.image = #imageLiteral(resourceName: "star.png")
            item.view = button
            return item

        case .favoritesToggle:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = NSButton(title: "Favorites Toggle", target: self, action: #selector(toggleFavorites))
            return item

        default:
            return nil
        }
    }
}

class SearchAndPreviewView: SearchPreviewView {

    @IBOutlet weak var searchModeToggle: NSButton!

    var events = PublishSubject<SearchViewEvents>()

    override func awakeFromNib() {
        setupSearchText()
        setupSearchModeToggle()
        setupSearchScopeToggle()
        super.awakeFromNib()
    }

    func setSearchModeButton(mode: HistorySearchMode) {
        let color = [NSAttributedStringKey.foregroundColor: prefs.currentTheme.clip.clipItemsTextColor]
        let titleString = NSAttributedString(string: mode.name(), attributes: color)

        self.searchModeToggle.attributedTitle = titleString
        self.searchModeToggle.toolTip = mode.toolTip()
    }

    private func setupSearchModeToggle() {
        let mode = HistoryService.shared.searchMode
        setSearchModeButton(mode: mode)

        self.searchModeToggle
            .rx
            .tap
            .map { .toggleSearchMode }
            .bind(to: self.events)
            .disposed(by: disposeBag)
    }

    func setSearchScopeButton(favoritesOnly: Bool) {
        if favoritesOnly {
            colorizeMagnifier(
                image:  #imageLiteral(resourceName: "star.png"),
                tooltip: "search_scope_tooltip_favorites".l7n
            )
        } else {
            colorizeMagnifier()
        }
    }

    private func setupSearchScopeToggle() {
        let favoritesOnly = HistoryService.shared.favoritesOnly
        setSearchScopeButton(favoritesOnly: favoritesOnly)

        self.searchScopeImageButton
            .rx
            .tap
            .map { .toggleSearchScope }
            .bind(to: self.events)
            .disposed(by: disposeBag)
    }

    private func setupSearchText() {
        self.searchText.delegate = self
        self.searchText.isFieldEditor = true
    }

    @objc func removeSelectedItems() {
        self.events.onNext(.removeSelected)
    }

    @objc func toggleFavoriteItems() {
        self.events.onNext(.toggleFavorite)
    }

    func setupClipItemsContextMenu() {
        let remove = NSMenuItem(title: "context_menu_remove_selected".l7n,
                                action: #selector(removeSelectedItems),
                                keyEquivalent: "")

        let favorite = NSMenuItem(title: "context_menu_favorite".l7n,
                                  action: #selector(toggleFavoriteItems),
                                  keyEquivalent: "")

        let contextMenu = NSMenu()
        contextMenu.addItem(remove)
        contextMenu.addItem(favorite)

        self.itemsList.menu = contextMenu
    }
    
    override func applyTheme() {
        super.applyTheme()

        setSearchModeButton(mode: HistoryService.shared.searchMode)
        setSearchScopeButton(favoritesOnly: HistoryService.shared.favoritesOnly)
    }
}
