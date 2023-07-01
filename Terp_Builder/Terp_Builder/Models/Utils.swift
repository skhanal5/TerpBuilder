//
//  Utils.swift
//  Terp_Builder
//
//  Created by Gavin Mealy on 3/31/23.
//

import Foundation

// Converts from "hh:mmam/pm" to (hh, mm)
func convertTime(t: String) -> (Int, Int) {
    let nums = t.split(separator: ":")
    var hr = Int(nums[0]) ?? 0
    let min = Int(nums[1].prefix(2)) ?? 0
    let meridiem = String(nums[1].suffix(2))
    
    if meridiem == "pm" && hr != 12 {
        hr += 12
    }
    
    return (hr, min)
}
