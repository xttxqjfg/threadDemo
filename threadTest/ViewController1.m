//
//  ViewController1.m
//  threadTest
//
//  Created by 易博 on 2017/3/20.
//  Copyright © 2017年 yb. All rights reserved.
//

#import "ViewController1.h"

@interface ViewController1 ()

@property (nonatomic,assign) int leftCont;

@property(nonatomic,strong) NSThread *thread1;
@property(nonatomic,strong) NSThread *thread2;
@property(nonatomic,strong) NSThread *thread3;

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    
    self.leftCont = 5;
    
    self.thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(sellTickets) object:nil];
    self.thread1.name = @"售票员A";
    
    self.thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(sellTickets) object:nil];
    self.thread2.name = @"售票员B";
    
    self.thread3 = [[NSThread alloc]initWithTarget:self selector:@selector(sellTickets) object:nil];
    self.thread3.name = @"售票员C";
    
    [self.thread1 start];
    [self.thread2 start];
    [self.thread3 start];
}

-(void)sellTickets
{
    while (1) {
        
        int count = self.leftCont;
        if (count > 0) {
            [NSThread sleepForTimeInterval:0.5];
            self.leftCont = count - 1;
            NSLog(@"%@--卖了一张票,还剩余%d张票",[[NSThread currentThread] name],self.leftCont);
        }
        if (self.leftCont == 0) {
            [NSThread exit];
        }
    }
}

-(void)setLeftCont:(int)leftCont
{
    @synchronized(self) {
        _leftCont = leftCont;
    };
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
