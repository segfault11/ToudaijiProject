//
//  ViewController.m
//  CoreLocationDemo
//
//  Created by Arno in Wolde Lübke on 28.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic, strong) CoreLocationController* locationController;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locLabel.text = @"HelloWorld!";
    self.locationController = [[CoreLocationController alloc] initWithLabel:locLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
