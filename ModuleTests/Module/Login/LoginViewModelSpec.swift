//
//  LoginViewModelSpec.swift
//  ModuleTests
//
//  Created by Yee Chuan Lee on 01/08/2019.
//  Copyright © 2019 Yee Chuan Lee. All rights reserved.
//

import Foundation
import Nimble
import Quick
import RxBlocking
import RxSwift
import RxCocoa
@testable import MVVM2019June20

fileprivate class MockLoginView: NSObject, LoginViewType {
    var intent: LoginIntent!
    
    override init() {
        
    }
    
    var isRouteToActivation = false
    func routeToActivation() {
        isRouteToActivation = true
    }
    
    var isRouteToDashboard = false
    func routeToDashboard() {
        isRouteToDashboard = true
    }
    
    func dismissView() {
        
    }
    
    func showProgressHUD() {
        
    }
    
    func showProgressHUD(label: String) {
        
    }
    
    func hideProgressHUD() {
        
    }
    
    func exitToLogin() {
        
    }
    
    func presentDialog(title: String?, message: String?, actions: [String]) -> Driver<Int> {
        return .just(0)
    }
    
    func presentDialog(title: String?, message: String?, actions: [DialogAction]) -> Driver<DialogAction> {
        return .just(actions.first!)
    }
    
    func presentDialog(title: String?, message: String?, action: DialogAction) -> Driver<DialogAction> {
        return .just(action)
    }
    
    var disposeOnWillRemoveFromParent: Bool = false
    
    func showLoginSessionExpire(error: NSError) -> Driver<Void> {
        return .just(())
    }
    
    var isPresentedError: Bool = false
    func present(error: Error, completion: @escaping () -> ()) {
        isPresentedError = true
    }
    
    func exitWithResult(animated: Bool, result: DismissResult, completion: (() -> ())?) {
        
    }
    
    func closeWithResult(animated: Bool, result: DismissResult, completion: (() -> ())?) {
        
    }
    
    func popWithResult(animated: Bool, result: DismissResult, completion: (() -> ())?) {
        
    }
    
    
}

fileprivate func mockDI() {
    DI.container.register(LoginSessionRepositoryType.self, factory: { r -> LoginSessionRepositoryType in
        return LoginSessionRepository()
    }).inObjectScope(.container)
    
    DI.container.register(BuildConfigType.self, factory: { r -> BuildConfigType in
        return DevelopmentBuildConfig()
    }).inObjectScope(.container)
    
    DI.container.register(LoginFormValidationServiceType.self, factory: { r -> LoginFormValidationServiceType in
        return LoginFormValidationService()
    }).inObjectScope(.container)
    
    DI.container.register(AuthServiceType.self, factory: { r -> AuthServiceType in
        return AuthService()
    }).inObjectScope(.container)
    
    DI.container.register(BO.Provider.self, factory: { r -> BO.Provider in
        let ret = BO.MockProvider.UnitTest
        return ret
    }).inObjectScope(.container)
    
    DI.container.register(UserDefaults.self, factory: { r -> UserDefaults in
        return UserDefaults.standard
    }).inObjectScope(.container)
}

class LoginViewModelSpec: QuickSpec {
    override func spec() {
        var Defaults: UserDefaults!
        let intent = LoginIntent(isModal: false,
                                 initialView: .login,
                                 enableDismiss: false)
        var object: LoginViewModel!
        var view: MockLoginView!
        describe("after screen is shown") {
            beforeEach {
                mockDI()
                Defaults = DI.container.resolve(UserDefaults.self)!
                object = LoginViewModel(intent: intent)
                view = MockLoginView()
                object.view = view
                object.startLoad = .just(())
            }
            context("when inputting form") {
                it("username entered will converted to uppercase") {
                    object.transform()
                    object.username.accept("abc")
                    expect( object.username.value ).toEventually(equal( "ABC" ))
                }
            }
            context("when submitting form") {
                it("prompt error dialog for empty username") {
                    let startSubmit = PublishRelay<Void>()
                    object.startSubmit = startSubmit.asDriverOnErrorJustComplete()
                    object.transform()
                    object.username.accept("")
                    object.password.accept("password")
                    startSubmit.accept(())
                    expect( view.isPresentedError ).toEventually(equal( true ))
                }
                it("prompt error dialog for empty password") {
                    let startSubmit = PublishRelay<Void>()
                    object.startSubmit = startSubmit.asDriverOnErrorJustComplete()
                    object.transform()
                    object.username.accept("username")
                    object.password.accept("")
                    startSubmit.accept(())
                    expect( view.isPresentedError ).toEventually(equal( true ))
                }
                it("prompt error dialog for no internet connection") {
                    DI.container.register(BO.Provider.self, factory: { r -> BO.Provider in
                        return BO.MockProvider.UnitTestWithNoInternet
                    }).inObjectScope(.container)
                    
                     let startSubmit = PublishRelay<Void>()
                     object.startSubmit = startSubmit.asDriverOnErrorJustComplete()
                     object.transform()
                     object.username.accept("A")
                     object.password.accept("a")
                     startSubmit.accept(())
                     expect( view.isPresentedError ).toEventually(equal( true ))
                 }
                it("route to activation if not activated") {
                    Defaults[.isActivated] = false
                    let startSubmit = PublishRelay<Void>()
                    object.startSubmit = startSubmit.asDriverOnErrorJustComplete()
                    object.transform()
                    object.username.accept("A")
                    object.password.accept("a")
                    startSubmit.accept(())
                    expect( view.isRouteToActivation ).toEventually(equal( true ))
                }
                it("route to dashboard if activated") {
                    Defaults[.isActivated] = true
                    let startSubmit = PublishRelay<Void>()
                    object.startSubmit = startSubmit.asDriverOnErrorJustComplete()
                    object.transform()
                    object.username.accept("A")
                    object.password.accept("a")
                    startSubmit.accept(())
                    expect( view.isRouteToDashboard ).toEventually(equal( true ))
                }
            }
        }
    }
}