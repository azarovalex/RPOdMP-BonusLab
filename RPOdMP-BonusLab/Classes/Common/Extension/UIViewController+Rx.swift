//
//  UIViewController+Rx.swift
//  RPOdMP-BonusLab
//
//  Created by Alex Azarov on 2/3/19.
//  Copyright © 2019 Alex Azarov. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

public extension Reactive where Base: UIViewController {
    
    public var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var error: Binder<Error> {
        return Binder(self.base) { viewController, error in
            viewController.show(error: error)
        }
    }
    
    var isLoading: Binder<Bool> {
        return Binder(self.base) { viewController, isLoading in
            isLoading ? HUD.show(.progress) : HUD.hide()
        }
    }
}

extension UIViewController {
    
    func show(error: Error) {
        let message = (error as? AppError)?.message ?? error.localizedDescription
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
