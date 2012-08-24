/*
 *  ECMacros.h
 *  ExpressCheckout
 *
 *  Header file with common macro definitions for the ECObject classes.
 */

//IMPORTANT: your class should include a private NSMutableDictionary called dataDict

//use this inside your @implementation to define a default init and dealloc method
//the init method creates dataDict (an NSMutableDictionary) and the dealloc method releases it
#define InitAndDealloc -(id)init { if (self = [super init]) { dataDict = [[NSMutableDictionary alloc] init]; } return self;}\
-(void)dealloc { [dataDict release]; [super dealloc]; }\
-(id)valueForUndefinedKey:(NSString *)key { return nil; }\
-(void)setValue:(id)value forKey:(NSString *)key {\
	NSObject *maybeArray = [self valueForKey:key];\
	if ([maybeArray isKindOfClass:[NSMutableArray class]]) {\
		[(NSMutableArray *)maybeArray addObject:value];\
	} else {\
		[dataDict setValue:value forKey:key];\
	}\
}


//define a getter and setter for a property using the given variable name and generating the given xml tag
#define GenericAccessor2(var, key, type) @dynamic var;\
-(void)set ## var:(type *)value { [dataDict setValue:value forKey:key]; }\
-(type *)var { return [dataDict valueForKey:key]; }

//define a getter and setter for a property whose variable name matches its xml tag
#define GenericAccessor1(var, type) GenericAccessor2(var, @#var, type)

//define a getter and setter for a property whose variable name, type, class, and xml tag all match
#define GenericAccessor(var) GenericAccessor1(var, var)

//define a getter and setter for a string property using the given variable name and generating the given xml tag
#define StringAccessor1(var, key) GenericAccessor2(var, key, NSString)

//define a getter and setter for a string property whose variable name matches its xml tag
#define StringAccessor(var) StringAccessor1(var, @#var)

//define a getter and setter for an array property using the given variable name and generating the given xml tag
#define ArrayAccessor1(var, key) GenericAccessor2(var, @#var, NSArray)

//define a getter and setter for an array property whose variable name matches its xml tag
#define ArrayAccessor(var) ArrayAccessor1(var, @#var)

//define a getter and setter for a boolean property using the given variable name and generating the given xml tag
#define BooleanAccessor1(var, key) @dynamic var;\
-(void)set ## var:(BOOL)value { [dataDict setValue:value ? @"true" : @"false" forKey:key]; }\
-(BOOL)var { return [@"true" isEqualToString:[dataDict valueForKey:key]]; }

//define a getter and setter for a boolean property whose variable name matches its xml tag
#define BooleanAccessor(var) BooleanAccessor1(var, @#var)

//define a getter and setter for a money amount property using the given variable name and generating the given xml tag
#define AmountAccessor1(var, key) @dynamic var;\
-(void)set ## var:(float)value { [dataDict setValue:[NSString stringWithFormat:@"%.2f", value] forKey:key]; }\
-(float)var { return [[dataDict valueForKey:key] floatValue]; }

//define a getter and setter for a money amount property whose variable name matches its xml tag
#define AmountAccessor(var) AmountAccessor1(var, @#var)

//define a getter and setter for a typedefined property using the given variable name and generating the given xml tag
#define TypedefAccessor1(var, key, type) @dynamic var;\
-(void)set ## var:(type)value { [dataDict setValue:[NSNumber numberWithInt:value] forKey:key]; }\
-(type)var { return (type)[[dataDict valueForKey:key] intValue]; }

//define a getter and setter for a typedefined property whose variable name matches its xml tag
#define TypedefAccessor(var, type) TypedefAccessor1(var, @#var, type)

//define a getter and setter for an integer property using the given variable name and generating the given xml tag
#define IntAccessor1(var, key) TypedefAccessor1(var, key, int)

//define a getter and setter for an integer property whose variable name matches its xml tag
#define IntAccessor(var) IntAccessor1(var, @#var)

//define a getter and "adder" for a mutable array property
#define MutableArrayAccessor2(var, key, type) @dynamic var;\
-(NSMutableArray *)var {\
	NSMutableArray *array = [dataDict valueForKey:key];\
	if (array == nil) {\
		array = [NSMutableArray array];\
		[dataDict setValue:array forKey:key];\
	}\
	return array;\
}\
-(void)add ## var:(type *)value {\
	[self.var addObject:value];\
}\
-(Class)classOf ## var {\
	return [type class];\
}

//define a getter and "adder" for a mutable array whose key matches its var
#define MutableArrayAccessor1(var, class) MutableArrayAccessor2(var, @#var, class)

//define a getter and "adder" for a mutable array whose class, key, and var all match
#define MutableArrayAccessor(var) MutableArrayAccessor1(var, var)

//define a getter and setter for an enum that gets converted to/from a string when communicating with server
#define EnumAccessor(var, type) @dynamic var;\
-(void)set ## var:(type)value {\
	if (value >= 0 && value < sizeof(type ## Strings)/sizeof(NSString *)) {\
		[dataDict setValue:type ## Strings[value] forKey:@#var];\
	}\
}\
-(type)var {\
	NSString *value = [dataDict valueForKey:@#var];\
	for (int i = 0; i < sizeof(type ## Strings)/sizeof(NSString *); i++) {\
		if ([type ## Strings[i] isEqualToString:value]) {\
			return i;\
		}\
	}\
	return -1;\
}
