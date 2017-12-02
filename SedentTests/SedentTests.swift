//
//  SedentTests.swift
//  SedentTests
//
//  Created by vt on 10/3/17.
//  Copyright © 2017 Vasiliy Tokarev. All rights reserved.
//

import XCTest
@testable import Sedent

class SedentTests: XCTestCase {
    var coach: Coach!
    var exerciseIndex: Int!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        coach = Coach()
    }
    
    override func tearDown() {
        exerciseIndex = nil
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCoachIsInitiated() {
        exerciseIndex = coach.currentExerciseIndex
        XCTAssertEqual(exerciseIndex, 0, "Exercise index is wrong")
    }
    
    func testExample() {
//         This is an example of a functional test case.
//         Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
