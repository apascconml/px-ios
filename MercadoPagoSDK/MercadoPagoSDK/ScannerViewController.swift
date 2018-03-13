//
//  ScannerViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 13/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import PayCardsRecognizer

class ScannerViewController: MercadoPagoUIViewController, PayCardsRecognizerPlatformDelegate {
    
    var recognizer: PayCardsRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recognizer = PayCardsRecognizer(delegate: self, resultMode: .sync, container: self.view, frameColor: .green)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recognizer.startCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        recognizer.stopCamera()
    }
    
    // PayCardsRecognizerPlatformDelegate
    
    func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
        print("number: ",result.recognizedNumber) // Card number
        print("name: ",result.recognizedHolderName) // Card holder
        print("month: ",result.recognizedExpireDateMonth) // Expire month
        print("year: ",result.recognizedExpireDateYear) // Expire year
    }
    
}
