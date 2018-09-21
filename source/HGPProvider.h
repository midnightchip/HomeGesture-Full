#include <CSPreferences/CSPreferencesProvider.h>
#define prefs [HGPProvider sharedProvider]

@interface HGPProvider : NSObject

+ (CSPreferencesProvider *)sharedProvider;

@end