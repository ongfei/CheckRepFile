//
//  ViewController.m
//  CheckRepFile
//
//  Created by ongfei on 2019/5/31.
//  Copyright © 2019 ongfei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak) IBOutlet NSButton *selectBtn;
@property (weak) IBOutlet NSTextField *pathText;
@property (weak) IBOutlet NSButton *searchBtn;
@property (nonatomic, strong) NSMutableArray *allFiles;
@property (nonatomic, strong) NSMutableArray *repetArr;
@property (nonatomic, strong) NSMutableArray *ignoreFilesArr;
@property (nonatomic, strong) NSMutableArray *ignoreFoldsArr;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (unsafe_unretained) IBOutlet NSTextView *ResultView;
@property (weak) IBOutlet NSButton *checkBtn;
@property (unsafe_unretained) IBOutlet NSTextView *repetTextView;
@property (nonatomic, assign) NSInteger repetCount;
@property (weak) IBOutlet NSTextField *ignoreField;
@property (weak) IBOutlet NSTextField *ignoreFolder;
@end

@implementation ViewController

- (IBAction)selectAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles:NO];
    
    [panel setCanChooseDirectories:YES];
    
//    [panel setAllowsMultipleSelection:YES];  //多选
    
    NSInteger finded = [panel runModal];
    
    if (finded == NSFileHandlingPanelOKButton) {
 
        for (NSURL *url in [panel URLs]) {
            self.pathText.stringValue = url.path;
        }
    }
}

- (IBAction)searchClick:(id)sender {
    if ([self.checkBtn state] == NSControlStateValueOff) {    
        [self.allFiles removeAllObjects];
    }
    [self.repetArr removeAllObjects];
    self.repetCount = 0;
    self.repetTextView.string = [NSString stringWithFormat:@"重复文件：0个"];
    
    [self traverseFilesWithPath:self.pathText.stringValue];
}

- (void)traverseFilesWithPath:(NSString *)filePath {
    
    NSArray *contens = [self.fileManager contentsOfDirectoryAtPath:filePath error:nil];
    for (id element in contens) {
       
        NSString *path = [filePath stringByAppendingPathComponent:element];
        BOOL isDir = NO;
        [self.fileManager fileExistsAtPath:path isDirectory:&isDir];
        if (isDir) {
            BOOL ignore = YES;
            for (NSString *suffix in self.ignoreFoldsArr) {
                if ([element hasSuffix:suffix]) {
                    ignore = NO;
                }
            }
            if (ignore) {
                [self traverseFilesWithPath:path];
            }
        }else{
            if (![element isEqualToString:@".DS_Store"]) {
                if ([self.allFiles containsObject:element] && ![self.ignoreFilesArr containsObject:element]) {

                    self.repetCount += 1;
                    NSString *repetLog = [NSString stringWithFormat:@"重复文件：%@ \n 地址：%@",element,filePath];
                    
                    [self.repetArr addObject:repetLog];
                    NSString *repetStr = [self.repetArr componentsJoinedByString:@"\n"];
                    self.repetTextView.string = [NSString stringWithFormat:@"重复文件：%ld个 \n %@",self.repetCount,repetStr];
                }else {
                    
                    [self.allFiles addObject:element];
                    [self.searchBtn setTitle:[NSString stringWithFormat:@"开始查找 已查找(%ld)",self.allFiles.count]];
                }
            }  
        }
        NSString *str = [self.allFiles componentsJoinedByString:@"\n"];
        [self.ResultView setString:str];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.allFiles = [NSMutableArray array];
    self.repetArr = [NSMutableArray array];
}


- (NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (NSMutableArray *)ignoreFilesArr {
    _ignoreFilesArr = [NSMutableArray array];
    if (self.ignoreField.stringValue.length == 0) {
        [_ignoreFilesArr addObjectsFromArray:[@"Contents.json,Info.plist,project.pbxproj,xcschememanagement.plist,README.md,LICENSE" componentsSeparatedByString:@","]];
    }else {
        [_ignoreFilesArr addObjectsFromArray:[self.ignoreField.stringValue componentsSeparatedByString:@","]];
    }
    return _ignoreFilesArr;
}

- (NSMutableArray *)ignoreFoldsArr {
    _ignoreFoldsArr = [NSMutableArray array];
    NSArray *tempArr;
    if (self.ignoreFolder.stringValue.length == 0) {
        tempArr = [@"*.framework,*Headers,*.bundle" componentsSeparatedByString:@","];
    }else {
        tempArr = [self.ignoreFolder.stringValue componentsSeparatedByString:@","];
    }
    for (NSString *str in tempArr) {
        [str hasPrefix:@"*"];
        [_ignoreFoldsArr addObject:[str stringByReplacingOccurrencesOfString:@"*" withString:@""]];
    }
    return _ignoreFoldsArr;
}

@end
