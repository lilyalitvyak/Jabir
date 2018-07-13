//
//  MLDetailsTableViewCell.h
//  Jabir
//
//  Created by Anurodh Pokharel on 12/8/17.
//  Copyright © 2017 Jabir.im. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLDetailsTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView* buddyIconView;
@property (nonatomic,weak) IBOutlet UITextView* buddyName;
@property (nonatomic,weak) IBOutlet UILabel* fullName;
@property (nonatomic,weak) IBOutlet UILabel* buddyStatus;

@property (nonatomic, weak) IBOutlet UITextView *cellDetails;

@end
