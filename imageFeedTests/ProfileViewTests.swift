//
//  ProfileViewTests.swift
//  ProfileViewTests
//
//  Created by Alex on /176/23.
//

@testable import imageFeed
import XCTest

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = true
    var logOutButtonWasTapped: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}

