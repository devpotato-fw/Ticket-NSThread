NSThread是基于线程使用，轻量级的多线程编程方法（相对GCD和NSOperation），一个NSThread对象代表一个线程，需要手动管理线程的生命周期，处理线程同步等问题。

方法一：
1、NSThread初始化线程（实例方法）:动态方法返回一个新的thread对象，需要调用start方法来启动线程。
NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(downloadImage:) object:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];

参数的意义：
* selector ：线程执行的方法，这个selector只能有一个参数，而且不能有返回值。
* target ：selector消息发送的对象
* object ：传输给target的唯一参数，也可以是nil

2、设置线程的优先级(0.0 - 1.0，1.0最高级)，可以不用设置默认是NSQualityOfServiceDefault
thread.threadPriority = NSQualityOfServiceUserInteractive;
参数的意义：
* NSQualityOfServiceUserInteractive：最高优先级，用于用户交互事件
* NSQualityOfServiceUserInitiated：次高优先级，用于用户需要马上执行的事件
* NSQualityOfServiceDefault：默认优先级，主线程和没有设置优先级的线程都默认为这个优先级
* NSQualityOfServiceUtility：普通优先级，用于普通任务
* NSQualityOfServiceBackground：最低优先级，用于不重要的任务

3、开启线程，执行下载图片方法
[thread start];

// 下载图片方法
-(void)downloadImage:(NSString *)url
{
NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
UIImage *image = [[UIImage alloc]initWithData:data];
if(image)
{
// 线程下载完图片后通知主线程更新界面
[self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];
}
}

-(void)updateUI:(UIImage*)image
{
self.imageView.image = image;
}  
方法二：
NSThread初始化线程（类方法）:会马上创建并开启新线程
[NSThread detachNewThreadSelector:@selector(downloadImage:) toTarget:self withObject:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
方法三：
使用 NSObject 的方法，隐式创建线程的方法
[self performSelectorInBackground:@selector(downloadImage:) withObject:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
补充：
取消线程
- (void)cancel;

启动线程
- (void)start;

判断某个线程的状态的属性
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished) BOOL finished;
@property (readonly, getter=isCancelled) BOOL cancelled;

设置和获取线程名字
-(void)setName:(NSString *)n;
-(NSString *)name;

获取当前线程信息
+ (NSThread *)currentThread;

获取主线程信息
+ (NSThread *)mainThread;

使当前线程暂停一段时间，或者暂停到某个时刻
+ (void)sleepForTimeInterval:(NSTimeInterval)time;
+ (void)sleepUntilDate:(NSDate *)date;

在指定线程上执行操作
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait NS_AVAILABLE(10_5, 2_0);

在主线程上执行操作
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait;

在当前线程执行操作
- (id)performSelector:(SEL)aSelector withObject:(id)object;

线程同步
* 线程和其他线程可能会共享一些资源，当多个线程同时读写同一份共享资源的时候，可能会引起冲突。线程同步是指是指在一定的时间内只允许某一个线程访问某个资源
* iOS实现线程加锁有NSLock和@synchronized两种方式
