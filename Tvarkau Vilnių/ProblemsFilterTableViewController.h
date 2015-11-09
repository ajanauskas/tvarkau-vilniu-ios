//
//  ProblemsFilterTableViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 12/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProblemsFilterDelegate <NSObject>

- (void)problemsFilterWithAddress:(NSString *)address description:(NSString *)description type:(NSInteger)problemType registrationDate:(NSDate *)registrationDate docNo:(NSString *)docNo;

@end

@interface ProblemsFilterTableViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewAccessibilityDelegate, UITextFieldDelegate>
{
    UITextField *activeField;
}

@property (nonatomic, weak) id<ProblemsFilterDelegate>delegate;

@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *problemDescription;
@property (weak, nonatomic) IBOutlet UIPickerView *problemType;
@property (weak, nonatomic) IBOutlet UISwitch *registrationDateSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *registrationDatePicker;
@property (weak, nonatomic) IBOutlet UITextField *docNo;

- (IBAction)filter:(id)sender;
- (IBAction)hideKeyboard:(UITextField*)sender;
- (IBAction)showHideRegistrationDatePicker:(UISwitch *)sender;

@end
