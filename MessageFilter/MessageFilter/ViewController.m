//
//  ViewController.m
//  MessageFilter
//
//  Created by Yue on 2018/12/13.
//  Copyright © 2018 Yue. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"
#import "MsgManage.h"


@interface ViewController ()<UITextViewDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextView *inputTextView;
@property (strong, nonatomic) UIButton *pasteButton;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) UIView   *moreView;
@property (strong, nonatomic) UIButton *moreButton;
@property (strong, nonatomic) TableViewController *tableVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.inputTextView];
    [_inputTextView addSubview:self.pasteButton];
    [self.view addSubview:self.leftButton];
    [self.view addSubview:self.rightButton];
    
    [self.view addSubview:self.moreView];
    [self.moreView addSubview:self.moreButton];
    
    self.tableVC = [[TableViewController alloc] init];
    [self addChildViewController:_tableVC];
    [self.moreView addSubview:_tableVC.view];
    [_tableVC didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableVC reloadTableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat margin = 20 + ((SCREEN_WIDTH > SCREEN_HEIGHT) ? 20 : 0);
    CGFloat width = SCREEN_WIDTH - 2*margin;
    
    _titleLabel.frame = CGRectMake(margin, StatusBarHeight, width, 50);
    CGFloat titleBottom = [self bottomOfView:_titleLabel];
    
    CGFloat inputHeight = SCREEN_HEIGHT/2.5;
    _inputTextView.frame = CGRectMake(margin, titleBottom + 8, width, inputHeight);
    CGFloat inputBottom = [self bottomOfView:_inputTextView];
    
    _pasteButton.frame = CGRectMake(10, 5, 70, 30);
    
    CGFloat buttonW = _inputTextView.frame.size.width / 2;
    _leftButton.frame = CGRectMake(margin, inputBottom, buttonW, 44);
    _rightButton.frame = CGRectMake(margin + buttonW, inputBottom, buttonW, 44);
    CGFloat buttonBottom = [self bottomOfView:_leftButton];
    
    CGFloat moreViewTop = buttonBottom + 10;
    CGFloat moreViewH = SCREEN_HEIGHT - moreViewTop;
    _moreView.frame = CGRectMake(margin, moreViewTop, width, moreViewH + 44);
    _moreButton.frame = CGRectMake(0, 0, width, 44);
    _tableVC.view.frame = CGRectMake(0, 44, width, moreViewH - 44);
}

- (CGFloat)bottomOfView:(UIView *)view {
    return view.frame.origin.y + view.frame.size.height;
}

#pragma mark - ===== 点击事件 =====
- (void)pasteButtonDidClicked:(UIButton *)sender {
    NSString *pasteboardStr = [UIPasteboard generalPasteboard].string;
    if (pasteboardStr.length) {
        _inputTextView.text = pasteboardStr;
        sender.hidden = YES;
    }
}

- (void)leftButtonDidClicked:(UIButton *)sender {
    [self addMessage:_inputTextView.text isFiltered:NO];
}
- (void)rightButtonDidClicked:(UIButton *)sender {
    [self addMessage:_inputTextView.text isFiltered:YES];
}

- (void)addMessage:(NSString *)message isFiltered:(BOOL)isFiltered {
    _inputTextView.text = nil;
    [_inputTextView resignFirstResponder];
    _pasteButton.hidden = NO;
    if (message.length) {
        [MsgManage addMessage:message isFilted:isFiltered];
    }
    [self.tableVC reloadTableView];
}

- (void)moreButtonDidClicked:(UIButton *)sender {
    TableViewController *tableVC = [[TableViewController alloc] init];
    [self presentViewController:tableVC animated:YES completion:nil];
}

#pragma mark - ===== UITextViewDelegate =====
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(nonnull NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _pasteButton.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _pasteButton.hidden = textView.text.length ? YES : NO;
}

#pragma mark - ===== 懒加载 =====
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [UILabel new];
        label.text = @"增加语料库";
        label.font = [UIFont boldSystemFontOfSize:24];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        UITextView *textView = [UITextView new];
        textView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
        textView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
        textView.delegate = self;
        textView.returnKeyType = UIReturnKeyDone;
        textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textView.layer.cornerRadius = 8;
        textView.layer.borderWidth = 1;
        textView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        textView.font = [UIFont systemFontOfSize:17];
        _inputTextView = textView;
    }
    return _inputTextView;
}

- (UIButton *)pasteButton {
    if (!_pasteButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.layer.cornerRadius = 8;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = button.titleLabel.textColor.CGColor;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitle:@"粘贴" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pasteButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        _pasteButton = button;
    }
    return _pasteButton;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        [button setTitle:@"标记为【正常】" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(leftButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        _leftButton = button;
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        [button setTitle:@"标记为【过滤】" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(rightButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        _rightButton = button;
    }
    return _rightButton;
}

- (UIView *)moreView {
    if (!_moreView) {
        UIView *view = [UIView new];
        view.layer.borderWidth = 1;
        view.layer.cornerRadius = 44;
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
        view.layer.masksToBounds = YES;
        _moreView = view;
    }
    return _moreView;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleEdgeInsets = UIEdgeInsetsMake(-35, 0, 0, 0);
        button.titleLabel.font = [UIFont boldSystemFontOfSize:60];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitle:@"︿" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(moreButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        _moreButton = button;
    }
    return _moreButton;
}

@end
