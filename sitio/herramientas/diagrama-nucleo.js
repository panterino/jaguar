(function dartProgram(){function copyProperties(a,b){var t=Object.keys(a)
for(var s=0;s<t.length;s++){var r=t[s]
b[r]=a[r]}}function mixinPropertiesHard(a,b){var t=Object.keys(a)
for(var s=0;s<t.length;s++){var r=t[s]
if(!b.hasOwnProperty(r)){b[r]=a[r]}}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var t=function(){}
t.prototype={p:{}}
var s=new t()
if(!(Object.getPrototypeOf(s)&&Object.getPrototypeOf(s).p===t.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var r=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(r))return true}}catch(q){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){Object.setPrototypeOf(a.prototype,b.prototype)
return}var t=Object.create(b.prototype)
copyProperties(a.prototype,t)
a.prototype=t}}function inheritMany(a,b){for(var t=0;t<b.length;t++){inherit(b[t],a)}}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazy(a,b,c,d){var t=a
a[b]=t
a[c]=function(){if(a[b]===t){a[b]=d()}a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var t=a
a[b]=t
a[c]=function(){if(a[b]===t){var s=d()
if(a[b]!==t){A.hS(b)}a[b]=s}var r=a[b]
a[c]=function(){return r}
return r}}function makeConstList(a,b){if(b!=null)A.d(a,b)
a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var t=0;t<a.length;++t){convertToFastObject(a[t])}}var y=0
function instanceTearOffGetter(a,b){var t=null
return a?function(c){if(t===null)t=A.dR(b)
return new t(c,this)}:function(){if(t===null)t=A.dR(b)
return new t(this,null)}}function staticTearOffGetter(a){var t=null
return function(){if(t===null)t=A.dR(a).prototype
return t}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number"){h+=x}return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var t=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var s=staticTearOffGetter(t)
a[b]=s}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var t=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var s=instanceTearOffGetter(c,t)
a[b]=s}function setOrUpdateInterceptorsByTag(a){var t=v.interceptorsByTag
if(!t){v.interceptorsByTag=a
return}copyProperties(a,t)}function setOrUpdateLeafTags(a){var t=v.leafTags
if(!t){v.leafTags=a
return}copyProperties(a,t)}function updateTypes(a){var t=v.types
var s=t.length
t.push.apply(t,a)
return s}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var t=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},s=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:t(0,0,null,["$0"],0),_instance_1u:t(0,1,null,["$1"],0),_instance_2u:t(0,2,null,["$2"],0),_instance_0i:t(1,0,null,["$0"],0),_instance_1i:t(1,1,null,["$1"],0),_instance_2i:t(1,2,null,["$2"],0),_static_0:s(0,null,["$0"],0),_static_1:s(1,null,["$1"],0),_static_2:s(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var J={
eb(a,b){if(a<0)throw A.b(A.dy("Length must be a non-negative integer: "+a))
return A.d(new Array(a),b.i("i<0>"))},
ec(a){if(a<256)switch(a){case 9:case 10:case 11:case 12:case 13:case 32:case 133:case 160:return!0
default:return!1}switch(a){case 5760:case 8192:case 8193:case 8194:case 8195:case 8196:case 8197:case 8198:case 8199:case 8200:case 8201:case 8202:case 8232:case 8233:case 8239:case 8287:case 12288:case 65279:return!0
default:return!1}},
fi(a,b){var t,s
for(t=a.length;b<t;){s=a.charCodeAt(b)
if(s!==32&&s!==13&&!J.ec(s))break;++b}return b},
fj(a,b){var t,s,r
for(t=a.length;b>0;b=s){s=b-1
if(!(s<t))return A.a(a,s)
r=a.charCodeAt(s)
if(r!==32&&r!==13&&!J.ec(r))break}return b},
aF(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.bd.prototype
return J.bX.prototype}if(typeof a=="string")return J.ar.prototype
if(a==null)return J.be.prototype
if(typeof a=="boolean")return J.bW.prototype
if(Array.isArray(a))return J.i.prototype
if(typeof a=="function")return J.bh.prototype
if(typeof a=="object"){if(a instanceof A.k){return a}else{return J.aO.prototype}}if(!(a instanceof A.k))return J.af.prototype
return a},
dU(a){if(a==null)return a
if(Array.isArray(a))return J.i.prototype
if(!(a instanceof A.k))return J.af.prototype
return a},
hC(a){if(typeof a=="string")return J.ar.prototype
if(a==null)return a
if(Array.isArray(a))return J.i.prototype
if(!(a instanceof A.k))return J.af.prototype
return a},
hD(a){if(typeof a=="string")return J.ar.prototype
if(a==null)return a
if(!(a instanceof A.k))return J.af.prototype
return a},
cj(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.aF(a).Z(a,b)},
e1(a,b){return J.dU(a).h(a,b)},
f7(a,b){return J.hD(a).bj(a,b)},
f8(a,b){return J.dU(a).U(a,b)},
M(a){return J.aF(a).gH(a)},
e2(a){return J.dU(a).gF(a)},
dx(a){return J.hC(a).gn(a)},
f9(a){return J.aF(a).ga1(a)},
bH(a){return J.aF(a).j(a)},
bU:function bU(){},
bW:function bW(){},
be:function be(){},
aO:function aO(){},
a8:function a8(){},
cM:function cM(){},
af:function af(){},
bh:function bh(){},
i:function i(a){this.$ti=a},
bV:function bV(){},
cm:function cm(a){this.$ti=a},
b2:function b2(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
bf:function bf(){},
bd:function bd(){},
bX:function bX(){},
ar:function ar(){}},A={dC:function dC(){},
ad(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
dI(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
dW(a){var t,s
for(t=$.L.length,s=0;s<t;++s)if(a===$.L[s])return!0
return!1},
fo(a,b,c,d){if(u.e.b(a))return new A.ba(a,b,c.i("@<0>").a3(d).i("ba<1,2>"))
return new A.ay(a,b,c.i("@<0>").a3(d).i("ay<1,2>"))},
dA(){return new A.bq("No element")},
c_:function c_(a){this.a=a},
cO:function cO(){},
o:function o(){},
I:function I(){},
bs:function bs(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
ax:function ax(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
ay:function ay(a,b,c){this.a=a
this.b=b
this.$ti=c},
ba:function ba(a,b,c){this.a=a
this.b=b
this.$ti=c},
az:function az(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
l:function l(a,b,c){this.a=a
this.b=b
this.$ti=c},
eT(a){var t=v.mangledGlobalNames[a]
if(t!=null)return t
return"minified:"+a},
m(a){var t
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
t=J.bH(a)
return t},
c1(a){var t,s=$.eh
if(s==null)s=$.eh=Symbol("identityHashCode")
t=a[s]
if(t==null){t=Math.random()*0x3fffffff|0
a[s]=t}return t},
fq(a,b){var t,s=/^\s*[+-]?((0x[a-f0-9]+)|(\d+)|([a-z0-9]+))\s*$/i.exec(a)
if(s==null)return null
if(3>=s.length)return A.a(s,3)
t=s[3]
if(t!=null)return parseInt(a,10)
if(s[2]!=null)return parseInt(a,16)
return null},
fp(a){var t,s
if(!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(a))return null
t=parseFloat(a)
if(isNaN(t)){s=B.e.aK(a)
if(s==="NaN"||s==="+NaN"||s==="-NaN")return t
return null}return t},
c2(a){var t,s,r,q
if(a instanceof A.k)return A.E(A.bF(a),null)
t=J.aF(a)
if(t===B.I||t===B.L||u.o.b(a)){s=B.F(a)
if(s!=="Object"&&s!=="")return s
r=a.constructor
if(typeof r=="function"){q=r.name
if(typeof q=="string"&&q!=="Object"&&q!=="")return q}}return A.E(A.bF(a),null)},
ei(a){var t,s,r
if(a==null||typeof a=="number"||A.dN(a))return J.bH(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.D)return a.j(0)
if(a instanceof A.ah)return a.bh(!0)
t=$.f5()
for(s=0;s<1;++s){r=t[s].co(a)
if(r!=null)return r}return"Instance of '"+A.c2(a)+"'"},
x(a){var t
if(0<=a){if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){t=a-65536
return String.fromCharCode((B.t.bg(t,10)|55296)>>>0,t&1023|56320)}}throw A.b(A.a9(a,0,1114111,null,null))},
a(a,b){if(a==null)J.dx(a)
throw A.b(A.eN(a,b))},
eN(a,b){var t,s="index"
if(!A.dO(b))return new A.al(!0,b,s,null)
t=J.dx(a)
if(b<0||b>=t)return A.dz(b,t,a,s)
return new A.bm(null,null,!0,b,s,"Value not in range")},
b_(a){return a},
b(a){return A.z(a,new Error())},
z(a,b){var t
if(a==null)a=new A.bv()
b.dartException=a
t=A.hT
if("defineProperty" in Object){Object.defineProperty(b,"message",{get:t})
b.name=""}else b.toString=t
return b},
hT(){return J.bH(this.dartException)},
ci(a,b){throw A.z(a,b==null?new Error():b)},
dv(a,b,c){var t
if(b==null)b=0
if(c==null)c=0
t=Error()
A.ci(A.h_(a,b,c),t)},
h_(a,b,c){var t,s,r,q,p,o,n,m,l
if(typeof b=="string")t=b
else{s="[]=;add;removeWhere;retainWhere;removeRange;setRange;setInt8;setInt16;setInt32;setUint8;setUint16;setUint32;setFloat32;setFloat64".split(";")
r=s.length
q=b
if(q>r){c=q/r|0
q%=r}t=s[q]}p=typeof c=="string"?c:"modify;remove from;add to".split(";")[c]
o=u.j.b(a)?"list":"ByteData"
n=a.$flags|0
m="a "
if((n&4)!==0)l="constant "
else if((n&2)!==0){l="unmodifiable "
m="an "}else l=(n&1)!==0?"fixed-length ":""
return new A.bw("'"+t+"': Cannot "+p+" "+m+l+o)},
G(a){throw A.b(A.Q(a))},
a3(a){var t,s,r,q,p,o
a=A.eS(a.replace(String({}),"$receiver$"))
t=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(t==null)t=A.d([],u.s)
s=t.indexOf("\\$arguments\\$")
r=t.indexOf("\\$argumentsExpr\\$")
q=t.indexOf("\\$expr\\$")
p=t.indexOf("\\$method\\$")
o=t.indexOf("\\$receiver\\$")
return new A.cQ(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),s,r,q,p,o)},
cR(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(t){return t.message}}(a)},
el(a){return function($expr$){try{$expr$.$method$}catch(t){return t.message}}(a)},
dD(a,b){var t=b==null,s=t?null:b.method
return new A.bY(a,s,t?null:b.receiver)},
dY(a){if(a==null)return new A.cw(a)
if(typeof a!=="object")return a
if("dartException" in a)return A.aH(a,a.dartException)
return A.hr(a)},
aH(a,b){if(u.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
hr(a){var t,s,r,q,p,o,n,m,l,k,j,i,h
if(!("message" in a))return a
t=a.message
if("number" in a&&typeof a.number=="number"){s=a.number
r=s&65535
if((B.t.bg(s,16)&8191)===10)switch(r){case 438:return A.aH(a,A.dD(A.m(t)+" (Error "+r+")",null))
case 445:case 5007:A.m(t)
return A.aH(a,new A.bl())}}if(a instanceof TypeError){q=$.eU()
p=$.eV()
o=$.eW()
n=$.eX()
m=$.f_()
l=$.f0()
k=$.eZ()
$.eY()
j=$.f2()
i=$.f1()
h=q.V(t)
if(h!=null)return A.aH(a,A.dD(A.aY(t),h))
else{h=p.V(t)
if(h!=null){h.method="call"
return A.aH(a,A.dD(A.aY(t),h))}else if(o.V(t)!=null||n.V(t)!=null||m.V(t)!=null||l.V(t)!=null||k.V(t)!=null||n.V(t)!=null||j.V(t)!=null||i.V(t)!=null){A.aY(t)
return A.aH(a,new A.bl())}}return A.aH(a,new A.c9(typeof t=="string"?t:""))}if(a instanceof RangeError){if(typeof t=="string"&&t.indexOf("call stack")!==-1)return new A.bp()
t=function(b){try{return String(b)}catch(g){}return null}(a)
return A.aH(a,new A.al(!1,null,null,typeof t=="string"?t.replace(/^RangeError:\s*/,""):t))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof t=="string"&&t==="too much recursion")return new A.bp()
return a},
dX(a){if(a==null)return J.M(a)
if(typeof a=="object")return A.c1(a)
return J.M(a)},
hy(a,b){var t,s,r,q=a.length
for(t=0;t<q;t=r){s=t+1
r=s+1
b.D(0,a[t],a[s])}return b},
hz(a,b){var t,s=a.length
for(t=0;t<s;++t)b.h(0,a[t])
return b},
fg(a1){var t,s,r,q,p,o,n,m,l,k,j=a1.co,i=a1.iS,h=a1.iI,g=a1.nDA,f=a1.aI,e=a1.fs,d=a1.cs,c=e[0],b=d[0],a=j[c],a0=a1.fT
a0.toString
t=i?Object.create(new A.c6().constructor.prototype):Object.create(new A.aI(null,null).constructor.prototype)
t.$initialize=t.constructor
s=i?function static_tear_off(){this.$initialize()}:function tear_off(a2,a3){this.$initialize(a2,a3)}
t.constructor=s
s.prototype=t
t.$_name=c
t.$_target=a
r=!i
if(r)q=A.e7(c,a,h,g)
else{t.$static_name=c
q=a}t.$S=A.fc(a0,i,h)
t[b]=q
for(p=q,o=1;o<e.length;++o){n=e[o]
if(typeof n=="string"){m=j[n]
l=n
n=m}else l=""
k=d[o]
if(k!=null){if(r)n=A.e7(l,n,h,g)
t[k]=n}if(o===f)p=n}t.$C=p
t.$R=a1.rC
t.$D=a1.dV
return s},
fc(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.b("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.fa)}throw A.b("Error in functionType of tearoff")},
fd(a,b,c,d){var t=A.e6
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,t)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,t)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,t)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,t)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,t)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,t)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,t)}},
e7(a,b,c,d){if(c)return A.ff(a,b,d)
return A.fd(b.length,d,a,b)},
fe(a,b,c,d){var t=A.e6,s=A.fb
switch(b?-1:a){case 0:throw A.b(new A.c4("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,s,t)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,s,t)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,s,t)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,s,t)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,s,t)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,s,t)
default:return function(e,f,g){return function(){var r=[g(this)]
Array.prototype.push.apply(r,arguments)
return e.apply(f(this),r)}}(d,s,t)}},
ff(a,b,c){var t,s
if($.e4==null)$.e4=A.e3("interceptor")
if($.e5==null)$.e5=A.e3("receiver")
t=b.length
s=A.fe(t,c,a,b)
return s},
dR(a){return A.fg(a)},
fa(a,b){return A.bE(v.typeUniverse,A.bF(a.a),b)},
e6(a){return a.a},
fb(a){return a.b},
e3(a){var t,s,r,q=new A.aI("receiver","interceptor"),p=Object.getOwnPropertyNames(q)
p.$flags=1
t=p
for(p=t.length,s=0;s<p;++s){r=t[s]
if(q[r]===a)return r}throw A.b(A.dy("Field name "+a+" not found."))},
hw(a,b){var t=b.length,s=v.rttc[""+t+";"+a]
if(s==null)return null
if(t===0)return s
if(t===s.length)return s.apply(null,b)
return s(b)},
dB(a,b,c,d,e,f){var t=b?"m":"",s=c?"":"i",r=d?"u":"",q=e?"s":"",p=function(g,h){try{return new RegExp(g,h)}catch(o){return o}}(a,t+s+r+q+f)
if(p instanceof RegExp)return p
throw A.b(A.e8("Illegal RegExp pattern ("+String(p)+")",a))},
hM(a,b,c){var t=a.indexOf(b,c)
return t>=0},
dS(a){if(a.indexOf("$",0)>=0)return a.replace(/\$/g,"$$$$")
return a},
hP(a,b,c,d){var t=b.aZ(a,d)
if(t==null)return a
return A.hR(a,t.b.index,t.gak(),c)},
eS(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
e(a,b,c){var t
if(typeof b=="string")return A.hO(a,b,c)
if(b instanceof A.bg){t=b.gb3()
t.lastIndex=0
return a.replace(t,A.dS(c))}return A.hN(a,b,c)},
hN(a,b,c){var t,s,r,q
for(t=J.f7(b,a),t=t.gF(t),s=0,r="";t.p();){q=t.gA()
r=r+a.substring(s,q.gaP())+c
s=q.gak()}t=r+a.substring(s)
return t.charCodeAt(0)==0?t:t},
hO(a,b,c){var t,s,r
if(b===""){if(a==="")return c
t=a.length
for(s=c,r=0;r<t;++r)s=s+a[r]+c
return s.charCodeAt(0)==0?s:s}if(a.indexOf(b,0)<0)return a
if(a.length<500||c.indexOf("$",0)>=0)return a.split(b).join(c)
return a.replace(new RegExp(A.eS(b),"g"),A.dS(c))},
hQ(a,b,c,d){return d===0?a.replace(b.b,A.dS(c)):A.hP(a,b,c,d)},
hR(a,b,c,d){return a.substring(0,b)+d+a.substring(c)},
h:function h(a,b){this.a=a
this.b=b},
ai:function ai(a,b){this.a=a
this.b=b},
b6:function b6(){},
B:function B(a,b,c){this.a=a
this.b=b
this.$ti=c},
bx:function bx(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
b7:function b7(){},
ap:function ap(a,b,c){this.a=a
this.b=b
this.$ti=c},
bT:function bT(){},
aM:function aM(a,b){this.a=a
this.$ti=b},
bo:function bo(){},
cQ:function cQ(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bl:function bl(){},
bY:function bY(a,b,c){this.a=a
this.b=b
this.c=c},
c9:function c9(a){this.a=a},
cw:function cw(a){this.a=a},
D:function D(){},
bK:function bK(){},
bL:function bL(){},
c8:function c8(){},
c6:function c6(){},
aI:function aI(a,b){this.a=a
this.b=b},
c4:function c4(a){this.a=a},
a0:function a0(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
cr:function cr(a,b){this.a=a
this.b=b
this.c=null},
cs:function cs(a,b){this.a=a
this.$ti=b},
av:function av(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
bj:function bj(a,b){this.a=a
this.$ti=b},
aw:function aw(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
J:function J(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
ah:function ah(){},
aD:function aD(){},
bg:function bg(a,b){var _=this
_.a=a
_.b=b
_.e=_.d=_.c=null},
bz:function bz(a){this.b=a},
ca:function ca(a,b,c){this.a=a
this.b=b
this.c=c},
cb:function cb(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
c7:function c7(a,b){this.a=a
this.c=b},
cg:function cg(a,b,c){this.a=a
this.b=b
this.c=c},
ch:function ch(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
dH(a,b){var t=b.c
return t==null?b.c=A.bC(a,"e9",[b.x]):t},
ej(a){var t=a.w
if(t===6||t===7)return A.ej(a.x)
return t===11||t===12},
fu(a){return a.as},
b0(a){return A.d2(v.typeUniverse,a,!1)},
hH(a,b){var t,s,r,q,p
if(a==null)return null
t=b.y
s=a.Q
if(s==null)s=a.Q=new Map()
r=b.as
q=s.get(r)
if(q!=null)return q
p=A.ak(v.typeUniverse,a.x,t,0)
s.set(r,p)
return p},
ak(a0,a1,a2,a3){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=a1.w
switch(a){case 5:case 1:case 2:case 3:case 4:return a1
case 6:t=a1.x
s=A.ak(a0,t,a2,a3)
if(s===t)return a1
return A.eu(a0,s,!0)
case 7:t=a1.x
s=A.ak(a0,t,a2,a3)
if(s===t)return a1
return A.et(a0,s,!0)
case 8:r=a1.y
q=A.aZ(a0,r,a2,a3)
if(q===r)return a1
return A.bC(a0,a1.x,q)
case 9:p=a1.x
o=A.ak(a0,p,a2,a3)
n=a1.y
m=A.aZ(a0,n,a2,a3)
if(o===p&&m===n)return a1
return A.dK(a0,o,m)
case 10:l=a1.x
k=a1.y
j=A.aZ(a0,k,a2,a3)
if(j===k)return a1
return A.ev(a0,l,j)
case 11:i=a1.x
h=A.ak(a0,i,a2,a3)
g=a1.y
f=A.hn(a0,g,a2,a3)
if(h===i&&f===g)return a1
return A.es(a0,h,f)
case 12:e=a1.y
a3+=e.length
d=A.aZ(a0,e,a2,a3)
p=a1.x
o=A.ak(a0,p,a2,a3)
if(d===e&&o===p)return a1
return A.dL(a0,o,d,!0)
case 13:c=a1.x
if(c<a3)return a1
b=a2[c-a3]
if(b==null)return a1
return b
default:throw A.b(A.bJ("Attempted to substitute unexpected RTI kind "+a))}},
aZ(a,b,c,d){var t,s,r,q,p=b.length,o=A.d3(p)
for(t=!1,s=0;s<p;++s){r=b[s]
q=A.ak(a,r,c,d)
if(q!==r)t=!0
o[s]=q}return t?o:b},
ho(a,b,c,d){var t,s,r,q,p,o,n=b.length,m=A.d3(n)
for(t=!1,s=0;s<n;s+=3){r=b[s]
q=b[s+1]
p=b[s+2]
o=A.ak(a,p,c,d)
if(o!==p)t=!0
m.splice(s,3,r,q,o)}return t?m:b},
hn(a,b,c,d){var t,s=b.a,r=A.aZ(a,s,c,d),q=b.b,p=A.aZ(a,q,c,d),o=b.c,n=A.ho(a,o,c,d)
if(r===s&&p===q&&n===o)return b
t=new A.cd()
t.a=r
t.b=p
t.c=n
return t},
d(a,b){a[v.arrayRti]=b
return a},
ds(a){var t=a.$S
if(t!=null){if(typeof t=="number")return A.hF(t)
return a.$S()}return null},
hG(a,b){var t
if(A.ej(b))if(a instanceof A.D){t=A.ds(a)
if(t!=null)return t}return A.bF(a)},
bF(a){if(a instanceof A.k)return A.O(a)
if(Array.isArray(a))return A.t(a)
return A.dM(J.aF(a))},
t(a){var t=a[v.arrayRti],s=u.n
if(t==null)return s
if(t.constructor!==s.constructor)return s
return t},
O(a){var t=a.$ti
return t!=null?t:A.dM(a)},
dM(a){var t=a.constructor,s=t.$ccache
if(s!=null)return s
return A.h7(a,t)},
h7(a,b){var t=a instanceof A.D?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,s=A.fO(v.typeUniverse,t.name)
b.$ccache=s
return s},
hF(a){var t,s=v.types,r=s[a]
if(typeof r=="string"){t=A.d2(v.typeUniverse,r,!1)
s[a]=t
return t}return r},
hE(a){return A.a4(A.O(a))},
dV(a){var t=A.ds(a)
return A.a4(t==null?A.bF(a):t)},
dP(a){var t
if(a instanceof A.ah)return A.hx(a.$r,a.b0())
t=a instanceof A.D?A.ds(a):null
if(t!=null)return t
if(u.bW.b(a))return J.f9(a).a
if(Array.isArray(a))return A.t(a)
return A.bF(a)},
a4(a){var t=a.r
return t==null?a.r=new A.d1(a):t},
hx(a,b){var t,s,r=b,q=r.length
if(q===0)return u.F
if(0>=q)return A.a(r,0)
t=A.bE(v.typeUniverse,A.dP(r[0]),"@<0>")
for(s=1;s<q;++s){if(!(s<r.length))return A.a(r,s)
t=A.ew(v.typeUniverse,t,A.dP(r[s]))}return A.bE(v.typeUniverse,t,a)},
hU(a){return A.a4(A.d2(v.typeUniverse,a,!1))},
h6(a){var t=this
t.b=A.hl(t)
return t.b(a)},
hl(a){var t,s,r,q,p
if(a===u.K)return A.hd
if(A.aG(a))return A.hh
t=a.w
if(t===6)return A.h4
if(t===1)return A.eI
if(t===7)return A.h8
s=A.hk(a)
if(s!=null)return s
if(t===8){r=a.x
if(a.y.every(A.aG)){a.f="$i"+r
if(r==="H")return A.hb
if(a===u.m)return A.ha
return A.hg}}else if(t===10){q=A.hw(a.x,a.y)
p=q==null?A.eI:q
return p==null?A.dp(p):p}return A.h2},
hk(a){if(a.w===8){if(a===u.S)return A.dO
if(a===u.i||a===u.H)return A.hc
if(a===u.N)return A.hf
if(a===u.y)return A.dN}return null},
h5(a){var t=this,s=A.h1
if(A.aG(t))s=A.fX
else if(t===u.K)s=A.dp
else if(A.b1(t)){s=A.h3
if(t===u.a3)s=A.fT
else if(t===u.aD)s=A.fW
else if(t===u.u)s=A.fR
else if(t===u.ae)s=A.eB
else if(t===u.dd)s=A.fS
else if(t===u.z)s=A.fV}else if(t===u.S)s=A.dn
else if(t===u.N)s=A.aY
else if(t===u.y)s=A.fQ
else if(t===u.H)s=A.eA
else if(t===u.i)s=A.ez
else if(t===u.m)s=A.fU
t.a=s
return t.a(a)},
h2(a){var t=this
if(a==null)return A.b1(t)
return A.eP(v.typeUniverse,A.hG(a,t),t)},
h4(a){if(a==null)return!0
return this.x.b(a)},
hg(a){var t,s=this
if(a==null)return A.b1(s)
t=s.f
if(a instanceof A.k)return!!a[t]
return!!J.aF(a)[t]},
hb(a){var t,s=this
if(a==null)return A.b1(s)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
t=s.f
if(a instanceof A.k)return!!a[t]
return!!J.aF(a)[t]},
ha(a){var t=this
if(a==null)return!1
if(typeof a=="object"){if(a instanceof A.k)return!!a[t.f]
return!0}if(typeof a=="function")return!0
return!1},
eH(a){if(typeof a=="object"){if(a instanceof A.k)return u.m.b(a)
return!0}if(typeof a=="function")return!0
return!1},
h1(a){var t=this
if(a==null){if(A.b1(t))return a}else if(t.b(a))return a
throw A.z(A.eD(a,t),new Error())},
h3(a){var t=this
if(a==null||t.b(a))return a
throw A.z(A.eD(a,t),new Error())},
eD(a,b){return new A.aX("TypeError: "+A.em(a,A.E(b,null)))},
hu(a,b,c,d){if(A.eP(v.typeUniverse,a,b))return a
throw A.z(A.fG("The type argument '"+A.E(a,null)+"' is not a subtype of the type variable bound '"+A.E(b,null)+"' of type variable '"+c+"' in '"+d+"'."),new Error())},
em(a,b){return A.bP(a)+": type '"+A.E(A.dP(a),null)+"' is not a subtype of type '"+b+"'"},
fG(a){return new A.aX("TypeError: "+a)},
N(a,b){return new A.aX("TypeError: "+A.em(a,b))},
h8(a){var t=this
return t.x.b(a)||A.dH(v.typeUniverse,t).b(a)},
hd(a){return a!=null},
dp(a){if(a!=null)return a
throw A.z(A.N(a,"Object"),new Error())},
hh(a){return!0},
fX(a){return a},
eI(a){return!1},
dN(a){return!0===a||!1===a},
fQ(a){if(!0===a)return!0
if(!1===a)return!1
throw A.z(A.N(a,"bool"),new Error())},
fR(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.z(A.N(a,"bool?"),new Error())},
ez(a){if(typeof a=="number")return a
throw A.z(A.N(a,"double"),new Error())},
fS(a){if(typeof a=="number")return a
if(a==null)return a
throw A.z(A.N(a,"double?"),new Error())},
dO(a){return typeof a=="number"&&Math.floor(a)===a},
dn(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.z(A.N(a,"int"),new Error())},
fT(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.z(A.N(a,"int?"),new Error())},
hc(a){return typeof a=="number"},
eA(a){if(typeof a=="number")return a
throw A.z(A.N(a,"num"),new Error())},
eB(a){if(typeof a=="number")return a
if(a==null)return a
throw A.z(A.N(a,"num?"),new Error())},
hf(a){return typeof a=="string"},
aY(a){if(typeof a=="string")return a
throw A.z(A.N(a,"String"),new Error())},
fW(a){if(typeof a=="string")return a
if(a==null)return a
throw A.z(A.N(a,"String?"),new Error())},
fU(a){if(A.eH(a))return a
throw A.z(A.N(a,"JSObject"),new Error())},
fV(a){if(a==null)return a
if(A.eH(a))return a
throw A.z(A.N(a,"JSObject?"),new Error())},
eK(a,b){var t,s,r
for(t="",s="",r=0;r<a.length;++r,s=", ")t+=s+A.E(a[r],b)
return t},
hj(a,b){var t,s,r,q,p,o,n=a.x,m=a.y
if(""===n)return"("+A.eK(m,b)+")"
t=m.length
s=n.split(",")
r=s.length-t
for(q="(",p="",o=0;o<t;++o,p=", "){q+=p
if(r===0)q+="{"
q+=A.E(m[o],b)
if(r>=0)q+=" "+s[r];++r}return q+"})"},
eF(a2,a3,a4){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=", ",a1=null
if(a4!=null){t=a4.length
if(a3==null)a3=A.d([],u.s)
else a1=a3.length
s=a3.length
for(r=t;r>0;--r)B.a.h(a3,"T"+(s+r))
for(q=u.X,p="<",o="",r=0;r<t;++r,o=a0){n=a3.length
m=n-1-r
if(!(m>=0))return A.a(a3,m)
p=p+o+a3[m]
l=a4[r]
k=l.w
if(!(k===2||k===3||k===4||k===5||l===q))p+=" extends "+A.E(l,a3)}p+=">"}else p=""
q=a2.x
j=a2.y
i=j.a
h=i.length
g=j.b
f=g.length
e=j.c
d=e.length
c=A.E(q,a3)
for(b="",a="",r=0;r<h;++r,a=a0)b+=a+A.E(i[r],a3)
if(f>0){b+=a+"["
for(a="",r=0;r<f;++r,a=a0)b+=a+A.E(g[r],a3)
b+="]"}if(d>0){b+=a+"{"
for(a="",r=0;r<d;r+=3,a=a0){b+=a
if(e[r+1])b+="required "
b+=A.E(e[r+2],a3)+" "+e[r]}b+="}"}if(a1!=null){a3.toString
a3.length=a1}return p+"("+b+") => "+c},
E(a,b){var t,s,r,q,p,o,n,m=a.w
if(m===5)return"erased"
if(m===2)return"dynamic"
if(m===3)return"void"
if(m===1)return"Never"
if(m===4)return"any"
if(m===6){t=a.x
s=A.E(t,b)
r=t.w
return(r===11||r===12?"("+s+")":s)+"?"}if(m===7)return"FutureOr<"+A.E(a.x,b)+">"
if(m===8){q=A.hq(a.x)
p=a.y
return p.length>0?q+("<"+A.eK(p,b)+">"):q}if(m===10)return A.hj(a,b)
if(m===11)return A.eF(a,b,null)
if(m===12)return A.eF(a.x,b,a.y)
if(m===13){o=a.x
n=b.length
o=n-1-o
if(!(o>=0&&o<n))return A.a(b,o)
return b[o]}return"?"},
hq(a){var t=v.mangledGlobalNames[a]
if(t!=null)return t
return"minified:"+a},
fP(a,b){var t=a.tR[b]
for(;typeof t=="string";)t=a.tR[t]
return t},
fO(a,b){var t,s,r,q,p,o=a.eT,n=o[b]
if(n==null)return A.d2(a,b,!1)
else if(typeof n=="number"){t=n
s=A.bD(a,5,"#")
r=A.d3(t)
for(q=0;q<t;++q)r[q]=s
p=A.bC(a,b,r)
o[b]=p
return p}else return n},
fN(a,b){return A.ex(a.tR,b)},
fM(a,b){return A.ex(a.eT,b)},
d2(a,b,c){var t,s=a.eC,r=s.get(b)
if(r!=null)return r
t=A.eq(A.eo(a,null,b,!1))
s.set(b,t)
return t},
bE(a,b,c){var t,s,r=b.z
if(r==null)r=b.z=new Map()
t=r.get(c)
if(t!=null)return t
s=A.eq(A.eo(a,b,c,!0))
r.set(c,s)
return s},
ew(a,b,c){var t,s,r,q=b.Q
if(q==null)q=b.Q=new Map()
t=c.as
s=q.get(t)
if(s!=null)return s
r=A.dK(a,b,c.w===9?c.y:[c])
q.set(t,r)
return r},
aj(a,b){b.a=A.h5
b.b=A.h6
return b},
bD(a,b,c){var t,s,r=a.eC.get(c)
if(r!=null)return r
t=new A.R(null,null)
t.w=b
t.as=c
s=A.aj(a,t)
a.eC.set(c,s)
return s},
eu(a,b,c){var t,s=b.as+"?",r=a.eC.get(s)
if(r!=null)return r
t=A.fK(a,b,s,c)
a.eC.set(s,t)
return t},
fK(a,b,c,d){var t,s,r
if(d){t=b.w
s=!0
if(!A.aG(b))if(!(b===u.P||b===u.T))if(t!==6)s=t===7&&A.b1(b.x)
if(s)return b
else if(t===1)return u.P}r=new A.R(null,null)
r.w=6
r.x=b
r.as=c
return A.aj(a,r)},
et(a,b,c){var t,s=b.as+"/",r=a.eC.get(s)
if(r!=null)return r
t=A.fI(a,b,s,c)
a.eC.set(s,t)
return t},
fI(a,b,c,d){var t,s
if(d){t=b.w
if(A.aG(b)||b===u.K)return b
else if(t===1)return A.bC(a,"e9",[b])
else if(b===u.P||b===u.T)return u.bc}s=new A.R(null,null)
s.w=7
s.x=b
s.as=c
return A.aj(a,s)},
fL(a,b){var t,s,r=""+b+"^",q=a.eC.get(r)
if(q!=null)return q
t=new A.R(null,null)
t.w=13
t.x=b
t.as=r
s=A.aj(a,t)
a.eC.set(r,s)
return s},
bB(a){var t,s,r,q=a.length
for(t="",s="",r=0;r<q;++r,s=",")t+=s+a[r].as
return t},
fH(a){var t,s,r,q,p,o=a.length
for(t="",s="",r=0;r<o;r+=3,s=","){q=a[r]
p=a[r+1]?"!":":"
t+=s+q+p+a[r+2].as}return t},
bC(a,b,c){var t,s,r,q=b
if(c.length>0)q+="<"+A.bB(c)+">"
t=a.eC.get(q)
if(t!=null)return t
s=new A.R(null,null)
s.w=8
s.x=b
s.y=c
if(c.length>0)s.c=c[0]
s.as=q
r=A.aj(a,s)
a.eC.set(q,r)
return r},
dK(a,b,c){var t,s,r,q,p,o
if(b.w===9){t=b.x
s=b.y.concat(c)}else{s=c
t=b}r=t.as+(";<"+A.bB(s)+">")
q=a.eC.get(r)
if(q!=null)return q
p=new A.R(null,null)
p.w=9
p.x=t
p.y=s
p.as=r
o=A.aj(a,p)
a.eC.set(r,o)
return o},
ev(a,b,c){var t,s,r="+"+(b+"("+A.bB(c)+")"),q=a.eC.get(r)
if(q!=null)return q
t=new A.R(null,null)
t.w=10
t.x=b
t.y=c
t.as=r
s=A.aj(a,t)
a.eC.set(r,s)
return s},
es(a,b,c){var t,s,r,q,p,o=b.as,n=c.a,m=n.length,l=c.b,k=l.length,j=c.c,i=j.length,h="("+A.bB(n)
if(k>0){t=m>0?",":""
h+=t+"["+A.bB(l)+"]"}if(i>0){t=m>0?",":""
h+=t+"{"+A.fH(j)+"}"}s=o+(h+")")
r=a.eC.get(s)
if(r!=null)return r
q=new A.R(null,null)
q.w=11
q.x=b
q.y=c
q.as=s
p=A.aj(a,q)
a.eC.set(s,p)
return p},
dL(a,b,c,d){var t,s=b.as+("<"+A.bB(c)+">"),r=a.eC.get(s)
if(r!=null)return r
t=A.fJ(a,b,c,s,d)
a.eC.set(s,t)
return t},
fJ(a,b,c,d,e){var t,s,r,q,p,o,n,m
if(e){t=c.length
s=A.d3(t)
for(r=0,q=0;q<t;++q){p=c[q]
if(p.w===1){s[q]=p;++r}}if(r>0){o=A.ak(a,b,s,0)
n=A.aZ(a,c,s,0)
return A.dL(a,o,n,c!==n)}}m=new A.R(null,null)
m.w=12
m.x=b
m.y=c
m.as=d
return A.aj(a,m)},
eo(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
eq(a){var t,s,r,q,p,o,n,m=a.r,l=a.s
for(t=m.length,s=0;s<t;){r=m.charCodeAt(s)
if(r>=48&&r<=57)s=A.fB(s+1,r,m,l)
else if((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124)s=A.ep(a,s,m,l,!1)
else if(r===46)s=A.ep(a,s,m,l,!0)
else{++s
switch(r){case 44:break
case 58:l.push(!1)
break
case 33:l.push(!0)
break
case 59:l.push(A.aC(a.u,a.e,l.pop()))
break
case 94:l.push(A.fL(a.u,l.pop()))
break
case 35:l.push(A.bD(a.u,5,"#"))
break
case 64:l.push(A.bD(a.u,2,"@"))
break
case 126:l.push(A.bD(a.u,3,"~"))
break
case 60:l.push(a.p)
a.p=l.length
break
case 62:A.fD(a,l)
break
case 38:A.fC(a,l)
break
case 63:q=a.u
l.push(A.eu(q,A.aC(q,a.e,l.pop()),a.n))
break
case 47:q=a.u
l.push(A.et(q,A.aC(q,a.e,l.pop()),a.n))
break
case 40:l.push(-3)
l.push(a.p)
a.p=l.length
break
case 41:A.fA(a,l)
break
case 91:l.push(a.p)
a.p=l.length
break
case 93:p=l.splice(a.p)
A.er(a.u,a.e,p)
a.p=l.pop()
l.push(p)
l.push(-1)
break
case 123:l.push(a.p)
a.p=l.length
break
case 125:p=l.splice(a.p)
A.fF(a.u,a.e,p)
a.p=l.pop()
l.push(p)
l.push(-2)
break
case 43:o=m.indexOf("(",s)
l.push(m.substring(s,o))
l.push(-4)
l.push(a.p)
a.p=l.length
s=o+1
break
default:throw"Bad character "+r}}}n=l.pop()
return A.aC(a.u,a.e,n)},
fB(a,b,c,d){var t,s,r=b-48
for(t=c.length;a<t;++a){s=c.charCodeAt(a)
if(!(s>=48&&s<=57))break
r=r*10+(s-48)}d.push(r)
return a},
ep(a,b,c,d,e){var t,s,r,q,p,o,n=b+1
for(t=c.length;n<t;++n){s=c.charCodeAt(n)
if(s===46){if(e)break
e=!0}else{if(!((((s|32)>>>0)-97&65535)<26||s===95||s===36||s===124))r=s>=48&&s<=57
else r=!0
if(!r)break}}q=c.substring(b,n)
if(e){t=a.u
p=a.e
if(p.w===9)p=p.x
o=A.fP(t,p.x)[q]
if(o==null)A.ci('No "'+q+'" in "'+A.fu(p)+'"')
d.push(A.bE(t,p,o))}else d.push(q)
return n},
fD(a,b){var t,s=a.u,r=A.en(a,b),q=b.pop()
if(typeof q=="string")b.push(A.bC(s,q,r))
else{t=A.aC(s,a.e,q)
switch(t.w){case 11:b.push(A.dL(s,t,r,a.n))
break
default:b.push(A.dK(s,t,r))
break}}},
fA(a,b){var t,s,r,q=a.u,p=b.pop(),o=null,n=null
if(typeof p=="number")switch(p){case-1:o=b.pop()
break
case-2:n=b.pop()
break
default:b.push(p)
break}else b.push(p)
t=A.en(a,b)
p=b.pop()
switch(p){case-3:p=b.pop()
if(o==null)o=q.sEA
if(n==null)n=q.sEA
s=A.aC(q,a.e,p)
r=new A.cd()
r.a=t
r.b=o
r.c=n
b.push(A.es(q,s,r))
return
case-4:b.push(A.ev(q,b.pop(),t))
return
default:throw A.b(A.bJ("Unexpected state under `()`: "+A.m(p)))}},
fC(a,b){var t=b.pop()
if(0===t){b.push(A.bD(a.u,1,"0&"))
return}if(1===t){b.push(A.bD(a.u,4,"1&"))
return}throw A.b(A.bJ("Unexpected extended operation "+A.m(t)))},
en(a,b){var t=b.splice(a.p)
A.er(a.u,a.e,t)
a.p=b.pop()
return t},
aC(a,b,c){if(typeof c=="string")return A.bC(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.fE(a,b,c)}else return c},
er(a,b,c){var t,s=c.length
for(t=0;t<s;++t)c[t]=A.aC(a,b,c[t])},
fF(a,b,c){var t,s=c.length
for(t=2;t<s;t+=3)c[t]=A.aC(a,b,c[t])},
fE(a,b,c){var t,s,r=b.w
if(r===9){if(c===0)return b.x
t=b.y
s=t.length
if(c<=s)return t[c-1]
c-=s
b=b.x
r=b.w}else if(c===0)return b
if(r!==8)throw A.b(A.bJ("Indexed base must be an interface type"))
t=b.y
if(c<=t.length)return t[c-1]
throw A.b(A.bJ("Bad index "+c+" for "+b.j(0)))},
eP(a,b,c){var t,s=b.d
if(s==null)s=b.d=new Map()
t=s.get(c)
if(t==null){t=A.u(a,b,null,c,null)
s.set(c,t)}return t},
u(a,b,c,d,e){var t,s,r,q,p,o,n,m,l,k,j
if(b===d)return!0
if(A.aG(d))return!0
t=b.w
if(t===4)return!0
if(A.aG(b))return!1
if(b.w===1)return!0
s=t===13
if(s)if(A.u(a,c[b.x],c,d,e))return!0
r=d.w
q=u.P
if(b===q||b===u.T){if(r===7)return A.u(a,b,c,d.x,e)
return d===q||d===u.T||r===6}if(d===u.K){if(t===7)return A.u(a,b.x,c,d,e)
return t!==6}if(t===7){if(!A.u(a,b.x,c,d,e))return!1
return A.u(a,A.dH(a,b),c,d,e)}if(t===6)return A.u(a,q,c,d,e)&&A.u(a,b.x,c,d,e)
if(r===7){if(A.u(a,b,c,d.x,e))return!0
return A.u(a,b,c,A.dH(a,d),e)}if(r===6)return A.u(a,b,c,q,e)||A.u(a,b,c,d.x,e)
if(s)return!1
q=t!==11
if((!q||t===12)&&d===u.Z)return!0
p=t===10
if(p&&d===u.cY)return!0
if(r===12){if(b===u.g)return!0
if(t!==12)return!1
o=b.y
n=d.y
m=o.length
if(m!==n.length)return!1
c=c==null?o:o.concat(c)
e=e==null?n:n.concat(e)
for(l=0;l<m;++l){k=o[l]
j=n[l]
if(!A.u(a,k,c,j,e)||!A.u(a,j,e,k,c))return!1}return A.eG(a,b.x,c,d.x,e)}if(r===11){if(b===u.g)return!0
if(q)return!1
return A.eG(a,b,c,d,e)}if(t===8){if(r!==8)return!1
return A.h9(a,b,c,d,e)}if(p&&r===10)return A.he(a,b,c,d,e)
return!1},
eG(a2,a3,a4,a5,a6){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1
if(!A.u(a2,a3.x,a4,a5.x,a6))return!1
t=a3.y
s=a5.y
r=t.a
q=s.a
p=r.length
o=q.length
if(p>o)return!1
n=o-p
m=t.b
l=s.b
k=m.length
j=l.length
if(p+k<o+j)return!1
for(i=0;i<p;++i){h=r[i]
if(!A.u(a2,q[i],a6,h,a4))return!1}for(i=0;i<n;++i){h=m[i]
if(!A.u(a2,q[p+i],a6,h,a4))return!1}for(i=0;i<j;++i){h=m[n+i]
if(!A.u(a2,l[i],a6,h,a4))return!1}g=t.c
f=s.c
e=g.length
d=f.length
for(c=0,b=0;b<d;b+=3){a=f[b]
for(;!0;){if(c>=e)return!1
a0=g[c]
c+=3
if(a<a0)return!1
a1=g[c-2]
if(a0<a){if(a1)return!1
continue}h=f[b+1]
if(a1&&!h)return!1
h=g[c-1]
if(!A.u(a2,f[b+2],a6,h,a4))return!1
break}}for(;c<e;){if(g[c+1])return!1
c+=3}return!0},
h9(a,b,c,d,e){var t,s,r,q,p,o=b.x,n=d.x
for(;o!==n;){t=a.tR[o]
if(t==null)return!1
if(typeof t=="string"){o=t
continue}s=t[n]
if(s==null)return!1
r=s.length
q=r>0?new Array(r):v.typeUniverse.sEA
for(p=0;p<r;++p)q[p]=A.bE(a,b,s[p])
return A.ey(a,q,null,c,d.y,e)}return A.ey(a,b.y,null,c,d.y,e)},
ey(a,b,c,d,e,f){var t,s=b.length
for(t=0;t<s;++t)if(!A.u(a,b[t],d,e[t],f))return!1
return!0},
he(a,b,c,d,e){var t,s=b.y,r=d.y,q=s.length
if(q!==r.length)return!1
if(b.x!==d.x)return!1
for(t=0;t<q;++t)if(!A.u(a,s[t],c,r[t],e))return!1
return!0},
b1(a){var t=a.w,s=!0
if(!(a===u.P||a===u.T))if(!A.aG(a))if(t!==6)s=t===7&&A.b1(a.x)
return s},
aG(a){var t=a.w
return t===2||t===3||t===4||t===5||a===u.X},
ex(a,b){var t,s,r=Object.keys(b),q=r.length
for(t=0;t<q;++t){s=r[t]
a[s]=b[s]}},
d3(a){return a>0?new Array(a):v.typeUniverse.sEA},
R:function R(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
cd:function cd(){this.c=this.b=this.a=null},
d1:function d1(a){this.a=a},
cc:function cc(){},
aX:function aX(a){this.a=a},
ct(a,b,c){return b.i("@<0>").a3(c).i("dE<1,2>").a(A.hy(a,new A.a0(b.i("@<0>").a3(c).i("a0<1,2>"))))},
ee(a,b){return new A.a0(a.i("@<0>").a3(b).i("a0<1,2>"))},
fk(a){return new A.aB(a.i("aB<0>"))},
fl(a,b){return b.i("ef<0>").a(A.hz(a,new A.aB(b.i("aB<0>"))))},
dJ(){var t=Object.create(null)
t["<non-identifier-key>"]=t
delete t["<non-identifier-key>"]
return t},
dG(a){var t,s
if(A.dW(a))return"{...}"
t=new A.ab("")
try{s={}
B.a.h($.L,a)
t.a+="{"
s.a=!0
a.al(0,new A.cu(s,t))
t.a+="}"}finally{if(0>=$.L.length)return A.a($.L,-1)
$.L.pop()}s=t.a
return s.charCodeAt(0)==0?s:s},
aB:function aB(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
cf:function cf(a){this.a=a
this.b=null},
by:function by(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
aP:function aP(){},
cu:function cu(a,b){this.a=a
this.b=b},
aa:function aa(){},
bA:function bA(){},
ed(a,b,c){return new A.bi(a,b)},
fZ(a){return a.cw()},
fy(a,b){return new A.cT(a,[],A.hv())},
fz(a,b,c){var t,s=new A.ab(""),r=A.fy(s,b)
r.an(a)
t=s.a
return t.charCodeAt(0)==0?t:t},
bM:function bM(){},
bO:function bO(){},
bi:function bi(a,b){this.a=a
this.b=b},
bZ:function bZ(a,b){this.a=a
this.b=b},
cn:function cn(){},
co:function co(a){this.b=a},
cU:function cU(){},
cV:function cV(a,b){this.a=a
this.b=b},
cT:function cT(a,b,c){this.c=a
this.a=b
this.b=c},
dF(a,b,c){var t,s,r
if(a<0||a>4294967295)A.ci(A.a9(a,0,4294967295,"length",null))
t=A.d(new Array(a),c.i("i<0>"))
t.$flags=1
s=t
if(a!==0&&b!=null)for(r=0;r<s.length;++r)s[r]=b
return s},
fn(a,b,c){var t,s,r=A.d([],c.i("i<0>"))
for(t=a.length,s=0;s<a.length;a.length===t||(0,A.G)(a),++s)B.a.h(r,c.a(a[s]))
r.$flags=1
return r},
fm(a,b){var t,s,r,q=A.d([],b.i("i<0>"))
for(t=a.a,s=A.O(a),t=new A.az(t.gF(t),a.b,s.i("az<1,2>")),s=s.y[1];t.p();){r=t.a
B.a.h(q,r==null?s.a(r):r)}return q},
f(a,b){return new A.bg(a,A.dB(a,!1,b,!1,!1,""))},
ek(a,b,c){var t=J.e2(b)
if(!t.p())return a
if(c.length===0){do a+=A.m(t.gA())
while(t.p())}else{a+=A.m(t.gA())
for(;t.p();)a=a+c+A.m(t.gA())}return a},
bP(a){if(typeof a=="number"||A.dN(a)||a==null)return J.bH(a)
if(typeof a=="string")return JSON.stringify(a)
return A.ei(a)},
bJ(a){return new A.bI(a)},
dy(a){return new A.al(!1,null,null,a)},
a9(a,b,c,d,e){return new A.bm(b,c,!0,a,d,"Invalid value")},
fs(a,b,c){if(0>a||a>c)throw A.b(A.a9(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.b(A.a9(b,a,c,"end",null))
return b}return c},
fr(a,b){return a},
dz(a,b,c,d){return new A.bS(b,!0,a,d,"Index out of range")},
fx(a){return new A.bw(a)},
fv(a){return new A.bq(a)},
Q(a){return new A.bN(a)},
e8(a,b){return new A.cl(a,b)},
fh(a,b,c){var t,s
if(A.dW(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}t=A.d([],u.s)
B.a.h($.L,a)
try{A.hi(a,t)}finally{if(0>=$.L.length)return A.a($.L,-1)
$.L.pop()}s=A.ek(b,u.k.a(t),", ")+c
return s.charCodeAt(0)==0?s:s},
ea(a,b,c){var t,s
if(A.dW(a))return b+"..."+c
t=new A.ab(b)
B.a.h($.L,a)
try{s=t
s.a=A.ek(s.a,a,", ")}finally{if(0>=$.L.length)return A.a($.L,-1)
$.L.pop()}t.a+=c
s=t.a
return s.charCodeAt(0)==0?s:s},
hi(a,b){var t,s,r,q,p,o,n,m=a.gF(a),l=0,k=0
while(!0){if(!(l<80||k<3))break
if(!m.p())return
t=A.m(m.gA())
B.a.h(b,t)
l+=t.length+2;++k}if(!m.p()){if(k<=5)return
if(0>=b.length)return A.a(b,-1)
s=b.pop()
if(0>=b.length)return A.a(b,-1)
r=b.pop()}else{q=m.gA();++k
if(!m.p()){if(k<=4){B.a.h(b,A.m(q))
return}s=A.m(q)
if(0>=b.length)return A.a(b,-1)
r=b.pop()
l+=s.length+2}else{p=m.gA();++k
for(;m.p();q=p,p=o){o=m.gA();++k
if(k>100){while(!0){if(!(l>75&&k>3))break
if(0>=b.length)return A.a(b,-1)
l-=b.pop().length+2;--k}B.a.h(b,"...")
return}}r=A.m(q)
s=A.m(p)
l+=s.length+r.length+4}}if(k>b.length+2){l+=5
n="..."}else n=null
while(!0){if(!(l>80&&b.length>3))break
if(0>=b.length)return A.a(b,-1)
l-=b.pop().length+2
if(n==null){l+=5
n="..."}}if(n!=null)B.a.h(b,n)
B.a.h(b,r)
B.a.h(b,s)},
eR(a){var t=B.e.aK(a),s=A.fq(t,null)
if(s==null)s=A.fp(t)
if(s!=null)return s
throw A.b(A.e8(a,null))},
eg(a,b,c,d){var t
if(B.j===c){t=J.M(a)
b=J.M(b)
return A.dI(A.ad(A.ad($.dw(),t),b))}if(B.j===d){t=J.M(a)
b=J.M(b)
c=J.M(c)
return A.dI(A.ad(A.ad(A.ad($.dw(),t),b),c))}t=J.M(a)
b=J.M(b)
c=J.M(c)
d=J.M(d)
d=A.dI(A.ad(A.ad(A.ad(A.ad($.dw(),t),b),c),d))
return d},
cS:function cS(){},
p:function p(){},
bI:function bI(a){this.a=a},
bv:function bv(){},
al:function al(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
bm:function bm(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
bS:function bS(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
bw:function bw(a){this.a=a},
bq:function bq(a){this.a=a},
bN:function bN(a){this.a=a},
bp:function bp(){},
cl:function cl(a,b){this.a=a
this.b=b},
j:function j(){},
bk:function bk(){},
k:function k(){},
c3:function c3(a){var _=this
_.a=a
_.c=_.b=0
_.d=-1},
ab:function ab(a){this.a=a},
as:function as(a,b){this.c=a
this.b=b},
cv:function cv(){},
n:function n(){},
W:function W(a,b,c){this.e=a
this.a=b
this.b=c},
br:function br(a,b,c){this.e=a
this.a=b
this.b=c},
b4:function b4(a,b,c){this.e=a
this.a=b
this.b=c},
ag:function ag(a,b,c){this.e=a
this.a=b
this.b=c},
a7:function a7(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
X:function X(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
A:function A(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
P:function P(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
r:function r(){},
b8:function b8(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
am:function am(a,b,c,d){var _=this
_.c=a
_.d=b
_.a=c
_.b=d},
b9:function b9(a,b,c){this.e=a
this.a=b
this.b=c},
b3:function b3(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
aW:function aW(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
aR:function aR(a,b,c){this.e=a
this.a=b
this.b=c},
aq:function aq(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
bt:function bt(a,b){this.a=a
this.b=b},
ac:function ac(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
aV:function aV(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
aS:function aS(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
aL:function aL(a,b,c,d,e,f,g){var _=this
_.e=a
_.f=b
_.r=c
_.w=d
_.x=e
_.a=f
_.b=g},
aK:function aK(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
ao:function ao(a,b,c){this.e=a
this.a=b
this.b=c},
aU:function aU(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
b5:function b5(a,b){this.a=a
this.b=b},
aA:function aA(a){this.a=a},
a1:function a1(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
cN:function cN(a,b,c){this.a=a
this.b=b
this.c=c},
cP:function cP(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
q(a,b,c){return new A.an(a,b)},
hs(){var t=$.e_(),s=A.t(t)
return new A.l(t,s.i("c(1)").a(new A.dr()),s.i("l<1,c>"))},
hm(a){var t=a.P(0)
if(t.br(0,0))throw A.b(a.ae("No se puede sacar la ra\xedz cuadrada de un n\xfamero negativo ("+A.dT(t)+")."))
return Math.sqrt(A.b_(t))},
eL(a){var t=a.P(0)
if(t.br(0,-1)||t.aL(0,1))throw A.b(a.ae(A.m(a.gct().gcu())+" solo funciona con valores entre -1 y 1."))
return t},
hp(a){var t,s=a.a2(0),r=a.am(1).aS(0,a.gca()),q=a.am(2).aS(0,a.gca())
if(r.aL(0,q))return""
t=r.cb(0,0,s.length)
return s.I(0,t,q.ao(0,1).cb(0,t,s.length))},
an:function an(a,b){this.a=a
this.b=b},
dr:function dr(){},
d4:function d4(){},
d5:function d5(){},
d6:function d6(){},
df:function df(){},
dg:function dg(){},
dh:function dh(){},
di:function di(){},
dj:function dj(){},
dk:function dk(){},
dl:function dl(){},
dm:function dm(){},
d7:function d7(){},
d8:function d8(){},
d9:function d9(){},
da:function da(){},
db:function db(){},
dc:function dc(){},
dd:function dd(){},
de:function de(){},
bc:function bc(){},
au(a,b,c,d){return new A.at(B.r,a,d,c)},
ck:function ck(a){this.b=a},
at:function at(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.e=d},
hA(a,b){var t,s=a.c,r=A.d([A.eC(a.a,b,B.C,s)],u.D)
for(t=a.b,t=new A.aw(t,t.r,t.e,A.O(t).i("aw<2>"));t.p();)r.push(A.eC(t.d,b,B.C,s))
return r},
eC(a,b,c,d){var t,s,r,q,p,o,n,m,l,k=a.f
if(k){t=a.a
s="Algoritmo "+t}else{t=A.d([],u.s)
r=a.c
if(r!=null)t.push("Funcion "+r+" <- ")
else t.push("SubProceso ")
r=a.a
q=a.b
p=A.t(q)
t.push(r+"("+new A.l(q,p.i("c(1)").a(new A.dq()),p.i("l<1,c>")).E(0,", ")+")")
s=B.a.bm(t)
t=r}o=new A.ce(b,c,d)
k=k?"Inicio":t
t=a.e
n=o.bk(B.o,k,t)
t=o.W(a.d,t)
k=d.e.u(0,a)
m=o.aM(A.d([n,t,o.bk(B.o,"Fin",k==null?0:k)],u.J))
k=b.w
l=m.aO(k,k)
k=2*k
return new A.bR(s,m.a+k,m.b+k,l.d,l.e,l.f)},
S(a,b,c,d,e,f,g){var t=d==null?A.d([],u.W):d,s=g==null?A.d([],u.R):g,r=f==null?A.d([],u.q):f
return new A.K(a,b,c,t,s,r,e==null?A.d([],u.h):e)},
Z:function Z(a){this.b=a},
bb:function bb(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
aJ:function aJ(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
a6:function a6(a,b,c){this.a=a
this.b=b
this.c=c},
C:function C(a,b){this.a=a
this.b=b},
U:function U(a,b,c){this.a=a
this.b=b
this.c=c},
bR:function bR(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bQ:function bQ(a,b){this.a=a
this.w=b},
dq:function dq(){},
K:function K(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g},
ce:function ce(a,b,c){this.a=a
this.b=b
this.c=c},
cZ:function cZ(a,b,c){this.a=a
this.b=b
this.c=c},
cX:function cX(){},
cY:function cY(){},
cW:function cW(){},
eE(a){var t=A.e(a,"&","&amp;")
t=A.e(t,"<","&lt;")
return A.e(t,">","&gt;")},
eO(c5,c6,c7){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8="\\.0$",b9="path",c0=' fill="#2A1A0B"',c1=c5.b,c2=c5.c,c3=new A.dt(c6),c4=new A.ab("")
if(c6){t=B.b.k(c1,1)
s=A.f(b8,!0)
t=A.e(t,s,"")
s=B.b.k(c2,1)
r=A.f(b8,!0)
s=A.e(s,r,"")
r=B.b.k(c1,1)
q=A.f(b8,!0)
r=A.e(r,q,"")
q=B.b.k(c2,1)
p=A.f(b8,!0)
q=A.e(q,p,"")
p=A.eE(c7)
o=B.b.k(c1,1)
n=A.f(b8,!0)
o=A.e(o,n,"")
n=B.b.k(c2,1)
m=A.f(b8,!0)
t=c4.a='<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 '+t+" "+s+'" width="'+r+'" height="'+q+'" font-family="ui-monospace, Menlo, Consolas, monospace" font-size="13"><title>'+p+'</title><rect width="'+o+'" height="'+A.e(n,m,"")+'" fill="#FFFBF6"/>'}else{t=B.b.k(c1,1)
s=A.f(b8,!0)
t=A.e(t,s,"")
s=B.b.k(c2,1)
r=A.f(b8,!0)
s=A.e(s,r,"")
r=B.b.k(Math.min(c1,520),1)
q=A.f(b8,!0)
t=c4.a='<svg viewBox="0 0 '+t+" "+s+'" width="'+A.e(r,q,"")+'" role="img" aria-labelledby="diag-tit"><title id="diag-tit">'+A.eE(c7)+"</title>"}t=c4.a=t+(c6?'<g stroke="#7A6450" stroke-width="1.5" fill="none" stroke-linejoin="round">':'<g class="linea" stroke-width="1.5" fill="none" stroke-linejoin="round">')
l=new A.ab("")
for(s=c5.e,r=s.length,q=u.s,k=0;k<s.length;s.length===r||(0,A.G)(s),++k){j=s[k]
i=j.a
t=B.b.k(B.a.gaF(i).a,1)
p=A.f(b8,!0)
t=A.e(t,p,"")
p=B.b.k(B.a.gaF(i).b,1)
o=A.f(b8,!0)
p=A.e(p,o,"")
o=A.d([],q)
n=A.t(i).i("bs<1>")
m=new A.bs(i,1,null,n)
m=new A.ax(m,m.gn(0),n.i("ax<I.E>"))
n=n.i("I.E")
for(;m.p();){h=m.d
if(h==null)h=n.a(h)
g=B.b.k(h.a,1)
f=A.f(b8,!0)
g=A.e(g,f,"")
f=B.b.k(h.b,1)
e=A.f(b8,!0)
o.push("L"+g+" "+A.e(f,e,""))}t='<path d="M'+t+" "+p+B.a.bm(o)+'"/>'
t=c4.a+=t
if(j.b&&i.length>=2){d=B.a.gl(i)
c=d.a
b=d.b
p=i.length
o=p-2
if(!(o>=0))return A.a(i,o)
a=i[o]
a0=c-a.a
a1=b-a.b
a2=Math.sqrt(a0*a0+a1*a1)
if(a2>0){a3=a0/a2
a4=a1/a2
a5=c-a3*8
a6=b-a4*8
p=B.b.k(c,1)
o=A.f(b8,!0)
p=A.e(p,o,"")
o=B.b.k(b,1)
n=A.f(b8,!0)
o=A.e(o,n,"")
n=a4*4
m=B.b.k(a5-n,1)
g=A.f(b8,!0)
m=A.e(m,g,"")
g=a3*4
f=B.b.k(a6+g,1)
e=A.f(b8,!0)
f=A.e(f,e,"")
n=B.b.k(a5+n,1)
e=A.f(b8,!0)
n=A.e(n,e,"")
g=B.b.k(a6-g,1)
e=A.f(b8,!0)
g=A.e(g,e,"")
e=c6?'fill="#7A6450"':'style="fill:var(--fig-linea);stroke:none"'
e='<path d="M'+p+" "+o+"L"+m+" "+f+"L"+n+" "+g+'z" '+e+' stroke="none"/>'
l.a+=e}}}t+="</g>"+l.j(0)
c4.a=t
for(s=c5.d,r=s.length,k=0;k<s.length;s.length===r||(0,A.G)(s),++k){a7=s[k]
a8=a7.a
q=a8.a
p=B.b.k(q,1)
o=A.f(b8,!0)
a9=A.e(p,o,"")
p=a8.b
o=B.b.k(p,1)
n=A.f(b8,!0)
b0=A.e(o,n,"")
o=a8.d
b1=o*0.35
b2=a7.b
$label0$0:{if(B.o===b2){n=B.b.k(a8.c,1)
m=A.f(b8,!0)
n=A.e(n,m,"")
m=B.b.k(o,1)
g=A.f(b8,!0)
m=A.e(m,g,"")
g=B.b.k(o/2,1)
f=A.f(b8,!0)
n=c3.$3("ini","rect",'x="'+a9+'" y="'+b0+'" width="'+n+'" height="'+m+'" rx="'+A.e(g,f,"")+'"')
break $label0$0}if(B.x===b2||B.q===b2){n=B.b.k(a8.c,1)
m=A.f(b8,!0)
n=A.e(n,m,"")
m=B.b.k(o,1)
g=A.f(b8,!0)
n=c3.$3("proc","rect",'x="'+a9+'" y="'+b0+'" width="'+n+'" height="'+A.e(m,g,"")+'" rx="3"')
break $label0$0}if(B.k===b2||B.p===b2){n=b2===B.k?"io":"sal"
m=B.b.k(q+b1,1)
g=A.f(b8,!0)
m=A.e(m,g,"")
g=q+a8.c
f=B.b.k(g,1)
e=A.f(b8,!0)
f=A.e(f,e,"")
g=B.b.k(g-b1,1)
e=A.f(b8,!0)
g=A.e(g,e,"")
e=B.b.k(p+o,1)
b3=A.f(b8,!0)
n=c3.$3(n,b9,'d="M'+m+" "+b0+" H"+f+" L"+g+" "+A.e(e,b3,"")+" H"+a9+' z"')
break $label0$0}if(B.l===b2){n=a8.c
m=q+n/2
g=B.b.k(m,1)
f=A.f(b8,!0)
g=A.e(g,f,"")
n=B.b.k(q+n,1)
f=A.f(b8,!0)
n=A.e(n,f,"")
f=p+o/2
e=B.b.k(f,1)
b3=A.f(b8,!0)
e=A.e(e,b3,"")
m=B.b.k(m,1)
b3=A.f(b8,!0)
m=A.e(m,b3,"")
b3=B.b.k(p+o,1)
b4=A.f(b8,!0)
b3=A.e(b3,b4,"")
f=B.b.k(f,1)
b4=A.f(b8,!0)
n=c3.$3("dec",b9,'d="M'+g+" "+b0+" L"+n+" "+e+" L"+m+" "+b3+" L"+a9+" "+A.e(f,b4,"")+' z"')
break $label0$0}if(B.m===b2){n=o*0.4
m=q+n
g=B.b.k(m,1)
f=A.f(b8,!0)
g=A.e(g,f,"")
f=q+a8.c
n=f-n
e=B.b.k(n,1)
b3=A.f(b8,!0)
e=A.e(e,b3,"")
f=B.b.k(f,1)
b3=A.f(b8,!0)
f=A.e(f,b3,"")
b3=p+o/2
b4=B.b.k(b3,1)
b5=A.f(b8,!0)
b4=A.e(b4,b5,"")
n=B.b.k(n,1)
b5=A.f(b8,!0)
n=A.e(n,b5,"")
b5=B.b.k(p+o,1)
b6=A.f(b8,!0)
b5=A.e(b5,b6,"")
m=B.b.k(m,1)
b6=A.f(b8,!0)
m=A.e(m,b6,"")
b3=B.b.k(b3,1)
b6=A.f(b8,!0)
n=c3.$3("dec",b9,'d="M'+g+" "+b0+" H"+e+" L"+f+" "+b4+" L"+n+" "+b5+" H"+m+" L"+a9+" "+A.e(b3,b6,"")+' z"')
break $label0$0}n=null}n=t+A.m(n)
c4.a=n
q=B.b.k(q+a8.c/2,1)
t=A.f(b8,!0)
t=A.e(q,t,"")
o=B.b.k(p+o/2+4.5,1)
p=A.f(b8,!0)
q=A.e(o,p,"")
p=c6?c0:""
o=A.e(a7.c,"&","&amp;")
o=A.e(o,"<","&lt;")
t=n+('<text x="'+t+'" y="'+q+'" text-anchor="middle"'+p+">"+A.e(o,">","&gt;")+"</text>")
c4.a=t}for(s=c5.f,r=s.length,k=0;k<s.length;s.length===r||(0,A.G)(s),++k){b7=s[k]
q=B.b.k(b7.a,1)
p=A.f(b8,!0)
q=A.e(q,p,"")
p=B.b.k(b7.b,1)
o=A.f(b8,!0)
p=A.e(p,o,"")
o=c6?c0:""
n=A.e(b7.c,"&","&amp;")
n=A.e(n,"<","&lt;")
t+='<text x="'+q+'" y="'+p+'" font-size="11"'+o+">"+A.e(n,">","&gt;")+"</text>"
c4.a=t}t=c4.a=t+"</svg>"
return t.charCodeAt(0)==0?t:t},
dt:function dt(a){this.a=a},
eJ(a){var t,s,r,q,p,o,n
$label0$0:{t=a instanceof A.A
if(t){s=a.e
r=s
r="o"===r}else{s=null
r=!1}if(r){r=1
break $label0$0}if(t){r=s
r="y"===r}else r=!1
if(r){r=2
break $label0$0}r=a instanceof A.X
if(r){if(t){q=s
p=t}else{s=a.e
q=s
p=!0}q="no"===q}else{p=t
q=!1}if(q){r=3
break $label0$0}if(t){o=!0
q=!0
if(p)n=s
else{s=a.e
n=s
p=o}if("="!==n){if(p)n=s
else{s=a.e
n=s
p=o}if("<>"!==n){if(p)n=s
else{s=a.e
n=s
p=o}if("<"!==n){if(p)n=s
else{s=a.e
n=s
p=o}if(">"!==n){if(p)n=s
else{s=a.e
n=s
p=o}if("<="!==n){if(p)q=s
else{s=a.e
q=s
p=o}q=">="===q}}}}}}else q=!1
if(q){r=4
break $label0$0}if(t){o=!0
if(p)q=s
else{s=a.e
q=s
p=o}if("+"!==q){if(p)q=s
else{s=a.e
q=s
p=o}q="-"===q}else q=!0}else q=!1
if(q){r=5
break $label0$0}if(t){o=!0
q=!0
if(p)n=s
else{s=a.e
n=s
p=o}if("*"!==n){if(p)n=s
else{s=a.e
n=s
p=o}if("/"!==n){if(p)q=s
else{s=a.e
q=s
p=o}q="mod"===q}}}else q=!1
if(q){r=6
break $label0$0}if(r){r=7
break $label0$0}if(t)r="^"===(p?s:a.e)
else r=!1
if(r){r=8
break $label0$0}r=9
break $label0$0}return r},
c0:function c0(a){this.b=a},
y:function y(a){this.a=a},
d_:function d_(a){this.a=a},
cp:function cp(){},
cq:function cq(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=0
_.f=_.e=1},
cx:function cx(a,b,c,d){var _=this
_.a=a
_.b=0
_.c=b
_.d=c
_.e=d},
cG:function cG(a){this.a=a},
cD:function cD(a){this.a=a},
cE:function cE(a){this.a=a},
cF:function cF(a){this.a=a},
cI:function cI(a){this.a=a},
cH:function cH(a){this.a=a},
cC:function cC(a){this.a=a},
cB:function cB(a){this.a=a},
cz:function cz(a){this.a=a},
cy:function cy(a){this.a=a},
cA:function cA(a){this.a=a},
cK:function cK(a){this.a=a},
cJ:function cJ(){},
bu(a,b,c,d,e,f,g){return new A.aT(a,b,f==null?b:f,e,g,c,d)},
ae:function ae(a){this.b=a},
aT:function aT(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g},
hB(a){var t,s,r,q,p,o,n,m,l,k="Diagrama de flujo de ",j=A.f("\\b(algoritmo|proceso)\\b",!1),i=j.b.test(a)?a:"Algoritmo programa\n"+a+"\nFinAlgoritmo\n"
try{j=u.N
t=A.hA(new A.cx(new A.cq(i,B.G,A.d([],u.A)).cn(),A.d([],u.d),new A.cP(new A.J(u.E),new A.J(u.cu),new A.J(u.v),new A.J(u.B),new A.J(u.aS)),A.fk(j)).ck(),B.H)
s=A.d([],u.x)
for(p=t,o=p.length,n=u.K,m=0;m<p.length;p.length===o||(0,A.G)(p),++m){r=p[m]
J.e1(s,A.ct(["titulo",r.a,"svg",A.eO(r,!1,k+r.a),"archivo",A.eO(r,!0,k+r.a),"ancho",r.b,"alto",r.c],j,n))}s=B.z.bl(A.ct(["diagramas",s,"error",null],j,u.da),null)
return s}catch(l){s=A.dY(l)
if(s instanceof A.at){q=s
s=A.d([],u.G)
j=q.a===B.r?"Error de escritura":"Error al ejecutar"
p=u.N
return B.z.bl(A.ct(["diagramas",s,"error",A.ct(["title",j,"line",q.c,"message",q.b,"hint",q.e],p,u.X)],p,u.K),null)}else throw l}},
hJ(){var t,s=new A.du()
if(typeof s=="function")A.ci(A.dy("Attempting to rewrap a JS function."))
t=function(a,b){return function(c){return a(b,c,arguments.length)}}(A.fY,s)
t[$.dZ()]=s
v.G.jaguarDiagrama=t},
du:function du(){},
hS(a){throw A.z(new A.c_("Field '"+a+"' has been assigned during initialization."),new Error())},
fY(a,b,c){u.Z.a(a)
if(A.dn(c)>=1)return a.$1(b)
return a.$0()},
eQ(a,b,c){A.hu(c,u.H,"T","max")
return Math.max(c.a(a),c.a(b))},
Y(a){var t,s,r,q
for(t=new A.c3(a.toLowerCase()),s="";t.p();){r=A.x(t.d)
q=B.V.u(0,r)
s+=q==null?r:q}return s.charCodeAt(0)==0?s:s},
hI(a,b){var t,s,r,q,p,o,n,m,l,k,j,i,h
if(a===b)return 0
t=a.length
if(t===0)return b.length
s=b.length
if(s===0)return t
r=s+1
q=u.S
p=J.eb(r,q)
for(o=0;o<r;++o)p[o]=o
n=A.dF(r,0,q)
for(o=1;o<=t;++o,m=n,n=p,p=m){B.a.D(n,0,o)
for(q=o-1,l=1;l<=s;++l){k=l-1
j=a.charCodeAt(q)===b.charCodeAt(k)?0:1
if(!(k<n.length))return A.a(n,k)
i=n[k]
h=p.length
if(!(l<h))return A.a(p,l)
i=Math.min(i+1,p[l]+1)
if(!(k<h))return A.a(p,k)
B.a.D(n,l,Math.min(i,p[k]+j))}}if(!(s<p.length))return A.a(p,s)
return p[s]},
dQ(a,b){var t,s,r,q,p,o,n,m=A.Y(a)
for(t=b.length,s=null,r=1073741824,q=0;q<b.length;b.length===t||(0,A.G)(b),++q){p=b[q]
o=A.hI(m,A.Y(p))
if(o<r){r=o
s=p}}n=m.length<=4?1:2
return r>0&&r<=n?s:null},
hL(a){var t=a.aK(0),s=$.f4()
if(!s.b.test(t))return null
return A.eR(t)},
dT(a){var t
$label0$0:{if(A.dO(a)){t=A.m(a)
break $label0$0}t=A.h0(a)
break $label0$0}return t},
h0(a){var t,s
if(a===(a<0?Math.ceil(a):Math.floor(a))&&Math.abs(a)<1e15)return B.t.j(B.b.cm(a))
t=B.b.k(a,10)
s=A.f("0+$",!0)
t=A.hQ(t,s,"",0)
return B.e.ce(t,".")?B.e.I(t,0,t.length-1):t}},B={}
var w=[A,J,B]
var $={}
A.dC.prototype={}
J.bU.prototype={
Z(a,b){return a===b},
gH(a){return A.c1(a)},
j(a){return"Instance of '"+A.c2(a)+"'"},
ga1(a){return A.a4(A.dM(this))}}
J.bW.prototype={
j(a){return String(a)},
gH(a){return a?519018:218159},
ga1(a){return A.a4(u.y)},
$ia2:1,
$iaE:1}
J.be.prototype={
Z(a,b){return null==b},
j(a){return"null"},
gH(a){return 0},
$ia2:1}
J.aO.prototype={$iaN:1}
J.a8.prototype={
gH(a){return 0},
j(a){return String(a)}}
J.cM.prototype={}
J.af.prototype={}
J.bh.prototype={
j(a){var t=a[$.dZ()]
if(t==null)return this.bu(a)
return"JavaScript function for "+J.bH(t)},
$ia_:1}
J.i.prototype={
h(a,b){A.t(a).c.a(b)
a.$flags&1&&A.dv(a,29)
a.push(b)},
a6(a,b){var t
A.t(a).i("j<1>").a(b)
a.$flags&1&&A.dv(a,"addAll",2)
if(Array.isArray(b)){this.bw(a,b)
return}for(t=J.e2(b);t.p();)a.push(t.gA())},
bw(a,b){var t,s
u.n.a(b)
t=b.length
if(t===0)return
if(a===b)throw A.b(A.Q(a))
for(s=0;s<t;++s)a.push(b[s])},
E(a,b){var t,s=A.dF(a.length,"",u.N)
for(t=0;t<a.length;++t)this.D(s,t,A.m(a[t]))
return s.join(b)},
bm(a){return this.E(a,"")},
cf(a,b,c,d){var t,s,r
d.a(b)
A.t(a).a3(d).i("1(1,2)").a(c)
t=a.length
for(s=b,r=0;r<t;++r){s=c.$2(s,a[r])
if(a.length!==t)throw A.b(A.Q(a))}return s},
U(a,b){if(!(b<a.length))return A.a(a,b)
return a[b]},
gaF(a){if(a.length>0)return a[0]
throw A.b(A.dA())},
gl(a){var t=a.length
if(t>0)return a[t-1]
throw A.b(A.dA())},
j(a){return A.ea(a,"[","]")},
gF(a){return new J.b2(a,a.length,A.t(a).i("b2<1>"))},
gH(a){return A.c1(a)},
gn(a){return a.length},
sn(a,b){a.$flags&1&&A.dv(a,"set length","change the length of")
if(b>a.length)A.t(a).c.a(null)
a.length=b},
D(a,b,c){A.t(a).c.a(c)
a.$flags&2&&A.dv(a)
if(!(b>=0&&b<a.length))throw A.b(A.eN(a,b))
a[b]=c},
$io:1,
$ij:1,
$iH:1}
J.bV.prototype={
co(a){var t,s,r
if(!Array.isArray(a))return null
t=a.$flags|0
if((t&4)!==0)s="const, "
else if((t&2)!==0)s="unmodifiable, "
else s=(t&1)!==0?"fixed, ":""
r="Instance of '"+A.c2(a)+"'"
if(s==="")return r
return r+" ("+s+"length: "+a.length+")"}}
J.cm.prototype={}
J.b2.prototype={
gA(){var t=this.d
return t==null?this.$ti.c.a(t):t},
p(){var t,s=this,r=s.a,q=r.length
if(s.b!==q){r=A.G(r)
throw A.b(r)}t=s.c
if(t>=q){s.d=null
return!1}s.d=r[t]
s.c=t+1
return!0},
$iw:1}
J.bf.prototype={
gci(a){return a===0?1/a<0:a<0},
cm(a){var t
if(a>=-2147483648&&a<=2147483647)return a|0
if(isFinite(a)){t=a<0?Math.ceil(a):Math.floor(a)
return t+0}throw A.b(A.fx(""+a+".toInt()"))},
k(a,b){var t
if(b>20)throw A.b(A.a9(b,0,20,"fractionDigits",null))
t=a.toFixed(b)
if(a===0&&this.gci(a))return"-"+t
return t},
j(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gH(a){var t,s,r,q,p=a|0
if(a===p)return p&536870911
t=Math.abs(a)
s=Math.log(t)/0.6931471805599453|0
r=Math.pow(2,s)
q=t<1?t/r:r/t
return((q*9007199254740992|0)+(q*3542243181176521|0))*599197+s*1259&536870911},
bg(a,b){var t
if(a>0)t=this.c3(a,b)
else{t=b>31?31:b
t=a>>t>>>0}return t},
c3(a,b){return b>31?0:a>>>b},
ga1(a){return A.a4(u.H)},
$iv:1,
$iT:1}
J.bd.prototype={
ga1(a){return A.a4(u.S)},
$ia2:1,
$iF:1}
J.bX.prototype={
ga1(a){return A.a4(u.i)},
$ia2:1}
J.ar.prototype={
aE(a,b,c){var t=b.length
if(c>t)throw A.b(A.a9(c,0,t,null,null))
return new A.cg(b,a,c)},
bj(a,b){return this.aE(a,b,0)},
ce(a,b){var t=b.length,s=a.length
if(t>s)return!1
return b===this.bt(a,s-t)},
aQ(a,b,c){var t,s=a.length
if(c>s)throw A.b(A.a9(c,0,s,null,null))
t=c+b.length
if(t>s)return!1
return b===a.substring(c,t)},
I(a,b,c){return a.substring(b,A.fs(b,c,a.length))},
bt(a,b){return this.I(a,b,null)},
aK(a){var t,s,r,q=a.trim(),p=q.length
if(p===0)return q
if(0>=p)return A.a(q,0)
if(q.charCodeAt(0)===133){t=J.fi(q,1)
if(t===p)return""}else t=0
s=p-1
if(!(s>=0))return A.a(q,s)
r=q.charCodeAt(s)===133?J.fj(q,s):p
if(t===0&&r===p)return q
return q.substring(t,r)},
O(a,b){return A.hM(a,b,0)},
j(a){return a},
gH(a){var t,s,r
for(t=a.length,s=0,r=0;r<t;++r){s=s+a.charCodeAt(r)&536870911
s=s+((s&524287)<<10)&536870911
s^=s>>6}s=s+((s&67108863)<<3)&536870911
s^=s>>11
return s+((s&16383)<<15)&536870911},
ga1(a){return A.a4(u.N)},
gn(a){return a.length},
$ia2:1,
$icL:1,
$ic:1}
A.c_.prototype={
j(a){return"LateInitializationError: "+this.a}}
A.cO.prototype={}
A.o.prototype={}
A.I.prototype={
gF(a){var t=this
return new A.ax(t,t.gn(t),A.O(t).i("ax<I.E>"))},
E(a,b){var t,s,r,q=this,p=q.gn(q)
if(b.length!==0){if(p===0)return""
t=A.m(q.U(0,0))
if(p!==q.gn(q))throw A.b(A.Q(q))
for(s=t,r=1;r<p;++r){s=s+b+A.m(q.U(0,r))
if(p!==q.gn(q))throw A.b(A.Q(q))}return s.charCodeAt(0)==0?s:s}else{for(r=0,s="";r<p;++r){s+=A.m(q.U(0,r))
if(p!==q.gn(q))throw A.b(A.Q(q))}return s.charCodeAt(0)==0?s:s}},
bn(a,b){var t,s,r,q=this
A.O(q).i("I.E(I.E,I.E)").a(b)
t=q.gn(q)
if(t===0)throw A.b(A.dA())
s=q.U(0,0)
for(r=1;r<t;++r){s=b.$2(s,q.U(0,r))
if(t!==q.gn(q))throw A.b(A.Q(q))}return s}}
A.bs.prototype={
gbF(){var t=this.a.length
return t},
gc4(){var t=this.a.length,s=this.b
if(s>t)return t
return s},
gn(a){var t=this.a.length,s=this.b
if(s>=t)return 0
return t-s},
U(a,b){var t=this,s=t.gc4()+b,r=t.gbF()
if(s>=r)throw A.b(A.dz(b,t.gn(0),t,"index"))
r=t.a
if(!(s<r.length))return A.a(r,s)
return r[s]}}
A.ax.prototype={
gA(){var t=this.d
return t==null?this.$ti.c.a(t):t},
p(){var t,s=this,r=s.a,q=r.gn(r)
if(s.b!==q)throw A.b(A.Q(r))
t=s.c
if(t>=q){s.d=null
return!1}s.d=r.U(0,t);++s.c
return!0},
$iw:1}
A.ay.prototype={
gF(a){var t=this.a
return new A.az(t.gF(t),this.b,A.O(this).i("az<1,2>"))},
gn(a){var t=this.a
return t.gn(t)}}
A.ba.prototype={$io:1}
A.az.prototype={
p(){var t=this,s=t.b
if(s.p()){t.a=t.c.$1(s.gA())
return!0}t.a=null
return!1},
gA(){var t=this.a
return t==null?this.$ti.y[1].a(t):t},
$iw:1}
A.l.prototype={
gn(a){return J.dx(this.a)},
U(a,b){return this.b.$1(J.f8(this.a,b))}}
A.h.prototype={$r:"+(1,2)",$s:1}
A.ai.prototype={$r:"+label,piece(1,2)",$s:2}
A.b6.prototype={
gaJ(a){return this.gn(this)===0},
j(a){return A.dG(this)},
$iV:1}
A.B.prototype={
gn(a){return this.b.length},
gbJ(){var t=this.$keys
if(t==null){t=Object.keys(this.a)
this.$keys=t}return t},
cc(a){if("__proto__"===a)return!1
return this.a.hasOwnProperty(a)},
u(a,b){if(!this.cc(b))return null
return this.b[this.a[b]]},
al(a,b){var t,s,r,q
this.$ti.i("~(1,2)").a(b)
t=this.gbJ()
s=this.b
for(r=t.length,q=0;q<r;++q)b.$2(t[q],s[q])}}
A.bx.prototype={
gA(){var t=this.d
return t==null?this.$ti.c.a(t):t},
p(){var t=this,s=t.c
if(s>=t.b){t.d=null
return!1}t.d=t.a[s]
t.c=s+1
return!0},
$iw:1}
A.b7.prototype={}
A.ap.prototype={
gn(a){return this.b},
gF(a){var t,s=this,r=s.$keys
if(r==null){r=Object.keys(s.a)
s.$keys=r}t=r
return new A.bx(t,t.length,s.$ti.i("bx<1>"))},
O(a,b){if("__proto__"===b)return!1
return this.a.hasOwnProperty(b)}}
A.bT.prototype={
Z(a,b){if(b==null)return!1
return b instanceof A.aM&&this.a.Z(0,b.a)&&A.dV(this)===A.dV(b)},
gH(a){return A.eg(this.a,A.dV(this),B.j,B.j)},
j(a){var t=B.a.E([A.a4(this.$ti.c)],", ")
return this.a.j(0)+" with "+("<"+t+">")}}
A.aM.prototype={
$2(a,b){return this.a.$1$2(a,b,this.$ti.y[0])},
$S(){return A.hH(A.ds(this.a),this.$ti)}}
A.bo.prototype={}
A.cQ.prototype={
V(a){var t,s,r=this,q=new RegExp(r.a).exec(a)
if(q==null)return null
t=Object.create(null)
s=r.b
if(s!==-1)t.arguments=q[s+1]
s=r.c
if(s!==-1)t.argumentsExpr=q[s+1]
s=r.d
if(s!==-1)t.expr=q[s+1]
s=r.e
if(s!==-1)t.method=q[s+1]
s=r.f
if(s!==-1)t.receiver=q[s+1]
return t}}
A.bl.prototype={
j(a){return"Null check operator used on a null value"}}
A.bY.prototype={
j(a){var t,s=this,r="NoSuchMethodError: method not found: '",q=s.b
if(q==null)return"NoSuchMethodError: "+s.a
t=s.c
if(t==null)return r+q+"' ("+s.a+")"
return r+q+"' on '"+t+"' ("+s.a+")"}}
A.c9.prototype={
j(a){var t=this.a
return t.length===0?"Error":"Error: "+t}}
A.cw.prototype={
j(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.D.prototype={
j(a){var t=this.constructor,s=t==null?null:t.name
return"Closure '"+A.eT(s==null?"unknown":s)+"'"},
$ia_:1,
gcr(){return this},
$C:"$1",
$R:1,
$D:null}
A.bK.prototype={$C:"$0",$R:0}
A.bL.prototype={$C:"$2",$R:2}
A.c8.prototype={}
A.c6.prototype={
j(a){var t=this.$static_name
if(t==null)return"Closure of unknown static method"
return"Closure '"+A.eT(t)+"'"}}
A.aI.prototype={
Z(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.aI))return!1
return this.$_target===b.$_target&&this.a===b.a},
gH(a){return(A.dX(this.a)^A.c1(this.$_target))>>>0},
j(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.c2(this.a)+"'")}}
A.c4.prototype={
j(a){return"RuntimeError: "+this.a}}
A.a0.prototype={
gn(a){return this.a},
gaJ(a){return this.a===0},
u(a,b){var t,s,r,q,p=null
if(typeof b=="string"){t=this.b
if(t==null)return p
s=t[b]
r=s==null?p:s.b
return r}else if(typeof b=="number"&&(b&0x3fffffff)===b){q=this.c
if(q==null)return p
s=q[b]
r=s==null?p:s.b
return r}else return this.cg(b)},
cg(a){var t,s,r=this.d
if(r==null)return null
t=r[this.aG(a)]
s=this.aH(t,a)
if(s<0)return null
return t[s].b},
D(a,b,c){var t,s,r,q,p,o,n=this,m=A.O(n)
m.c.a(b)
m.y[1].a(c)
if(typeof b=="string"){t=n.b
n.aV(t==null?n.b=n.aA():t,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){s=n.c
n.aV(s==null?n.c=n.aA():s,b,c)}else{r=n.d
if(r==null)r=n.d=n.aA()
q=n.aG(b)
p=r[q]
if(p==null)r[q]=[n.aB(b,c)]
else{o=n.aH(p,b)
if(o>=0)p[o].b=c
else p.push(n.aB(b,c))}}},
al(a,b){var t,s,r=this
A.O(r).i("~(1,2)").a(b)
t=r.e
s=r.r
for(;t!=null;){b.$2(t.a,t.b)
if(s!==r.r)throw A.b(A.Q(r))
t=t.c}},
aV(a,b,c){var t,s=A.O(this)
s.c.a(b)
s.y[1].a(c)
t=a[b]
if(t==null)a[b]=this.aB(b,c)
else t.b=c},
aB(a,b){var t=this,s=A.O(t),r=new A.cr(s.c.a(a),s.y[1].a(b))
if(t.e==null)t.e=t.f=r
else t.f=t.f.c=r;++t.a
t.r=t.r+1&1073741823
return r},
aG(a){return J.M(a)&1073741823},
aH(a,b){var t,s
if(a==null)return-1
t=a.length
for(s=0;s<t;++s)if(J.cj(a[s].a,b))return s
return-1},
j(a){return A.dG(this)},
aA(){var t=Object.create(null)
t["<non-identifier-key>"]=t
delete t["<non-identifier-key>"]
return t},
$idE:1}
A.cr.prototype={}
A.cs.prototype={
gn(a){return this.a.a},
gF(a){var t=this.a
return new A.av(t,t.r,t.e,this.$ti.i("av<1>"))}}
A.av.prototype={
gA(){return this.d},
p(){var t,s=this,r=s.a
if(s.b!==r.r)throw A.b(A.Q(r))
t=s.c
if(t==null){s.d=null
return!1}else{s.d=t.a
s.c=t.c
return!0}},
$iw:1}
A.bj.prototype={
gn(a){return this.a.a},
gF(a){var t=this.a
return new A.aw(t,t.r,t.e,this.$ti.i("aw<1>"))}}
A.aw.prototype={
gA(){return this.d},
p(){var t,s=this,r=s.a
if(s.b!==r.r)throw A.b(A.Q(r))
t=s.c
if(t==null){s.d=null
return!1}else{s.d=t.b
s.c=t.c
return!0}},
$iw:1}
A.J.prototype={
aG(a){return A.dX(a)&1073741823},
aH(a,b){var t,s,r
if(a==null)return-1
t=a.length
for(s=0;s<t;++s){r=a[s].a
if(r==null?b==null:r===b)return s}return-1}}
A.ah.prototype={
j(a){return this.bh(!1)},
bh(a){var t,s,r,q,p,o=this.bH(),n=this.b0(),m=(a?"Record ":"")+"("
for(t=o.length,s="",r=0;r<t;++r,s=", "){m+=s
q=o[r]
if(typeof q=="string")m=m+q+": "
if(!(r<n.length))return A.a(n,r)
p=n[r]
m=a?m+A.ei(p):m+A.m(p)}m+=")"
return m.charCodeAt(0)==0?m:m},
bH(){var t,s=this.$s
for(;$.d0.length<=s;)B.a.h($.d0,null)
t=$.d0[s]
if(t==null){t=this.bz()
B.a.D($.d0,s,t)}return t},
bz(){var t,s,r,q=this.$r,p=q.indexOf("("),o=q.substring(1,p),n=q.substring(p),m=n==="()"?0:n.replace(/[^,]/g,"").length+1,l=u.K,k=J.eb(m,l)
for(t=0;t<m;++t)k[t]=t
if(o!==""){s=o.split(",")
t=s.length
for(r=m;t>0;){--r;--t
B.a.D(k,r,s[t])}}k=A.fn(k,!1,l)
k.$flags=3
return k}}
A.aD.prototype={
b0(){return[this.a,this.b]},
Z(a,b){if(b==null)return!1
return b instanceof A.aD&&this.$s===b.$s&&J.cj(this.a,b.a)&&J.cj(this.b,b.b)},
gH(a){return A.eg(this.$s,this.a,this.b,B.j)}}
A.bg.prototype={
j(a){return"RegExp/"+this.a+"/"+this.b.flags},
gb3(){var t=this,s=t.c
if(s!=null)return s
s=t.b
return t.c=A.dB(t.a,s.multiline,!s.ignoreCase,s.unicode,s.dotAll,"g")},
gbL(){var t=this,s=t.d
if(s!=null)return s
s=t.b
return t.d=A.dB(t.a,s.multiline,!s.ignoreCase,s.unicode,s.dotAll,"y")},
aE(a,b,c){var t=b.length
if(c>t)throw A.b(A.a9(c,0,t,null,null))
return new A.ca(this,b,c)},
bj(a,b){return this.aE(0,b,0)},
aZ(a,b){var t,s=this.gb3()
if(s==null)s=A.dp(s)
s.lastIndex=b
t=s.exec(a)
if(t==null)return null
return new A.bz(t)},
bG(a,b){var t,s=this.gbL()
if(s==null)s=A.dp(s)
s.lastIndex=b
t=s.exec(a)
if(t==null)return null
return new A.bz(t)},
$icL:1,
$ift:1}
A.bz.prototype={
gaP(){return this.b.index},
gak(){var t=this.b
return t.index+t[0].length},
$iaQ:1,
$ibn:1}
A.ca.prototype={
gF(a){return new A.cb(this.a,this.b,this.c)}}
A.cb.prototype={
gA(){var t=this.d
return t==null?u.a0.a(t):t},
p(){var t,s,r,q,p,o,n=this,m=n.b
if(m==null)return!1
t=n.c
s=m.length
if(t<=s){r=n.a
q=r.aZ(m,t)
if(q!=null){n.d=q
p=q.gak()
if(q.b.index===p){t=!1
if(r.b.unicode){r=n.c
o=r+1
if(o<s){if(!(r>=0&&r<s))return A.a(m,r)
r=m.charCodeAt(r)
if(r>=55296&&r<=56319){if(!(o>=0))return A.a(m,o)
t=m.charCodeAt(o)
t=t>=56320&&t<=57343}}}p=(t?p+1:p)+1}n.c=p
return!0}}n.b=n.d=null
return!1},
$iw:1}
A.c7.prototype={
gak(){return this.a+this.c.length},
$iaQ:1,
gaP(){return this.a}}
A.cg.prototype={
gF(a){return new A.ch(this.a,this.b,this.c)}}
A.ch.prototype={
p(){var t,s,r=this,q=r.c,p=r.b,o=p.length,n=r.a,m=n.length
if(q+o>m){r.d=null
return!1}t=n.indexOf(p,q)
if(t<0){r.c=m+1
r.d=null
return!1}s=t+o
r.d=new A.c7(t,p)
r.c=s===r.c?s+1:s
return!0},
gA(){var t=this.d
t.toString
return t},
$iw:1}
A.R.prototype={
i(a){return A.bE(v.typeUniverse,this,a)},
a3(a){return A.ew(v.typeUniverse,this,a)}}
A.cd.prototype={}
A.d1.prototype={
j(a){return A.E(this.a,null)}}
A.cc.prototype={
j(a){return this.a}}
A.aX.prototype={}
A.aB.prototype={
gF(a){var t=this,s=new A.by(t,t.r,t.$ti.i("by<1>"))
s.c=t.e
return s},
gn(a){return this.a},
O(a,b){var t,s
if(b!=="__proto__"){t=this.b
if(t==null)return!1
return u.O.a(t[b])!=null}else{s=this.bA(b)
return s}},
bA(a){var t=this.d
if(t==null)return!1
return this.b_(t[B.e.gH(a)&1073741823],a)>=0},
h(a,b){var t,s,r=this
r.$ti.c.a(b)
if(typeof b=="string"&&b!=="__proto__"){t=r.b
return r.aX(t==null?r.b=A.dJ():t,b)}else if(typeof b=="number"&&(b&1073741823)===b){s=r.c
return r.aX(s==null?r.c=A.dJ():s,b)}else return r.bv(b)},
bv(a){var t,s,r,q=this
q.$ti.c.a(a)
t=q.d
if(t==null)t=q.d=A.dJ()
s=J.M(a)&1073741823
r=t[s]
if(r==null)t[s]=[q.aq(a)]
else{if(q.b_(r,a)>=0)return!1
r.push(q.aq(a))}return!0},
aX(a,b){this.$ti.c.a(b)
if(u.O.a(a[b])!=null)return!1
a[b]=this.aq(b)
return!0},
aq(a){var t=this,s=new A.cf(t.$ti.c.a(a))
if(t.e==null)t.e=t.f=s
else t.f=t.f.b=s;++t.a
t.r=t.r+1&1073741823
return s},
b_(a,b){var t,s
if(a==null)return-1
t=a.length
for(s=0;s<t;++s)if(J.cj(a[s].a,b))return s
return-1},
$ief:1}
A.cf.prototype={}
A.by.prototype={
gA(){var t=this.d
return t==null?this.$ti.c.a(t):t},
p(){var t=this,s=t.c,r=t.a
if(t.b!==r.r)throw A.b(A.Q(r))
else if(s==null){t.d=null
return!1}else{t.d=t.$ti.i("1?").a(s.a)
t.c=s.b
return!0}},
$iw:1}
A.aP.prototype={
al(a,b){var t,s,r,q=this,p=A.O(q)
p.i("~(1,2)").a(b)
for(t=new A.av(q,q.r,q.e,p.i("av<1>")),p=p.y[1];t.p();){s=t.d
r=q.u(0,s)
b.$2(s,r==null?p.a(r):r)}},
gn(a){return this.a},
gaJ(a){return this.a===0},
j(a){return A.dG(this)},
$iV:1}
A.cu.prototype={
$2(a,b){var t,s=this.a
if(!s.a)this.b.a+=", "
s.a=!1
s=this.b
t=A.m(a)
s.a=(s.a+=t)+": "
t=A.m(b)
s.a+=t},
$S:4}
A.aa.prototype={
j(a){return A.ea(this,"{","}")},
$io:1,
$ij:1,
$ic5:1}
A.bA.prototype={}
A.bM.prototype={}
A.bO.prototype={}
A.bi.prototype={
j(a){var t=A.bP(this.a)
return(this.b!=null?"Converting object to an encodable object failed:":"Converting object did not return an encodable object:")+" "+t}}
A.bZ.prototype={
j(a){return"Cyclic error in JSON stringify"}}
A.cn.prototype={
bl(a,b){var t=A.fz(a,this.gcd().b,null)
return t},
gcd(){return B.M}}
A.co.prototype={}
A.cU.prototype={
bp(a){var t,s,r,q,p,o,n=a.length
for(t=this.c,s=0,r=0;r<n;++r){q=a.charCodeAt(r)
if(q>92){if(q>=55296){p=q&64512
if(p===55296){o=r+1
o=!(o<n&&(a.charCodeAt(o)&64512)===56320)}else o=!1
if(!o)if(p===56320){p=r-1
p=!(p>=0&&(a.charCodeAt(p)&64512)===55296)}else p=!1
else p=!0
if(p){if(r>s)t.a+=B.e.I(a,s,r)
s=r+1
p=A.x(92)
t.a+=p
p=A.x(117)
t.a+=p
p=A.x(100)
t.a+=p
p=q>>>8&15
p=A.x(p<10?48+p:87+p)
t.a+=p
p=q>>>4&15
p=A.x(p<10?48+p:87+p)
t.a+=p
p=q&15
p=A.x(p<10?48+p:87+p)
t.a+=p}}continue}if(q<32){if(r>s)t.a+=B.e.I(a,s,r)
s=r+1
p=A.x(92)
t.a+=p
switch(q){case 8:p=A.x(98)
t.a+=p
break
case 9:p=A.x(116)
t.a+=p
break
case 10:p=A.x(110)
t.a+=p
break
case 12:p=A.x(102)
t.a+=p
break
case 13:p=A.x(114)
t.a+=p
break
default:p=A.x(117)
t.a+=p
p=A.x(48)
t.a=(t.a+=p)+p
p=q>>>4&15
p=A.x(p<10?48+p:87+p)
t.a+=p
p=q&15
p=A.x(p<10?48+p:87+p)
t.a+=p
break}}else if(q===34||q===92){if(r>s)t.a+=B.e.I(a,s,r)
s=r+1
p=A.x(92)
t.a+=p
p=A.x(q)
t.a+=p}}if(s===0)t.a+=a
else if(s<n)t.a+=B.e.I(a,s,n)},
ap(a){var t,s,r,q
for(t=this.a,s=t.length,r=0;r<s;++r){q=t[r]
if(a==null?q==null:a===q)throw A.b(new A.bZ(a,null))}B.a.h(t,a)},
an(a){var t,s,r,q,p=this
if(p.bo(a))return
p.ap(a)
try{t=p.b.$1(a)
if(!p.bo(t)){r=A.ed(a,null,p.gbc())
throw A.b(r)}r=p.a
if(0>=r.length)return A.a(r,-1)
r.pop()}catch(q){s=A.dY(q)
r=A.ed(a,s,p.gbc())
throw A.b(r)}},
bo(a){var t,s,r=this
if(typeof a=="number"){if(!isFinite(a))return!1
r.c.a+=B.b.j(a)
return!0}else if(a===!0){r.c.a+="true"
return!0}else if(a===!1){r.c.a+="false"
return!0}else if(a==null){r.c.a+="null"
return!0}else if(typeof a=="string"){t=r.c
t.a+='"'
r.bp(a)
t.a+='"'
return!0}else if(u.j.b(a)){r.ap(a)
r.cp(a)
t=r.a
if(0>=t.length)return A.a(t,-1)
t.pop()
return!0}else if(u.bC.b(a)){r.ap(a)
s=r.cq(a)
t=r.a
if(0>=t.length)return A.a(t,-1)
t.pop()
return s}else return!1},
cp(a){var t,s,r=this.c
r.a+="["
t=a.length
if(t!==0){if(0>=t)return A.a(a,0)
this.an(a[0])
for(s=1;s<a.length;++s){r.a+=","
this.an(a[s])}}r.a+="]"},
cq(a){var t,s,r,q,p,o,n=this,m={}
if(a.gaJ(a)){n.c.a+="{}"
return!0}t=a.gn(a)*2
s=A.dF(t,null,u.X)
r=m.a=0
m.b=!0
a.al(0,new A.cV(m,s))
if(!m.b)return!1
q=n.c
q.a+="{"
for(p='"';r<t;r+=2,p=',"'){q.a+=p
n.bp(A.aY(s[r]))
q.a+='":'
o=r+1
if(!(o<t))return A.a(s,o)
n.an(s[o])}q.a+="}"
return!0}}
A.cV.prototype={
$2(a,b){var t,s
if(typeof a!="string")this.a.b=!1
t=this.b
s=this.a
B.a.D(t,s.a++,a)
B.a.D(t,s.a++,b)},
$S:4}
A.cT.prototype={
gbc(){var t=this.c.a
return t.charCodeAt(0)==0?t:t}}
A.cS.prototype={
j(a){return this.aa()}}
A.p.prototype={}
A.bI.prototype={
j(a){var t=this.a
if(t!=null)return"Assertion failed: "+A.bP(t)
return"Assertion failed"}}
A.bv.prototype={}
A.al.prototype={
gau(){return"Invalid argument"+(!this.a?"(s)":"")},
gar(){return""},
j(a){var t=this,s=t.c,r=s==null?"":" ("+s+")",q=t.d,p=q==null?"":": "+q,o=t.gau()+r+p
if(!t.a)return o
return o+t.gar()+": "+A.bP(t.gaI())},
gaI(){return this.b}}
A.bm.prototype={
gaI(){return A.eB(this.b)},
gau(){return"RangeError"},
gar(){var t,s=this.e,r=this.f
if(s==null)t=r!=null?": Not less than or equal to "+A.m(r):""
else if(r==null)t=": Not greater than or equal to "+A.m(s)
else if(r>s)t=": Not in inclusive range "+A.m(s)+".."+A.m(r)
else t=r<s?": Valid value range is empty":": Only valid value is "+A.m(s)
return t}}
A.bS.prototype={
gaI(){return A.dn(this.b)},
gau(){return"RangeError"},
gar(){if(A.dn(this.b)<0)return": index must not be negative"
var t=this.f
if(t===0)return": no indices are valid"
return": index should be less than "+t},
gn(a){return this.f}}
A.bw.prototype={
j(a){return"Unsupported operation: "+this.a}}
A.bq.prototype={
j(a){return"Bad state: "+this.a}}
A.bN.prototype={
j(a){var t=this.a
if(t==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.bP(t)+"."}}
A.bp.prototype={
j(a){return"Stack Overflow"},
$ip:1}
A.cl.prototype={
j(a){var t=this.a,s=""!==t?"FormatException: "+t:"FormatException",r=this.b
if(typeof r=="string"){if(r.length>78)r=B.e.I(r,0,75)+"..."
return s+"\n"+r}else return s}}
A.j.prototype={
gn(a){var t,s=this.gF(this)
for(t=0;s.p();)++t
return t},
U(a,b){var t,s
A.fr(b,"index")
t=this.gF(this)
for(s=b;t.p();){if(s===0)return t.gA();--s}throw A.b(A.dz(b,b-s,this,"index"))},
j(a){return A.fh(this,"(",")")}}
A.bk.prototype={
gH(a){return A.k.prototype.gH.call(this,0)},
j(a){return"null"}}
A.k.prototype={$ik:1,
Z(a,b){return this===b},
gH(a){return A.c1(this)},
j(a){return"Instance of '"+A.c2(this)+"'"},
ga1(a){return A.hE(this)},
toString(){return this.j(this)}}
A.c3.prototype={
gA(){return this.d},
p(){var t,s,r,q=this,p=q.b=q.c,o=q.a,n=o.length
if(p===n){q.d=-1
return!1}if(!(p<n))return A.a(o,p)
t=o.charCodeAt(p)
s=p+1
if((t&64512)===55296&&s<n){if(!(s<n))return A.a(o,s)
r=o.charCodeAt(s)
if((r&64512)===56320){q.c=s+1
q.d=65536+((t&1023)<<10)+(r&1023)
return!0}}q.c=s
q.d=t
return!0},
$iw:1}
A.ab.prototype={
gn(a){return this.a.length},
j(a){var t=this.a
return t.charCodeAt(0)==0?t:t},
$ifw:1}
A.as.prototype={
aa(){return"JType."+this.b}}
A.cv.prototype={}
A.n.prototype={}
A.W.prototype={}
A.br.prototype={}
A.b4.prototype={}
A.ag.prototype={}
A.a7.prototype={}
A.X.prototype={}
A.A.prototype={}
A.P.prototype={}
A.r.prototype={}
A.b8.prototype={}
A.am.prototype={}
A.b9.prototype={}
A.b3.prototype={}
A.aW.prototype={}
A.aR.prototype={}
A.aq.prototype={}
A.bt.prototype={}
A.ac.prototype={}
A.aV.prototype={}
A.aS.prototype={}
A.aL.prototype={}
A.aK.prototype={}
A.ao.prototype={
$0(){return this.e.$0()},
$1(a){return this.e.$1(a)},
$2(a,b){return this.e.$2(a,b)},
$3(a,b,c){return this.e.$3(a,b,c)},
$5$stmt(a,b,c,d,e){return this.e.$5$stmt(a,b,c,d,e)},
$2$hint(a,b){return this.e.$2$hint(a,b)}}
A.aU.prototype={}
A.b5.prototype={}
A.aA.prototype={}
A.a1.prototype={}
A.cN.prototype={}
A.cP.prototype={
aN(a,b){this.e.D(0,a,b)
return b}}
A.an.prototype={}
A.dr.prototype={
$1(a){return u.t.a(a).a},
$S:9}
A.d4.prototype={
$1(a){return a.P(0).cs(0)},
$S:5}
A.d5.prototype={
$1(a){var t=a.P(0)
if(t.bq(0,0))throw A.b(a.ae("Ln solo funciona con n\xfameros mayores que cero."))
return Math.log(A.b_(t))},
$S:0}
A.d6.prototype={
$1(a){return Math.exp(A.b_(a.P(0)))},
$S:0}
A.df.prototype={
$1(a){return Math.sin(A.b_(a.P(0)))},
$S:0}
A.dg.prototype={
$1(a){return Math.cos(A.b_(a.P(0)))},
$S:0}
A.dh.prototype={
$1(a){return Math.tan(A.b_(a.P(0)))},
$S:0}
A.di.prototype={
$1(a){A.eL(a)
return void 1},
$S:0}
A.dj.prototype={
$1(a){A.eL(a)
return void 1},
$S:0}
A.dk.prototype={
$1(a){return Math.atan(A.b_(a.P(0)))},
$S:0}
A.dl.prototype={
$1(a){return a.P(0).cB(0)},
$S:2}
A.dm.prototype={
$1(a){return a.P(0).cv(0)},
$S:2}
A.d7.prototype={
$1(a){var t=a.am(0)
if(t.bq(0,0))throw A.b(a.ae("Azar necesita un n\xfamero mayor que cero."))
return a.gcl().cj(t)},
$S:2}
A.d8.prototype={
$1(a){var t=a.am(0),s=a.am(1)
if(t.aL(0,s))throw A.b(a.ae("En Aleatorio(a, b) el primer n\xfamero no puede ser mayor que el segundo."))
return t.ao(0,a.gcl().cj(s.aS(0,t).ao(0,1)))},
$S:2}
A.d9.prototype={
$1(a){return a.a2(0).length},
$S:2}
A.da.prototype={
$1(a){return a.a2(0).cA(0)},
$S:3}
A.db.prototype={
$1(a){return a.a2(0).cz(0)},
$S:3}
A.dc.prototype={
$1(a){return a.a2(0).ao(0,a.a2(1))},
$S:3}
A.dd.prototype={
$1(a){var t=A.hL(a.a2(0))
if(t==null)throw A.b(a.ae('"'+A.m(a.a2(0))+'" no es un n\xfamero.'))
return t},
$S:5}
A.de.prototype={
$1(a){return A.dT(a.P(0))},
$S:3}
A.bc.prototype={}
A.ck.prototype={
aa(){return"ErrorKind."+this.b}}
A.at.prototype={
j(a){return(this.a===B.r?"Error de escritura":"Error al ejecutar")+" (l\xednea "+this.c+"): "+this.b}}
A.Z.prototype={
aa(){return"BlockShape."+this.b}}
A.bb.prototype={}
A.aJ.prototype={}
A.a6.prototype={}
A.C.prototype={}
A.U.prototype={}
A.bR.prototype={}
A.bQ.prototype={}
A.dq.prototype={
$1(a){return u.a4.a(a).a},
$S:10}
A.K.prototype={
aO(a,b){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e=A.d([],u.W)
for(t=f.d,s=t.length,r=0;r<t.length;t.length===s||(0,A.G)(t),++r){q=t[r]
p=q.a
e.push(new A.aJ(new A.bb(p.a+a,p.b+b,p.c,p.d),q.b,q.c,q.d,q.e))}t=A.d([],u.h)
for(s=f.r,p=s.length,r=0;r<s.length;s.length===p||(0,A.G)(s),++r){o=s[r]
t.push(new A.a6(o.a+a,o.b+b,o.c))}s=A.d([],u.R)
for(p=f.e,n=p.length,m=u.f,r=0;r<p.length;p.length===n||(0,A.G)(p),++r){l=p[r]
k=A.d([],m)
for(j=l.a,i=j.length,h=0;h<j.length;j.length===i||(0,A.G)(j),++h){g=j[h]
k.push(new A.h(g.a+a,g.b+b))}s.push(new A.C(k,l.b))}p=A.d([],u.q)
for(n=f.f,m=n.length,r=0;r<n.length;n.length===m||(0,A.G)(n),++r){l=n[r]
p.push(new A.U(l.a+a,l.b+b,l.c))}return A.S(f.a,f.b,f.c,e,t,p,s)},
a0(a,b,c,d){var t=this,s=b.aO(c,d)
B.a.a6(t.d,s.d)
B.a.a6(t.e,s.e)
B.a.a6(t.f,s.f)
B.a.a6(t.r,s.r)}}
A.ce.prototype={
bE(a){return new A.y(this.b).t(u.U.a(a))},
a7(a,b,c,d){var t,s
$label0$0:{if(B.k===a||B.p===a){t=28
break $label0$0}if(B.m===a){t=32
break $label0$0}if(B.q===a){t=16
break $label0$0}t=0
break $label0$0}s=Math.max(90,b.length*this.a.a+32+t)
return A.S(s,40,s/2,A.d([new A.aJ(new A.bb(0,0,s,40),a,b,c,d)],u.W),null,null,null)},
bk(a,b,c){return this.a7(a,b,c,null)},
aR(a,b,c){var t,s,r,q,p,o,n,m
u.ck.a(a)
t=A.d([],u.J)
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.G)(a),++r)t.push(this.bs(a[r]))
q=this.aM(t)
p=new A.cZ(a,b,c)
if(a.length===0){B.a.h(q.r,new A.a6(q.c,0,p.$1(0)))
return q}s=q.r
o=q.c
B.a.h(s,new A.a6(o,-10,p.$1(0)))
for(n=0,m=0;m<t.length;++m){if(m>0){B.a.h(s,new A.a6(o,n+14,p.$1(m)))
n+=28}if(!(m<t.length))return A.a(t,m)
n+=t[m].b}B.a.h(s,new A.a6(o,q.b+10,p.$1(a.length)))
return q},
W(a,b){return this.aR(a,b,null)},
bs(a5){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=this,a4=null
$label0$0:{if(a5 instanceof A.aq){t=a5.a
s=a3.ag(new A.y(a3.b).t(a5.e),t,a5)
r=a3.W(a5.f,t)
q=a3.c.b.u(0,a5)
p=a5.r
if(q!=null)o=a3.W(p==null?B.N:p,q)
else o=a3.aR(p==null?A.d([],u.b):p,t,a5)
t=a3.aW(s,A.d([new A.ai("No",o),new A.ai("S\xed",r)],u.p),!0)
break $label0$0}if(a5 instanceof A.ac){t=a3.c6(a5)
break $label0$0}if(a5 instanceof A.aV){t=a5.a
t=a3.bf(B.l,new A.y(a3.b).t(a5.e),t,a3.W(a5.f,t),"S\xed","No",a5)
break $label0$0}if(a5 instanceof A.aL){n=a5.e
m=a5.f
l=a5.r
k=a5.w
t=a3.b
if(t===B.h){p=new A.y(t).t(m)
j=new A.y(t).t(l)
t=k==null?"1":new A.y(t).t(k)
t=n+" \u2190 "+p+", "+j+", "+t}else{p=new A.y(t).t(m)
j=new A.y(t).t(l)
t=k==null?"":" Con Paso "+new A.y(t).t(k)
t=n+" <- "+p+" Hasta "+j+t}p=a5.a
p=a3.be(B.m,t,p,a3.W(a5.x,p),a5)
t=p
break $label0$0}if(a5 instanceof A.aK){t=a5.a
t=a3.be(B.m,"Para Cada "+a5.e+" de "+a5.f,t,a3.W(a5.r,t),a5)
break $label0$0}if(a5 instanceof A.aS){i=a3.W(a5.e,a5.a)
t=a5.f
h=a3.ag(new A.y(a3.b).t(t),t.a,a5)
g=h.a/2
t=i.c
f=Math.max(g,t)+22
e=A.S(f+Math.max(g,i.a-t),0,f,a4,a4,a4,a4)
p=e.e
j=u.f
B.a.h(p,new A.C(A.d([new A.h(f,0),new A.h(f,14)],j),!0))
e.a0(0,i,f-t,14)
t=14+i.b
d=t+28
B.a.h(p,new A.C(A.d([new A.h(f,t),new A.h(f,d)],j),!0))
t=f-g
e.a0(0,h,t,d)
c=f-f+4
b=h.b
a=d+b/2
B.a.h(p,new A.C(A.d([new A.h(t,a),new A.h(c,a),new A.h(c,7),new A.h(f,7)],j),!0))
a0=a5.r?B.ad:B.ae
a1=e.f
B.a.h(a1,new A.U(t-24,a-16,a0.a))
b=d+b
B.a.h(a1,new A.U(f+6,b+2,a0.b))
a2=b+16.8
B.a.h(p,new A.C(A.d([new A.h(f,b),new A.h(f,a2)],j),!1))
p=A.S(e.a,a2,f,e.d,e.r,a1,p)
t=p
break $label0$0}if(a5 instanceof A.aR){t=a3.a7(B.k,new A.y(a3.b).af(a5),a5.a,a5)
break $label0$0}if(a5 instanceof A.aW){t=a3.a7(B.p,new A.y(a3.b).af(a5),a5.a,a5)
break $label0$0}if(a5 instanceof A.ao){t=a3.a7(B.q,new A.y(a3.b).af(a5),a5.a,a5)
break $label0$0}t=a3.a7(B.x,new A.y(a3.b).af(a5),a5.a,a5)
break $label0$0}return t},
aM(a){var t,s,r,q,p,o,n,m,l,k=null
u.a.a(a)
if(a.length===0)return A.S(45,0,22.5,k,k,k,k)
t=A.t(a)
s=t.i("v(1)")
t=t.i("l<1,v>")
r=new A.l(a,s.a(new A.cX()),t).bn(0,B.y)
t=r+new A.l(a,s.a(new A.cY()),t).bn(0,B.y)
q=A.S(t,0,r,k,k,k,k)
for(s=q.e,p=u.f,o=0,n=0;n<a.length;++n){m=a[n]
if(n>0){l=o+28
B.a.h(s,new A.C(A.d([new A.h(r,o),new A.h(r,l)],p),!0))
o=l}q.a0(0,m,r-m.c,o)
o+=m.b}return A.S(t,o,r,q.d,q.r,q.f,s)},
c6(a){var t,s,r,q,p,o,n,m,l,k,j,i=this
u.bh.a(a)
t=a.a
s=i.ag(new A.y(i.b).t(a.e),t,a)
r=A.d([],u.p)
for(q=a.f,p=q.length,o=i.gbD(),n=i.c,m=0;m<q.length;q.length===p||(0,A.G)(q),++m){l=q[m]
k=l.a
j=A.t(k)
j=new A.l(k,j.i("c(1)").a(o),j.i("l<1,c>")).E(0,", ")
k=n.c.u(0,l)
if(k==null)k=t
r.push(new A.ai(j,i.W(l.b,k)))}q=a.r
if(q!=null){p=n.d.u(0,a)
r.push(new A.ai("De Otro Modo",i.W(q,p==null?t:p)))}return i.aW(s,r,!1)},
ag(a,b,c){var t=Math.max(117,a.length*this.a.a*1.35+32+24)
return A.S(t,56,t/2,A.d([new A.aJ(new A.bb(0,0,t,56),B.l,a,b,c)],u.W),null,null,null)},
aW(a8,a9,b0){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7=null
u.bd.a(a9)
t=a8.a/2
s=A.d([],u.cw)
if(b0&&a9.length===2){r=a9.length
if(0>=r)return A.a(a9,0)
q=a9[0].b
if(1>=r)return A.a(a9,1)
r=a9[1]
B.a.h(s,Math.min(-t,-18-(q.a-q.c)))
B.a.h(s,Math.max(t,18+r.b.c))}else{r=B.a.cf(a9,0,new A.cW(),u.i)
p=a9.length
o=-(r+36*(p-1))/2
for(n=0;n<a9.length;a9.length===p||(0,A.G)(a9),++n){r=a9[n].b
B.a.h(s,o+r.c)
o+=r.a+36}}for(r=a9.length,p=s.length,m=t,l=m,k=0;k<r;++k){j=a9[k].b
if(!(k<p))return A.a(s,k)
i=s[k]
h=j.c
l=Math.max(l,-(i-h))
m=Math.max(m,i+j.a-h)}g=A.S(l+m,0,l,a7,a7,a7,a7)
f=l-t
g.a0(0,a8,f,0)
r=a8.b
e=r+(b0?16.8:33.6)
d=r+14
for(p=g.e,i=u.f,h=g.f,c=d+2,b=r/2,a=b-16,a0=l+t,a1=0,k=0;k<a9.length;++k){a2=a9[k]
a3=a2.a
j=a2.b
if(!(k<s.length))return A.a(s,k)
o=l+s[k]
if(b0){a4=k===0
a5=a4?f:a0
B.a.h(p,new A.C(A.d([new A.h(a5,b),new A.h(o,b),new A.h(o,e)],i),!0))
B.a.h(h,new A.U(a4?a5-22:a5+6,a,a3))}else{B.a.h(p,new A.C(A.d([new A.h(l,r),new A.h(l,d),new A.h(o,d),new A.h(o,e)],i),!0))
B.a.h(h,new A.U(o+4,c,a3))}g.a0(0,j,o-j.c,e)
a1=Math.max(a1,j.b)}a6=e+a1+16.8
for(k=0;k<a9.length;++k){if(!(k<s.length))return A.a(s,k)
o=l+s[k]
B.a.h(p,new A.C(A.d([new A.h(o,e+a9[k].b.b),new A.h(o,a6),new A.h(l,a6)],i),!1))}return A.S(g.a,a6,l,g.d,g.r,h,p)},
bf(a,b,a0,a1,a2,a3,a4){var t,s,r,q,p,o,n,m,l,k=null,j=a===B.l?this.ag(b,a0,a4):this.a7(a,b,a0,a4),i=j.a/2,h=a1.c,g=Math.max(i,h)+22,f=g+(Math.max(i,a1.a-h)+22),e=A.S(f,0,g,k,k,k,k),d=e.e,c=u.f
B.a.h(d,new A.C(A.d([new A.h(g,0),new A.h(g,14)],c),!0))
e.a0(0,j,g-i,14)
t=j.b
s=14+t
r=s+28
B.a.h(d,new A.C(A.d([new A.h(g,s),new A.h(g,r)],c),!0))
e.a0(0,a1,g-h,r)
q=r+a1.b
p=q+14
o=g-g+4
B.a.h(d,new A.C(A.d([new A.h(g,q),new A.h(g,p),new A.h(o,p),new A.h(o,7),new A.h(g,7)],c),!0))
n=f-4
m=14+t/2
l=p+16.8
t=g+i
B.a.h(d,new A.C(A.d([new A.h(t,m),new A.h(n,m),new A.h(n,l),new A.h(g,l)],c),!1))
if(a2!=null)B.a.h(e.f,new A.U(g+6,s+2,a2))
if(a3!=null)B.a.h(e.f,new A.U(t+6,m-16,a3))
return A.S(e.a,l,g,e.d,e.r,e.f,d)},
be(a,b,c,d,e){return this.bf(a,b,c,d,null,null,e)}}
A.cZ.prototype={
$1(a){return new A.bc()},
$S:11}
A.cX.prototype={
$1(a){return u.V.a(a).c},
$S:7}
A.cY.prototype={
$1(a){u.V.a(a)
return a.a-a.c},
$S:7}
A.cW.prototype={
$2(a,b){return A.ez(a)+u.bb.a(b).b.a},
$S:12}
A.dt.prototype={
$3(a,b,c){if(!this.a)return"<"+b+' class="'+a+' fig" '+c+"/>"
return"<"+b+' fill="'+A.m(B.U.u(0,a))+'" stroke="#7A6450" '+c+"/>"},
$S:13}
A.c0.prototype={
aa(){return"Notation."+this.b}}
A.y.prototype={
t(a){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this
u.U.a(a)
$label0$0:{if(a instanceof A.W){t=A.dT(a.e)
break $label0$0}if(a instanceof A.br){s=a.e
t=e.a===B.h&&!B.e.O(s,"'")?"'"+s+"'":'"'+s+'"'
break $label0$0}if(a instanceof A.b4){s=a.e
if(e.a===B.h)t=s?".V.":".F."
else t=s?"Verdadero":"Falso"
break $label0$0}if(a instanceof A.ag){r=a.e
t=r
break $label0$0}if(a instanceof A.a7){r=a.e
q=a.f
t=e.ga8()
p=A.t(q)
o=p.i("c(1)")
p=p.i("l<1,c>")
t=e.a===B.h?r+"("+new A.l(q,o.a(t),p).E(0,", ")+")":r+"["+new A.l(q,o.a(t),p).E(0,", ")+"]"
break $label0$0}if(a instanceof A.P){t=e.bx(a)
break $label0$0}n=a instanceof A.X
if(n){m=a.e
t=m
t="no"===t}else{m=null
t=!1}if(t){l=a.f
t=e.a===B.h?"NOT":"NO"
t=t+" "+e.a5(l,3)
break $label0$0}if(n){k=m
t=k+e.a5(a.f,7)
break $label0$0}n=a instanceof A.A
if(n){m=a.e
t=m
t="^"===t}else t=!1
if(t){j=a.f
i=a.r
t=e.a5(j,9)+"^"+e.a5(i,7)
break $label0$0}if(n){k=m
h=A.eJ(a)
g=h===4?5:h
f=e.a===B.h?B.Y.u(0,k):B.Z.u(0,k)
if(f==null)f=k
t=e.a5(a.f,g)+" "+f+" "+e.a5(a.r,h+1)
break $label0$0}t=null}return t},
bx(a){var t,s,r,q,p,o,n,m,l=this
u._.a(a)
t=a.e
s=t.toLowerCase()
r=l.a===B.h
if(r&&s==="subcadena"&&a.f.length===3){q=a.f
r=q.length
p=r===3
o=null
n=null
if(p){if(0>=r)return A.a(q,0)
m=q[0]
if(1>=r)return A.a(q,1)
o=q[1]
if(2>=r)return A.a(q,2)
n=q[2]}else m=null
if(!p)throw A.b(A.fv("Pattern matching error"))
return"SUBSTRING("+l.t(m)+", "+l.t(o)+", "+l.t(new A.A("+",new A.A("-",n,o,0,0),new A.W(1,0,0),0,0))+")"}if(r){r=B.T.u(0,s)
t=r==null?t:r}r=a.f
p=A.t(r)
return t+"("+new A.l(r,p.i("c(1)").a(l.ga8()),p.i("l<1,c>")).E(0,", ")+")"},
a5(a,b){return A.eJ(a)<b?"("+this.t(a)+")":this.t(a)},
af(a){var t,s,r,q,p,o,n,m,l=this,k=", "
$label0$0:{if(a instanceof A.b8){t="Definir "+B.a.E(a.e,k)+" Como "+a.f.c
break $label0$0}if(a instanceof A.b9){s=a.e
t=A.t(s)
t="Dimension "+new A.l(s,t.i("c(1)").a(new A.d_(l)),t.i("l<1,c>")).E(0,k)
break $label0$0}if(a instanceof A.b3){t=l.t(a.e)
r=l.a===B.h?"\u2190":"<-"
r=t+" "+r+" "+l.t(a.f)
t=r
break $label0$0}if(a instanceof A.aW){q=a.e
if(l.a===B.h){u.L.a(q)
t=A.t(q)
t=new A.l(q,t.i("c(1)").a(l.ga8()),t.i("l<1,c>")).E(0,k)}else{t=a.f?"":" Sin Saltar"
u.L.a(q)
r=A.t(q)
r="Escribir"+t+" "+new A.l(q,r.i("c(1)").a(l.ga8()),r.i("l<1,c>")).E(0,k)
t=r}break $label0$0}if(a instanceof A.aR){p=a.e
t=u.L
r=l.ga8()
if(l.a===B.h){t.a(p)
t=A.t(p)
t=new A.l(p,t.i("c(1)").a(r),t.i("l<1,c>")).E(0,k)}else{t.a(p)
t=A.t(p)
t="Leer "+new A.l(p,t.i("c(1)").a(r),t.i("l<1,c>")).E(0,k)}break $label0$0}if(a instanceof A.ao){t=l.t(a.e)
break $label0$0}o=a instanceof A.aU
n=null
if(o){n=a.e
t=n
t=t==null}else t=!1
if(t){t="Esperar Tecla"
break $label0$0}if(o)t=n!=null
else t=!1
if(t){m=o?n:a.e
t=l.t(m==null?u.U.a(m):m)
r=a.f?"Milisegundos":"Segundos"
r="Esperar "+t+" "+r
t=r
break $label0$0}if(a instanceof A.b5){t="Borrar Pantalla"
break $label0$0}if(a instanceof A.aq||a instanceof A.ac||a instanceof A.aV||a instanceof A.aS||a instanceof A.aL||a instanceof A.aK){t=""
break $label0$0}t=null}return t}}
A.d_.prototype={
$1(a){var t,s,r,q,p
u.Y.a(a)
t=this.a
s=t.a===B.h
r=s?"(":"["
q=u.L.a(a.d)
p=A.t(q)
p=new A.l(q,p.i("c(1)").a(t.ga8()),p.i("l<1,c>")).E(0,", ")
t=s?")":"]"
return a.c+r+p+t},
$S:14}
A.cp.prototype={
j(a){return"Language(es)"}}
A.cq.prototype={
cn(){var t,s,r,q,p,o,n,m,l=this,k=null
for(t=l.a,s=t.length,r=l.c;q=l.d,q<s;){p=t[q]
if(p==="\n"){q=l.e
o=l.f
B.a.h(r,new A.aT(B.i,"\n","\n",k,k,q,o))
l.J()}else if(p===" "||p==="\t"||p==="\r"||p==="\ufeff")l.J()
else if(B.e.aQ(t,"//",q))while(!0){q=l.d
if(!(q<s&&t[q]!=="\n"))break
l.J()}else{o=p==="."
if(o){n=$.f3()
if(q>s)A.ci(A.a9(q,0,s,k,k))
q=n.bG(t,q)!=null}else q=!1
if(q)l.bB()
else{q=$.bG().b
if(!q.test(p))if(o){m=l.d+1
o=m<s?t[m]:""
q=q.test(o)}else q=!1
else q=!0
if(q)l.bM()
else if(B.D.O(0,p)||p==="'")l.c5()
else{q=$.e0()
if(q.b.test(p))l.c9()
else l.c7()}}}}B.a.h(r,A.bu(B.d,"",l.e,l.f,k,k,k))
return r},
bd(a){var t=this.d+a,s=this.a
return t<s.length?s[t]:""},
J(){var t=this,s=t.a,r=t.d
if(!(r<s.length))return A.a(s,r)
if(s[r]==="\n"){++t.e
t.f=1}else ++t.f
t.d=r+1},
bM(){var t,s,r,q=this,p=q.e,o=q.f,n=q.d,m=q.a,l=m.length
while(!0){t=q.d
if(t<l){s=$.bG()
t=m[t]
t=s.b.test(t)}else t=!1
if(!t)break
q.J()}if(q.bd(0)==="."){t=$.bG()
s=q.bd(1)
t=t.b.test(s)}else t=!1
if(t){q.J()
while(!0){t=q.d
if(t<l){s=$.bG()
t=m[t]
t=s.b.test(t)}else t=!1
if(!t)break
q.J()}}r=B.e.I(m,n,q.d)
B.a.h(q.c,A.bu(B.E,r,p,o,null,null,A.eR(r)))},
c5(){var t,s,r,q,p=this,o=p.e,n=p.f,m=p.d,l=p.a,k=l.length
if(!(m<k))return A.a(l,m)
t=l[m]
s=t==="'"?A.fl(["'"],u.N):B.D
p.J()
while(!0){r=p.d
if(!(r<k&&!s.O(0,l[r])))break
r=p.d
if(!(r<k))return A.a(l,r)
if(l[r]==="\n")break
p.J()}r=p.d
if(r<k){if(!(r<k))return A.a(l,r)
k=l[r]==="\n"}else k=!0
if(k)throw A.b(A.au("Falta la comilla que cierra este texto.",n,"Cierra el texto con "+t+" en la misma l\xednea.",o))
q=B.e.I(l,m+1,r)
p.J()
B.a.h(p.c,A.bu(B.w,B.e.I(l,m,p.d),o,n,null,null,q))},
c9(){var t,s,r,q,p=this,o=p.e,n=p.f,m=p.d,l=p.a,k=l.length
while(!0){t=p.d
if(t<k){s=$.e0()
t=l[t]
if(!s.b.test(t)){t=$.bG()
s=p.d
if(!(s<k))return A.a(l,s)
s=l[s]
t=t.b.test(s)}else t=!0}else t=!1
if(!t)break
p.J()}r=B.e.I(l,m,p.d)
B.B.u(0,A.Y(r))
l=p.by()
if(l)B.B.u(0,A.Y(r))
q=A.Y(r)
B.a.h(p.c,A.bu(B.c,r,o,n,null,q,null))
return},
by(){var t,s,r=this.d,q=this.a,p=q.length
while(!0){t=r<p
if(t){s=q[r]
s=s===" "||s==="\t"}else s=!1
if(!s)break;++r}return t&&q[r]==="("},
bB(){var t,s=this,r=s.e,q=s.f,p=s.d,o=B.e.I(s.a,p,p+3)
for(t=0;t<3;++t)s.J()
if(1>=o.length)return A.a(o,1)
B.a.h(s.c,A.bu(B.c,o,r,q,null,o[1].toLowerCase()==="v"?"verdadero":"falso",null))},
c7(){var t,s,r,q,p=this,o=null,n=p.e,m=p.f,l=p.a,k=p.d,j=l.length
if(!(k<j))return A.a(l,k)
t=B.X.u(0,l[k])
if(t!=null){p.J()
B.a.h(p.c,A.bu(B.f,t,n,m,o,o,o))
return}for(k=p.d,s=0;s<29;++s){r=B.R[s]
if(B.e.aQ(l,r,k)){for(l=r.length,q=0;q<l;++q)p.J()
B.a.h(p.c,new A.aT(B.f,r,r,o,o,n,m))
return}}if(!(k<j))return A.a(l,k)
throw A.b(A.au("No reconozco el car\xe1cter '"+l[k]+"'.",m,o,n))}}
A.cx.prototype={
gaD(){var t=this.a,s=this.b
s=s>0?s-1:0
if(!(s<t.length))return A.a(t,s)
return t[s].f},
ck(){var t,s,r,q,p,o,n,m,l=this,k='Empieza con "Algoritmo mi_programa" y termina con "FinAlgoritmo".',j=A.ee(u.N,u.Q)
l.ad()
t=l.a
s=null
while(!0){r=l.b
q=t.length
if(!(r<q))return A.a(t,r)
p=t[r]
if(!(p.a!==B.d))break
p=r<q?p:B.a.gl(t)
if(!(p.a===B.c&&p.c==="algoritmo")){o=l.b
p=o<t.length?t[o]:B.a.gl(t)
r=p.a===B.c&&p.c==="proceso"}else r=!0
if(r){n=l.bV()
if(s!=null)throw A.b(A.au("Solo puede haber un Algoritmo por archivo; ya hay uno en la l\xednea "+s.e+".",0,null,n.e))
s=n}else{o=l.b
p=o<t.length?t[o]:B.a.gl(t)
r=!0
if(!(p.a===B.c&&p.c==="funcion")){o=l.b
p=o<t.length?t[o]:B.a.gl(t)
if(!(p.a===B.c&&p.c==="subproceso")){o=l.b
p=o<t.length?t[o]:B.a.gl(t)
r=p.a===B.c&&p.c==="subalgoritmo"}}if(r){n=l.bT()
r=n.a
m=j.u(0,A.Y(r))
if(m!=null)throw A.b(A.au("La funci\xf3n '"+r+"' ya fue definida en la l\xednea "+m.e+".",0,null,n.e))
j.D(0,A.Y(r),n)}else throw A.b(l.G("El c\xf3digo debe ir dentro de 'Algoritmo' ... 'FinAlgoritmo'.",k))}l.ad()}if(s==null)throw A.b(A.au("Falta el bloque principal 'Algoritmo ... FinAlgoritmo'.",0,k,1))
l.c8(j)
return new A.cN(s,j,l.d)},
gX(){var t=this.a,s=this.b
if(!(s<t.length))return A.a(t,s)
return t[s]},
ab(a){var t=this.b+a,s=this.a,r=s.length
if(t<r){if(!(t>=0))return A.a(s,t)
s=s[t]}else s=B.a.gl(s)
return s},
m(){var t,s=this.a,r=this.b
if(!(r<s.length))return A.a(s,r)
t=s[r]
if(t.a!==B.d)this.b=r+1
return t},
N(a,b){var t=this.ab(b)
return t.a===B.c&&t.c===a},
B(a){return this.N(a,0)},
L(a,b){var t=this.ab(b)
return t.a===B.f&&t.b===a},
T(a){return this.L(a,0)},
b1(a){var t=this.ab(a).a
return t===B.i||t===B.d||this.L(";",a)},
ah(){return this.b1(0)},
v(a){if(!this.B(a))return!1
this.m()
return!0},
q(a){if(!this.T(a))return!1
this.m()
return!0},
aT(){return this.q("<-")||this.q("=")||this.q(":=")},
ad(){var t,s,r,q=this,p=q.a
while(!0){t=q.b
s=p.length
if(!(t<s))return A.a(p,t)
r=p[t]
if(r.a!==B.i){r=t<s?r:B.a.gl(p)
t=r.a===B.f&&r.b===";"}else t=!0
if(!t)break
t=q.b
if(!(t<p.length))return A.a(p,t)
if(p[t].a!==B.d)q.b=t+1}},
G(a,b){var t,s=this.a,r=this.b
if(!(r<s.length))return A.a(s,r)
t=s[r]
return A.au(a,t.r,b,t.f)},
K(a){return this.G(a,null)},
av(a,b,c){if(this.v(a))return
throw A.b(this.K("Se esperaba '"+b+"' "+c+", pero encontr\xe9 "+this.gX().M()+"."))},
a4(a,b){if(this.q(a))return
throw A.b(this.K("Se esperaba '"+a+"' "+b+", pero encontr\xe9 "+this.gX().M()+"."))},
R(a){var t,s=this,r=s.a,q=s.b
if(!(q<r.length))return A.a(r,q)
t=r[q]
r=t.a===B.c
if(r&&!B.n.O(0,t.c))return s.m()
if(r){r=t.b
throw A.b(s.G("'"+r+"' es una palabra reservada (el lenguaje ya la usa) y no puede ser un nombre "+a+".","Elige otro nombre, por ejemplo '"+r+"1' o uno que describa el dato, como 'total'."))}throw A.b(s.K("Se esperaba un nombre "+a+", pero encontr\xe9 "+t.M()+"."))},
S(a){var t
if(!this.B("fin"+a))t=this.B("fin")&&this.N(a,1)
else t=!0
return t},
a_(){if(this.B("fin"))this.m()
this.m()},
b2(){var t=this,s=t.a,r=t.b
if(!(r<s.length))return A.a(s,r)
r=s[r]
s=!0
if(!(r.a===B.c&&B.af.O(0,r.c)))if(!(t.B("hasta")&&t.N("que",1)))s=t.B("mientras")&&t.N("que",1)||t.bI()
return s},
bI(){return this.B("de")&&this.N("otro",1)&&this.N("modo",2)},
a9(){var t,s,r=this
if(r.ah())return
t=r.a
s=r.b
if(!(s<t.length))return A.a(t,s)
s=t[s]
if(s.a===B.c&&B.n.O(0,s.c))return
if(r.bK("escribir"))throw A.b(r.G("Sobra "+r.gX().M()+" en esta l\xednea: falta una coma o una comilla.",'Separa con comas lo que muestras y pon los textos entre comillas: Escribir "Hola ", nombre'))
throw A.b(r.G("Sobra "+r.gX().M()+" al final de la instrucci\xf3n.",'Pon cada instrucci\xf3n en su propia l\xednea o sep\xe1ralas con ";".'))},
bK(a){var t,s=this.b,r=this.a,q=r.length,p=s
while(!0){if(p>0){t=p-1
if(!(t<q))return A.a(r,t)
t=r[t]
if(!(s<q))return A.a(r,s)
t=t.f===r[s].f}else t=!1
if(!t)break;--p}if(!(p>=0&&p<q))return A.a(r,p)
r=r[p]
return r.a===B.c&&r.c===a},
bV(){var t,s,r,q,p=this,o=p.m(),n=o.c==="algoritmo",m=n?"Algoritmo":"Proceso"
if(!p.ah())m=p.R("para el algoritmo").b
p.a9()
t=n?"FinAlgoritmo":"FinProceso"
s=p.Y(t,new A.cG(p),o)
p.a_()
r=p.gaD()
p.a9()
q=new A.a1(m,B.P,null,s,o.f,!0)
p.d.aN(q,r)
return q},
bT(){var t,s,r,q,p,o,n=this,m="para la funci\xf3n",l=n.m(),k=n.R(m)
if(n.q("<-")||n.q("=")){t=k.b
k=n.R(m)}else t=null
s=A.d([],u.c)
if(n.q("(")){if(!n.T(")"))do{r=n.R("para el par\xe1metro")
if(n.v("por"))if(!n.v("referencia"))if(!n.v("valor"))throw A.b(n.K("Despu\xe9s de 'Por' se esperaba 'Referencia' o 'Valor'."))
B.a.h(s,new A.aA(r.b))}while(n.q(","))
n.a4(")","para cerrar la lista de par\xe1metros")}n.a9()
q=n.Y("Fin"+l.b,new A.cD(n),l)
n.a_()
p=n.gaD()
n.a9()
o=new A.a1(k.b,s,t,q,l.f,!1)
n.d.aN(o,p)
return o},
Y(a,b,c){var t,s,r,q=this
u.cN.a(b)
t=A.d([],u.b)
for(s=q.a;!0;){q.ad()
r=q.b
if(!(r<s.length))return A.a(s,r)
if(s[r].a===B.d)throw A.b(q.az(c,a))
if(b.$0())return t
if(q.b2()){s=c.b
throw A.b(q.G("Encontr\xe9 "+q.gX().M()+", pero antes falta '"+a+"' para cerrar el '"+s+"' de la l\xednea "+c.f+".","Cierra primero el '"+s+"' con '"+a+"'. Despu\xe9s va "+q.gX().M()+"."))}B.a.h(t,q.ba())}},
az(a,b){var t=a.b,s=a.f
return A.au("Falta '"+b+"' para cerrar el '"+t+"' de la l\xednea "+s+".",a.r,"Cada '"+t+"' necesita su '"+b+"'. Escr\xedbelo en su propia l\xednea, debajo de lo que va dentro del bloque.",s)},
ba(){var t,s,r=this,q=r.a,p=r.b
if(!(p<q.length))return A.a(q,p)
t=q[p]
if(t.a!==B.c)throw A.b(r.K("Esta l\xednea no empieza con una instrucci\xf3n v\xe1lida (encontr\xe9 "+t.M()+")."))
s=t.c
$label0$0:{if("definir"===s){q=r.bP()
break $label0$0}if("dimension"===s||"dimensionar"===s){q=r.bQ()
break $label0$0}if("escribir"===s||"imprimir"===s||"mostrar"===s){q=r.c2()
break $label0$0}if("leer"===s){q=r.bY()
break $label0$0}if("si"===s){q=r.bU()
break $label0$0}if("segun"===s){q=r.c_()
break $label0$0}if("mientras"===s){q=r.c1()
break $label0$0}if("repetir"===s){q=r.bZ()
break $label0$0}if("para"===s){q=r.N("cada",1)?r.bS():r.bR()
break $label0$0}if("esperar"===s){q=r.c0()
break $label0$0}if("borrarpantalla"===s||"limpiarpantalla"===s){q=r.b7()
break $label0$0}if(("borrar"===s||"limpiar"===s)&&r.N("pantalla",1)){q=r.b7()
break $label0$0}q=r.bN()
break $label0$0}r.d.a.D(0,q,r.gaD())
r.a9()
return q},
bN(){var t,s,r,q,p=this,o=p.a,n=p.b
if(!(n<o.length))return A.a(o,n)
t=o[n]
o=t.c
if(B.n.O(0,o)){if(p.L("<-",1)||p.L("=",1)||p.L("[",1)){n=t.b
$label0$0:{if("y"===o){o="'Y' es el operador l\xf3gico. Usa otro nombre, por ejemplo 'y1' o 'coordY'."
break $label0$0}if("o"===o){o="'O' es el operador l\xf3gico. Usa otro nombre, por ejemplo 'o1'."
break $label0$0}o="Elige otro nombre, por ejemplo '"+n+"1'."
break $label0$0}throw A.b(p.G("'"+n+"' es una palabra reservada (el lenguaje ya la usa) y no puede ser el nombre de una variable.",o))}throw A.b(p.K("No se esperaba '"+t.b+"' aqu\xed."))}if(p.L("<-",1)||p.L("=",1)||p.L(":=",1)||p.L("[",1)||p.aw(1)){s=p.bb()
if(!p.aT())throw A.b(p.K("Se esperaba '<-' para asignar un valor a '"+t.b+"'."))
return new A.b3(s,p.C(),t.f,t.r)}if(p.L("(",1)){p.m()
p.m()
r=p.b5(t)
B.a.h(p.c,new A.h(r,!0))
return new A.ao(r,t.f,t.r)}if(p.b1(1)){p.m()
o=t.f
n=t.r
r=new A.P(t.b,B.O,o,n)
B.a.h(p.c,new A.h(r,!0))
return new A.ao(r,o,n)}o=t.b
q=A.dQ(o,B.A)
n=q!=null?"\xbfQuisiste decir '"+q+"'?":"Revisa que est\xe9 bien escrita. Si quer\xedas guardar un valor, usa '"+o+" <- valor'."
throw A.b(p.G("No entiendo la instrucci\xf3n '"+o+"'.",n))},
bb(){var t=this,s=t.aw(1),r=t.R("de variable")
if(t.T("["))return new A.a7(r.b,t.aC(),r.f,r.r)
if(s)return new A.a7(r.b,t.b9(),r.f,r.r)
return new A.ag(r.b,r.f,r.r)},
aw(a){var t,s=this
if(s.L("(",a)){t=a-1
t=s.e.O(0,s.ab(t).c)&&s.ab(t).a===B.c}else t=!1
return t},
b9(){var t,s=this
s.a4("(","para el \xedndice")
t=A.d([s.C()],u.I)
for(;s.q(",");)B.a.h(t,s.C())
s.a4(")","para cerrar el \xedndice")
return t},
aC(){var t=this,s=A.d([],u.I)
for(;t.q("[");){B.a.h(s,t.C())
for(;t.q(",");)B.a.h(s,t.C())
t.a4("]","para cerrar el \xedndice")}return s},
bP(){var t,s,r,q,p,o=this,n=o.m(),m=A.d([],u.s)
do B.a.h(m,o.R("de variable").b)
while(o.q(","))
if(!(o.v("como")||o.v("es")))throw A.b(o.K("Se esperaba 'Como' y un tipo, por ejemplo: Definir "+B.a.gaF(m)+" Como Entero."))
t=o.a
s=o.b
if(!(s<t.length))return A.a(t,s)
r=t[s]
t=r.a===B.c
q=t?B.S.u(0,r.c):null
if(q==null){p=t?A.dQ(r.b,B.Q):null
t=r.M()
s=p!=null?"\xbfQuisiste decir '"+p+"'?":"Los tipos son Entero, Real, Logico, Caracter y Texto."
throw A.b(o.G(t+" no es un tipo de dato v\xe1lido.",s))}o.m()
return new A.b8(m,q,n.f,n.r)},
bQ(){var t,s=this,r=s.m(),q=A.d([],u.r),p=s.e
do{t=s.R("de arreglo")
if(!s.T("["))throw A.b(s.K("Se esperaba '[' con el tama\xf1o del arreglo, por ejemplo: Dimension "+t.b+"[10]."))
B.a.h(q,new A.am(t.b,s.aC(),t.f,t.r))
p.h(0,t.c)}while(s.q(","))
return new A.b9(q,r.f,r.r)},
aU(){var t,s=this
if(s.B("sin"))t=s.N("saltar",1)||s.N("bajar",1)
else t=!1
if(t){s.m()
s.m()
return!0}return s.v("sinsaltar")||s.v("sinbajar")},
c2(){var t,s,r,q,p,o,n,m=this,l=m.m(),k=!m.aU(),j=A.d([],u.I)
if(!m.ah()&&!m.B("sin"))do B.a.h(j,m.C())
while(m.q(","))
if(m.aU())k=!1
t=!1
if(j.length!==0)if(B.a.gl(j) instanceof A.ag){t=m.a
s=m.b
if(!(s<t.length))return A.a(t,s)
t=t[s].a===B.c&&!m.ah()}if(t){r=A.d([u.a2.a(B.a.gl(j)).e],u.s)
t=m.a
q=0
while(!0){p=m.b+q
s=(p<t.length?t[p]:B.a.gl(t)).a
o=!0
if(s!==B.i)if(s!==B.d){p=m.b+q
n=p<t.length?t[p]:B.a.gl(t)
s=n.a===B.f&&n.b===";"}else s=o
else s=o
if(!s){p=m.b+q
s=(p<t.length?t[p]:B.a.gl(t)).a===B.c}else s=!1
if(!s)break
p=m.b+q
B.a.h(r,(p<t.length?t[p]:B.a.gl(t)).b);++q}throw A.b(m.G("Falta poner el texto entre comillas.",'Los textos van entre comillas: Escribir "'+B.a.E(r," ")+'"'))}return new A.aW(j,k,l.f,l.r)},
bY(){var t=this.m(),s=A.d([],u.I)
do B.a.h(s,this.bb())
while(this.q(","))
return new A.aR(s,t.f,t.r)},
bU(){var t,s,r,q,p=this,o=p.m(),n=p.C()
p.v("entonces")
t=p.Y("FinSi",new A.cE(p),o)
if(p.B("sino")){s=p.m().f
r=p.Y("FinSi",new A.cF(p),o)}else{r=null
s=null}p.a_()
q=new A.aq(n,t,r,o.f,o.r)
if(s!=null)p.d.b.D(0,q,s)
return q},
c_(){var t,s,r,q,p,o,n,m,l,k,j,i,h,g=this,f=g.m(),e=g.C()
g.v("hacer")
t=A.d([],u.l)
s=A.d([],u.c4)
for(r=g.a,q=null,p=null;!0;){g.ad()
o=g.b
n=r.length
if(!(o<n))return A.a(r,o)
m=r[o]
if(m.a===B.d)throw A.b(g.az(f,"FinSegun"))
m=o<n?m:B.a.gl(r)
if(!(m.a===B.c&&m.c==="finsegun")){l=g.b
m=l<r.length?r[l]:B.a.gl(r)
if(m.a===B.c&&m.c==="fin"){l=g.b+1
m=l<r.length?r[l]:B.a.gl(r)
o=m.a===B.c&&m.c==="segun"}else o=!1}else o=!0
if(o)break
l=g.b
m=l<r.length?r[l]:B.a.gl(r)
o=!1
if(m.a===B.c&&m.c==="de"){l=g.b+1
m=l<r.length?r[l]:B.a.gl(r)
if(m.a===B.c&&m.c==="otro"){l=g.b+2
m=l<r.length?r[l]:B.a.gl(r)
o=m.a===B.c&&m.c==="modo"}}if(o){o=g.b
n=r.length
if(!(o<n))return A.a(r,o)
k=r[o]
p=k.f
if(k.a!==B.d){++o
g.b=o}if(!(o<n))return A.a(r,o)
if(r[o].a!==B.d)o=g.b=o+1
if(!(o<n))return A.a(r,o)
if(r[o].a!==B.d)g.b=o+1
g.q(":")
q=g.b6(f)
continue}o=g.b
if(!(o<r.length))return A.a(r,o)
B.a.h(s,r[o].f)
j=g.bi()
if(j==null)throw A.b(g.G("Dentro de 'Segun' cada opci\xf3n empieza con un valor seguido de ':'.",'Por ejemplo:  1: Escribir "uno"'))
B.a.h(t,new A.bt(j,g.b6(f)))}g.a_()
i=new A.ac(e,t,q,f.f,f.r)
for(r=g.d,o=r.c,h=0;h<t.length;++h){n=t[h]
if(!(h<s.length))return A.a(s,h)
o.D(0,n,s[h])}if(p!=null)r.d.D(0,i,p)
return i},
bi(){var t,s,r=this,q=r.b,p=r.c,o=p.length
try{if((r.B("caso")||r.B("opcion"))&&!r.L("<-",1))r.m()
t=A.d([r.C()],u.I)
for(;r.q(",");)J.e1(t,r.C())
if(r.q(":"))return t}catch(s){if(!(A.dY(s) instanceof A.at))throw s}r.b=q
B.a.sn(p,o)
return null},
b6(a){var t,s,r,q,p,o,n,m,l=this,k=A.d([],u.b)
for(t=l.c,s=l.a;!0;){l.ad()
r=l.b
q=s.length
if(!(r<q))return A.a(s,r)
p=s[r]
if(p.a===B.d)throw A.b(l.az(a,"FinSegun"))
p=r<q?p:B.a.gl(s)
if(!(p.a===B.c&&p.c==="finsegun")){o=l.b
p=o<s.length?s[o]:B.a.gl(s)
if(p.a===B.c&&p.c==="fin"){o=l.b+1
p=o<s.length?s[o]:B.a.gl(s)
r=p.a===B.c&&p.c==="segun"}else r=!1}else r=!0
if(!r){o=l.b
r=!1
p=o<s.length?s[o]:B.a.gl(s)
if(p.a===B.c&&p.c==="de"){o=l.b+1
p=o<s.length?s[o]:B.a.gl(s)
if(p.a===B.c&&p.c==="otro"){o=l.b+2
p=o<s.length?s[o]:B.a.gl(s)
r=p.a===B.c&&p.c==="modo"}}}else r=!0
if(r)return k
n=l.b
m=t.length
r=l.bi()
l.b=n
B.a.sn(t,m)
if(r!=null)return k
if(l.b2()){t=a.b
throw A.b(l.G("Encontr\xe9 "+l.gX().M()+", pero antes falta 'FinSegun' para cerrar el '"+t+"' de la l\xednea "+a.f+".","Cierra primero el '"+t+"' con 'FinSegun'. Despu\xe9s va "+l.gX().M()+"."))}B.a.h(k,l.ba())}},
c1(){var t,s=this,r=s.m(),q=s.C()
s.v("hacer")
t=s.Y("FinMientras",new A.cI(s),r)
s.a_()
return new A.aV(q,t,r.f,r.r)},
bZ(){var t=this,s=t.m(),r=t.Y("Hasta Que",new A.cH(t),s),q=t.B("hasta")
t.m()
t.m()
return new A.aS(r,t.C(),q,s.f,s.r)},
bR(){var t,s,r,q,p,o=this,n=o.m(),m=o.R("para la variable del ciclo")
if(!o.aT()){t=m.b
throw A.b(o.G("Se esperaba '<-' despu\xe9s de '"+t+"'.","Por ejemplo: Para "+t+" <- 1 Hasta 10 Hacer"))}s=o.C()
o.av("hasta","Hasta","en el ciclo Para")
r=o.C()
if(o.v("con")){o.av("paso","Paso","despu\xe9s de 'Con'")
q=o.C()}else q=null
o.v("hacer")
p=o.Y("FinPara",new A.cC(o),n)
o.a_()
return new A.aL(m.b,s,r,q,p,n.f,n.r)},
bS(){var t,s,r,q=this,p=q.m()
q.m()
t=q.R("para la variable del ciclo")
q.av("de","De","en el ciclo Para Cada")
s=q.R("de arreglo")
q.v("hacer")
r=q.Y("FinPara",new A.cB(q),p)
q.a_()
return new A.aK(t.b,s.b,r,p.f,p.r)},
c0(){var t,s,r=this,q=r.m()
if(r.v("tecla"))return new A.aU(null,!1,q.f,q.r)
t=r.C()
s=r.v("milisegundo")||r.v("milisegundos")
if(!s)if(!(r.v("segundo")||r.v("segundos")))throw A.b(r.K("Se esperaba 'Segundos' o 'Milisegundos', por ejemplo: Esperar 2 Segundos."))
return new A.aU(t,s,q.f,q.r)},
b7(){var t=this.m()
this.v("pantalla")
return new A.b5(t.f,t.r)},
C(){var t,s,r,q,p,o,n=this,m=n.ai()
for(t=n.a;!0;){s=n.b
r=t.length
if(!(s<r))return A.a(t,s)
q=t[s]
p=s<r?q:B.a.gl(t)
s=!0
if(!(p.a===B.c&&p.c==="o")){o=n.b
p=o<t.length?t[o]:B.a.gl(t)
if(!(p.a===B.c&&p.c==="or")){o=n.b
p=o<t.length?t[o]:B.a.gl(t)
if(!(p.a===B.f&&p.b==="|")){o=n.b
p=o<t.length?t[o]:B.a.gl(t)
s=p.a===B.f&&p.b==="||"}}}if(s){s=n.b
if(!(s<t.length))return A.a(t,s)
if(t[s].a!==B.d)n.b=s+1
m=new A.A("o",m,n.ai(),q.f,q.r)}else{o=n.b
p=o<t.length?t[o]:B.a.gl(t)
if(!(p.a===B.c&&p.c==="xor")){o=n.b
p=o<t.length?t[o]:B.a.gl(t)
s=p.a===B.c&&p.c==="xnor"}else s=!0
if(s){s=n.b
if(!(s<t.length))return A.a(t,s)
if(t[s].a!==B.d)n.b=s+1
s=q.c==="xor"?"<>":"="
m=new A.A(s,m,n.ai(),q.f,q.r)}else{o=n.b
p=o<t.length?t[o]:B.a.gl(t)
if(p.a===B.c&&p.c==="nor"){s=n.b
if(!(s<t.length))return A.a(t,s)
if(t[s].a!==B.d)n.b=s+1
s=q.f
r=q.r
m=new A.X("no",new A.A("o",m,n.ai(),s,r),s,r)}else return m}}}},
ai(){var t,s,r,q,p,o,n=this,m=n.aj()
for(t=n.a;!0;){s=n.b
r=t.length
if(!(s<r))return A.a(t,s)
q=t[s]
p=s<r?q:B.a.gl(t)
s=!0
if(!(p.a===B.c&&p.c==="y")){o=n.b
p=o<t.length?t[o]:B.a.gl(t)
if(!(p.a===B.c&&p.c==="and")){o=n.b
p=o<t.length?t[o]:B.a.gl(t)
if(!(p.a===B.f&&p.b==="&")){o=n.b
p=o<t.length?t[o]:B.a.gl(t)
s=p.a===B.f&&p.b==="&&"}}}if(s){s=n.b
if(!(s<t.length))return A.a(t,s)
if(t[s].a!==B.d)n.b=s+1
m=new A.A("y",m,n.aj(),q.f,q.r)}else{o=n.b
p=o<t.length?t[o]:B.a.gl(t)
if(p.a===B.c&&p.c==="nand"){s=n.b
if(!(s<t.length))return A.a(t,s)
if(t[s].a!==B.d)n.b=s+1
s=q.f
r=q.r
m=new A.X("no",new A.A("y",m,n.aj(),s,r),s,r)}else return m}}},
aj(){var t,s=this
if(s.B("no")||s.B("not")||s.T("~")||s.T("!")){t=s.m()
return new A.X("no",s.aj(),t.f,t.r)}return s.bO()},
bO(){var t,s,r=this,q=r.b4(),p=r.a,o=r.b
if(!(o<p.length))return A.a(p,o)
t=p[o]
s=t.a===B.f?B.W.u(0,t.b):null
if(s==null)return q
r.m()
return new A.A(s,q,r.b4(),t.f,t.r)},
b4(){var t,s,r,q=this,p=q.b8(),o=q.a
while(!0){t=q.b
s=t<o.length?o[t]:B.a.gl(o)
if(!(s.a===B.f&&s.b==="+")){t=q.b
s=t<o.length?o[t]:B.a.gl(o)
r=s.a===B.f&&s.b==="-"}else r=!0
if(!r)break
r=q.b
if(!(r<o.length))return A.a(o,r)
s=o[r]
if(s.a!==B.d)q.b=r+1
p=new A.A(s.b,p,q.b8(),s.f,s.r)}return p},
b8(){var t,s,r,q,p,o,n,m=this,l=m.ac()
for(t=m.a;!0;){s=m.b
r=t.length
if(!(s<r))return A.a(t,s)
q=t[s]
p=s<r?q:B.a.gl(t)
if(!(p.a===B.f&&p.b==="*")){o=m.b
p=o<t.length?t[o]:B.a.gl(t)
s=p.a===B.f&&p.b==="/"}else s=!0
if(s)n=q.b
else{o=m.b
p=o<t.length?t[o]:B.a.gl(t)
if(!(p.a===B.f&&p.b==="%")){o=m.b
p=o<t.length?t[o]:B.a.gl(t)
s=p.a===B.c&&p.c==="mod"}else s=!0
if(!s)return l
n="mod"}s=m.b
if(!(s<t.length))return A.a(t,s)
if(t[s].a!==B.d)m.b=s+1
l=new A.A(n,l,m.ac(),q.f,q.r)}},
ac(){var t,s=this
if(s.T("-")){t=s.m()
return new A.X("-",s.ac(),t.f,t.r)}if(s.q("+"))return s.ac()
return s.bW()},
bW(){var t,s=this,r=s.bX()
if(s.T("^")){t=s.m()
return new A.A("^",r,s.ac(),t.f,t.r)}return r},
bX(){var t,s,r,q,p,o=this,n=o.a,m=o.b
if(!(m<n.length))return A.a(n,m)
t=n[m]
s=t.a
if(B.E===s){o.m()
n=t.e
n.toString
return new A.W(A.eA(n),t.f,t.r)}if(B.w===s){o.m()
n=t.e
n.toString
return new A.br(A.aY(n),t.f,t.r)}if(B.f===s&&t.b==="("){o.m()
r=o.C()
o.a4(")","para cerrar el par\xe9ntesis")
return r}if(B.c===s){n=t.c
m=n==="verdadero"
if(m||n==="falso"){o.m()
return new A.b4(m,t.f,t.r)}if(B.n.O(0,n)){m=t.b
n=n==="entonces"||n==="hacer"?"Parece que falta la condici\xf3n antes de '"+m+"'.":null
throw A.b(o.G("Se esperaba un valor, pero encontr\xe9 la palabra '"+m+"'.",n))}if(o.aw(1)){o.m()
return new A.a7(t.b,o.b9(),t.f,t.r)}o.m()
if(o.q("(")){q=o.b5(t)
p=o.bC(q)
if(p!=null)return p
B.a.h(o.c,new A.h(q,!1))
return q}if(o.T("["))return new A.a7(t.b,o.aC(),t.f,t.r)
return new A.ag(t.b,t.f,t.r)}if(B.i===s||B.d===s)throw A.b(o.K("Falta un valor: la instrucci\xf3n termina antes de tiempo."))
throw A.b(o.K("Se esperaba un valor, pero encontr\xe9 "+t.M()+"."))},
b5(a){var t,s=this,r=A.d([],u.I)
if(!s.T(")"))do B.a.h(r,s.C())
while(s.q(","))
t=a.b
s.a4(")","para cerrar la llamada a "+t)
return new A.P(t,r,a.f,a.r)},
bC(a){var t,s,r,q,p,o,n,m,l,k,j,i,h,g=null,f="Exp",e={},d=a.f
e.a=e.b=null
e.b=a.a
e.a=a.b
t=new A.cz(e)
s=new A.cy(e)
r=new A.cA(e)
q=a.e
p=B.a_.u(0,A.Y(q))
if(p!=null)return d.length===1?t.$2(p,d):g
o=A.Y(q)
n=d.length
m="log"===o
if(m){l=1===n
q=l
k=n}else{k=g
l=k
q=!1}if(q)return s.$3("/",t.$2("Ln",d),t.$2("Ln",A.d([new A.W(10,e.b,e.a)],u.I)))
if("sinh"===o)if(m){q=l
j=m}else{l=1===n
q=l
k=n
m=!0
j=!0}else{j=m
q=!1}if(q){q=t.$2(f,d)
if(0>=d.length)return A.a(d,0)
return s.$3("/",s.$3("-",q,t.$2(f,A.d([r.$1(d[0])],u.I))),new A.W(2,e.b,e.a))}if("cosh"===o)if(m)q=l
else{if(j)q=k
else{q=n
k=q
j=!0}l=1===q
q=l
m=!0}else q=!1
if(q){q=t.$2(f,d)
if(0>=d.length)return A.a(d,0)
return s.$3("/",s.$3("+",q,t.$2(f,A.d([r.$1(d[0])],u.I))),new A.W(2,e.b,e.a))}if("tanh"===o)if(m)q=l
else{if(j)q=k
else{q=n
k=q
j=!0}l=1===q
q=l}else q=!1
if(q){e=t.$2(f,d)
if(0>=d.length)return A.a(d,0)
q=u.I
e=s.$3("-",e,t.$2(f,A.d([r.$1(d[0])],q)))
i=t.$2(f,d)
if(0>=d.length)return A.a(d,0)
return s.$3("/",e,s.$3("+",i,t.$2(f,A.d([r.$1(d[0])],q))))}if("substring"===o)r=3===(j?k:n)
else r=!1
if(r){if(1>=n)return A.a(d,1)
r=d[1]
if(2>=n)return A.a(d,2)
h=s.$3("-",s.$3("+",r,d[2]),new A.W(1,e.b,e.a))
e=d.length
if(0>=e)return A.a(d,0)
r=d[0]
if(1>=e)return A.a(d,1)
return t.$2("Subcadena",A.d([r,d[1],h],u.I))}return g},
c8(a){var t,s,r,q,p,o,n,m,l,k,j,i,h,g=", pero se le dieron "
u.bV.a(a)
for(t=this.c,s=t.length,r=0;r<t.length;t.length===s||(0,A.G)(t),++r){q={}
p=t[r]
q.a=null
o=q.a=p.a
n=p.b
p=o.e
m=A.Y(p)
l=a.u(0,m)
k=$.f6().u(0,m)
j=new A.cK(q)
if(l!=null){p=o.f.length
i=l.b.length
if(p!==i)throw A.b(j.$1("'"+l.a+"' recibe "+this.aY(i)+g+q.a.f.length+"."))
if(!n&&l.c==null){t=l.a
throw A.b(j.$2$hint("'"+t+"' no devuelve ning\xfan valor, as\xed que no puede usarse dentro de una expresi\xf3n.","Para que devuelva un valor def\xednela como 'Funcion resultado <- "+t+"(...)'."))}}else if(k!=null){p=o.f.length
i=k.b
if(p!==i)throw A.b(j.$1("'"+k.a+"' recibe "+this.aY(i)+g+q.a.f.length+"."))}else{t=A.O(a).i("bj<2>")
s=u.N
t=A.fm(A.fo(new A.bj(a,t),t.i("c(j.E)").a(new A.cJ()),t.i("j.E"),s),s)
B.a.a6(t,A.hs())
if(n)B.a.a6(t,B.A)
h=A.dQ(p,t)
t=q.a.e
t=n?"No entiendo la instrucci\xf3n '"+t+"'.":"No existe ninguna funci\xf3n llamada '"+t+"'."
throw A.b(j.$2$hint(t,h!=null?"\xbfQuisiste decir '"+h+"'?":null))}}},
aY(a){return a===1?"1 valor":""+a+" valores"}}
A.cG.prototype={
$0(){var t=this.a
return t.S("algoritmo")||t.S("proceso")},
$S:1}
A.cD.prototype={
$0(){var t=this.a
return t.S("funcion")||t.S("subproceso")||t.S("subalgoritmo")},
$S:1}
A.cE.prototype={
$0(){var t=this.a
return t.B("sino")||t.S("si")},
$S:1}
A.cF.prototype={
$0(){return this.a.S("si")},
$S:1}
A.cI.prototype={
$0(){return this.a.S("mientras")},
$S:1}
A.cH.prototype={
$0(){var t=this.a
return(t.B("hasta")||t.B("mientras"))&&t.N("que",1)},
$S:1}
A.cC.prototype={
$0(){return this.a.S("para")},
$S:1}
A.cB.prototype={
$0(){return this.a.S("para")},
$S:1}
A.cz.prototype={
$2(a,b){var t=this.a
return new A.P(a,u.L.a(b),t.b,t.a)},
$S:15}
A.cy.prototype={
$3(a,b,c){var t=this.a
return new A.A(a,b,c,t.b,t.a)},
$S:16}
A.cA.prototype={
$1(a){var t=this.a
return new A.X("-",a,t.b,t.a)},
$S:17}
A.cK.prototype={
$2$hint(a,b){var t=this.a.a
return A.au(a,t.b,b,t.a)},
$1(a){return this.$2$hint(a,null)},
$S:18}
A.cJ.prototype={
$1(a){return u.Q.a(a).a},
$S:19}
A.ae.prototype={
aa(){return"TokenType."+this.b}}
A.aT.prototype={
M(){var t,s=this.a
$label0$0:{if(B.i===s){t="el fin de la l\xednea"
break $label0$0}if(B.d===s){t="el fin del archivo"
break $label0$0}if(B.w===s){t='el texto "'+A.m(this.e)+'"'
break $label0$0}t="'"+this.b+"'"
break $label0$0}return t}}
A.du.prototype={
$1(a){return A.hB(A.aY(a))},
$S:20};(function aliases(){var t=J.a8.prototype
t.bu=t.j})();(function installTearOffs(){var t=hunkHelpers._static_1,s=hunkHelpers._instance_1u,r=hunkHelpers.installStaticTearOff
t(A,"hv","fZ",21)
t(A,"eM","hm",8)
t(A,"ht","hp",8)
s(A.ce.prototype,"gbD","bE",6)
s(A.y.prototype,"ga8","t",6)
r(A,"hK",2,null,["$1$2","$2"],["eQ",function(a,b){return A.eQ(a,b,u.H)}],22,0)})();(function inheritance(){var t=hunkHelpers.inherit,s=hunkHelpers.inheritMany
t(A.k,null)
s(A.k,[A.dC,J.bU,A.bo,J.b2,A.p,A.cO,A.j,A.ax,A.az,A.ah,A.b6,A.bx,A.aa,A.D,A.cQ,A.cw,A.aP,A.cr,A.av,A.aw,A.bg,A.bz,A.cb,A.c7,A.ch,A.R,A.cd,A.d1,A.cf,A.by,A.bM,A.bO,A.cU,A.cS,A.bp,A.cl,A.bk,A.c3,A.ab,A.cv,A.bt,A.aA,A.a1,A.cN,A.cP,A.an,A.bc,A.at,A.bb,A.aJ,A.a6,A.C,A.U,A.bR,A.bQ,A.K,A.ce,A.y,A.cp,A.cq,A.cx,A.aT])
s(J.bU,[J.bW,J.be,J.aO,J.bf,J.ar])
s(J.aO,[J.a8,J.i])
s(J.a8,[J.cM,J.af,J.bh])
t(J.bV,A.bo)
t(J.cm,J.i)
s(J.bf,[J.bd,J.bX])
s(A.p,[A.c_,A.bv,A.bY,A.c9,A.c4,A.cc,A.bi,A.bI,A.al,A.bw,A.bq,A.bN])
s(A.j,[A.o,A.ay,A.ca,A.cg])
s(A.o,[A.I,A.cs,A.bj])
s(A.I,[A.bs,A.l])
t(A.ba,A.ay)
t(A.aD,A.ah)
s(A.aD,[A.h,A.ai])
t(A.B,A.b6)
s(A.aa,[A.b7,A.bA])
t(A.ap,A.b7)
s(A.D,[A.bT,A.bK,A.bL,A.c8,A.dr,A.d4,A.d5,A.d6,A.df,A.dg,A.dh,A.di,A.dj,A.dk,A.dl,A.dm,A.d7,A.d8,A.d9,A.da,A.db,A.dc,A.dd,A.de,A.dq,A.cZ,A.cX,A.cY,A.dt,A.d_,A.cy,A.cA,A.cK,A.cJ,A.du])
t(A.aM,A.bT)
t(A.bl,A.bv)
s(A.c8,[A.c6,A.aI])
t(A.a0,A.aP)
t(A.J,A.a0)
t(A.aX,A.cc)
t(A.aB,A.bA)
s(A.bL,[A.cu,A.cV,A.cW,A.cz])
t(A.bZ,A.bi)
t(A.cn,A.bM)
t(A.co,A.bO)
t(A.cT,A.cU)
s(A.al,[A.bm,A.bS])
s(A.cS,[A.as,A.ck,A.Z,A.c0,A.ae])
s(A.cv,[A.n,A.r,A.am])
s(A.n,[A.W,A.br,A.b4,A.ag,A.a7,A.X,A.A,A.P])
s(A.r,[A.b8,A.b9,A.b3,A.aW,A.aR,A.aq,A.ac,A.aV,A.aS,A.aL,A.aK,A.ao,A.aU,A.b5])
s(A.bK,[A.cG,A.cD,A.cE,A.cF,A.cI,A.cH,A.cC,A.cB])})()
var v={G:typeof self!="undefined"?self:globalThis,typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{F:"int",v:"double",T:"num",c:"String",aE:"bool",bk:"Null",H:"List",k:"Object",V:"Map",aN:"JSObject"},mangledNames:{},types:["v(a5)","aE()","F(a5)","c(a5)","~(k?,k?)","T(a5)","c(n)","v(K)","k(a5)","c(an)","c(aA)","bc(F)","v(v,+label,piece(c,K))","c(c,c,c)","c(am)","P(c,H<n>)","n(c,n,n)","n(n)","at(c{hint:c?})","c(a1)","c(c)","@(@)","0^(0^,0^)<T>"],arrayRti:Symbol("$ti"),rttc:{"2;":(a,b)=>c=>c instanceof A.h&&a.b(c.a)&&b.b(c.b),"2;label,piece":(a,b)=>c=>c instanceof A.ai&&a.b(c.a)&&b.b(c.b)}}
A.fN(v.typeUniverse,JSON.parse('{"bh":"a8","cM":"a8","af":"a8","bW":{"aE":[],"a2":[]},"be":{"a2":[]},"aO":{"aN":[]},"a8":{"aN":[]},"i":{"H":["1"],"o":["1"],"aN":[],"j":["1"]},"bV":{"bo":[]},"cm":{"i":["1"],"H":["1"],"o":["1"],"aN":[],"j":["1"]},"b2":{"w":["1"]},"bf":{"v":[],"T":[]},"bd":{"v":[],"F":[],"T":[],"a2":[]},"bX":{"v":[],"T":[],"a2":[]},"ar":{"c":[],"cL":[],"a2":[]},"c_":{"p":[]},"o":{"j":["1"]},"I":{"o":["1"],"j":["1"]},"bs":{"I":["1"],"o":["1"],"j":["1"],"I.E":"1","j.E":"1"},"ax":{"w":["1"]},"ay":{"j":["2"],"j.E":"2"},"ba":{"ay":["1","2"],"o":["2"],"j":["2"],"j.E":"2"},"az":{"w":["2"]},"l":{"I":["2"],"o":["2"],"j":["2"],"I.E":"2","j.E":"2"},"h":{"aD":[],"ah":[]},"ai":{"aD":[],"ah":[]},"b6":{"V":["1","2"]},"B":{"b6":["1","2"],"V":["1","2"]},"bx":{"w":["1"]},"b7":{"aa":["1"],"c5":["1"],"o":["1"],"j":["1"]},"ap":{"b7":["1"],"aa":["1"],"c5":["1"],"o":["1"],"j":["1"]},"bT":{"D":[],"a_":[]},"aM":{"D":[],"a_":[]},"bl":{"p":[]},"bY":{"p":[]},"c9":{"p":[]},"D":{"a_":[]},"bK":{"D":[],"a_":[]},"bL":{"D":[],"a_":[]},"c8":{"D":[],"a_":[]},"c6":{"D":[],"a_":[]},"aI":{"D":[],"a_":[]},"c4":{"p":[]},"a0":{"aP":["1","2"],"dE":["1","2"],"V":["1","2"]},"cs":{"o":["1"],"j":["1"],"j.E":"1"},"av":{"w":["1"]},"bj":{"o":["1"],"j":["1"],"j.E":"1"},"aw":{"w":["1"]},"J":{"a0":["1","2"],"aP":["1","2"],"dE":["1","2"],"V":["1","2"]},"aD":{"ah":[]},"bg":{"ft":[],"cL":[]},"bz":{"bn":[],"aQ":[]},"ca":{"j":["bn"],"j.E":"bn"},"cb":{"w":["bn"]},"c7":{"aQ":[]},"cg":{"j":["aQ"],"j.E":"aQ"},"ch":{"w":["aQ"]},"cc":{"p":[]},"aX":{"p":[]},"aB":{"aa":["1"],"ef":["1"],"c5":["1"],"o":["1"],"j":["1"]},"by":{"w":["1"]},"aP":{"V":["1","2"]},"aa":{"c5":["1"],"o":["1"],"j":["1"]},"bA":{"aa":["1"],"c5":["1"],"o":["1"],"j":["1"]},"bi":{"p":[]},"bZ":{"p":[]},"v":{"T":[]},"F":{"T":[]},"H":{"o":["1"],"j":["1"]},"bn":{"aQ":[]},"c":{"cL":[]},"bI":{"p":[]},"bv":{"p":[]},"al":{"p":[]},"bm":{"p":[]},"bS":{"p":[]},"bw":{"p":[]},"bq":{"p":[]},"bN":{"p":[]},"bp":{"p":[]},"c3":{"w":["F"]},"ab":{"fw":[]},"P":{"n":[]},"aq":{"r":[]},"ac":{"r":[]},"W":{"n":[]},"br":{"n":[]},"b4":{"n":[]},"ag":{"n":[]},"a7":{"n":[]},"X":{"n":[]},"A":{"n":[]},"b8":{"r":[]},"b9":{"r":[]},"b3":{"r":[]},"aW":{"r":[]},"aR":{"r":[]},"aV":{"r":[]},"aS":{"r":[]},"aL":{"r":[]},"aK":{"r":[]},"ao":{"r":[]},"aU":{"r":[]},"b5":{"r":[]}}'))
A.fM(v.typeUniverse,JSON.parse('{"o":1,"bA":1,"bM":2,"bO":2}'))
var u=(function rtii(){var t=A.b0
return{Y:t("am"),t:t("an"),_:t("P"),w:t("B<c,c>"),M:t("ap<c>"),e:t("o<@>"),C:t("p"),U:t("n"),Z:t("a_"),k:t("j<@>"),r:t("i<am>"),I:t("i<n>"),W:t("i<aJ>"),h:t("i<a6>"),q:t("i<U>"),R:t("i<C>"),D:t("i<bR>"),x:t("i<V<c,k>>"),G:t("i<k>"),c:t("i<aA>"),d:t("i<+(P,aE)>"),p:t("i<+label,piece(c,K)>"),f:t("i<+(v,v)>"),b:t("i<r>"),s:t("i<c>"),l:t("i<bt>"),A:t("i<aT>"),J:t("i<K>"),cw:t("i<v>"),n:t("i<@>"),c4:t("i<F>"),T:t("be"),m:t("aN"),g:t("bh"),cu:t("J<aq,F>"),E:t("J<r,F>"),aS:t("J<a1,F>"),v:t("J<bt,F>"),B:t("J<ac,F>"),L:t("H<n>"),bd:t("H<+label,piece(c,K)>"),ck:t("H<r>"),a:t("H<K>"),j:t("H<@>"),bV:t("V<c,a1>"),bC:t("V<@,@>"),P:t("bk"),K:t("k"),a4:t("aA"),cY:t("hW"),F:t("+()"),bb:t("+label,piece(c,K)"),a0:t("bn"),N:t("c"),Q:t("a1"),bh:t("ac"),bW:t("a2"),o:t("af"),a2:t("ag"),V:t("K"),y:t("aE"),cN:t("aE()"),i:t("v"),S:t("F"),bc:t("e9<bk>?"),z:t("aN?"),da:t("H<V<c,k>>?"),X:t("k?"),aD:t("c?"),O:t("cf?"),u:t("aE?"),dd:t("v?"),a3:t("F?"),ae:t("T?"),H:t("T")}})();(function constants(){var t=hunkHelpers.makeConstList
B.I=J.bU.prototype
B.a=J.i.prototype
B.t=J.bd.prototype
B.b=J.bf.prototype
B.e=J.ar.prototype
B.L=J.aO.prototype
B.o=new A.Z("terminal")
B.x=new A.Z("process")
B.k=new A.Z("input")
B.p=new A.Z("output")
B.l=new A.Z("decision")
B.m=new A.Z("loop")
B.q=new A.Z("call")
B.y=new A.aM(A.hK(),A.b0("aM<v>"))
B.F=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.z=new A.cn()
B.a6={}
B.B=new A.B(B.a6,[],A.b0("B<c,H<c>>"))
B.G=new A.cp()
B.j=new A.cO()
B.r=new A.ck("syntax")
B.H=new A.bQ(7.6,16)
B.ah=new A.bQ(7.8,24)
B.M=new A.co(null)
B.O=t([],u.I)
B.P=t([],u.c)
B.N=t([],u.b)
B.A=t(["Definir","Dimension","Escribir","Leer","Si","Sino","Segun","Mientras","Repetir","Para","Esperar","FinSi","FinMientras","FinPara","FinSegun","FinAlgoritmo","FinFuncion","FinSubProceso"],u.s)
B.Q=t(["Entero","Real","Numero","Logico","Caracter","Texto","Cadena"],u.s)
B.R=t(["<-","<=",">=","<>","==","!=",":=","&&","||","+","-","*","/","^","%","(",")","[","]",",",";",":","=","<",">","&","|","~","!"],u.s)
B.aa={entero:0,real:1,numero:2,numerico:3,logico:4,caracter:5,texto:6,cadena:7}
B.J=new A.as("Entero","entero")
B.u=new A.as("Real","real")
B.K=new A.as("L\xf3gico","logico")
B.v=new A.as("Texto","texto")
B.S=new A.B(B.aa,[B.J,B.u,B.u,B.u,B.K,B.v,B.v,B.v],A.b0("B<c,as>"))
B.a1={raiz:0,rc:1,abs:2,longitud:3,redon:4,trunc:5,ln:6,exp:7,sen:8,cos:9,tan:10,asen:11,acos:12,atan:13,azar:14}
B.T=new A.B(B.a1,["SQRT","SQRT","ABS","LEN","ROUND","TRUNC","LN","EXP","SIN","COS","TAN","ASIN","ACOS","ATAN","RANDOM"],u.w)
B.ab={ini:0,io:1,proc:2,dec:3,sal:4}
B.U=new A.B(B.ab,["#F7D995","#F4E3C4","#EFE6DC","#CDEBC5","#DCEFD7"],u.w)
B.a7={"\xe1":0,"\xe9":1,"\xed":2,"\xf3":3,"\xfa":4,"\xfc":5}
B.V=new A.B(B.a7,["a","e","i","o","u","u"],u.w)
B.a2={"=":0,"==":1,"<>":2,"!=":3,"<":4,">":5,"<=":6,">=":7}
B.W=new A.B(B.a2,["=","=","<>","<>","<",">","<=",">="],u.w)
B.a8={"\u2190":0,"\u2260":1,"\u2264":2,"\u2265":3}
B.X=new A.B(B.a8,["<-","<>","<=",">="],u.w)
B.a9={o:0,y:1,mod:2,"<>":3}
B.Y=new A.B(B.a9,["OR","AND","MOD","!="],u.w)
B.a4={o:0,y:1,mod:2}
B.Z=new A.B(B.a4,["O","Y","MOD"],u.w)
B.ac={sqrt:0,abs:1,len:2,round:3,trunc:4,ln:5,exp:6,sin:7,cos:8,tan:9,asin:10,acos:11,atan:12,random:13}
B.a_=new A.B(B.ac,["Raiz","Abs","Longitud","Redon","Trunc","Ln","Exp","Sen","Cos","Tan","ASen","ACos","ATan","Azar"],u.w)
B.C=new A.c0("pseint")
B.h=new A.c0("dfd")
B.ad=new A.h("No","S\xed")
B.ae=new A.h("S\xed","No")
B.a3={'"':0,"\u201c":1,"\u201d":2}
B.D=new A.ap(B.a3,3,u.M)
B.a5={finalgoritmo:0,finproceso:1,finfuncion:2,finsubproceso:3,finsubalgoritmo:4,finsi:5,sino:6,finsegun:7,finmientras:8,finpara:9,fin:10,algoritmo:11,proceso:12,funcion:13,subproceso:14,subalgoritmo:15}
B.af=new A.ap(B.a5,16,u.M)
B.a0={algoritmo:0,finalgoritmo:1,proceso:2,finproceso:3,funcion:4,finfuncion:5,subproceso:6,finsubproceso:7,subalgoritmo:8,finsubalgoritmo:9,definir:10,como:11,dimension:12,dimensionar:13,escribir:14,imprimir:15,mostrar:16,leer:17,si:18,entonces:19,sino:20,finsi:21,segun:22,hacer:23,finsegun:24,mientras:25,finmientras:26,repetir:27,hasta:28,que:29,para:30,con:31,paso:32,finpara:33,cada:34,esperar:35,fin:36,y:37,o:38,no:39,mod:40,verdadero:41,falso:42}
B.n=new A.ap(B.a0,43,u.M)
B.c=new A.ae("word")
B.E=new A.ae("number")
B.w=new A.ae("string")
B.f=new A.ae("symbol")
B.i=new A.ae("newline")
B.d=new A.ae("eof")
B.ag=A.hU("k")})();(function staticFields(){$.L=A.d([],u.G)
$.eh=null
$.e5=null
$.e4=null
$.d0=A.d([],A.b0("i<H<k>?>"))})();(function lazyInitializers(){var t=hunkHelpers.lazyFinal
t($,"hV","dZ",()=>v.getIsolateTag("_$dart_dartClosure"))
t($,"ic","f5",()=>A.d([new J.bV()],A.b0("i<bo>")))
t($,"hX","eU",()=>A.a3(A.cR({
toString:function(){return"$receiver$"}})))
t($,"hY","eV",()=>A.a3(A.cR({$method$:null,
toString:function(){return"$receiver$"}})))
t($,"hZ","eW",()=>A.a3(A.cR(null)))
t($,"i_","eX",()=>A.a3(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(s){return s.message}}()))
t($,"i2","f_",()=>A.a3(A.cR(void 0)))
t($,"i3","f0",()=>A.a3(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(s){return s.message}}()))
t($,"i1","eZ",()=>A.a3(A.el(null)))
t($,"i0","eY",()=>A.a3(function(){try{null.$method$}catch(s){return s.message}}()))
t($,"i5","f2",()=>A.a3(A.el(void 0)))
t($,"i4","f1",()=>A.a3(function(){try{(void 0).$method$}catch(s){return s.message}}()))
t($,"i9","dw",()=>A.dX(B.ag))
t($,"id","f6",()=>{var s,r,q,p=A.ee(u.N,u.t)
for(s=$.e_(),r=0;r<22;++r){q=s[r]
p.D(0,A.Y(q.a),q)}return p})
t($,"i6","e_",()=>A.d([A.q("Raiz",1,A.eM()),A.q("RC",1,A.eM()),A.q("Abs",1,new A.d4()),A.q("Ln",1,new A.d5()),A.q("Exp",1,new A.d6()),A.q("Sen",1,new A.df()),A.q("Cos",1,new A.dg()),A.q("Tan",1,new A.dh()),A.q("ASen",1,new A.di()),A.q("ACos",1,new A.dj()),A.q("ATan",1,new A.dk()),A.q("Trunc",1,new A.dl()),A.q("Redon",1,new A.dm()),A.q("Azar",1,new A.d7()),A.q("Aleatorio",2,new A.d8()),A.q("Longitud",1,new A.d9()),A.q("Mayusculas",1,new A.da()),A.q("Minusculas",1,new A.db()),A.q("Subcadena",3,A.ht()),A.q("Concatenar",2,new A.dc()),A.q("ConvertirANumero",1,new A.dd()),A.q("ConvertirATexto",1,new A.de())],A.b0("i<an>")))
t($,"ia","e0",()=>A.f("[A-Za-z\xc1\xc9\xcd\xd3\xda\xdc\xd1\xe1\xe9\xed\xf3\xfa\xfc\xf1_]",!0))
t($,"i8","bG",()=>A.f("[0-9]",!0))
t($,"i7","f3",()=>A.f("\\.([VvFf])\\.",!0))
t($,"ib","f4",()=>A.f("^[+-]?(\\d+\\.?\\d*|\\.\\d+)([eE][+-]?\\d+)?$",!0))})();(function nativeSupport(){!function(){var t=function(a){var n={}
n[a]=1
return Object.keys(hunkHelpers.convertToFastObject(n))[0]}
v.getIsolateTag=function(a){return t("___dart_"+a+v.isolateTag)}
var s="___dart_isolate_tags_"
var r=Object[s]||(Object[s]=Object.create(null))
var q="_ZxYxX"
for(var p=0;;p++){var o=t(q+"_"+p+"_")
if(!(o in r)){r[o]=1
v.isolateTag=o
break}}}()
hunkHelpers.setOrUpdateInterceptorsByTag({})
hunkHelpers.setOrUpdateLeafTags({})})()
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var t=document.scripts
function onLoad(b){for(var r=0;r<t.length;++r){t[r].removeEventListener("load",onLoad,false)}a(b.target)}for(var s=0;s<t.length;++s){t[s].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var t=A.hJ
if(typeof dartMainRunner==="function"){dartMainRunner(t,[])}else{t([])}})})()