//
//  AnplitudeEvents.swift
//  RACK
//
//  Created by Алексей Петров on 15/09/2019.
//  Copyright © 2019 fawn.team. All rights reserved.
//

import Foundation
import Amplitude_iOS
import DatingKit


enum AmplitudeEvensts: Int, CaseIterable {
    
    //MARK: - screens
    case loginScr
    case emailScr
    case codeScr
    case firstOnboardingScr
    case secondOnboardingScr
    case thriedOnboardingScr
    case avatarScr
    case searchScr
    case chatListScr
    case chatScr
    case paygateScr
    case trialScr
    
    //MARK: - buttons
    case loginFBTap
    case loginEmailTap
    case loginTermsTap
    case emailTap
    case codeTap
    case firstOnboardingTap
    case secondOnboardingTap
    case triedOnboardingTap
    case avatarContinueTap
    case avatarRandTap
    case chatListNewSearchTap
    case chatListCurrentTap
    
    //MARK: - errors
    case emailError
    case codeError
    
    //MARK: - succses
    case codeSucces
    
    var getEvent: String! {
        switch  self {
            
        //MARK: - screens events names
        case .firstOnboardingScr, .secondOnboardingScr, .thriedOnboardingScr:
            return "Onboarding Scr"
        case .codeScr:
            return "Code Scr"
        case .loginScr:
            return "Login Scr"
        case .emailScr:
            return "Email Scr"
        case .avatarScr:
            return "Avatar Scr"
        case .searchScr:
            return "Search Scr"
        case .chatListScr:
            return "Chat List Scr"
        case .chatListNewSearchTap, .chatListCurrentTap:
            return "Chat List Tap"
        case .chatScr:
            return "Chat Scr"
        case .paygateScr:
            return "Paygate Scr"
        case .trialScr:
            return "Trial Scr"
            
        //MARK: - buttons events names
        case .firstOnboardingTap, .secondOnboardingTap, .triedOnboardingTap:
            return "Onboarding Tap"
        case .loginEmailTap, .loginFBTap, .loginTermsTap:
            return "Login Tap"
        case .emailTap:
            return "Email Tap"
        case .codeTap:
            return "Code Tap"
        case .avatarContinueTap, .avatarRandTap:
            return "Avatar Tap"
            
        //MARK: - errors events names
        case .codeError:
            return "Code Error"
        case .emailError:
            return "Email Error"
            
        //MARK: - succes events names
        case .codeSucces:
            return "Code Success"
        }
    }
    
    var getParams: [AnyHashable : Any]! {
        switch self {
            
        //MARK: - screens params
        case .avatarScr, .searchScr, .chatListScr, .paygateScr, .trialScr:
            return nil
        case .firstOnboardingScr:
            return ["step" : "1"]
        case .secondOnboardingScr:
            return ["step" : "2"]
        case .thriedOnboardingScr:
            return ["step" : "3"]
            
        //MARK: - buttons params
        case .firstOnboardingScr:
            return ["step" : "1",
                    "what" : "continue"]
        case .secondOnboardingTap:
            return ["step" : "2",
                    "what" : "continue"]
        case .triedOnboardingTap:
            return ["step" : "3",
                    "what" : "continue"]
        case .codeTap:
            return ["what" : "send_new_code"]
        case .emailTap:
            return ["what" : "continue"]
        case .loginTermsTap:
            return ["what": "terms_and_conditions"]
        case .loginEmailTap:
            return ["what": "email_login"]
        case .loginFBTap:
            return ["what": "facebook_login"]
        case .avatarContinueTap:
            return ["what" : "continue"]
        case .avatarRandTap:
            return ["what" : "randomize"]
        case .chatListCurrentTap:
            return  ["what" : "chat"]
        case .chatListNewSearchTap:
            return  ["what" : "new_search"]
            
        //MARK: - default params
        default:
            return nil
        }
    }
    
}

extension Amplitude {
    
    func log(event: AmplitudeEvensts) {
        self.logEvent(event.getEvent, withEventProperties: event.getParams, outOfSession: false)
    }
    
    func log(event: AmplitudeEvensts, with properties: [AnyHashable : Any]) {
        self.logEvent(event.getEvent, withEventProperties: properties, outOfSession: false)
    }
    
}
