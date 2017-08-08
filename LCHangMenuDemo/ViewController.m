//
//  ViewController.m
//  LCHangMenuDemo
//
//  Created by lcc on 2017/8/7.
//  Copyright © 2017年 early bird international. All rights reserved.
//

#import "ViewController.h"
#import "LCSelectMenuView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) LCSelectMenuView *selectMenu;

@property (nonatomic,strong) UIView *headerView;

@property (nonatomic,copy) NSMutableArray *sectionHeaderArray;

@property (nonatomic,copy) NSMutableArray *sectionLocationArray;

@property (nonatomic,assign) BOOL scrollFlag; //手动滚动标志，防止点击菜单滚动触发didScroll代理方法造成菜单定位死循环

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUI];
}

- (void)setUI{

    [self.view addSubview:self.tableView];
    
    //定位当前的标题位置（该计算要在tableView刷新之后计算来保证header位置的准确）
    [self markSectionHeaderLocation];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark- tableView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    self.scrollFlag = NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return self.selectMenu.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    
    return 10;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseID"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    return self.sectionHeaderArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 44;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat offsetY = scrollView.contentOffset.y;
    
    //悬浮菜单
    [self hangOnMenu:offsetY];
    
    //菜单联动
    [self updateMenuTitle:offsetY];
    
}

/**
 联动过程步骤title
 */
- (void)updateMenuTitle:(CGFloat)contentOffsetY{
    
    if(!self.scrollFlag){
        
        //遍历
        for (int i = 0; i<self.sectionLocationArray.count; i++) {
            
            //最后一个按钮
            if (i == self.sectionLocationArray.count - 1) {
                
                if (contentOffsetY >= [self.sectionLocationArray[i] floatValue]) {
                    
                    
                    [self.selectMenu setCurrentPage:i];
                    
                }
                
                
            }else{
                
                if (contentOffsetY >= [self.sectionLocationArray[i] floatValue] && contentOffsetY < [self.sectionLocationArray[i+1] floatValue]) {
                    
                    
                    [self.selectMenu setCurrentPage:i];
                }
                
                
            }
            
            
            
        }
        
        
        
    }
    
    
    
}


- (void)markSectionHeaderLocation{
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.sectionLocationArray = nil;
        //计算对应每个分组头的位置
        for (int i = 0; i < self.selectMenu.titleArray.count; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            CGRect frame = [self.tableView rectForSection:indexPath.section];
            
            //第一组的偏移量比其他组少10
            CGFloat offsetY = (frame.origin.y-64-44);
            
            NSLog(@"offsetY is %f",offsetY);
            
            [self.sectionLocationArray addObject:[NSNumber numberWithFloat:offsetY]];
            
        }
        
        
    });
    
    
    
}



- (void)hangOnMenu:(CGFloat)offsetY{
    
    if (offsetY > (176 - 44)) {
        
        //防止多次更改页面层级
        if ([self.selectMenu.superview isEqual:self.view]) {
            
            return;
        }
        
        //加载到view上
        self.selectMenu.frame = CGRectMake(0, 64, SCREEN_WIDTH, 44);
        [self.view addSubview:self.selectMenu];
        
    }
    
    else{
        
        //防止多次更改页面层级
        if ([self.selectMenu.superview isEqual:self.tableView]) {
            
            return;
        }
        
        //加载到view上
        self.selectMenu.frame = CGRectMake(0, 196, SCREEN_WIDTH, 44);
        [self.tableView addSubview:self.selectMenu];
    
        
    }

    
}

#pragma -mark- lazy load
- (NSMutableArray *)sectionLocationArray{

    if (!_sectionLocationArray) {
        _sectionLocationArray = [NSMutableArray new];
    }
    
    return _sectionLocationArray;
}

- (LCSelectMenuView *)selectMenu{

    if (!_selectMenu) {
        _selectMenu = [LCSelectMenuView new];
        _selectMenu.frame = CGRectMake(0, 196, SCREEN_WIDTH, 44);
        _selectMenu.titleArray = @[@"商品介绍",@"商品型号",@"商品参数",@"相关评论",@"相关推荐"];
        
        __weak typeof(self) _ws = self;
        
        [_selectMenu setPageSelectBlock:^(NSInteger index) {
            
            CGRect rect = [_ws.tableView rectForSection:index];
            
            CGFloat offsetY = rect.origin.y - 20 - 44 - 44;
            
            [_ws.tableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
            
            _ws.scrollFlag = YES; //打开菜单点击标志，防止滚动代理didScrollView触发
            
        }];
        
        
    }
    
    return _selectMenu;
}

- (UITableView *)tableView{

    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseID"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.headerView;
        
        [_tableView addSubview:self.selectMenu];
    }
    
    return _tableView;
}

- (UIView *)headerView{

    if (!_headerView) {
        _headerView = [UIView new];
        
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 184);
        imageView.image = [UIImage imageNamed:@"fzlmnhctxb_62928.jpg"];
        
        [_headerView addSubview:imageView];
        _headerView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 250);
        
    }
    
    return _headerView;
}

- (NSMutableArray *)sectionHeaderArray{

    if (!_sectionHeaderArray) {
        _sectionHeaderArray = [NSMutableArray new];
        
        for (int i = 0; i < self.selectMenu.titleArray.count; i++) {
            
            UIView *sectionHeader = [UIView new];
            sectionHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
            sectionHeader.backgroundColor = [UIColor whiteColor];
            
            UILabel *titlLabel = [UILabel new];
            titlLabel.frame = CGRectMake(0, 0, 150, 44);
            titlLabel.font = [UIFont systemFontOfSize:14];
            titlLabel.textAlignment = NSTextAlignmentCenter;
            titlLabel.center = sectionHeader.center;
            
            titlLabel.text = self.selectMenu.titleArray[i];
            
            [sectionHeader addSubview:titlLabel];
            
            [_sectionHeaderArray addObject:sectionHeader];
            
        }
        
        
    }
    
    return _sectionHeaderArray;
}


@end
