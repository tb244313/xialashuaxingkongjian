//
//  WJTableViewController.m
//  shuaxinkongjian
//
//  Created by apple on 16/11/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "WJTableViewController.h"
#import "WJPullDownToRefreshView.h"

//self.tableView.contentIntset.top 可以让内容往下某个值开始

@interface WJTableViewController ()

//要显示的数据
@property (nonatomic, strong) NSArray *cities;

@end

@implementation WJTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载数据
    self.cities =  [self loadData];

    //创建frame
    CGRect refreshViewFrame = CGRectMake(0, -60, [UIScreen mainScreen].bounds.size.width, 60);
    
    //创建下拉刷新控件
    WJPullDownToRefreshView *refreshView = [[WJPullDownToRefreshView alloc] initWithFrame:refreshViewFrame];
    refreshView.backgroundColor = [UIColor brownColor];
    //添加到tableview里面
    [self.tableView addSubview:refreshView];
    
    //1.定义了Block, 2.传递Block 
    refreshView.refreshingBlock = ^(){
    
//        NSLog(@"控制器知道进入刷新状态了");
        
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //加载数据
            NSArray *newData = [self loadData];
            NSMutableArray *arrayM = [NSMutableArray arrayWithArray:newData];
            [arrayM addObjectsFromArray:self.cities];
            self.cities = arrayM;
            [self.tableView reloadData];
            
            //结束刷新
            [refreshView endRefreshing];
            
        });
    };
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    NSLog(@"self.tableView.contentInsert.top = %f",self.tableView.contentInset.top);

}
/**
 加载数据

 */
-(NSArray *)loadData{

    //文件的路径
    NSString *citiesFile = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"plist"];
    
    NSArray *array = [NSArray arrayWithContentsOfFile:citiesFile];
    
    return array;

}

#pragma mark - Table view data source

//返回cell数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cities.count;

}
//返回一个cell给talbleView去显示
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    //设置cell的内容
    cell.textLabel.text = self.cities[indexPath.row];
    
    return cell;
    

}

//tableView滚动了就会调用这个方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    //控制器中 tableView滚动了，切换刷新控件的状态
    NSLog(@"控制器中 tableView滚动了");


}



@end
