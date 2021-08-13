//
//  ColorAttributeTransformer.swift
//  BowTies
//
//  Created by Кирилл Нескоромный on 09.08.2021.
//  Copyright © 2021 Razeware. All rights reserved.
//

import UIKit

class ColorAttributeTransformer: NSSecureUnarchiveFromDataTransformer {
  //1 Переопределите allowedTopLevelClasses, чтобы вернуть список классов, которые может декодировать этот преобразователь данных. Мы хотим сохранить и извлечь экземпляры UIColor, поэтому здесь вы возвращаете массив, содержащий только этот класс.
    override static var allowedTopLevelClasses: [AnyClass] {
      [UIColor.self]
  }
  //2 Как следует из названия, статическая функция register() помогает вам зарегистрировать свой подкласс с помощью ValueTransformer. Но зачем вам это нужно делать? ValueTransformer  поддерживает сопоставление ключ-значение, где ключом является имя, указанное с помощью NSValueTransformerName, а значение является экземпляром соответствующего преобразователя. Это сопоставление понадобится вам позже в редакторе моделей данных.
    static func register() {
      let className = String(describing: ColorAttributeTransformer.self)
      
      let name = NSValueTransformerName(className)
      let transformer = ColorAttributeTransformer()
      
      ValueTransformer.setValueTransformer(transformer, forName: name)
    }

}
