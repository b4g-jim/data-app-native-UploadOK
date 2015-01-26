
#import "selectorPickerViewController.h"

@interface selectorPickerViewController ()

@end

@implementation selectorPickerViewController

- (id)initWithSource:(NSArray*)pSource parentName:(NSString*)pName parent:(id)p
{
    self = [super initWithNibName:@"selectorPickerViewController" bundle:nil];
    if (self) {
        pickerSource = [NSArray arrayWithArray:pSource];
        parentName = pName;
        parent = p;
        // Custom initialization
    }
    return self;
}


- (void)updateWithSource:(NSArray*)pSource parentName:(NSString*)pName parent:(id)p
{
    pickerSource = [NSArray arrayWithArray:pSource];
    parentName = pName;
    parent = p;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerSource count];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerSource objectAtIndex:row];
}

-(void)setPickerView:(CGRect)fr
{
//    [self setframe:f];
    int rowNumber=0;
    
    @try
    {
        NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:parentName];
    
         [picker selectRow:[value intValue] inComponent:0 animated:NO];
    }
    @catch (NSException *e) {
        
    }
       
}
-(void)setframe:(CGRect)ff
{
    [picker setFrame:ff];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecieved)];
    [tapRecognizer setNumberOfTapsRequired:1];
    
    [self.view setGestureRecognizers:[NSArray arrayWithObject:tapRecognizer]];

    
    [self setPickerView:f];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",row] forKey:parentName];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [parent update];

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
}

-(void)tapRecieved
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if([parent respondsToSelector:@selector(selectionDone)])
    {
        [parent performSelector:@selector(selectionDone)];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
