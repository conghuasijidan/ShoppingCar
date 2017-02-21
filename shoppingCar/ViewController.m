//
//  ViewController.m
//  shoppingCar
//
//  Created by 葱花思鸡蛋 on 2017/2/19.
//  Copyright © 2017年 葱花思鸡蛋. All rights reserved.
//

#import "ViewController.h"
#import "AnimationViewController.h"
@interface ViewController ()

@property(nonatomic,strong)UINavigationController *nav;
@property(nonatomic,strong)UIView *popView;
@property(nonatomic,strong)UIView *maskView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置背景颜色 第一层
    self.view.backgroundColor = [UIColor blackColor];
    //添加子控制器 第二层
    AnimationViewController *aniVC = [[AnimationViewController alloc] init];
    aniVC.view.frame = self.view.bounds;
    aniVC.view.backgroundColor = [UIColor whiteColor];
    aniVC.title = @"动画界面";
    self.nav = [[UINavigationController alloc] initWithRootViewController:aniVC];
    
    [self addChildViewController:self.nav];
    [self.view addSubview:self.nav.view];
    [aniVC.view didMoveToSuperview];
    //有的添加到nav.view上
    UIButton *showBtn = [[UIButton alloc] init];
    [showBtn setTitle:@"show" forState:UIControlStateNormal];
    [showBtn addTarget:self action:@selector(showAction) forControlEvents:UIControlEventTouchUpInside];
    [showBtn setBackgroundColor:[UIColor orangeColor]];
    showBtn.center = aniVC.view.center;
    [showBtn sizeToFit];
    [aniVC.view addSubview:showBtn];
    
    NSLog(@"%@,%@",self.nav.view,aniVC.view);
    //第三层 罩层 有的添加到nav.view上
    self.maskView = [[UIView alloc] initWithFrame:aniVC.view.bounds];
    self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.maskView.alpha = 0;
    [aniVC.view addSubview:self.maskView];
    // 罩层上添加手势
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
    [self.maskView addGestureRecognizer:tapRecognizer];
    
    
    //第四层 carView 购物车视图 添加到window上
    self.popView = [[UIView alloc] initWithFrame:CGRectMake(0, self.maskView.bounds.size.height, self.maskView.bounds.size.width, self.maskView.bounds.size.height*0.5)];
    
    self.popView.backgroundColor = [UIColor redColor];
    
    
    
}

- (void)showAction
{
    // 开始的时候把popView加载到window上面去，类似于系统的actionSheet之类的弹窗
    [[UIApplication sharedApplication].windows[0] addSubview:self.popView];
    // 先计算出popView的弹出高度
    CGRect rec = self.popView.frame;
    rec.origin.y = self.view.bounds.size.height / 2;
    [UIView animateWithDuration:0.3 animations:^{
        // 先逆时针X轴旋转 缩小到0.95呗，向内凹陷的透视效果 如果不进行下一波操作，那么这个效果就是View向内倾斜了
        self.nav.view.layer.transform = [self transform1];
    } completion:^(BOOL finished) {
        // 倾斜完之后，我们再进行第二段操作，先把transform设置为初始化，然后透视还是和第一段一样，让他回归到正常（不倾斜）同时让大小动画为0.8，高度向上移动一点点，maskView出来，popView也顺着出来指定高度
        [UIView animateWithDuration:0.3 animations:^{
            
            self.nav.view.layer.transform = [self transform2];
            self.maskView.alpha = 0.5;
            self.popView.frame = rec;
        } completion:^(BOOL finished) {
        }];
    }];
    
    
}

- (void)cancelAction{
    
    // 先计算出popView回去的位置
    CGRect rec = self.popView.frame;
    rec.origin.y = self.view.bounds.size.height;
    
    // 动画回去
    [UIView animateWithDuration:0.4 animations:^{
        // popView回去
        self.popView.frame = rec;
        // mask回0
        self.maskView.alpha = 0;
        // 在进行旋转，向内凹陷，大小缩为0.95倍
        self.nav.view.layer.transform = [self transform1];
        
    } completion:^(BOOL finished) {
        
        // 折叠完之后让transform回归到正常水平就好了
        [UIView animateWithDuration:0.3 animations:^{
            
            self.nav.view.layer.transform = CATransform3DIdentity;
            
        } completion:^(BOOL finished) {
            
            // 把popView从Window中移除
            [self.popView removeFromSuperview];
            
        }];
        
    }];
    
    
}


// 第一次形变
- (CATransform3D)transform1{
    // 每次进来都进行初始化 回归到正常状态
    CATransform3D form1 = CATransform3DIdentity;
    // m34就是实现视图的透视效果的（俗称近大远小）
    form1.m34 = 1.0/-900;
    //缩小的效果
    form1 = CATransform3DScale(form1, 0.95, 0.95, 1);
    //x轴旋转
    form1 = CATransform3DRotate(form1, 15.0 * M_PI/180.0, 1, 0, 0);
    return form1;
    
}


// 第二次形变
- (CATransform3D)transform2{
    // 初始化 再次回归正常
    CATransform3D form2 = CATransform3DIdentity;
    // 用上面用到的m34 来设置透视效果
    form2.m34 = [self transform1].m34;
    //向上平移一丢丢 让视图平滑点
    form2 = CATransform3DTranslate(form2, 0, self.view.frame.size.height * (-0.08), 0);
    //最终再次缩小到0.8倍
    form2 = CATransform3DScale(form2, 0.8, 0.8, 1);
    return form2;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
