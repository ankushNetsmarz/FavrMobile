//
//  GroupNameAndDetailVC.m
//  Favr
//
//  Created by Ankush on 04/07/14.
//  Copyright (c) 2014 Netsmartz. All rights reserved.
//

#import "GroupNameAndDetailVC.h"

@interface GroupNameAndDetailVC ()

@end

@implementation GroupNameAndDetailVC
@synthesize groupMemberArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.groupImageViewObj.layer.cornerRadius = 62;
    self.groupImageViewObj.layer.masksToBounds = YES;
    
    rectGroup = self.groupInfoView.frame;
    NSLog(@"group member array %@", groupMemberArray);
    self.groupTitleTxtFld.delegate = self;
    self.GroupDescTxtView.delegate = self;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.groupTitleTxtFld.text = @"";
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.GroupDescTxtView.text = @"";
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect rect = self.groupInfoView.frame;
    rect.origin.y = rect.origin.y - 50;
    self.groupInfoView.frame = rect;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.groupInfoView.frame = rectGroup;
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect rect = self.groupInfoView.frame;
    rect.origin.y = rect.origin.y - 160;
    self.groupInfoView.frame = rect;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.groupInfoView.frame = rectGroup;
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    [textView resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createGroup:(UIBarButtonItem *)sender {
    
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    NSData *imagedata = UIImagePNGRepresentation(self.groupImageViewObj.image);
    NSString *encodedBase64Image = [imagedata base64Encoding];
    
    NSMutableDictionary *groupMemberIDs = [[NSMutableDictionary alloc] init];
    
    NSLog(@"%@", [[groupMemberArray objectAtIndex:0] objectAtIndex:0]);
    for (int i = 0; i < [[groupMemberArray objectAtIndex:0] count]; i++)
    {
//        [groupMemberIDs addObject:[[[groupMemberArray objectAtIndex:0] objectAtIndex:i] objectAtIndex:3]];
        [groupMemberIDs setObject:[[[groupMemberArray objectAtIndex:0] objectAtIndex:i] objectAtIndex:3] forKey:[[[groupMemberArray objectAtIndex:0] objectAtIndex:i] objectAtIndex:0]];
    }
    NSLog(@"group members %@", groupMemberIDs);
    NSString *groupAdmin = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    
    [PFCloud callFunctionInBackground:@"createGroup"
                       withParameters:@{
                                        @"grpDescription": self.GroupDescTxtView.text,
                                        @"grpName": self.groupTitleTxtFld.text,
                                        @"grpUser":groupMemberIDs,
                                        @"grpAdmin":groupAdmin,
                                        @"grpImage": encodedBase64Image
                                        }
                                block:^(NSString *results, NSError *error) {
                                    
                                    [hud hide:YES];
//                                    [self showStatus:@"Favr Created Successfully" timeout:5];
                                    
                                }];

    
}
- (IBAction)groupImageBtnAct:(UIButton *)sender {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.groupImageViewObj.image = image;
    //Or you can get the image url from AssetsLibrary
    //    NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)backBtnAct:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
