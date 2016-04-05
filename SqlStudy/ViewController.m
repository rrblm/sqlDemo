//
//  ViewController.m
//  SqlStudy
//
//  Created by GFENG on 16/1/28.
//  Copyright © 2016年 GFENG. All rights reserved.
//

#import "ViewController.h"
#import "AddViewController.h"
#import "ChangeViewController.h"
#import "FMDB.h"

#import "TestProtocol.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating>

@property (nonatomic,strong) NSMutableArray *nameAry;

@property (nonatomic,strong) NSMutableArray *timeAry;

@property (nonatomic,strong) NSString *dbPath;

@property (nonatomic,weak) UITableView *table;

@property (nonatomic,assign) NSInteger count;

@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,strong) UISearchController *search;

@end

static NSString * const reuseId = @"cellid";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TestProtocol *test = [[TestProtocol alloc]init];
    [test testProtocol];
    
    
    self.nameAry = [NSMutableArray array];
    self.timeAry = [NSMutableArray array];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(order)];
    
    UITableView *table = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table.rowHeight = 50;
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [UIView new];
    [self.view addSubview:table];
    self.table = table;
    
    self.search = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.search.searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40);
    self.search.searchResultsUpdater = self;
    self.search.dimsBackgroundDuringPresentation = NO;
    self.table.tableHeaderView = self.search.searchBar;
    
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.dbPath = [NSString stringWithFormat:@"%@/person.sqlite",docPath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:self.dbPath]==NO) {
        // 创建数据库
        FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
        if ([db open]) {
            // 创建Users表
            [db executeUpdate:@"CREATE TABLE Users (username VARCHAR(30) ,time VARCHAR(30))"];
        }
        
        [db close];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateData];
}


-(void)updateData{
    [self.nameAry removeAllObjects];
    [self.timeAry removeAllObjects];
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    FMResultSet *set = [db executeQuery:@"SELECT * FROM Users"];
    while ([set next]) {
        [self.nameAry addObject:[set stringForColumn:@"username"]];
        [self.timeAry addObject:[set stringForColumn:@"time"]];
    }
    [db close];
    if (self.nameAry.count==self.count-1) {
        [self.table deleteRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [self.table reloadData];
    }
    self.count = self.nameAry.count;
}

#pragma mark 添加数据
-(void)add{
    AddViewController *VC = [[AddViewController alloc]init];
    VC.dbPath = self.dbPath;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
    [self presentViewController:nav animated:YES completion:NULL];
}


#pragma mark 排序
-(void)order{
    
    static BOOL isOrder = NO;
    
    if (isOrder) {
        [self updateData];
        isOrder = NO;
        return;
    }
    
    [self.nameAry removeAllObjects];
    [self.timeAry removeAllObjects];
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    
    NSString *sql = @"SELECT * FROM Users ORDER BY username";   //升序
    //NSString *sql = @"SELECT * FROM Users ORDER BY username DESC";  //降序
    FMResultSet *set = [db executeQuery:sql];
    while ([set next]) {
        [self.nameAry addObject:[set stringForColumn:@"username"]];
        [self.timeAry addObject:[set stringForColumn:@"time"]];
    }
    
    [db close];
    
    [self.table reloadData];
    
    isOrder = YES;
}

#pragma mark  查找数据
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Users WHERE username LIKE '\%%\%@\%%\'",searchController.searchBar.text];
    
    [self.nameAry removeAllObjects];
    [self.timeAry removeAllObjects];
    
    FMResultSet *set = [db executeQuery:sql];
    while ([set next]) {
        
        [self.nameAry addObject:[set stringForColumn:@"username"]];
        [self.timeAry addObject:[set stringForColumn:@"time"]];
        
    }
    
    
    [db close];
    
    [self.table reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.nameAry.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.f];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.textLabel.text = self.nameAry[indexPath.row];
    cell.detailTextLabel.text = self.timeAry[indexPath.row];
}

#pragma mark 删除数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    self.indexPath = indexPath;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
        [db open];
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM Users WHERE username='%@'",self.nameAry[indexPath.row]];
        
        [db executeUpdate:sql];
        
        [db close];
        
        
        [self updateData];
    }
}

#pragma mark 修改数据
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ChangeViewController *VC = [[ChangeViewController alloc]init];
    VC.name = self.nameAry[indexPath.row];
    VC.dbPath = self.dbPath;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
