//
//  WMGroupScrollView.m
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/21.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "WMGroupScrollView.h"

@implementation WMGroupScrollView
@synthesize LabelView;
@synthesize myScrollView;
@synthesize pageControl;


- (void)InitSubViews{
    
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    
    self.btnArrays = [[NSMutableArray alloc]init];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
   // CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.LabelView = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 30)];
    self.LabelView.text = @"水印样式";
    self.LabelView.textColor = [UIColor whiteColor];
    self.LabelView.font = [UIFont fontWithName:@"Helvetica" size:15];
    [self addSubview:self.LabelView];
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((width-80)/2, 8, 80, 20)];
    self.pageControl.numberOfPages = [self.WMGroupDataSource numberOfWMGroupImageViews];
    [self addSubview:self.pageControl];
    //暂不使用pagecontrol，隐藏
    self.pageControl.hidden = YES;
    
    
    self.whiteOrBlack = [UIButton buttonWithType:UIButtonTypeCustom];
    self.whiteOrBlack.frame = CGRectMake(width-30-10, 5, 30, 30);
    self.whiteOrBlack.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    [self.whiteOrBlack setImage:[UIImage imageNamed:@"watermark_b.png"] forState:UIControlStateNormal];
    self.whiteOrBlack.titleLabel.textColor = [UIColor whiteColor];
    [self.whiteOrBlack addTarget:self action:@selector(ChangeWhiteAndBlack:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.whiteOrBlack];
    
    self.myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, width, height-35)];
    self.myScrollView.delegate = self;
    self.myScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview: self.myScrollView];
    
  
    
    static CGFloat imageWidth = 65.f;
    static CGFloat space = 20.f;
    
    NSInteger num = [self.WMGroupDataSource numberOfWMGroupImageViews];
    CGFloat contentWidth = (num+1) * (imageWidth + space) + space;
    self.myScrollView.contentSize = CGSizeMake(contentWidth, imageWidth);
    
    for (NSInteger i = 0; i <= num; i++) {
    
        CGFloat x = (space * (i+1)) + (imageWidth * i);
        UIButton  *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, 10, imageWidth, imageWidth)];
        btn.tag = i;
        
        if (i == num) {
            //TODO:替换添加按钮图片。
            [btn setImage:[UIImage imageNamed:@"marker_standard_1_1_b.png"] forState:UIControlStateNormal];
        }
        else{
            [btn setImage:[self.WMGroupDataSource GroupImageOfIndex:i] forState:UIControlStateNormal];
        }
        
        [btn addTarget:self action:@selector(imageClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnArrays addObject:btn];
        [self.myScrollView addSubview:btn];
        
        if (i == 0) {
            //加粗边框
            btn.layer.borderColor = [UIColor greenColor].CGColor;
            btn.layer.borderWidth = 3.f;
        }
    }
}

- (void)saveBtnClick:(id)sender{
    
    [self.WMGroupDelegate saveBtnClick];
}

- (void)ChangeWhiteAndBlack:(id)sender{
    
    [self.WMGroupDelegate ChangeWhiteAndBlack];
}

- (IBAction)imageClick:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    self.pageControl.currentPage = btn.tag;
    
    //最后一个为加号
    if (btn.tag == [self.WMGroupDataSource numberOfWMGroupImageViews]) {
        
        [self.WMGroupDelegate AddNewWaterMarkBtnClick];
    }
    else{
        //清除其他按钮边框
        [self removeOtherBtnBorder:btn.tag];
        
        [self.WMGroupDelegate DidClickWMGroupImageAtIndex:btn.tag withImage:btn.imageView.image];
    }
    
}

- (void)removeOtherBtnBorder:(NSInteger) index{
    
    for (NSInteger i = 0; i < self.btnArrays.count; i++) {
        UIButton *btn = [self.btnArrays objectAtIndex:i];
        if (i == index) {
            //加粗边框
            btn.layer.borderColor = [UIColor greenColor].CGColor;
            btn.layer.borderWidth = 3.f;
        }
        else{
            //清除边框
            btn.layer.borderWidth = 0.f;
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //偏移量
    //CGFloat x = scrollView.contentOffset.x;
    
}

@end
