@interface SmoothLine : UIView<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIPopoverController* imagePopoverController;
    UIImagePickerController* imagePC;
}
@property (retain) UIColor* currentColor;
@property float currentSize;
@property (retain) UIImage* pickedImage;
@property (retain) UIImage* screenImage;
@property (retain) NSMutableArray* arrayStrokes;
@property (retain) NSMutableArray* arrayAbandonedStrokes;


-(void) setColor:(UIColor*)theColor;
-(void) viewJustLoaded;
-(void)undo;
-(void)redo;
-(void)clearCanvas;
@end
