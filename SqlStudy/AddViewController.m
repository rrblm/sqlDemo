//
//  AddViewController.m
//  SqlStudy
//
//  Created by GFENG on 16/1/28.
//  Copyright © 2016年 GFENG. All rights reserved.
//

#import "AddViewController.h"
#import "FMDB.h"

@interface AddViewController ()

@property (weak, nonatomic) IBOutlet UITextField *text;

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新增数据";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backToVc)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)backToVc{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)done{
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO Users(username,time) VALUES ('%@','%@')",self.text.text,dateStr];
        
    [db executeUpdate:sql];
    
    [db close];
    
    
    [self backToVc];
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
