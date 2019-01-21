//
//  TableViewController.m
//  MessageFilter
//
//  Created by Yue on 2018/12/14.
//  Copyright © 2018 Yue. All rights reserved.
//

#import "TableViewController.h"
#import "MsgManage.h"

static NSString *const TableViewIdentify = @"TableViewReuseIdentifier";

@interface TableViewController ()

@property (copy, nonatomic) NSArray *dataArr;
@property (strong, nonatomic) UIView   *headView;
@property (strong, nonatomic) UILabel  *titleLabel;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *shareButton;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArr = [NSArray arrayWithArray:[MsgManage messageList]];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TableViewIdentify];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeActoin:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipe];
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ImportNotificationName" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf reloadTableView];
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat labelW = 150;
    CGFloat labelX = (self.view.bounds.size.width - labelW) / 2;
    _titleLabel.frame = CGRectMake(labelX, 0, labelW, 44);
    _backButton.frame = CGRectMake(10, 0, 44, 44);
    _shareButton.frame = CGRectMake(self.view.bounds.size.width - 54, 0, 44, 44);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ===== 点击事件 =====
- (void)backButtonClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareButtonClicked:(UIButton *)sender {
    NSArray *shareItems = @[[NSURL fileURLWithPath:[MsgManage filePath]]];
    UIActivityViewController *activityController=[[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    //iPad
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popController = [activityController popoverPresentationController];
        popController.barButtonItem = [self.navigationItem.rightBarButtonItems lastObject];
        [self presentViewController:activityController animated:YES completion:nil];
    }
    //iPhone
    else if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)swipeActoin:(UISwipeGestureRecognizer *)sender {
    [self backButtonClicked:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewIdentify forIndexPath:indexPath];
    if (_dataArr.count) {
        NSDictionary *msgDic = [_dataArr objectAtIndex:indexPath.row];
        NSString *msg = [msgDic valueForKey:@"text"];
        NSString *label = [msgDic valueForKey:@"label"];
        NSString *sign = [label isEqualToString:@"正常"] ? @"⧳" : @"⧲";
        cell.textLabel.text = [NSString stringWithFormat:@"%@　%@",sign,msg];
    }
    return cell;
}

- (void)reloadTableView {
    _titleLabel.text = [NSString stringWithFormat:@"%ld条消息",_dataArr.count];
    self.dataArr = [NSArray arrayWithArray:[MsgManage messageList]];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.view.frame.size.width == [UIScreen mainScreen].bounds.size.width) {
        return 44;
    }
    else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.view.frame.size.width == [UIScreen mainScreen].bounds.size.width) {
        return self.headView;
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_dataArr.count) {
        NSDictionary *msgDic = [_dataArr objectAtIndex:indexPath.row];
        NSString *msg = [msgDic valueForKey:@"text"];
        [self showAlertWithMessage:msg];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSDictionary *msgDic = [_dataArr objectAtIndex:indexPath.row];
        NSString *msg = [msgDic valueForKey:@"text"];
        [MsgManage deleteMessage:msg];
        self.dataArr = [NSArray arrayWithArray:[MsgManage messageList]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        _titleLabel.text = [NSString stringWithFormat:@"%ld条消息",_dataArr.count];
    }
}

#pragma mark - ===== 信息详情Alert =====
- (void)showAlertWithMessage:(NSString *)message {
    if (!message.length) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"信息" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"标记为【正常】" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MsgManage addMessage:message isFilted:NO];
        [self reloadTableView];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"标记为【过滤】" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MsgManage addMessage:message isFilted:YES];
        [self reloadTableView];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"删除这条信息" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [MsgManage deleteMessage:message];
        [self reloadTableView];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - ===== 懒加载 =====
- (UIView *)headView {
    if (!_headView) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        [view addSubview:self.backButton];
        [view addSubview:self.shareButton];
        [view addSubview:self.titleLabel];
        _headView = view;
    }
    return _headView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [UILabel new];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%ld条消息",_dataArr.count];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [UIFont systemFontOfSize:35];
        [button setTitle:@"⊗" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _backButton = button;
    }
    return _backButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [UIFont systemFontOfSize:35];
        [button setTitle:@"⤴︎" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _shareButton = button;
    }
    return _shareButton;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
