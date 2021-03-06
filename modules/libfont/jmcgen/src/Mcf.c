/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 2 -*-
 *
 * ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is mozilla.org code.
 *
 * The Initial Developer of the Original Code is
 * Netscape Communications Corporation.
 * Portions created by the Initial Developer are Copyright (C) 1998
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */
/*******************************************************************************
 * Source date: 9 Apr 1997 21:45:13 GMT
 * netscape/fonts/cf module C stub file
 * Generated by jmc version 1.8 -- DO NOT EDIT
 ******************************************************************************/

#include <stdlib.h>
#include <string.h>
#include "xp_mem.h"

/* Include the implementation-specific header: */
#include "Pcf.h"

/* Include other interface headers: */

/*******************************************************************************
 * cf Methods
 ******************************************************************************/

#ifndef OVERRIDE_cf_getInterface
JMC_PUBLIC_API(void*)
_cf_getInterface(struct cf* self, jint op, const JMCInterfaceID* iid, JMCException* *exc)
{
	if (memcmp(iid, &cf_ID, sizeof(JMCInterfaceID)) == 0)
		return cfImpl2cf(cf2cfImpl(self));
	return _cf_getBackwardCompatibleInterface(self, iid, exc);
}
#endif

#ifndef OVERRIDE_cf_addRef
JMC_PUBLIC_API(void)
_cf_addRef(struct cf* self, jint op, JMCException* *exc)
{
	cfImplHeader* impl = (cfImplHeader*)cf2cfImpl(self);
	impl->refcount++;
}
#endif

#ifndef OVERRIDE_cf_release
JMC_PUBLIC_API(void)
_cf_release(struct cf* self, jint op, JMCException* *exc)
{
	cfImplHeader* impl = (cfImplHeader*)cf2cfImpl(self);
	if (--impl->refcount == 0) {
		cf_finalize(self, exc);
	}
}
#endif

#ifndef OVERRIDE_cf_hashCode
JMC_PUBLIC_API(jint)
_cf_hashCode(struct cf* self, jint op, JMCException* *exc)
{
	return (jint)self;
}
#endif

#ifndef OVERRIDE_cf_equals
JMC_PUBLIC_API(jbool)
_cf_equals(struct cf* self, jint op, void* obj, JMCException* *exc)
{
	return self == obj;
}
#endif

#ifndef OVERRIDE_cf_clone
JMC_PUBLIC_API(void*)
_cf_clone(struct cf* self, jint op, JMCException* *exc)
{
	cfImpl* impl = cf2cfImpl(self);
	cfImpl* newImpl = (cfImpl*)malloc(sizeof(cfImpl));
	if (newImpl == NULL) return NULL;
	memcpy(newImpl, impl, sizeof(cfImpl));
	((cfImplHeader*)newImpl)->refcount = 1;
	return newImpl;
}
#endif

#ifndef OVERRIDE_cf_toString
JMC_PUBLIC_API(const char*)
_cf_toString(struct cf* self, jint op, JMCException* *exc)
{
	return NULL;
}
#endif

#ifndef OVERRIDE_cf_finalize
JMC_PUBLIC_API(void)
_cf_finalize(struct cf* self, jint op, JMCException* *exc)
{
	/* Override this method and add your own finalization here. */
	XP_FREEIF(self);
}
#endif

/*******************************************************************************
 * Jump Tables
 ******************************************************************************/

const struct cfInterface cfVtable = {
	_cf_getInterface,
	_cf_addRef,
	_cf_release,
	_cf_hashCode,
	_cf_equals,
	_cf_clone,
	_cf_toString,
	_cf_finalize,
	_cf_GetState,
	_cf_EnumerateSizes,
	_cf_GetRenderableFont,
	_cf_GetMatchInfo,
	_cf_GetRcMajorType,
	_cf_GetRcMinorType
};

/*******************************************************************************
 * Factory Operations
 ******************************************************************************/

JMC_PUBLIC_API(cf*)
cfFactory_Create(JMCException* *exception, struct nfrc* a)
{
	cfImplHeader* impl = (cfImplHeader*)XP_NEW_ZAP(cfImpl);
	cf* self;
	if (impl == NULL) {
		JMC_EXCEPTION(exception, JMCEXCEPTION_OUT_OF_MEMORY);
		return NULL;
	}
	self = cfImpl2cf(impl);
	impl->vtablecf = &cfVtable;
	impl->refcount = 1;
	_cf_init(self, exception, a);
	if (JMC_EXCEPTION_RETURNED(exception)) {
		XP_FREE(impl);
		return NULL;
	}
	return self;
}

