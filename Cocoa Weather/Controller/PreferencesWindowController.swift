//
//  PreferencesWindow.swift
//  Cocoa Weather
//
//  Created by zhs852 on 2018/9/23.
//  Copyright © 2018 zhs852. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var cityTextField: NSTextField!
    @IBOutlet weak var menuTempCheckBox: NSButton!
    @IBOutlet weak var pushNotificationCheckBox: NSButton!
    @IBOutlet weak var frequencyPopUpButton: NSPopUpButton!
    @IBOutlet weak var tempUnitSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var customApiKeyTextField: NSTextField!
    
    var delegate: PreferencesWindowDelegate?
    
    var settingsReset = false
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name("PreferencesWindow")
    }
    
    @IBAction func helpClicked(_ sender: Any) {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Help", comment: "Help")
        alert.informativeText = NSLocalizedString("APIKeyHelp", comment: "APIKeyHelp")
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.beginSheetModal(for: self.window!, completionHandler: {response -> Void in})
    }
    
    @IBAction func frequencyChanged(_ sender: Any) {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Caution", comment: "Caution")
        alert.informativeText = NSLocalizedString("FrenquencyChangedCaution", comment: "FrenquencyChangedCaution")
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.beginSheetModal(for: self.window!, completionHandler: {response -> Void in})
    }
    
    @IBAction func responseCodeClicked(_ sender: Any) {
        let responseCode = UserDefaults.standard.integer(forKey: "responseCode")
        let responseCodes = [0, 200, 400, 401, 404]
        let responseInfo = NSLocalizedString(String(responseCode), comment: "responseInfo")
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "\(NSLocalizedString("ResponseCode", comment: "ResponseCode"))\(String(responseCode))"
        if responseCodes.contains(responseCode) == true {
            alert.informativeText = "\(responseInfo)"
        } else {
            alert.informativeText = ""
        }
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.beginSheetModal(for: self.window!, completionHandler: {response -> Void in})
    }
    
    @IBAction func resetClicked(_ sender: Any) {
        let userDefaults = UserDefaults.standard.dictionaryRepresentation()
        for key in userDefaults {
            UserDefaults.standard.removeObject(forKey: key.key)
        }
        self.settingsReset = true
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Reset", comment: "Reset")
        alert.informativeText = NSLocalizedString("ResetInfo", comment: "ResetInfo")
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.beginSheetModal(for: self.window!, completionHandler: {response -> Void in})
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titlebarAppearsTransparent = true
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        let defaults = UserDefaults.standard
        let city = defaults.string(forKey: "city") ?? DEFAULT_CITY
        let frequency = defaults.integer(forKey: "frequency")
        let tempUnit = defaults.integer(forKey: "unit")
        let menuTemp = NSControl.StateValue(defaults.integer(forKey: "menuTemp"))
        let pushNotification = NSControl.StateValue(defaults.integer(forKey: "pushNotification"))
        let apiKey = defaults.string(forKey: "apiKey") ?? ""
        cityTextField.stringValue = city
        frequencyPopUpButton.selectItem(at: frequency)
        tempUnitSegmentedControl.selectedSegment = tempUnit
        menuTempCheckBox.state = menuTemp
        pushNotificationCheckBox.state = pushNotification
        customApiKeyTextField.stringValue = apiKey
    }
    
    func windowWillClose(_ notification: Notification) {
        if self.settingsReset == false {
            let defaults = UserDefaults.standard
            defaults.setValue(menuTempCheckBox.state, forKey: "menuTemp")
            defaults.setValue(pushNotificationCheckBox.state, forKey: "pushNotification")
            defaults.setValue(frequencyPopUpButton.indexOfSelectedItem, forKey: "frequency")
            defaults.setValue(tempUnitSegmentedControl.selectedSegment, forKey: "unit")
            if cityTextField.stringValue == "" {
                defaults.removeObject(forKey: "city")
            } else {
                defaults.setValue(cityTextField.stringValue, forKey: "city")
            }
            if customApiKeyTextField.stringValue == "" {
                defaults.removeObject(forKey: "apiKey")
            } else {
                defaults.setValue(customApiKeyTextField.stringValue, forKey: "apiKey")
            }
            switch tempUnitSegmentedControl.selectedSegment {
            case 1:
                defaults.setValue("°F", forKey: "tempUnit")
                defaults.setValue("imperial", forKey: "requestUnit")
            default:
                defaults.setValue("°C", forKey: "tempUnit")
                defaults.setValue("metric", forKey: "requestUnit")
            }
            switch frequencyPopUpButton.indexOfSelectedItem {
            case 1:
                defaults.setValue(3600, forKey: "refreshFrequency")
            case 2:
                defaults.setValue(10800, forKey: "refreshFrequency")
            case 3:
                defaults.setValue(21600, forKey: "refreshFrequency")
            case 4:
                defaults.setValue(43200, forKey: "refreshFrequency")
            default:
                defaults.setValue(1800, forKey: "refreshFrequency")
            }
        }
        self.settingsReset = false
        delegate?.preferencesDidUpdate()
    }
    
}
