//
// SettingsVC.h
// ShaarliCompanion
//
// Created by Marcus Rohrmoser on 23.07.15.
// Copyright (c) 2015 Marcus Rohrmoser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShaarliM.h"

@interface SettingsVC : UITableViewController
@property (assign, nonatomic, readwrite) ShaarliM *shaarli;
@end
