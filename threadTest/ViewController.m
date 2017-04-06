//
//  ViewController.m
//  threadTest
//
//  Created by 易博 on 2017/3/14.
//  Copyright © 2017年 yb. All rights reserved.
//

#import "ViewController.h"
#import <sys/time.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    //同步执行串行队列
//    NSLog(@"同步执行串行队列......");
//    [self performQueuesUseSync:[self creatSeriaQueue:@"sync.seroal.queue"]];
    
    //同步执行并行队列
//    NSLog(@"同步执行并行队列......");
//    [self performQueuesUseSync:[self creatConcurrentQueue:@"sync.concurrent.queue"]];
    
    //异步执行串行队列
//    NSLog(@"异步执行串行队列.......");
//    [self performQueuesUseAsync:[self creatSeriaQueue:@"async.seroal.queue"]];
    
    //异步执行并行队列
//    NSLog(@"异步执行并行队列.......");
//    [self performQueuesUseAsync:[self creatConcurrentQueue:@"sync.concurrent.queue"]];
    
    //任务组自动管理
//    [self performGroupQueue];
    
    //任务组手动管理
//    [self performGroupUseEnterAndLeave];
    
    //信号量同步锁
//    [self useSemaphoreLock];
    
    //循环执行
//    [self useDispatchApply];
    
    //暂停和重启队列
//    [self queueSuspendAndResume];
    
    //队列栅栏
    [self useBarrierAsync];
    
}

/**
 *  获取当前线程
 *
 *  @return return value description
 */
-(NSThread *)getCurrentThread
{
    return [NSThread currentThread];
}

/**
 *  当前线程休眠
 *
 *  @param timer timer description
 */
-(void)currentThreadSleep:(NSTimeInterval)timer
{
    [NSThread sleepForTimeInterval:timer];
}

/**
 *  获取主队列
 *
 *  @return return value description
 */
-(dispatch_queue_t)getMainQueue
{
    return dispatch_get_main_queue();
}

/**
 *  获取全局队列并指定优先级
 *
 *  @param priority priority description
 *
 *  @return return value description
 */
-(dispatch_queue_t)getGlobalQueue:(dispatch_queue_priority_t)priority
{
    return dispatch_get_global_queue(priority, 0);
}

/**
 *  创建并行队列
 *
 *  @param queueName queueName description
 *
 *  @return return value description
 */
-(dispatch_queue_t)creatConcurrentQueue:(NSString *)queueName
{
    return dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
}

/**
 *  创建串行队列
 *
 *  @param queueName queueName description
 *
 *  @return return value description
 */
-(dispatch_queue_t)creatSeriaQueue:(NSString *)queueName
{
    return dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
}

/**
 *  使用dispatch_sync在当前线程中执行队列
 *
 *  @param queue queue description
 */
-(void)performQueuesUseSync:(dispatch_queue_t)queue
{
    for(int i=0;i<5;i++)
    {
        dispatch_sync(queue, ^{
            [self currentThreadSleep:2];
            NSLog(@"当前执行的线程:%@",[self getCurrentThread]);
            NSLog(@"执行第%d个任务",i);
        });
        NSLog(@"执行第%d个任务完毕",i);
    }
    NSLog(@"所有队列任务使用同步方式执行完毕");
}

/**
 *  使用dispatch_async在当前线程中执行队列
 *
 *  @param queue queue description
 */
-(void)performQueuesUseAsync:(dispatch_queue_t)queue
{
    //串行队列
    dispatch_queue_t serialQueue = [self creatSeriaQueue:@"serialQueue"];
    for(int i=0;i<5;i++)
    {
        dispatch_async(queue, ^{
            [self currentThreadSleep:(arc4random()%3)];
            NSThread *currentThread = [self getCurrentThread];
            //同步锁
            dispatch_sync(serialQueue, ^{
                NSLog(@"sleep的线程:%@",currentThread);
                NSLog(@"当前输出内容的线程:%@",[self getCurrentThread]);
                NSLog(@"执行第%d个%@",i,queue);
            });
        });
        NSLog(@"第%d个任务添加完毕..",i);
    }
    NSLog(@"使用异步方式添加队列完毕..");
}

/**
 *  延时执行
 *
 *  @param time time description
 */
-(void)afterPerform:(double)time
{
    //dispatch_time用于计算相对时间，当设备睡眠时，dispatch_time也一起睡眠
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, time*NSEC_PER_SEC);
    dispatch_after(delayTime, [self getGlobalQueue:0], ^{
        NSLog(@"执行线程:%@\ndispatch_time:延迟秒%f执行",[self getCurrentThread],time);
    });
    
    //dispatch_walltime用于计算绝对时间，是根据挂钟来计算时间的，不会随着设备的睡眠而睡眠
    NSTimeInterval nowInterval = [NSDate alloc].timeIntervalSince1970;
    _STRUCT_TIMESPEC nowStruct;
    nowStruct.tv_sec = nowInterval;
    nowStruct.tv_nsec = 0;
    
    dispatch_time_t delayWalltime = dispatch_walltime(&nowStruct, time*NSEC_PER_SEC);
    dispatch_after(delayWalltime, [self getGlobalQueue:0], ^{
        NSLog(@"执行线程:%@\ndispatch_time:延迟秒%f执行",[self getCurrentThread],time);
    });
}

/**
 *  一组队列执行完毕之后再执行需要执行的任务，可以使用dispatch_group来执行队列
 */
-(void)performGroupQueue
{
    NSLog(@"任务组自动管理....");
    dispatch_queue_t concurrentQueue = [self creatConcurrentQueue:@"com.yb"];
    dispatch_group_t group = dispatch_group_create();
    
    //将group于queue进行管理，并且自动执行
    for(int i=0;i<5;i++)
    {
        dispatch_group_async(group, concurrentQueue, ^{
            [self currentThreadSleep:1];
            NSLog(@"任务%d执行完毕..",i);
        });
    }
    
    //队列组的都执行完毕后会进行通知
    dispatch_group_notify(group, [self getMainQueue], ^{
        NSLog(@"所有任务组执行完毕..");
    });
    
    NSLog(@"异步执行测试，不会阻塞当前进程...");
}

/**
 *  使用enter和leave手动管理group和queue
 */
-(void)performGroupUseEnterAndLeave
{
    NSLog(@"任务组手动管理...");
    dispatch_queue_t concurrentQueue = [self creatConcurrentQueue:@"com.yb"];
    dispatch_group_t group = dispatch_group_create();
    
    //将group和queue进行手动关联和管理，自动执行
    for(int i=0;i<5;i++)
    {
        //进入队列组
        dispatch_group_enter(group);
        
        dispatch_group_async(group, concurrentQueue, ^{
            [self currentThreadSleep:1];
            NSLog(@"任务%d执行完毕..",i);
            //离开队列组
            dispatch_group_leave(group);
        });
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"任务组执行完毕");
    
    dispatch_group_notify(group, concurrentQueue, ^{
        NSLog(@"手动管理的队列执行完毕...");
    });
}

/**
 *  信号量同步锁
 */
-(void)useSemaphoreLock
{
    dispatch_queue_t concurrentQueue = [self creatConcurrentQueue:@"com.yb"];
    
    //创建信号量
    dispatch_semaphore_t semaphoreLock = dispatch_semaphore_create(1);
    
    __block int testNum = 1;
    
    for (int i=0; i<5; i++) {
        dispatch_async(concurrentQueue, ^{
            //上锁
            dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
            
            testNum += 1;
            [self currentThreadSleep:1];
            NSLog(@"当前线程:%@",[self getCurrentThread]);
            NSLog(@"第%d次执行:testNum=%d",i,testNum);
            
            //开锁
            dispatch_semaphore_signal(semaphoreLock);
        });
    }
    NSLog(@"异步执行测试..");
}

/**
 *  循环执行
 */
-(void)useDispatchApply
{
    NSLog(@"循环多次执行并行队列..");
    dispatch_queue_t concurrentQueue = [self creatConcurrentQueue:@"com.yb"];
    
    //会阻塞当前线程，但是concurrentQueue队列会在新的线程中执行
    dispatch_apply(3, concurrentQueue, ^(size_t index) {
        [self currentThreadSleep:index];
        NSLog(@"第%zu次执行：%@",index,[self getCurrentThread]);
    });
    
    NSLog(@"循环多次执行串行队列");
    dispatch_queue_t serialQueue = [self creatSeriaQueue:@"com.yb"];
    
    //会阻塞当前线程，serialQueue队列在当前线程中执行
    dispatch_apply(3, serialQueue, ^(size_t index) {
        [self currentThreadSleep:index];
        NSLog(@"第%zu次执行：%@",index,[self getCurrentThread]);
    });
}

/**
 *  暂停和重启队列
 */
-(void)queueSuspendAndResume
{
    NSLog(@"暂停和重启队列...");
    dispatch_queue_t concurrentQueue = [self creatConcurrentQueue:@"com.yb"];
    
    //将队列进行挂起
    dispatch_suspend(concurrentQueue);
    
    dispatch_async(concurrentQueue, ^{
        NSLog(@"执行任务...");
    });
    
    [self currentThreadSleep:2];
    //将挂起的队列唤醒
    dispatch_resume(concurrentQueue);
}

/**
 *  队列栅栏
 */
-(void)useBarrierAsync
{
    NSLog(@"队列栅栏..");
    dispatch_queue_t concurrentQueue = [self creatConcurrentQueue:@"com.yb"];
    
    for (int i=0; i<5; i++) {
        dispatch_async(concurrentQueue, ^{
            [self currentThreadSleep:i];
            NSLog(@"第一批:%d,%@",i,[self getCurrentThread]);
        });
    }
    
    dispatch_barrier_async(concurrentQueue, ^{
        NSLog(@"第一批执行完毕之后才会执行第二批，%@",[self getCurrentThread]);
    });
    
    for (int i=0; i<5; i++) {
        dispatch_async(concurrentQueue, ^{
            [self currentThreadSleep:i];
            NSLog(@"第二批:%d,%@",i,[self getCurrentThread]);
        });
    }
    
    NSLog(@"异步执行测试..");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
