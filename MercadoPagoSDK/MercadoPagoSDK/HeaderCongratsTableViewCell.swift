//
//  HeaderCongratsTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/25/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class HeaderCongratsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageError: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    func fillCell(payment: Payment, paymentMethod: PaymentMethod, color: UIColor){
        if payment.status == "approved" {
            icon.image = MercadoPago.getImage("iconoAcreditado")
            title.text = "¡Listo, se acreditó tu pago!"
            messageError.text = ""
            view.backgroundColor = color
        } else if payment.status == "in_process" {
            icon.image = MercadoPago.getImage("congrats_iconPending")
            title.text = "Estamos procesando el pago"
            messageError.text = ""
            view.backgroundColor = color
        } else if payment.statusDetail == "cc_rejected_call_for_authorize" {
            icon.image = MercadoPago.getImage("congrats_iconoAutorizarTel")
            let currency = MercadoPagoContext.getCurrency()
            
            let totalAmount = Utils.getAttributedAmount(payment.transactionDetails.totalPaidAmount, thousandSeparator: String(currency.thousandsSeparator), decimalSeparator: String(currency.decimalSeparator), currencySymbol: String(currency.symbol), color:UIColor.white(), fontSize: 22, baselineOffset:11)
            let title = NSMutableAttributedString(string: "Debes autorizar ", attributes: nil)
            if let paymentMethodName = paymentMethod.name {
                
                title.append(NSMutableAttributedString(string: "\(paymentMethod.name!) ", attributes: nil))
            }
            title.append(NSMutableAttributedString(string: "el pago de ", attributes: nil))
            title.append(totalAmount)
            title.append(NSMutableAttributedString(string: " a MercadoPago", attributes: nil))
            self.title.attributedText = title
            messageError.text = ""
            view.backgroundColor = color
        } else {
            icon.image = MercadoPago.getImage("congrats_iconoTcError")
            var title = (payment.statusDetail + "_title")
            if !title.existsLocalized() {
                title = "Uy, no pudimos procesar el pago".localized
            }
            
            if let paymentMethodName = paymentMethod.name {
                let titleWithParams = (title.localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethodName)")
                self.title.text = titleWithParams
            }
            messageError.text = "Algo salió mal… "
            view.backgroundColor = color
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
