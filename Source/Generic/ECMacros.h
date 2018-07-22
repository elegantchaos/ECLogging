// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#ifndef EC_DEBUG
#ifndef EC_RELEASE
#error You must define either EC_DEBUG or EC_RELEASE in the project configuration.
#endif
#endif


#define ECUnused(v) (void)(v)

#if EC_DEBUG

#define ECCastTo(_class_, _expression_) ((_class_*)[ECAssertion assertObject:(_expression_)isOfClass:([_class_ class])])
#define ECSafeCastTo ECCastTo

#else

#define ECCastTo(_class_, _expression_) ((_class_*)(_expression_))
#define ECSafeCastTo(_class_, _expression_) ([_expression_ isKindOfClass:[_class_ class]] ? (_class_*)(_expression_) : nil)

#endif
