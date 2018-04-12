//
//  PreferencesWindow+MultipleItemWrapping.swift
//  CutBox
//
//  Created by Jason on 11/4/18.
//  Copyright © 2018 ocodo. All rights reserved.
//

import RxSwift
import RxCocoa

extension PreferencesWindow {
    func setupWrappingStringTextFields() {
        let (start, end) = prefs.wrappingStrings
        self.wrapStartTextField.stringValue = start ?? ""
        self.wrapEndTextField.stringValue = end ?? ""

        let shouldWrapSaved = prefs.useWrappingStrings
        self.shouldWrapMultipleSelection.state = shouldWrapSaved ? .on : .off
        updateWrappingMultipleSelection(shouldWrapSaved)

        Observable
            .combineLatest(self.wrapStartTextField.rx.text,
                           self.wrapEndTextField.rx.text)
            { ($0, $1) }
            .skip(1)
            .subscribe(onNext: { self.prefs.wrappingStrings = $0 })
            .disposed(by: disposeBag)

        self.shouldWrapMultipleSelection.rx.state
            .skip(1)
            .map { $0 == .on }
            .subscribe(onNext: { self.updateWrappingMultipleSelection($0) })
            .disposed(by: disposeBag)
    }

    func updateWrappingMultipleSelection(_ bool: Bool) {
        prefs.useWrappingStrings = bool
        [self.wrapStartTextField,
         self.wrapEndTextField]
            .forEach { $0?.isEnabled = bool }
    }
}
