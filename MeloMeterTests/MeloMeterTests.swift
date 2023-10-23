//
//  MeloMeterTests.swift
//  MeloMeterTests
//
//  Created by 오현택 on 2023/10/23.
//

import XCTest
import RxSwift

@testable import MeloMeter

final class MeloMeterTests: XCTestCase {
    private var logInRepository: LogInRepositoryP!
    private var firebaseService: FirebaseService!
    private var disposeBag: DisposeBag!
    override func setUpWithError() throws {
        self.firebaseService = DefaultFirebaseService()
        self.logInRepository = LogInRepository(firebaseService: self.firebaseService)
    }

    override func tearDownWithError() throws {
        logInRepository = nil
        firebaseService = nil
        disposeBag = nil
    }

    func testCoupleCombined_WhenInput_ShouldReturnTrue() throws {
        
        
        XCTAssertTrue(
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
