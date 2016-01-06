//
//  RockauthiOSTests.swift
//  RockauthiOSTests
//
//  Created by Brandon Roth on 12/1/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import XCTest

class RockauthiOSTests: XCTestCase {
    
    let bundle = NSBundle(forClass: RockauthiOSTests.self)
    let apiClient = RockauthClient(baseURL: NSURL(string: "https://m6eitwi40c.execute-api.us-east-1.amazonaws.com/dev/")!, clientID: "TMkOgswr533ZUvbd0ZlA1O90", clientSecret: "OpANNPD9cuSWOVg6yuBDdJqs3Rzx1EIlrXzygI9ZtLShObO1")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func jsonFromFile(file: String) -> [String: AnyObject] {
        let url = bundle.URLForResource(file, withExtension: "json")!
        let jsonFile = NSData(contentsOfURL: url)!
        let json = try! NSJSONSerialization.JSONObjectWithData(jsonFile, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
        return json
    }
    
    func testFacebookSignInSessionSerialization() {
        let json = self.jsonFromFile("facebookLoginJson")
        
        let session = RockAuthSession(json: json)
        XCTAssertNotNil(session)
        
        let user = session!.user
        XCTAssert(user.id == 140)
        XCTAssertEqual(user.id, 140)
        XCTAssertNil(user.email)
        XCTAssertNil(user.firstName)
        XCTAssertNil(user.lastName)
        
        let auth = session!.authentication
        XCTAssert(auth.id == 654)
        XCTAssert(auth.token == "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiIiLCJpYXQiOjE0NDg5ODg3NTIsImV4cCI6MTQ4MDUyNDc1MiwiYXVkIjoiVE1rT2dzd3I1MzNaVXZiZDBabEExTzkwIiwic3ViIjoxNDAsImp0aSI6Ii9VU29xeVhVNnpBQ1BTVFVZdXBZV2lleGN0VzVqL1ZtIn0.OeysjDQhZUitaH3UfJMHS_dcT2vL_kD-u1xJVnYxYi8")
        
        XCTAssert(auth.expiration == NSDate(timeIntervalSince1970: 1480524752))
        XCTAssert(auth.tokenID == "/USoqyXU6zACPSTUYupYWiexctW5j/Vm")
        
        let auths = session!.authentications
        XCTAssert(auths.count == 1)
        XCTAssert(auths.first! == auth)
        
        let providerAuths = session!.providerAuthentications
        XCTAssert(providerAuths.count == 2)
        
        let pAuth = providerAuths.first!
        XCTAssert(pAuth.name == "facebook")
        XCTAssert(pAuth.id == 54)
        XCTAssert(pAuth.userID == "10102922162809270")
    }
    
    func testEmailSignupSessionSerialization() {
        let json = self.jsonFromFile("emailSignupJson")
        
        let session = RockAuthSession(json: json)
        XCTAssertNotNil(session)
        
        let user = session!.user
        XCTAssertEqual(user.id, 150)
        XCTAssert(user.email == "testUser@rocketmade.com")
        XCTAssert(user.firstName == "Test")
        XCTAssert(user.lastName == "User")
        
        let auth = session!.authentication
        XCTAssert(auth.id == 656)
        XCTAssert(auth.token == "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiIiLCJpYXQiOjE0NDg5OTA2MDMsImV4cCI6MTQ4MDUyNjYwMywiYXVkIjoiVE1rT2dzd3I1MzNaVXZiZDBabEExTzkwIiwic3ViIjoxNTAsImp0aSI6IjFwclE0TFB4cEI1Nml2VmNmcUdxajVpSmQxQ0R4M2I4In0.YPq9u3EHauk-Gylp0wIOsTU8vdXg8KAwWY0Tc4GK7m8")
        
        XCTAssert(auth.expiration == NSDate(timeIntervalSince1970: 1480526603))
        XCTAssert(auth.tokenID == "1prQ4LPxpB56ivVcfqGqj5iJd1CDx3b8")
        
        let auths = session!.authentications
        XCTAssert(auths.count == 1)
        XCTAssert(auths.first! == auth)
        
        XCTAssert(session!.providerAuthentications.count == 0)
    }
    
    func testEmailLogin() {
        
        let expectation = expectationWithDescription("email login")
        apiClient.login("testUser@rocketmade.com", password: "password", success: { (session) -> Void in
           expectation.fulfill()
            XCTAssertNotNil(session)
            }) { (error) -> Void in
                XCTFail()
           expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(100) { (error) -> Void in
            
        }
    }
    
//    func testFailedEmailLogin() {
//        
//        let expectation = expectationWithDescription("email login")
//        apiClient.login("testUser@rocketmade.com", password: "password1", success: { (session) -> Void in
//            expectation.fulfill()
//                XCTFail()
//            }) { (error) -> Void in
//                
//                if let e = error as? RockauthError {
//                    XCTAssertEqual(e.message, "Password is invalid\n")
//                }
//                expectation.fulfill()
//        }
//        
//        waitForExpectationsWithTimeout(100) { (error) -> Void in
//            
//        }
//    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
        
    }
    
}
