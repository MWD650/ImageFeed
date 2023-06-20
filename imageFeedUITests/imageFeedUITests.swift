//
//  imageFeedUITests.swift
//  imageFeedUITests
//
//  Created by Alex on /186/23.
//

import XCTest

final class imageFeedUITests: XCTestCase {
    
   private let logIn:String = "ваш логин"
   private let passWord:String = "ваш пароль"
    
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {   // тестируем сценарий авторизации
        
        
        app.buttons["Authenticate"].tap()  // Нажать кнопку авторизации
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(logIn)
        webView.swipeUp()
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))

        passwordTextField.tap()
       // sleep(3)
        passwordTextField.typeText (passWord)

        webView.swipeUp()
        app.toolbars["Toolbar"].buttons["Done"].tap()
       
        webView.swipeUp() // скрываем клавиатуру после ввода текста (необязательно)
        
        print(app.debugDescription) // печатаем в консоли дерево UI-элементов (для отладки и выявления проблем)
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(5)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["likeButton"].tap()
        sleep(3)
        cellToLike.buttons["likeButton"].tap()
        
        sleep(5)
        
        cellToLike.tap()
        
        sleep(5)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["backButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
        sleep(5)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(5)
        XCTAssertTrue(app.staticTexts["Alexander"].exists)
        sleep(2)
        XCTAssertTrue(app.staticTexts["@mwd650"].exists)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Logout"].scrollViews.otherElements.buttons["Да"].tap()
        
        let webView = app.webViews["UnsplashWebView"] //
        webView.waitForExistence(timeout: 5)
    }
} 
