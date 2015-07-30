//
//  XXFAdHeadlineView.m
//  XXFCusromView
//
//  Created by sc on 15-3-6.
//  Copyright (c) 2014年 Oliver. All rights reserved.
//

/***@brief zise*/
#define ZS [UIColor colorWithRed:186.f/255.0 green:47.f/255.0 blue:251.f/255.0 alpha:1]

#import "XXFAdHeadlineView.h"
#import "UIImageView+WebCache.h"

@implementation XXFAdHeadlineView
{
    CGFloat height,width;
}

@synthesize scrollView;
@synthesize slideImagesArr;
@synthesize pageControl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
       
    }
    return self;
}

- (void)initSubViews{
    
    // 宽度和高度
    height = self.frame.size.height;
    width  = self.frame.size.width;
    
    // 初始化 scrollview
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    [self addSubview:scrollView];
    
    // 初始化 pagecontrol
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(width/2 -60,height-30,120,30)];

    [self addSubview:pageControl];
    
    // 初始化 数组 并添加四张图片
    slideImagesArr = [NSMutableArray  array];
}

/**
 *	@brief	需要传输的数据
 *
 *	@param 	imgArr 	图片数组
 *	@param 	Interval 	滚动时间
 */
- (void)setSlideImgArr:(NSMutableArray*)imgArr Interval:(NSTimeInterval)Interval
{
    slideImagesArr = imgArr;
    
    // 当imgArr里面没有东西时结束程序
    if (imgArr.count == 0)
    {
        return;
    }
    
    /// 定时器 循环
    [NSTimer scheduledTimerWithTimeInterval:Interval target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
    /**
     *  scrollView的属性
     */
    {
        scrollView.bounces = YES;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        scrollView.userInteractionEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
    }
    /**
     *  pageControl的属性
     */
    {
        [pageControl setCurrentPageIndicatorTintColor:[UIColor blueColor]];
        [pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        pageControl.numberOfPages = [self.slideImagesArr count];
        pageControl.currentPage = 0;
        // 触摸mypagecontrol触发change这个方法事件
        [pageControl addTarget:self action:@selector(turnPage) forControlEvents:UIControlEventValueChanged];
    }
    
    // 创建N个图片 imageview
    for (int i = 0;i<[slideImagesArr count];i++)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[slideImagesArr objectAtIndex:i]]];
        imageView.tag = i;
        // 首页是第0页,默认从第1页开始的。所以加当前的宽度。。。
        imageView.frame = CGRectMake((width * i) + width, 0, width, height);
        [scrollView addSubview:imageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUpClick:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
    }
    
    // 取数组最后一张图片 放在第0页
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[slideImagesArr objectAtIndex:([slideImagesArr count]-1)]]];
    // 添加最后1页在首页 循环
    imageView.frame = CGRectMake(0, 0, width, height);
    [scrollView addSubview:imageView];
    // 取数组第一张图片 放在最后1页
    imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[slideImagesArr objectAtIndex:0]]];
    // 添加第1页在最后 循环
    imageView.frame = CGRectMake((width * ([slideImagesArr count] + 1)) , 0, width, height);
    [scrollView addSubview:imageView];
    // +上第1页和第4页  原理：4-[1-2-3-4]-1
    [scrollView setContentSize:CGSizeMake(width * ([slideImagesArr count] + 2), height)];
    [scrollView setContentOffset:CGPointMake(0, 0)];
    // 默认从序号1位置放第1页 ，序号0位置位置放最后一页
    [self.scrollView scrollRectToVisible:CGRectMake(width,0,width,height) animated:YES];
}

/**
 *  scrollview 委托函数
 *
 *  @param scrollView
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pagewidth = width;
    int currentPage = floor((self.scrollView.contentOffset.x - pagewidth/ ([slideImagesArr count]+2)) / pagewidth) + 1;
    
    if (currentPage==0)
    {
        [self.scrollView scrollRectToVisible:CGRectMake(width * [slideImagesArr count],0,width,height) animated:YES]; // 序号0 最后1页
    }
    else if (currentPage==([slideImagesArr count]+1))
    {
        [self.scrollView scrollRectToVisible:CGRectMake(width,0,width,height) animated:YES]; // 最后+1,循环第1页
    }
}

/**
 *  scrollview 委托函数
 *
 *  @param sender
 */
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pagewidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pagewidth/([slideImagesArr count]+2))/pagewidth)+1;
    page --;
    // 默认从第二页开始
    pageControl.currentPage = page;
}

/**
 *  pagecontrol 选择器的方法
 */
- (void)turnPage
{
    NSInteger page = pageControl.currentPage;
    // 获取当前的page
    [self.scrollView scrollRectToVisible:CGRectMake(width*(page+1),0,width,height) animated:YES];
    // 触摸pagecontroller那个点点 往后翻一页 +1
}


/**
 *	@brief	定时器 绑定的方法
 */
- (void)runTimePage
{
    NSInteger page = pageControl.currentPage; // 获取当前的page
    page++;
    page = page > slideImagesArr.count-1 ? 0 : page ;
    pageControl.currentPage = page;
    [self turnPage];
}

/**
 *  图片点击事件
 */
- (void)tapUpClick:(UITapGestureRecognizer*)tap
{
    if (_delegate)
    {
        [_delegate tapClick:(int)tap.view.tag];
    }
}

@end
