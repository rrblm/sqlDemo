//
//  ChangeViewController.m
//  SqlStudy
//
//  Created by GFENG on 16/1/28.
//  Copyright © 2016年 GFENG. All rights reserved.
//

#import "ChangeViewController.h"
#import "FMDatabase.h"

@interface ChangeViewController ()

@property (nonatomic,weak) UITextField *tf;

@end

@implementation ChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"修改数据";
    
    UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(50, 100, 200, 50)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.text = self.name;
    [self.view addSubview:tf];
    self.tf = tf;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(50, 250, 200, 50);
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn setTitle:@"修改" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)save{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE Users SET username='%@' , time='%@' WHERE username='%@'",self.tf.text,dateStr,self.name];
    
    
    [db executeUpdate:sql];
    
    [db close];
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
