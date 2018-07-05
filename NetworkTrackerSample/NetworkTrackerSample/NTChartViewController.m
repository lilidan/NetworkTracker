//
//  NTChartViewController.m
//  breakWork
//
//  Created by sgcy on 2018/7/4.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTChartViewController.h"
#import "AAChartKit.h"
#import "NTWebModel.h"
#import "NTHTTPModel.h"
#import "NTTCPModel.h"
#import "NTDataKeeper.h"
#import <objc/runtime.h>

@interface NTChartViewController ()<AAChartViewDidFinishLoadDelegate>

@property (nonatomic, strong) AAChartModel *aaChartModel;
@property (nonatomic, strong) AAChartView  *aaChartView;

@end

@implementation NTChartViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barTintColor = [self colorWithHexString:@"#ffffff"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[self colorWithHexString:@"#ffffff"]}];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [self colorWithHexString:@"#ffffff"];
    
    [self setUpTheSegmentedControls];
    [self setUpTheSwitchs];
    
    AAChartType chartType = AAChartTypeBar;
    [self setUpTheAAChartViewWithChartType:chartType];
    [self setChartModelWithIndex:0];
    [self refreshTheChartView];
}


- (void)setUpTheAAChartViewWithChartType:(AAChartType)chartType {
    
    CGFloat chartViewWidth  = self.view.frame.size.width;
    CGFloat chartViewHeight = self.view.frame.size.height-220;
    self.aaChartView = [[AAChartView alloc]init];
    self.aaChartView.frame = CGRectMake(0, 60, chartViewWidth, chartViewHeight);
    self.aaChartView.delegate = self;
    self.aaChartView.scrollEnabled = NO;

    [self.view addSubview:self.aaChartView];
    
    
    self.aaChartView.isClearBackgroundColor = YES;
    
    [self configureTheStyleForDifferentTypeChart];
    
    [self.aaChartView aa_drawChartWithChartModel:_aaChartModel];
}

- (NSArray *)getPropertyList:(Class)class
{
    NSMutableArray *propertyArr = [[NSMutableArray alloc] init];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        NSString * key = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
        [propertyArr addObject: key];
    }
    free(properties);
    return [propertyArr copy];
}

- (void) setChartModelWithIndex:(NSInteger)index
{
    NSArray *models;
    Class modelClass;
    if (index == 0) {
        models = [NTDataKeeper shareInstance].httpModels;
        modelClass = [NTHTTPModel class];
    }else if (index == 1){
        models = [NTDataKeeper shareInstance].webModels;
        modelClass = [NTWebModel class];
    }else{
        models = [NTDataKeeper shareInstance].tcpModels;
        modelClass = [NTTCPModel class];
    }
    NSArray *property = [[self getPropertyList:modelClass] arrayByAddingObjectsFromArray:[self getPropertyList:[NTBaseModel class]]];
    if (index < 2) {
        property = [property arrayByAddingObjectsFromArray:[self getPropertyList:[NTHTTPBaseModel class]]];
    }
    
    NSMutableArray *series = [[NSMutableArray alloc] init];
    for (NSString *startkey in property) {
        if ([startkey containsString:@"EndDate"]) {
            NSString *endkey = [startkey stringByReplacingOccurrencesOfString:@"EndDate" withString:@"StartDate"];
            NSString *key = [startkey stringByReplacingOccurrencesOfString:@"EndDate" withString:@""];
//            [keys addObject:key];
            NSMutableArray *deltas = [[NSMutableArray alloc] init];
            for (id model in models) {
                id startValue = [model valueForKey:startkey];
                id endValue = [model valueForKey:endkey];
                if (startValue && endValue) {
                    NSTimeInterval delta = [startValue timeIntervalSinceDate:endValue];
                    [deltas addObject:@(delta)];
                }else{
                    [deltas addObject:@(0)];
                }
            }
            [series addObject:AAObject(AASeriesElement)
             .nameSet(key)
             .dataSet(deltas)];
        }
    }
    
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    for (NTBaseModel *model in models) {
        NSString *urlStr;
        if (model.remoteURL) {
            urlStr = model.remoteURL;
        }else{
            urlStr = model.remoteAddressAndPort;
        }
        NSURL *url = [NSURL URLWithString:urlStr];
        if (url.host) {
            [urls addObject:url.host];
        }else{
            [urls addObject:urlStr];
        }
    }
    
    
    self.aaChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeBar)
    .titleSet(@"")
    .subtitleSet(@"")
    .yAxisLineWidthSet(@0)
    .colorsThemeSet(@[@"#fe117c",@"#ffc069",@"#06caf4",@"#7dffc0",@"#7f8c8d"])
    .yAxisTitleSet(@"")
    .tooltipValueSuffixSet(@"℃")
    .backgroundColorSet(@"#ffffff")
    .yAxisGridLineWidthSet(@0)
    .seriesSet(series);
    
//    _aaChartModel.categories = @[@"Java", @"Swift", @"Python", @"Ruby", @"PHP", @"Go", @"C", @"C#", @"C++", @"Perl", @"R", @"MATLAB"];//设置 X 轴坐标文字内容

    _aaChartModel.categories = [urls copy];
    _aaChartModel.animationType = AAChartAnimationBounce;
    _aaChartModel.yAxisTitle = @"";
    _aaChartModel.animationDuration = @1200;
    
}


- (void)configureTheYAxisPlotLineForAAChartView {
    _aaChartModel
    .yAxisMaxSet(@(21))//Y轴最大值
    .yAxisMinSet(@(1))//Y轴最小值
    .yAxisAllowDecimalsSet(NO)//是否允许Y轴坐标值小数
    .yAxisTickPositionsSet(@[@(0),@(25),@(50),@(75),@(100)])//指定y轴坐标
    .yAxisPlotLinesSet(@[
                         AAObject(AAPlotLinesElement)
                         .colorSet(@"#F05353")//颜色值(16进制)
                         .dashStyleSet(AALineDashSyleTypeLongDashDot)//样式：Dash,Dot,Solid等,默认Solid
                         .widthSet(@(1)) //标示线粗细
                         .valueSet(@(20)) //所在位置
                         .zIndexSet(@(1)) //层叠,标示线在图表中显示的层叠级别，值越大，显示越向前
                         .labelSet(@{@"text":@"标示线1",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})/*这里其实也可以像AAPlotLinesElement这样定义个对象来赋值（偷点懒直接用了字典，最会终转为js代码，可参考https://www.hcharts.cn/docs/basic-plotLines来写字典）*/
                         ,AAObject(AAPlotLinesElement)
                         .colorSet(@"#33BDFD")
                         .dashStyleSet(AALineDashSyleTypeLongDashDot)
                         .widthSet(@(1))
                         .valueSet(@(40))
                         .labelSet(@{@"text":@"标示线2",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})
                         ,AAObject(AAPlotLinesElement)
                         .colorSet(@"#ADFF2F")
                         .dashStyleSet(AALineDashSyleTypeLongDashDot)
                         .widthSet(@(1))
                         .valueSet(@(60))
                         .labelSet(@{@"text":@"标示线3",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})
                         ]
                       );
}

- (void)configureTheStyleForDifferentTypeChart {
        _aaChartModel.animationType = AAChartAnimationBounce;//图形的渲染动画为弹性动画
        _aaChartModel.yAxisTitle = @"";
        _aaChartModel.animationDuration = @1200;//图形渲染动画时长为1200毫秒
}

- (NSArray *)configureTheRandomColorArray {
    NSMutableArray *colorStringArr = [[NSMutableArray alloc]init];
    for (int i=0; i<20; i++) {
        int R = (arc4random() % 256) ;
        int G = (arc4random() % 256) ;
        int B = (arc4random() % 256) ;
        NSString *colorStr = [NSString stringWithFormat:@"rgba(%d,%d,%d,0.9)",R,G,B];
        [colorStringArr addObject:colorStr];
    }
    return colorStringArr;
}

#pragma mark -- AAChartView delegate
- (void)AAChartViewDidFinishLoad {

}

- (void)setUpTheSegmentedControls{
    
    NSArray *segmentedArray = @[@[@"HTTP",
                                  @"WebView",
                                  @"TCP"]
                                ];
    NSArray *typeLabelNameArr = @[@"Network type selection"];
    for (int i=0; i<segmentedArray.count; i++) {
        UISegmentedControl * segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray[i]];
        segmentedControl.frame = CGRectMake(20, 40*i+(self.view.frame.size.height-45), self.view.frame.size.width-40, 20);
        segmentedControl.tintColor = [UIColor redColor];
        //        segmentedControl.tintColor = [UIColor lightGrayColor];
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.tag = i;
        [segmentedControl addTarget:self action:@selector(customsegmentedControlCellValueBeChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:segmentedControl];
        UILabel *typeLabel = [[UILabel alloc]init];
        typeLabel.textColor = [UIColor lightGrayColor];
        typeLabel.frame =CGRectMake(20, 40*i+(self.view.frame.size.height-65), self.view.frame.size.width-40, 20);
        typeLabel.text = typeLabelNameArr[i];
        typeLabel.font = [UIFont systemFontOfSize:11.0f];
        [self.view addSubview:typeLabel];
    }
}

- (void)customsegmentedControlCellValueBeChanged:(UISegmentedControl *)segmentedControl {
    [self setChartModelWithIndex:segmentedControl.selectedSegmentIndex];
    [self refreshTheChartView];
}

- (void)refreshTheChartView {
    //    self.aaChartModel.colorsTheme = [self configureTheRandomColorArray];//random colors theme, Just for fun!!!
    [self.aaChartView aa_refreshChartWithChartModel:self.aaChartModel];
}

- (void)setUpTheSwitchs {
    UISwitch * switchView = [[UISwitch alloc]init];
    switchView.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height-105, 100, 20);
    switchView.onTintColor = [self colorWithHexString:@"#FFDEAD"];
    switchView.thumbTintColor = [UIColor whiteColor];
    switchView.on = NO;
    [switchView addTarget:self action:@selector(switchViewClicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switchView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 80, self.view.frame.size.height-100, 80, 20)];
    label.text = @"Stacking";
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor grayColor];
    [self.view addSubview:label];
}

- (void)switchViewClicked:(UISwitch *)switchView {
    self.aaChartModel.stacking = (switchView.on ? AAChartStackingTypeNormal : AAChartStackingTypeFalse);
    [self refreshTheChartView];
}

- (UIColor *) colorWithHexString: (NSString *)color {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


@end
