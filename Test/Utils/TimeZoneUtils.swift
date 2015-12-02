//
//  TimeZoneUtils.swift
//  Test
//
//  Created by Daniel Rodriguez on 12/1/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

/**
 *  Util functions for working with NSTimeZone objects
 */
struct TimeZoneUtils {
    
    /**
     Get a NSTimeZone instance associated to a specific label.
     
     - parameter label: A label displayed to the user, identifying a Timezone.
     
     - returns: A NSTimeZone instance, or nil if the label doesn't correspond to any NSTimeZone
     */
    static func NSTimeZoneFromLabel(label:String) -> NSTimeZone? {
        
        for value in TimeZoneConstants.AmericaTimeZones.allValues {
            if value.getTimeZoneLabel() == label {
                return value.getTimeZone()
            }
        }
        for value in TimeZoneConstants.UnitedKingdomTimeZones.allValues {
            if value.getTimeZoneLabel() == label {
                return value.getTimeZone()
            }
        }
        for value in TimeZoneConstants.OtherTimeZones.allValues {
            if value.getTimeZoneLabel() == label {
                return value.getTimeZone()
            }
        }
        
        return nil
    }
    
    /**
     Get a Label associated to a NSTimeZone.
     
     - parameter timezone: A NSTimeZone instance.
     
     - returns: A String with the label, or nil if the NSTimeZone instance doesn't have a corresponding label.
     */
    static func TimeZoneLabelFromNSTimeZone(timezone:NSTimeZone) -> String? {
        
        for value in TimeZoneConstants.AmericaTimeZones.allValues {
            if value.getTimeZone()?.name == timezone.name {
                return value.getTimeZoneLabel()
            }
        }
        for value in TimeZoneConstants.UnitedKingdomTimeZones.allValues {
            if value.getTimeZone()?.name == timezone.name {
                return value.getTimeZoneLabel()
            }
        }
        for value in TimeZoneConstants.OtherTimeZones.allValues {
            if value.getTimeZone()?.name == timezone.name {
                return value.getTimeZoneLabel()
            }
        }
        return nil
    }
    
    
}

extension NSTimeZone {
    
    /**
     A util function to retrieve a NSTimeZone label.
     
     - returns: The label (String), or the empty String ("") if there's no associated label.
     - seealso: + TimeZoneLabelFromNSTimeZone: (TimeZoneUtils)
     */
    func getLabel() -> String {        
        return TimeZoneUtils.TimeZoneLabelFromNSTimeZone(self) ?? ""
    }
}
