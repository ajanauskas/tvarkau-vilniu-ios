//
//  ProblemsListTableViewCell.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 09/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProblemsListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *problemDescription;
@property (weak, nonatomic) IBOutlet UIImageView *status;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@end
