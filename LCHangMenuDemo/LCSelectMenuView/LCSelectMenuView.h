//
//  LCSelectMenuView.h
//  LCSelectMenuView
//
//  Created by lcc on 2017/6/30.
//  Copyright © 2017年 early bird international. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LCColorRGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface LCSelectMenuView : UIView

@property (nonatomic,strong) NSArray *titleArray;

@property (nonatomic,assign) NSInteger currentPage; //当前的页码


@property (nonatomic,copy) void (^pageSelectBlock)(NSInteger curPage); //菜单选择回调

@end
