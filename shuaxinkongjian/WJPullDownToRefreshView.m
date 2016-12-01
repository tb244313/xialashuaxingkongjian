//
//  WJPullDownToRefreshView.m
//  shuaxinkongjian
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "WJPullDownToRefreshView.h"
#define WJPullDownToRefreshViewHeight 60
//自己监听tableview的滚动
//tableView是刷新控件的父控件
//其实就是监听父控件的滚动
//willMoveToSuperview会传入父控件
//监听父控件的滚动

//3种状态
typedef enum {

    WJPullDownToRefreshViewStatusNormal,      //正常状态
    WJPullDownToRefreshViewStatusPulling,     //释放刷新状态
    WJPullDownToRefreshViewStatusRefreshing   //正在刷新

} WJPullDownToRefreshViewStatus;

@interface WJPullDownToRefreshView ()
//图片
@property (nonatomic, strong) UIImageView *imageView;
//文字
@property (nonatomic, strong) UILabel *label;

//纪录当前状态
@property (nonatomic, assign) WJPullDownToRefreshViewStatus currentStatus;

//父控件，是可以滚动的
@property (nonatomic, strong) UIScrollView *superScrollView;


// 吃包子动画图片
@property (nonatomic, strong) NSArray *refreshingImage;

@end
@implementation WJPullDownToRefreshView

//添加子控件
-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        //添加控件
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        
        //设置frame
        _imageView.frame = CGRectMake(130, 5, 50, 50);
        _label.frame = CGRectMake(190, 20, 200, 20);
        
    }
    return self;
}

-(void)dealloc{

    //移除KVO监听
    [self.superScrollView removeObserver:self forKeyPath:@"contentOffset"];
    

}

//控件将要添加到父控件中
-(void)willMoveToSuperview:(UIView *)newSuperview{

    [super willMoveToSuperview:newSuperview];
    NSLog(@"willMoveToSuperview = %@",newSuperview);

    //可以获取父控件
    //只有父控件能滚动的才去监听 类型判断
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView *)newSuperview;
        
        // 监听父控件的滚动其实就是监听self.superScrollView对象的contentOffset属性的改变
        //KVO Key-Value observing
        //KVO:键值监听
        //KVO作用：就是监听一个对象的属性的改变
        //KVO使用：要监听哪个对象就用哪个对象调用？addObserver: forKeyPath: context:
        //参数：addObserver：谁来监听
        //forKeyPath:要监听的属性
        //KVO:当监听对象的身上的属性发生改变会调用addObserver 对象的addObserver: forKeyPath: context:
        //注意：使用KVO和使用通知一样需要 取消
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
        
        
    }
}

//这个对象的这个方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{

    NSLog(@"自己监听父控件的滚动 = %f", self.superScrollView.contentOffset.y);

    //根据拖动的程度切换状态
    if (self.superScrollView.isDragging)
    {
        //手拖动nomal->pulling, pulling->normal
        //偏移值
        CGFloat normalPullingOffset = -124;
        if (self.currentStatus == WJPullDownToRefreshViewStatusPulling && self.superScrollView.contentOffset.y > normalPullingOffset)//-90>-124
        {
            NSLog(@"切换到normal");
            self.currentStatus = WJPullDownToRefreshViewStatusNormal;

        }else if (self.currentStatus == WJPullDownToRefreshViewStatusNormal && self.superScrollView.contentOffset.y <= normalPullingOffset) //-150 < -124
        {
        
            NSLog(@"切换到Pulling");
            self.currentStatus = WJPullDownToRefreshViewStatusPulling;
        
        }else
        {
        //手松开pulling->refreshing
            if (self.currentStatus == WJPullDownToRefreshViewStatusPulling) {
                NSLog(@"切换refreshing");
                self.currentStatus = WJPullDownToRefreshViewStatusRefreshing;

            }

    
        }
    }
}

-(void)setCurrentStatus:(WJPullDownToRefreshViewStatus)currentStatus{

    _currentStatus = currentStatus;
    
    // 设置内容
    switch (_currentStatus) {
        case WJPullDownToRefreshViewStatusNormal:
            NSLog(@"切换到normol");
            [self.imageView stopAnimating];
            self.label.text = @"下拉刷新";
            self.imageView.image = [UIImage imageNamed:@"grade_A"];
            break;
        case WJPullDownToRefreshViewStatusPulling:
            NSLog(@"切换到Pulling");
            self.label.text = @"释放刷新";
            self.imageView.image = [UIImage imageNamed:@"grade_B"];
            break;
            
        case WJPullDownToRefreshViewStatusRefreshing:
            NSLog(@"切换到Refreshing");
            self.label.text = @"正在刷新...";


            //TODO:吃包子动画
            self.imageView.animationImages = self.refreshingImage;
            self.imageView.animationDuration = 0.1 * self.refreshingImage.count;
            // 开始动画
            [self.imageView startAnimating];
            
            //tableView往下面走  只改变了top值
            [UIView animateWithDuration:0.25 animations:^{
                self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top + WJPullDownToRefreshViewHeight, self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom, self.superScrollView.contentInset.right);
            }];
    
            //让控制器做事情
            //Block使用：1.定义Block, 2.传递Block 3.调用Block
            if (self.refreshingBlock) {
                self.refreshingBlock();
//                NSLog(@"控制器知道进入刷新状态了");

            }

            break;
            
//        default:
//            break;
    }

}

-(void)endRefreshing{

    // 结束刷新 refreshing ->normal
     //tableView回去
    if (self.currentStatus == WJPullDownToRefreshViewStatusRefreshing) {
        self.currentStatus = WJPullDownToRefreshViewStatusNormal;
        //TODO:tableView回去
        [UIView animateWithDuration:0.25 animations:^{
            self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top - WJPullDownToRefreshViewHeight, self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom, self.superScrollView.contentInset.right);
        }];
        
    }

}
#pragma mark - 懒加载
//getter
-(UIImageView *)imageView{

    if (_imageView == nil) {
        //创建图片
        UIImage *normalImage = [UIImage imageNamed:@"grade_B"];
        
        _imageView = [[UIImageView alloc] initWithImage:normalImage];
    }


    return _imageView;
}

-(UILabel *)label{

    if (_label == nil) {
        _label = [[UILabel alloc] init];
        //设置
        _label.textColor = [UIColor darkGrayColor];
        _label.font = [UIFont systemFontOfSize:16];
        _label.text = @"下拉刷新";
    }


    return _label;
}

-(NSArray *)refreshingImage{

    if (_refreshingImage == nil) {
        NSMutableArray *arrayM = [NSMutableArray array];
        
        // 加载图片
        for (int i = 1; i < 4; i++) {
            NSString *imageName = [NSString stringWithFormat:@"grade_0%d",i];
            
            UIImage *image = [UIImage imageNamed:imageName];
            [arrayM addObject:image];
            
        }
        _refreshingImage = arrayM;
        
    }

    return _refreshingImage;
}
@end
