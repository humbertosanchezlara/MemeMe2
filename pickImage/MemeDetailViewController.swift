//
//  MemeDetailViewController.swift
//  pickImage
//
//  Created by Humberto Sanchez Lara on 8/9/17.
//  Copyright © 2017 Humberto Sanchez. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    var meme: Meme!
    
    @IBOutlet weak var memedImage: UIImageView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        memedImage.image = meme.memedImage
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! MemeEditorViewController
        controller.meme = self.meme
         
    }



}
