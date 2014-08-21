//
//  Macro.h
//  Chattar
//
//  Created by IgorKh on 8/2/12.
//
//

#define QB_SERIALIZE_OBJECT(var_name, coder)		[coder encodeObject:var_name forKey:@#var_name]
#define QB_SERIALIZE_INTEGER(var_name, coder)	    [coder encodeInteger:var_name forKey:@#var_name]
#define QB_SERIALIZE_INT(var_name, coder)	        [coder encodeInt:var_name forKey:@#var_name]
#define QB_SERIALIZE_FLOAT(var_name, coder)		    [coder encodeFloat:var_name forKey:@#var_name]
#define QB_SERIALIZE_DOUBLE(var_name, coder)		[coder encodeDouble:var_name forKey:@#var_name]
#define QB_SERIALIZE_BOOL(var_name, coder)			[coder encodeBool:var_name forKey:@#var_name]

#define QB_DESERIALIZE_OBJECT(var_name, decoder)	var_name = [[decoder decodeObjectForKey:@#var_name] retain]
#define QB_DESERIALIZE_INTEGER(var_name, decoder)	var_name = [decoder decodeIntegerForKey:@#var_name]
#define QB_DESERIALIZE_INT(var_name, decoder)	    var_name = [decoder decodeIntForKey:@#var_name]
#define QB_DESERIALIZE_FLOAT(var_name, decoder)	    var_name = [decoder decodeFloatForKey:@#var_name]
#define QB_DESERIALIZE_DOUBLE(var_name, decoder)	var_name = [decoder decodeDoubleForKey:@#var_name]
#define QB_DESERIALIZE_BOOL(var_name, decoder)		var_name = [decoder decodeBoolForKey:@#var_name]

#define QB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)