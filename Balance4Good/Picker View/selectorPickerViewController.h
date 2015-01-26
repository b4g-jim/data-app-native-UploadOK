//For Drop down list  - There won't be any need to change these files.

#import <UIKit/UIKit.h>

@interface selectorPickerViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>
{
    IBOutlet UIPickerView* picker;
    NSArray *pickerSource;
    CGRect f;
    NSString *parentName;
    id parent;
    NSString *fieldToBeChangedValue;
}
- (id)initWithSource:(NSArray*)pSource parentName:(NSString*)pName parent:(id)p;
- (void)updateWithSource:(NSArray*)pSource parentName:(NSString*)pName parent:(id)p;
-(void)setPickerView:(CGRect)fr;
@end
