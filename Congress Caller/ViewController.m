//
//  ViewController.m
//  Congress Caller
//
//  Created by Christopher Brandow on 11/18/16.
//  Copyright © 2016 Personal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *dataSourceArray;
@property (weak, nonatomic) IBOutlet UILabel *issueLabel;
@property (weak, nonatomic) IBOutlet UILabel *scriptLabel;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSAssert(self.tableView != nil, @"D'Oh!! you forgot to hook up IBOutlet");
    NSAssert(self.tableView.delegate != nil, @"D'Oh!! you forgot to hook up delegate");
    NSAssert(self.tableView.dataSource != nil, @"D'Oh!! you forgot to hook up datasource");

    [self updateContactsWithCompletion];
    [self updateAlertWithCompletion];
}

- (void)updateContactsWithCompletion //TODO: completionBlock and location && genericize the session setup
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:@"https://congress.api.sunlightfoundation.com/legislators/locate?latitude=34.147358&longitude=-118.149118"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];

    [[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *reps = results[@"results"];

            for (NSDictionary *rep in reps) {
                NSLog(@"name: %@. %@ %@ - %@", rep[@"title"], rep[@"first_name"], rep[@"last_name"], rep[@"phone"]);
            }
            self.dataSourceArray = [reps copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }] resume];

}

- (void)updateAlertWithCompletion //TODO: completionBlock and location && genericize the session setup
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:@"https://api.myjson.com/bins/3ir1e"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];

    [[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"results json: %@", results);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scriptLabel.text = results[@"script"];
                self.issueLabel.text = results[@"issue_description"];
            });
        }
    }] resume];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    NSDictionary *entry = self.dataSourceArray[indexPath.row];
    NSString *string = [NSString stringWithFormat:@"%@ %@ -- %@", entry[@"first_name"] ?: @"", entry[@"last_name"] ?: @"", entry[@"title"] ?: @""];
    cell.detailTextLabel.text =  entry[@"phone"] ?: @"";
    cell.textLabel.text = string;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *phoneNumber = self.dataSourceArray[indexPath.row][@"phone"];
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumber]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];

    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:nil];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [[UIApplication sharedApplication] openURL:phoneFallbackUrl options:@{} completionHandler:nil];
    } else {

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)dataSourceArray
{
    return _dataSourceArray ?: @[@{@"first_name" : @"one"}];
}

@end
