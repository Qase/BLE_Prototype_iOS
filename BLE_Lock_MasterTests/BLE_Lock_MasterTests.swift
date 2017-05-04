//
//  BLE_Lock_MasterTests.swift
//  BLE_Lock_MasterTests
//
//  Created by Martin Troup on 02/05/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import XCTest
import RxTest
@testable import BLE_Lock_Master

class BLE_Lock_MasterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        BluetoothMasterManager.shared.start()
        wait(for: [expectation(description: "expectation")], timeout: 1000)
    }
    
    
}
