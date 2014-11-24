//
//  ViewController.m
//

#import "ViewController.h"
#import "STTwitter.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *twitterFeed;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic,retain) CLLocationManager *locationManager;
 
@property (nonatomic, strong) NSArray *results;

@end
NSString * const termToSearch = @"samsung";

@implementation ViewController

- (NSString *)deviceLocation
{
    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    return theLocation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"xz9ew8UZ6rz8TW3QBSDYg"
                                                            consumerSecret:@"rm8grg0aIPCUnTpgC5H1NMt4uWYUVXKPqH8brIqD4o"];
   
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locationManager startUpdatingLocation];
    
    //users current location
    float userLatitude =   self.locationManager.location.coordinate.latitude;
    float userLongitude =   self.locationManager.location.coordinate.longitude;
    
    NSLog(@" lat: %f",userLatitude);
    NSLog(@" lon: %f",userLongitude);
    
    NSString *geoCode = [NSString stringWithFormat:@"%f,%f,1mi", userLatitude, userLongitude];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        [twitter getSearchTweetsWithQuery:termToSearch
                                  geocode:geoCode
                                     lang:nil
                                   locale:nil
                               resultType:nil
                                    count:@"100"
                                    until:nil
                                  sinceID:nil
                                    maxID:nil
                          includeEntities:nil
                                 callback:nil
                             successBlock: ^(NSDictionary *searchMetaData, NSArray *status){
                                 self.results = status;
                                 NSString *user;
                                 NSString *comment;
                                 NSString *img;
                                 NSString *date;
                                 for (NSDictionary *twit in self.results) {
                                     
                                     self.twitterFeed = [NSMutableArray arrayWithArray:status];
                                     
                                     [self.tableView reloadData];
                                     
                                     
                                     user = [twit valueForKeyPath:@"user.screen_name"];
                                     comment = [twit valueForKey:@"text"];
                                     img = [twit valueForKeyPath:@"user.profile_image_url"];
                                     date = [twit valueForKey:@"created_at"];
                                     
                                     NSLog(@"User: %@ ",user);
                                     NSLog(@"Comentario: %@",comment);
                                     NSLog(@"Data: %@",date);
                                     NSLog(@"ImgUserProfile: %@",img);
                                     NSLog(@"\n\n");
                                 }
                             } errorBlock:^(NSError *error) {
                                 NSLog(@"Error1");
                             }
         ];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error2");
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.twitterFeed.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID =  @"CellID" ;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSInteger idx = indexPath.row;
    NSDictionary *t = self.twitterFeed[idx];
    
    cell.textLabel.text = t[@"text"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
