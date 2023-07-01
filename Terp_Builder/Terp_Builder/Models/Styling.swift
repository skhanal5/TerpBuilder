//
//  Styling.swift
//  Terp_Builder
//
//  Created by Subodh Khanal on 3/24/23.
//

import Foundation
import SwiftUI

/*
 
 General UI/UX Rules for consistency across views (feel free to change)
 Comes from UMD Branding Guidelines
 
 Primary color: #e21833 (Referred to as Color.accentColor)
 Secondary color: #FFD200 (Refered to in code as CUSTOM.SECONDARY)
 Neutral color: #E6E6E6 (Referred to in code as Custom.NEUTRAL)
 Highlight color: #7f7f7f (Referred to in code as CUSTOM.HIGHLIGHT)
 
 The above colors have been added into /Assets
 
 Font-family: Helvetica Neue for all titles, system for everything else
 Font-size: Titles are size 20, everything else is default system standards
*/


/*
    Struct contains all custom colors
 */
struct CustomColor {
    static let NEUTRAL = Color("UMD-Neutral")
    static let SECONDARY = Color("UMD-Secondary")
    static let HIGHLIGHT = Color("UMD-Highlight")
}
