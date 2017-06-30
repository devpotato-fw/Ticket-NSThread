//
//  ViewController.m
//  Ticket(NSThread)
//
//  Created by wangfang on 2017/3/2.
//  Copyright © 2017年 onefboy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (assign, nonatomic) NSUInteger ticketCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 先监听线程退出的通知，以便知道线程什么时候退出
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(threadExitNotice)
                                                 name:NSThreadWillExitNotification
                                               object:nil];
    
    _ticketCount = 50;
    
    // 新建两个子线程（代表两个窗口同时销售门票）
    NSThread *window1 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
    window1.name = @"北京售票窗口";
    [window1 start];
    
    NSThread *window2 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
    window2.name = @"广州售票窗口";
    [window2 start];
}

- (void)threadExitNotice {

    NSLog(@"---%@", [NSThread currentThread]);
}

// 线程启动后，执行saleTicket，执行完毕后就会退出，为了模拟持续售票的过程，我们需要给它加一个循环
- (void)saleTicket {
    while (1) {
        // 添加同步锁
        @synchronized(self) {
            //如果还有票，继续售卖
            if (_ticketCount > 0) {
                _ticketCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", _ticketCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
            }
            //如果已卖完，关闭售票窗口
            else {
                break;
            }
        }
    }
}

/* 
 我们注意到，线程启动后，执行saleTicket完毕后就马上退出了，
 怎样能让线程一直运行呢（窗口一直开放，可以随时指派其卖演唱会的门票的任务），
 答案就是给线程加上runLoop
 */
- (void)test {

    // 新建两个子线程（代表两个窗口同时销售门票）
    NSThread * window1 = [[NSThread alloc]initWithTarget:self selector:@selector(thread1) object:nil];
    [window1 start];
    
    NSThread * window2 = [[NSThread alloc]initWithTarget:self selector:@selector(thread2) object:nil];
    [window2 start];
    
    // 然后就可以指派任务给线程了，这里我们让两个线程都执行相同的任务（售票）
    [self performSelector:@selector(saleTicket2) onThread:window1 withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(saleTicket2) onThread:window2 withObject:nil waitUntilDone:NO];
}

// 接着我们给线程创建一个runLoop，runLoop不需要手动创建，只需要在当前线程中获取runLoop对象即可。
- (void)thread1 {
    [NSThread currentThread].name = @"北京售票窗口";
    NSRunLoop * runLoop1 = [NSRunLoop currentRunLoop];
    [runLoop1 runUntilDate:[NSDate date]]; //一直运行
}

- (void)thread2 {
    [NSThread currentThread].name = @"广州售票窗口";
    NSRunLoop * runLoop2 = [NSRunLoop currentRunLoop];
    [runLoop2 runMode:NSDefaultRunLoopMode
           beforeDate:[NSDate dateWithTimeIntervalSinceNow:10.0]]; //自定义运行时间
}

- (void)saleTicket2 {
    while (1) {
        @synchronized(self) {
            //如果还有票，继续售卖
            if (_ticketCount > 0) {
                _ticketCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", _ticketCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
            } else {//如果已卖完，关闭售票窗口
                if ([NSThread currentThread].isCancelled) {
                    break;
                }else {
                    NSLog(@"售卖完毕");
                    //给当前线程标记为取消状态
                    [[NSThread currentThread] cancel];
                    //停止当前线程的runLoop
                    CFRunLoopStop(CFRunLoopGetCurrent());
                }
            }
        }
    }
}

@end
