//
//  DetalleViewController.swift
//  OpenLibraryApp
//
//  Created by Gerardo Villarroel on 6/20/16.
//  Copyright © 2016 Gerardo Villarroel. All rights reserved.
//

import UIKit

class DetalleViewController: UIViewController {

    var detalleLibro = [AnyObject]()
    
    @IBOutlet weak var portadaLibro: UIImageView!
    @IBOutlet weak var datosLibro: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datosLibro.text = "Tìtulo: " + (detalleLibro[0] as! String) + "\n"
        
        if detalleLibro.count > 2 {
            portadaLibro.image = UIImage(data: detalleLibro[1] as! NSData)
            datosLibro.text =  datosLibro.text! + "Autores: " + (detalleLibro[2] as! String)
        } else {
            datosLibro.text =  datosLibro.text! + "Autores: " + (detalleLibro[1] as! String)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
