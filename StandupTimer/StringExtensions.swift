//
//  StringExtensions.swift
//  StandupTimer
//
//  Created by Andrej Jasso on 21/07/2019.
//  Copyright © 2019 Andrej Jasso. All rights reserved.
//

import Foundation

extension String {
    
    static func timeDuration(seconds: Double, unitStyle: DateComponentsFormatter.UnitsStyle = .brief) -> String? {
        var allowedUnits: NSCalendar.Unit = [.minute, .second]
        
        if seconds / 3600 >= 1 {
            allowedUnits = [.hour, .minute, .second ]
        }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitStyle
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = allowedUnits
        
        return formatter.string(from: seconds)
    }
    
}
