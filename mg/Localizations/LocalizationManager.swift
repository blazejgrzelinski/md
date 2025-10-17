//
//  LocalizationManager.swift
//  mg
//
//  Created by Blazej Grzelinski on 09/10/2025.
//

import Foundation

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = Locale.current.languageCode ?? "en"
    
    private init() {}
    
    func localizedString(for key: String, arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: arguments)
    }
    
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: "AppLanguage")
        
        // Update bundle for immediate effect
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            Bundle.setLanguage(languageCode)
        }
    }
    
    func getCurrentLanguage() -> String {
        return UserDefaults.standard.string(forKey: "AppLanguage") ?? Locale.current.languageCode ?? "en"
    }
}

// MARK: - Bundle Extension for Language Switching
extension Bundle {
    private static var bundle: Bundle!
    
    public static func localizedBundle() -> Bundle! {
        if bundle == nil {
            bundle = Bundle.main
        }
        return bundle
    }
    
    public static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, Bundle.self)
        }
        
        objc_setAssociatedObject(Bundle.main, &bundle, Bundle.main, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            bundle = Bundle.main
            return
        }
        
        bundle = Bundle(path: path)
    }
}

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
