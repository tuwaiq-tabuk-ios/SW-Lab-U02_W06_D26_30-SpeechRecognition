//
//  CommandCell.swift
//  SpokenWord
//
//  Created by Marzouq Almukhlif on 06/04/1443 AH.
//  Copyright © 1443 Apple. All rights reserved.
//

import UIKit


class CommandCell: UITableViewCell {
  
  let bubbleView: CommandBubbleView = {
    let v = CommandBubbleView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  
  var leadingOrTrailingConstraint = NSLayoutConstraint()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  func commonInit() -> Void {
    
    // add the bubble view
    contentView.addSubview(bubbleView)
    
    // constrain top / bottom with 12-pts padding
    // constrain width to lessThanOrEqualTo 2/3rds (66%) of the width of the cell
    NSLayoutConstraint.activate([
      bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0),
      bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0),
      bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.66),
    ])
    
  }
  
  func setData(_ command: MyCommandTextModel) -> Void {
    
    // set the label text
    bubbleView.commandLabel.text = command.command
    
    // tell the bubble view whether it's an incoming or outgoing message
    bubbleView.incoming = command.incoming
    
    // left- or right-align the bubble view, based on incoming or outgoing
    leadingOrTrailingConstraint.isActive = false
    if command.incoming {
      leadingOrTrailingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12.0)
    } else {
      leadingOrTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12.0)
    }
    leadingOrTrailingConstraint.isActive = true
  }
  
}
