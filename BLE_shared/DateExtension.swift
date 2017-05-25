//
//  DateExtension.swift
//  BLE_shared
//
//  Created by Martin Troup on 24/05/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import Foundation

extension Date {
    /// Method to convert Date instance to String with custom date time format.
    ///
    /// - Parameter format: format of Date
    /// - Returns: String instance
    public func asString(withFormat format: String = "yyyy-MM-dd hh:mm:ss:sss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        //formatter.locale = Locale(identifier: "en_US")
        
        return formatter.string(from: self)
    }
}
