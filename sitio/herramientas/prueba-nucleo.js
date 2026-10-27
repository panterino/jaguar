(function dartProgram(){function copyProperties(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
b[q]=a[q]}}function mixinPropertiesHard(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
if(!b.hasOwnProperty(q)){b[q]=a[q]}}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var s=function(){}
s.prototype={p:{}}
var r=new s()
if(!(Object.getPrototypeOf(r)&&Object.getPrototypeOf(r).p===s.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var q=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(q))return true}}catch(p){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){Object.setPrototypeOf(a.prototype,b.prototype)
return}var s=Object.create(b.prototype)
copyProperties(a.prototype,s)
a.prototype=s}}function inheritMany(a,b){for(var s=0;s<b.length;s++){inherit(b[s],a)}}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazy(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){a[b]=d()}a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){var r=d()
if(a[b]!==s){A.kh(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a,b){if(b!=null)A.j(a,b)
a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.ft(b)
return new s(c,this)}:function(){if(s===null)s=A.ft(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.ft(a).prototype
return s}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number"){h+=x}return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var s=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var r=staticTearOffGetter(s)
a[b]=r}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var s=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var r=instanceTearOffGetter(c,s)
a[b]=r}function setOrUpdateInterceptorsByTag(a){var s=v.interceptorsByTag
if(!s){v.interceptorsByTag=a
return}copyProperties(a,s)}function setOrUpdateLeafTags(a){var s=v.leafTags
if(!s){v.leafTags=a
return}copyProperties(a,s)}function updateTypes(a){var s=v.types
var r=s.length
s.push.apply(s,a)
return r}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var s=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},r=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:s(0,0,null,["$0"],0),_instance_1u:s(0,1,null,["$1"],0),_instance_2u:s(0,2,null,["$2"],0),_instance_0i:s(1,0,null,["$0"],0),_instance_1i:s(1,1,null,["$1"],0),_instance_2i:s(1,2,null,["$2"],0),_static_0:r(0,null,["$0"],0),_static_1:r(1,null,["$1"],0),_static_2:r(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var J={
fy(a,b,c,d){return{i:a,p:b,e:c,x:d}},
fv(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.fw==null){A.k4()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.a(A.h_("Return interceptor for "+A.m(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.ei
if(o==null)o=$.ei=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.k9(a)
if(p!=null)return p
if(typeof a=="function")return B.S
s=Object.getPrototypeOf(a)
if(s==null)return B.B
if(s===Object.prototype)return B.B
if(typeof q=="function"){o=$.ei
if(o==null)o=$.ei=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.u,enumerable:false,writable:true,configurable:true})
return B.u}return B.u},
id(a,b){if(a<0||a>4294967295)throw A.a(A.al(a,0,4294967295,"length",null))
return J.ie(new Array(a),b)},
fP(a,b){if(a<0)throw A.a(A.cp("Length must be a non-negative integer: "+a,null))
return A.j(new Array(a),b.h("n<0>"))},
ie(a,b){var s=A.j(a,b.h("n<0>"))
s.$flags=1
return s},
fQ(a){if(a<256)switch(a){case 9:case 10:case 11:case 12:case 13:case 32:case 133:case 160:return!0
default:return!1}switch(a){case 5760:case 8192:case 8193:case 8194:case 8195:case 8196:case 8197:case 8198:case 8199:case 8200:case 8201:case 8202:case 8232:case 8233:case 8239:case 8287:case 12288:case 65279:return!0
default:return!1}},
ig(a,b){var s,r
for(s=a.length;b<s;){r=a.charCodeAt(b)
if(r!==32&&r!==13&&!J.fQ(r))break;++b}return b},
ih(a,b){var s,r,q
for(s=a.length;b>0;b=r){r=b-1
if(!(r<s))return A.b(a,r)
q=a.charCodeAt(r)
if(q!==32&&q!==13&&!J.fQ(q))break}return b},
aC(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.bA.prototype
return J.cH.prototype}if(typeof a=="string")return J.b2.prototype
if(a==null)return J.bB.prototype
if(typeof a=="boolean")return J.cG.prototype
if(Array.isArray(a))return J.n.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a0.prototype
if(typeof a=="symbol")return J.bE.prototype
if(typeof a=="bigint")return J.bD.prototype
return a}if(a instanceof A.i)return a
return J.fv(a)},
hz(a){if(typeof a=="string")return J.b2.prototype
if(a==null)return a
if(Array.isArray(a))return J.n.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a0.prototype
if(typeof a=="symbol")return J.bE.prototype
if(typeof a=="bigint")return J.bD.prototype
return a}if(a instanceof A.i)return a
return J.fv(a)},
f_(a){if(a==null)return a
if(Array.isArray(a))return J.n.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a0.prototype
if(typeof a=="symbol")return J.bE.prototype
if(typeof a=="bigint")return J.bD.prototype
return a}if(a instanceof A.i)return a
return J.fv(a)},
cn(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.aC(a).a5(a,b)},
hU(a,b){return J.f_(a).k(a,b)},
fF(a,b){return J.f_(a).Z(a,b)},
ag(a){return J.aC(a).gE(a)},
hV(a){return J.f_(a).gbX(a)},
di(a){return J.f_(a).gF(a)},
bl(a){return J.hz(a).gm(a)},
fG(a){return J.aC(a).gv(a)},
co(a){return J.aC(a).i(a)},
cE:function cE(){},
cG:function cG(){},
bB:function bB(){},
v:function v(){},
au:function au(){},
cX:function cX(){},
bZ:function bZ(){},
a0:function a0(){},
bD:function bD(){},
bE:function bE(){},
n:function n(a){this.$ti=a},
cF:function cF(){},
dy:function dy(a){this.$ti=a},
bn:function bn(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
bC:function bC(){},
bA:function bA(){},
cH:function cH(){},
b2:function b2(){}},A={fc:function fc(){},
aw(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
fk(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
eS(a,b,c){return a},
fx(a){var s,r
for(s=$.X.length,r=0;r<s;++r)if(a===$.X[r])return!0
return!1},
fj(a,b,c,d){A.b7(b,"start")
if(c!=null){A.b7(c,"end")
if(b>c)A.bk(A.al(b,0,c,"start",null))}return new A.aQ(a,b,c,d.h("aQ<0>"))},
fT(a,b,c,d){if(t.U.b(a))return new A.bv(a,b,c.h("@<0>").I(d).h("bv<1,2>"))
return new A.aO(a,b,c.h("@<0>").I(d).h("aO<1,2>"))},
fO(){return new A.b8("No element")},
ib(){return new A.b8("Too few elements")},
cL:function cL(a){this.a=a},
dW:function dW(){},
h:function h(){},
O:function O(){},
aQ:function aQ(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
aN:function aN(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aO:function aO(a,b,c){this.a=a
this.b=b
this.$ti=c},
bv:function bv(a,b,c){this.a=a
this.b=b
this.$ti=c},
bM:function bM(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
aj:function aj(a,b,c){this.a=a
this.b=b
this.$ti=c},
N:function N(){},
hF(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
kJ(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.G.b(a)},
m(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.co(a)
return s},
cY(a){var s,r=$.fU
if(r==null)r=$.fU=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
it(a,b){var s,r=/^\s*[+-]?((0x[a-f0-9]+)|(\d+)|([a-z0-9]+))\s*$/i.exec(a)
if(r==null)return null
if(3>=r.length)return A.b(r,3)
s=r[3]
if(s!=null)return parseInt(a,10)
if(r[2]!=null)return parseInt(a,16)
return null},
is(a){var s,r
if(!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(a))return null
s=parseFloat(a)
if(isNaN(s)){r=B.c.aj(a)
if(r==="NaN"||r==="+NaN"||r==="-NaN")return s
return null}return s},
cZ(a){var s,r,q,p
if(a instanceof A.i)return A.V(A.bi(a),null)
s=J.aC(a)
if(s===B.R||s===B.T||t.cr.b(a)){r=B.v(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.V(A.bi(a),null)},
fV(a){var s,r,q
if(a==null||typeof a=="number"||A.aq(a))return J.co(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.as)return a.i(0)
if(a instanceof A.aW)return a.bQ(!0)
s=$.hT()
for(r=0;r<1;++r){q=s[r].dk(a)
if(q!=null)return q}return"Instance of '"+A.cZ(a)+"'"},
J(a){var s
if(0<=a){if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){s=a-65536
return String.fromCharCode((B.e.bO(s,10)|55296)>>>0,s&1023|56320)}}throw A.a(A.al(a,0,1114111,null,null))},
ir(a){var s=a.$thrownJsError
if(s==null)return null
return A.bh(s)},
b(a,b){if(a==null)J.bl(a)
throw A.a(A.hx(a,b))},
hx(a,b){var s,r="index",q=null
if(!A.cj(b))return new A.ab(!0,b,r,q)
s=J.bl(a)
if(b<0||b>=s)return A.dq(b,s,a,q,r)
return new A.b6(q,q,!0,b,r,"Value not in range")},
jN(a){return new A.ab(!0,a,null,null)},
a(a){return A.K(a,new Error())},
K(a,b){var s
if(a==null)a=new A.an()
b.dartException=a
s=A.ki
if("defineProperty" in Object){Object.defineProperty(b,"message",{get:s})
b.name=""}else b.toString=s
return b},
ki(){return J.co(this.dartException)},
bk(a,b){throw A.K(a,b==null?new Error():b)},
dh(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.bk(A.jd(a,b,c),s)},
jd(a,b,c){var s,r,q,p,o,n,m,l,k
if(typeof b=="string")s=b
else{r="[]=;add;removeWhere;retainWhere;removeRange;setRange;setInt8;setInt16;setInt32;setUint8;setUint16;setUint32;setFloat32;setFloat64".split(";")
q=r.length
p=b
if(p>q){c=p/q|0
p%=q}s=r[p]}o=typeof c=="string"?c:"modify;remove from;add to".split(";")[c]
n=t.j.b(a)?"list":"ByteData"
m=a.$flags|0
l="a "
if((m&4)!==0)k="constant "
else if((m&2)!==0){k="unmodifiable "
l="an "}else k=(m&1)!==0?"fixed-length ":""
return new A.c_("'"+s+"': Cannot "+o+" "+l+k+n)},
W(a){throw A.a(A.Y(a))},
ao(a){var s,r,q,p,o,n
a=A.hE(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.j([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.dY(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
dZ(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
fZ(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
fd(a,b){var s=b==null,r=s?null:b.method
return new A.cJ(a,r,s?null:b.receiver)},
aE(a){var s
if(a==null)return new A.dE(a)
if(a instanceof A.bx){s=a.a
return A.aD(a,s==null?A.aA(s):s)}if(typeof a!=="object")return a
if("dartException" in a)return A.aD(a,a.dartException)
return A.jM(a)},
aD(a,b){if(t.R.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
jM(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.e.bO(r,16)&8191)===10)switch(q){case 438:return A.aD(a,A.fd(A.m(s)+" (Error "+q+")",null))
case 445:case 5007:A.m(s)
return A.aD(a,new A.bR())}}if(a instanceof TypeError){p=$.hG()
o=$.hH()
n=$.hI()
m=$.hJ()
l=$.hM()
k=$.hN()
j=$.hL()
$.hK()
i=$.hP()
h=$.hO()
g=p.a_(s)
if(g!=null)return A.aD(a,A.fd(A.af(s),g))
else{g=o.a_(s)
if(g!=null){g.method="call"
return A.aD(a,A.fd(A.af(s),g))}else if(n.a_(s)!=null||m.a_(s)!=null||l.a_(s)!=null||k.a_(s)!=null||j.a_(s)!=null||m.a_(s)!=null||i.a_(s)!=null||h.a_(s)!=null){A.af(s)
return A.aD(a,new A.bR())}}return A.aD(a,new A.d6(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.bW()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.aD(a,new A.ab(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.bW()
return a},
bh(a){var s
if(a instanceof A.bx)return a.b
if(a==null)return new A.cb(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.cb(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
fz(a){if(a==null)return J.ag(a)
if(typeof a=="object")return A.cY(a)
return J.ag(a)},
jZ(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.q(0,a[s],a[r])}return b},
k_(a,b){var s,r=a.length
for(s=0;s<r;++s)b.k(0,a[s])
return b},
jm(a,b,c,d,e,f){t.Z.a(a)
switch(A.ae(b)){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.a(new A.e6("Unsupported number of arguments for wrapped closure"))},
eU(a,b){var s=a.$identity
if(!!s)return s
s=A.jU(a,b)
a.$identity=s
return s},
jU(a,b){var s
switch(b){case 0:s=a.$0
break
case 1:s=a.$1
break
case 2:s=a.$2
break
case 3:s=a.$3
break
case 4:s=a.$4
break
default:s=null}if(s!=null)return s.bind(a)
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.jm)},
i2(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.d3().constructor.prototype):Object.create(new A.b_(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.fL(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.hZ(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.fL(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
hZ(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.a("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.hX)}throw A.a("Error in functionType of tearoff")},
i_(a,b,c,d){var s=A.fK
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
fL(a,b,c,d){if(c)return A.i1(a,b,d)
return A.i_(b.length,d,a,b)},
i0(a,b,c,d){var s=A.fK,r=A.hY
switch(b?-1:a){case 0:throw A.a(new A.d1("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
i1(a,b,c){var s,r
if($.fI==null)$.fI=A.fH("interceptor")
if($.fJ==null)$.fJ=A.fH("receiver")
s=b.length
r=A.i0(s,c,a,b)
return r},
ft(a){return A.i2(a)},
hX(a,b){return A.ch(v.typeUniverse,A.bi(a.a),b)},
fK(a){return a.a},
hY(a){return a.b},
fH(a){var s,r,q,p=new A.b_("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.a(A.cp("Field name "+a+" not found.",null))},
k0(a){return v.getIsolateTag(a)},
k9(a){var s,r,q,p,o,n=A.af($.hA.$1(a)),m=$.eY[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.f3[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=A.hi($.ht.$2(a,n))
if(q!=null){m=$.eY[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.f3[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.f6(s)
$.eY[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.f3[n]=s
return s}if(p==="-"){o=A.f6(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.hC(a,s)
if(p==="*")throw A.a(A.h_(n))
if(v.leafTags[n]===true){o=A.f6(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.hC(a,s)},
hC(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.fy(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
f6(a){return J.fy(a,!1,null,!!a.$iS)},
kb(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.f6(s)
else return J.fy(s,c,null,null)},
k4(){if(!0===$.fw)return
$.fw=!0
A.k5()},
k5(){var s,r,q,p,o,n,m,l
$.eY=Object.create(null)
$.f3=Object.create(null)
A.k3()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.hD.$1(o)
if(n!=null){m=A.kb(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
k3(){var s,r,q,p,o,n,m=B.E()
m=A.bf(B.F,A.bf(B.G,A.bf(B.w,A.bf(B.w,A.bf(B.H,A.bf(B.I,A.bf(B.J(B.v),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.hA=new A.f0(p)
$.ht=new A.f1(o)
$.hD=new A.f2(n)},
bf(a,b){return a(b)||b},
jW(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
fb(a,b,c,d,e,f){var s=b?"m":"",r=c?"":"i",q=d?"u":"",p=e?"s":"",o=function(g,h){try{return new RegExp(g,h)}catch(n){return n}}(a,s+r+q+p+f)
if(o instanceof RegExp)return o
throw A.a(A.fM("Illegal RegExp pattern ("+String(o)+")",a))},
hy(a){if(a.indexOf("$",0)>=0)return a.replace(/\$/g,"$$$$")
return a},
ke(a,b,c,d){var s=b.bv(a,d)
if(s==null)return a
return A.kg(a,s.b.index,s.gbU(),c)},
hE(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
kc(a,b,c){var s=A.kd(a,b,c)
return s},
kd(a,b,c){var s,r,q
if(b===""){if(a==="")return c
s=a.length
for(r=c,q=0;q<s;++q)r=r+a[q]+c
return r.charCodeAt(0)==0?r:r}if(a.indexOf(b,0)<0)return a
if(a.length<500||c.indexOf("$",0)>=0)return a.split(b).join(c)
return a.replace(new RegExp(A.hE(b),"g"),A.hy(c))},
kf(a,b,c,d){return d===0?a.replace(b.b,A.hy(c)):A.ke(a,b,c,d)},
kg(a,b,c,d){return a.substring(0,b)+d+a.substring(c)},
ay:function ay(a,b){this.a=a
this.b=b},
bq:function bq(){},
Z:function Z(a,b,c){this.a=a
this.b=b
this.$ti=c},
c2:function c2(a,b){this.a=a
this.$ti=b},
aT:function aT(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
br:function br(){},
aG:function aG(a,b,c){this.a=a
this.b=b
this.$ti=c},
bV:function bV(){},
dY:function dY(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bR:function bR(){},
cJ:function cJ(a,b,c){this.a=a
this.b=b
this.c=c},
d6:function d6(a){this.a=a},
dE:function dE(a){this.a=a},
bx:function bx(a,b){this.a=a
this.b=b},
cb:function cb(a){this.a=a
this.b=null},
as:function as(){},
cu:function cu(){},
cv:function cv(){},
d4:function d4(){},
d3:function d3(){},
b_:function b_(a,b){this.a=a
this.b=b},
d1:function d1(a){this.a=a},
ai:function ai(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
dC:function dC(a,b){this.a=a
this.b=b
this.c=null},
bI:function bI(a,b){this.a=a
this.$ti=b},
aK:function aK(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
aM:function aM(a,b){this.a=a
this.$ti=b},
aL:function aL(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
bG:function bG(a,b){this.a=a
this.$ti=b},
bH:function bH(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
T:function T(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
f0:function f0(a){this.a=a},
f1:function f1(a){this.a=a},
f2:function f2(a){this.a=a},
aW:function aW(){},
bb:function bb(){},
cI:function cI(a,b){var _=this
_.a=a
_.b=b
_.e=_.d=_.c=null},
c5:function c5(a){this.b=a},
e0:function e0(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
b4:function b4(){},
bP:function bP(){},
cM:function cM(){},
b5:function b5(){},
bN:function bN(){},
bO:function bO(){},
cN:function cN(){},
cO:function cO(){},
cP:function cP(){},
cQ:function cQ(){},
cR:function cR(){},
cS:function cS(){},
cT:function cT(){},
bQ:function bQ(){},
cU:function cU(){},
c6:function c6(){},
c7:function c7(){},
c8:function c8(){},
c9:function c9(){},
fi(a,b){var s=b.c
return s==null?b.c=A.cf(a,"at",[b.x]):s},
fX(a){var s=a.w
if(s===6||s===7)return A.fX(a.x)
return s===11||s===12},
iy(a){return a.as},
bg(a){return A.er(v.typeUniverse,a,!1)},
aX(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.aX(a1,s,a3,a4)
if(r===s)return a2
return A.ha(a1,r,!0)
case 7:s=a2.x
r=A.aX(a1,s,a3,a4)
if(r===s)return a2
return A.h9(a1,r,!0)
case 8:q=a2.y
p=A.be(a1,q,a3,a4)
if(p===q)return a2
return A.cf(a1,a2.x,p)
case 9:o=a2.x
n=A.aX(a1,o,a3,a4)
m=a2.y
l=A.be(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.fn(a1,n,l)
case 10:k=a2.x
j=a2.y
i=A.be(a1,j,a3,a4)
if(i===j)return a2
return A.hb(a1,k,i)
case 11:h=a2.x
g=A.aX(a1,h,a3,a4)
f=a2.y
e=A.jI(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.h8(a1,g,e)
case 12:d=a2.y
a4+=d.length
c=A.be(a1,d,a3,a4)
o=a2.x
n=A.aX(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.fo(a1,n,c,!0)
case 13:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.a(A.cr("Attempted to substitute unexpected RTI kind "+a0))}},
be(a,b,c,d){var s,r,q,p,o=b.length,n=A.es(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.aX(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
jJ(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.es(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.aX(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
jI(a,b,c,d){var s,r=b.a,q=A.be(a,r,c,d),p=b.b,o=A.be(a,p,c,d),n=b.c,m=A.jJ(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.da()
s.a=q
s.b=o
s.c=m
return s},
j(a,b){a[v.arrayRti]=b
return a},
fu(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.k2(s)
return a.$S()}return null},
k6(a,b){var s
if(A.fX(b))if(a instanceof A.as){s=A.fu(a)
if(s!=null)return s}return A.bi(a)},
bi(a){if(a instanceof A.i)return A.L(a)
if(Array.isArray(a))return A.a4(a)
return A.fp(J.aC(a))},
a4(a){var s=a[v.arrayRti],r=t.p
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
L(a){var s=a.$ti
return s!=null?s:A.fp(a)},
fp(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.jl(a,s)},
jl(a,b){var s=a instanceof A.as?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.j0(v.typeUniverse,s.name)
b.$ccache=r
return r},
k2(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.er(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
k1(a){return A.aa(A.L(a))},
fs(a){var s
if(a instanceof A.aW)return a.by()
s=a instanceof A.as?A.fu(a):null
if(s!=null)return s
if(t.bW.b(a))return J.fG(a).a
if(Array.isArray(a))return A.a4(a)
return A.bi(a)},
aa(a){var s=a.r
return s==null?a.r=new A.eq(a):s},
jY(a,b){var s,r,q=b,p=q.length
if(p===0)return t.cD
if(0>=p)return A.b(q,0)
s=A.ch(v.typeUniverse,A.fs(q[0]),"@<0>")
for(r=1;r<p;++r){if(!(r<q.length))return A.b(q,r)
s=A.hc(v.typeUniverse,s,A.fs(q[r]))}return A.ch(v.typeUniverse,s,a)},
a5(a){return A.aa(A.er(v.typeUniverse,a,!1))},
jk(a){var s=this
s.b=A.jF(s)
return s.b(a)},
jF(a){var s,r,q,p,o
if(a===t.K)return A.js
if(A.aZ(a))return A.jw
s=a.w
if(s===6)return A.ji
if(s===1)return A.ho
if(s===7)return A.jn
r=A.jE(a)
if(r!=null)return r
if(s===8){q=a.x
if(a.y.every(A.aZ)){a.f="$i"+q
if(q==="l")return A.jq
if(a===t.m)return A.jp
return A.jv}}else if(s===10){p=A.jW(a.x,a.y)
o=p==null?A.ho:p
return o==null?A.aA(o):o}return A.jg},
jE(a){if(a.w===8){if(a===t.S)return A.cj
if(a===t.i||a===t.o)return A.jr
if(a===t.N)return A.ju
if(a===t.y)return A.aq}return null},
jj(a){var s=this,r=A.jf
if(A.aZ(s))r=A.j8
else if(s===t.K)r=A.aA
else if(A.bj(s)){r=A.jh
if(s===t.a3)r=A.j6
else if(s===t.u)r=A.hi
else if(s===t.cG)r=A.j3
else if(s===t.ae)r=A.hh
else if(s===t.dd)r=A.j5
else if(s===t.aQ)r=A.j7}else if(s===t.S)r=A.ae
else if(s===t.N)r=A.af
else if(s===t.y)r=A.j2
else if(s===t.o)r=A.hg
else if(s===t.i)r=A.j4
else if(s===t.m)r=A.hf
s.a=r
return s.a(a)},
jg(a){var s=this
if(a==null)return A.bj(s)
return A.k7(v.typeUniverse,A.k6(a,s),s)},
ji(a){if(a==null)return!0
return this.x.b(a)},
jv(a){var s,r=this
if(a==null)return A.bj(r)
s=r.f
if(a instanceof A.i)return!!a[s]
return!!J.aC(a)[s]},
jq(a){var s,r=this
if(a==null)return A.bj(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.i)return!!a[s]
return!!J.aC(a)[s]},
jp(a){var s=this
if(a==null)return!1
if(typeof a=="object"){if(a instanceof A.i)return!!a[s.f]
return!0}if(typeof a=="function")return!0
return!1},
hn(a){if(typeof a=="object"){if(a instanceof A.i)return t.m.b(a)
return!0}if(typeof a=="function")return!0
return!1},
jf(a){var s=this
if(a==null){if(A.bj(s))return a}else if(s.b(a))return a
throw A.K(A.hj(a,s),new Error())},
jh(a){var s=this
if(a==null||s.b(a))return a
throw A.K(A.hj(a,s),new Error())},
hj(a,b){return new A.cd("TypeError: "+A.h1(a,A.V(b,null)))},
h1(a,b){return A.cC(a)+": type '"+A.V(A.fs(a),null)+"' is not a subtype of type '"+b+"'"},
a3(a,b){return new A.cd("TypeError: "+A.h1(a,b))},
jn(a){var s=this
return s.x.b(a)||A.fi(v.typeUniverse,s).b(a)},
js(a){return a!=null},
aA(a){if(a!=null)return a
throw A.K(A.a3(a,"Object"),new Error())},
jw(a){return!0},
j8(a){return a},
ho(a){return!1},
aq(a){return!0===a||!1===a},
j2(a){if(!0===a)return!0
if(!1===a)return!1
throw A.K(A.a3(a,"bool"),new Error())},
j3(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.K(A.a3(a,"bool?"),new Error())},
j4(a){if(typeof a=="number")return a
throw A.K(A.a3(a,"double"),new Error())},
j5(a){if(typeof a=="number")return a
if(a==null)return a
throw A.K(A.a3(a,"double?"),new Error())},
cj(a){return typeof a=="number"&&Math.floor(a)===a},
ae(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.K(A.a3(a,"int"),new Error())},
j6(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.K(A.a3(a,"int?"),new Error())},
jr(a){return typeof a=="number"},
hg(a){if(typeof a=="number")return a
throw A.K(A.a3(a,"num"),new Error())},
hh(a){if(typeof a=="number")return a
if(a==null)return a
throw A.K(A.a3(a,"num?"),new Error())},
ju(a){return typeof a=="string"},
af(a){if(typeof a=="string")return a
throw A.K(A.a3(a,"String"),new Error())},
hi(a){if(typeof a=="string")return a
if(a==null)return a
throw A.K(A.a3(a,"String?"),new Error())},
hf(a){if(A.hn(a))return a
throw A.K(A.a3(a,"JSObject"),new Error())},
j7(a){if(a==null)return a
if(A.hn(a))return a
throw A.K(A.a3(a,"JSObject?"),new Error())},
hq(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.V(a[q],b)
return s},
jz(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.hq(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.V(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
hk(a3,a4,a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=", ",a2=null
if(a5!=null){s=a5.length
if(a4==null)a4=A.j([],t.s)
else a2=a4.length
r=a4.length
for(q=s;q>0;--q)B.a.k(a4,"T"+(r+q))
for(p=t.X,o="<",n="",q=0;q<s;++q,n=a1){m=a4.length
l=m-1-q
if(!(l>=0))return A.b(a4,l)
o=o+n+a4[l]
k=a5[q]
j=k.w
if(!(j===2||j===3||j===4||j===5||k===p))o+=" extends "+A.V(k,a4)}o+=">"}else o=""
p=a3.x
i=a3.y
h=i.a
g=h.length
f=i.b
e=f.length
d=i.c
c=d.length
b=A.V(p,a4)
for(a="",a0="",q=0;q<g;++q,a0=a1)a+=a0+A.V(h[q],a4)
if(e>0){a+=a0+"["
for(a0="",q=0;q<e;++q,a0=a1)a+=a0+A.V(f[q],a4)
a+="]"}if(c>0){a+=a0+"{"
for(a0="",q=0;q<c;q+=3,a0=a1){a+=a0
if(d[q+1])a+="required "
a+=A.V(d[q+2],a4)+" "+d[q]}a+="}"}if(a2!=null){a4.toString
a4.length=a2}return o+"("+a+") => "+b},
V(a,b){var s,r,q,p,o,n,m,l=a.w
if(l===5)return"erased"
if(l===2)return"dynamic"
if(l===3)return"void"
if(l===1)return"Never"
if(l===4)return"any"
if(l===6){s=a.x
r=A.V(s,b)
q=s.w
return(q===11||q===12?"("+r+")":r)+"?"}if(l===7)return"FutureOr<"+A.V(a.x,b)+">"
if(l===8){p=A.jL(a.x)
o=a.y
return o.length>0?p+("<"+A.hq(o,b)+">"):p}if(l===10)return A.jz(a,b)
if(l===11)return A.hk(a,b,null)
if(l===12)return A.hk(a.x,b,a.y)
if(l===13){n=a.x
m=b.length
n=m-1-n
if(!(n>=0&&n<m))return A.b(b,n)
return b[n]}return"?"},
jL(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
j1(a,b){var s=a.tR[b]
for(;typeof s=="string";)s=a.tR[s]
return s},
j0(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.er(a,b,!1)
else if(typeof m=="number"){s=m
r=A.cg(a,5,"#")
q=A.es(s)
for(p=0;p<s;++p)q[p]=r
o=A.cf(a,b,q)
n[b]=o
return o}else return m},
j_(a,b){return A.hd(a.tR,b)},
iZ(a,b){return A.hd(a.eT,b)},
er(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.h5(A.h3(a,null,b,!1))
r.set(b,s)
return s},
ch(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.h5(A.h3(a,b,c,!0))
q.set(c,r)
return r},
hc(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.fn(a,b,c.w===9?c.y:[c])
p.set(s,q)
return q},
az(a,b){b.a=A.jj
b.b=A.jk
return b},
cg(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.a8(null,null)
s.w=b
s.as=c
r=A.az(a,s)
a.eC.set(c,r)
return r},
ha(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.iX(a,b,r,c)
a.eC.set(r,s)
return s},
iX(a,b,c,d){var s,r,q
if(d){s=b.w
r=!0
if(!A.aZ(b))if(!(b===t.P||b===t.T))if(s!==6)r=s===7&&A.bj(b.x)
if(r)return b
else if(s===1)return t.P}q=new A.a8(null,null)
q.w=6
q.x=b
q.as=c
return A.az(a,q)},
h9(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.iV(a,b,r,c)
a.eC.set(r,s)
return s},
iV(a,b,c,d){var s,r
if(d){s=b.w
if(A.aZ(b)||b===t.K)return b
else if(s===1)return A.cf(a,"at",[b])
else if(b===t.P||b===t.T)return t.bc}r=new A.a8(null,null)
r.w=7
r.x=b
r.as=c
return A.az(a,r)},
iY(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.a8(null,null)
s.w=13
s.x=b
s.as=q
r=A.az(a,s)
a.eC.set(q,r)
return r},
ce(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
iU(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
cf(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.ce(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.a8(null,null)
r.w=8
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.az(a,r)
a.eC.set(p,q)
return q},
fn(a,b,c){var s,r,q,p,o,n
if(b.w===9){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.ce(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.a8(null,null)
o.w=9
o.x=s
o.y=r
o.as=q
n=A.az(a,o)
a.eC.set(q,n)
return n},
hb(a,b,c){var s,r,q="+"+(b+"("+A.ce(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.a8(null,null)
s.w=10
s.x=b
s.y=c
s.as=q
r=A.az(a,s)
a.eC.set(q,r)
return r},
h8(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.ce(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.ce(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.iU(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.a8(null,null)
p.w=11
p.x=b
p.y=c
p.as=r
o=A.az(a,p)
a.eC.set(r,o)
return o},
fo(a,b,c,d){var s,r=b.as+("<"+A.ce(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.iW(a,b,c,r,d)
a.eC.set(r,s)
return s},
iW(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.es(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.aX(a,b,r,0)
m=A.be(a,c,r,0)
return A.fo(a,n,m,c!==m)}}l=new A.a8(null,null)
l.w=12
l.x=b
l.y=c
l.as=d
return A.az(a,l)},
h3(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
h5(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.iO(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.h4(a,r,l,k,!1)
else if(q===46)r=A.h4(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.aV(a.u,a.e,k.pop()))
break
case 94:k.push(A.iY(a.u,k.pop()))
break
case 35:k.push(A.cg(a.u,5,"#"))
break
case 64:k.push(A.cg(a.u,2,"@"))
break
case 126:k.push(A.cg(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.iQ(a,k)
break
case 38:A.iP(a,k)
break
case 63:p=a.u
k.push(A.ha(p,A.aV(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.h9(p,A.aV(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.iN(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.h6(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.iS(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-2)
break
case 43:n=l.indexOf("(",r)
k.push(l.substring(r,n))
k.push(-4)
k.push(a.p)
a.p=k.length
r=n+1
break
default:throw"Bad character "+q}}}m=k.pop()
return A.aV(a.u,a.e,m)},
iO(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
h4(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===9)o=o.x
n=A.j1(s,o.x)[p]
if(n==null)A.bk('No "'+p+'" in "'+A.iy(o)+'"')
d.push(A.ch(s,o,n))}else d.push(p)
return m},
iQ(a,b){var s,r=a.u,q=A.h2(a,b),p=b.pop()
if(typeof p=="string")b.push(A.cf(r,p,q))
else{s=A.aV(r,a.e,p)
switch(s.w){case 11:b.push(A.fo(r,s,q,a.n))
break
default:b.push(A.fn(r,s,q))
break}}},
iN(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.h2(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.aV(p,a.e,o)
q=new A.da()
q.a=s
q.b=n
q.c=m
b.push(A.h8(p,r,q))
return
case-4:b.push(A.hb(p,b.pop(),s))
return
default:throw A.a(A.cr("Unexpected state under `()`: "+A.m(o)))}},
iP(a,b){var s=b.pop()
if(0===s){b.push(A.cg(a.u,1,"0&"))
return}if(1===s){b.push(A.cg(a.u,4,"1&"))
return}throw A.a(A.cr("Unexpected extended operation "+A.m(s)))},
h2(a,b){var s=b.splice(a.p)
A.h6(a.u,a.e,s)
a.p=b.pop()
return s},
aV(a,b,c){if(typeof c=="string")return A.cf(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.iR(a,b,c)}else return c},
h6(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.aV(a,b,c[s])},
iS(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.aV(a,b,c[s])},
iR(a,b,c){var s,r,q=b.w
if(q===9){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==8)throw A.a(A.cr("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.a(A.cr("Bad index "+c+" for "+b.i(0)))},
k7(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.G(a,b,null,c,null)
r.set(c,s)}return s},
G(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(A.aZ(d))return!0
s=b.w
if(s===4)return!0
if(A.aZ(b))return!1
if(b.w===1)return!0
r=s===13
if(r)if(A.G(a,c[b.x],c,d,e))return!0
q=d.w
p=t.P
if(b===p||b===t.T){if(q===7)return A.G(a,b,c,d.x,e)
return d===p||d===t.T||q===6}if(d===t.K){if(s===7)return A.G(a,b.x,c,d,e)
return s!==6}if(s===7){if(!A.G(a,b.x,c,d,e))return!1
return A.G(a,A.fi(a,b),c,d,e)}if(s===6)return A.G(a,p,c,d,e)&&A.G(a,b.x,c,d,e)
if(q===7){if(A.G(a,b,c,d.x,e))return!0
return A.G(a,b,c,A.fi(a,d),e)}if(q===6)return A.G(a,b,c,p,e)||A.G(a,b,c,d.x,e)
if(r)return!1
p=s!==11
if((!p||s===12)&&d===t.Z)return!0
o=s===10
if(o&&d===t.cY)return!0
if(q===12){if(b===t.g)return!0
if(s!==12)return!1
n=b.y
m=d.y
l=n.length
if(l!==m.length)return!1
c=c==null?n:n.concat(c)
e=e==null?m:m.concat(e)
for(k=0;k<l;++k){j=n[k]
i=m[k]
if(!A.G(a,j,c,i,e)||!A.G(a,i,e,j,c))return!1}return A.hm(a,b.x,c,d.x,e)}if(q===11){if(b===t.g)return!0
if(p)return!1
return A.hm(a,b,c,d,e)}if(s===8){if(q!==8)return!1
return A.jo(a,b,c,d,e)}if(o&&q===10)return A.jt(a,b,c,d,e)
return!1},
hm(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.G(a3,a4.x,a5,a6.x,a7))return!1
s=a4.y
r=a6.y
q=s.a
p=r.a
o=q.length
n=p.length
if(o>n)return!1
m=n-o
l=s.b
k=r.b
j=l.length
i=k.length
if(o+j<n+i)return!1
for(h=0;h<o;++h){g=q[h]
if(!A.G(a3,p[h],a7,g,a5))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.G(a3,p[o+h],a7,g,a5))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.G(a3,k[h],a7,g,a5))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;!0;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.G(a3,e[a+2],a7,g,a5))return!1
break}}for(;b<d;){if(f[b+1])return!1
b+=3}return!0},
jo(a,b,c,d,e){var s,r,q,p,o,n=b.x,m=d.x
for(;n!==m;){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.ch(a,b,r[o])
return A.he(a,p,null,c,d.y,e)}return A.he(a,b.y,null,c,d.y,e)},
he(a,b,c,d,e,f){var s,r=b.length
for(s=0;s<r;++s)if(!A.G(a,b[s],d,e[s],f))return!1
return!0},
jt(a,b,c,d,e){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.G(a,r[s],c,q[s],e))return!1
return!0},
bj(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.aZ(a))if(s!==6)r=s===7&&A.bj(a.x)
return r},
aZ(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
hd(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
es(a){return a>0?new Array(a):v.typeUniverse.sEA},
a8:function a8(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
da:function da(){this.c=this.b=this.a=null},
eq:function eq(a){this.a=a},
d9:function d9(){},
cd:function cd(a){this.a=a},
iH(){var s,r,q
if(self.scheduleImmediate!=null)return A.jO()
if(self.MutationObserver!=null&&self.document!=null){s={}
r=self.document.createElement("div")
q=self.document.createElement("span")
s.a=null
new self.MutationObserver(A.eU(new A.e2(s),1)).observe(r,{childList:true})
return new A.e1(s,r,q)}else if(self.setImmediate!=null)return A.jP()
return A.jQ()},
iI(a){self.scheduleImmediate(A.eU(new A.e3(t.M.a(a)),0))},
iJ(a){self.setImmediate(A.eU(new A.e4(t.M.a(a)),0))},
iK(a){A.fl(B.o,t.M.a(a))},
fl(a,b){var s=B.e.aL(a.a,1000)
return A.iT(s<0?0:s,b)},
iT(a,b){var s=new A.eo()
s.c7(a,b)
return s},
C(a){return new A.d7(new A.F($.y,a.h("F<0>")),a.h("d7<0>"))},
B(a,b){a.$2(0,null)
b.b=!0
return b.a},
e(a,b){A.j9(a,b)},
A(a,b){var s,r,q=b.$ti
q.h("1/?").a(a)
s=a==null?q.c.a(a):a
if(!b.b)b.a.ca(s)
else{r=b.a
if(q.h("at<1>").b(s))r.br(s)
else r.bt(s)}},
z(a,b){var s=A.aE(a),r=A.bh(a),q=b.b,p=b.a
if(q)p.aY(new A.a6(s,r))
else p.bq(new A.a6(s,r))},
j9(a,b){var s,r,q=new A.eM(b),p=new A.eN(b)
if(a instanceof A.F)a.bP(q,p,t.z)
else{s=t.z
if(a instanceof A.F)a.aS(q,p,s)
else{r=new A.F($.y,t._)
r.a=8
r.c=a
r.bP(q,p,s)}}},
D(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.y.c_(new A.eQ(s),t.H,t.S,t.z)},
h7(a,b,c){return 0},
fa(a){var s
if(t.R.b(a)){s=a.gaA()
if(s!=null)return s}return B.O},
fN(a,b){var s
if(!b.b(null))throw A.a(A.f9(null,"computation","The type parameter is not nullable"))
s=new A.F($.y,b.h("F<0>"))
A.iC(a,new A.dp(null,s,b))
return s},
ea(a,b,c){var s,r,q,p,o={},n=o.a=a
for(s=t._;r=n.a,(r&4)!==0;n=a){a=s.a(n.c)
o.a=a}if(n===b){s=A.iz()
b.bq(new A.a6(new A.ab(!0,n,null,"Cannot complete a future with itself"),s))
return}q=b.a&1
s=n.a=r|q
if((s&24)===0){p=t.F.a(b.c)
b.a=b.a&1|4
b.c=n
n.bM(p)
return}if(!c)if(b.c==null)n=(s&16)===0||q!==0
else n=!1
else n=!0
if(n){p=b.au()
b.aB(o.a)
A.aS(b,p)
return}b.a^=2
A.dg(null,null,b.b,t.M.a(new A.eb(o,b)))},
aS(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d={},c=d.a=a
for(s=t.n,r=t.F;!0;){q={}
p=c.a
o=(p&16)===0
n=!o
if(b==null){if(n&&(p&1)===0){m=s.a(c.c)
A.fr(m.a,m.b)}return}q.a=b
l=b.a
for(c=b;l!=null;c=l,l=k){c.a=null
A.aS(d.a,c)
q.a=l
k=l.a}p=d.a
j=p.c
q.b=n
q.c=j
if(o){i=c.c
i=(i&1)!==0||(i&15)===8}else i=!0
if(i){h=c.b.b
if(n){p=p.b===h
p=!(p||p)}else p=!1
if(p){s.a(j)
A.fr(j.a,j.b)
return}g=$.y
if(g!==h)$.y=h
else g=null
c=c.c
if((c&15)===8)new A.ef(q,d,n).$0()
else if(o){if((c&1)!==0)new A.ee(q,j).$0()}else if((c&2)!==0)new A.ed(d,q).$0()
if(g!=null)$.y=g
c=q.c
if(c instanceof A.F){p=q.a.$ti
p=p.h("at<2>").b(c)||!p.y[1].b(c)}else p=!1
if(p){f=q.a.b
if((c.a&24)!==0){e=r.a(f.c)
f.c=null
b=f.aK(e)
f.a=c.a&30|f.a&1
f.c=c.c
d.a=c
continue}else A.ea(c,f,!0)
return}}f=q.a.b
e=r.a(f.c)
f.c=null
b=f.aK(e)
c=q.b
p=q.c
if(!c){f.$ti.c.a(p)
f.a=8
f.c=p}else{s.a(p)
f.a=f.a&1|16
f.c=p}d.a=f
c=f}},
jA(a,b){var s
if(t.C.b(a))return b.c_(a,t.z,t.K,t.l)
s=t.v
if(s.b(a))return s.a(a)
throw A.a(A.f9(a,"onError",u.c))},
jy(){var s,r
for(s=$.bd;s!=null;s=$.bd){$.cl=null
r=s.b
$.bd=r
if(r==null)$.ck=null
s.a.$0()}},
jH(){$.fq=!0
try{A.jy()}finally{$.cl=null
$.fq=!1
if($.bd!=null)$.fB().$1(A.hu())}},
hr(a){var s=new A.d8(a),r=$.ck
if(r==null){$.bd=$.ck=s
if(!$.fq)$.fB().$1(A.hu())}else $.ck=r.b=s},
jD(a){var s,r,q,p=$.bd
if(p==null){A.hr(a)
$.cl=$.ck
return}s=new A.d8(a)
r=$.cl
if(r==null){s.b=p
$.bd=$.cl=s}else{q=r.b
s.b=q
$.cl=r.b=s
if(q==null)$.ck=s}},
ko(a,b){A.eS(a,"stream",t.K)
return new A.de(b.h("de<0>"))},
iC(a,b){var s=$.y
if(s===B.i)return A.fl(a,t.M.a(b))
return A.fl(a,t.M.a(s.bS(b)))},
fr(a,b){A.jD(new A.eP(a,b))},
hp(a,b,c,d,e){var s,r=$.y
if(r===c)return d.$0()
$.y=c
s=r
try{r=d.$0()
return r}finally{$.y=s}},
jC(a,b,c,d,e,f,g){var s,r=$.y
if(r===c)return d.$1(e)
$.y=c
s=r
try{r=d.$1(e)
return r}finally{$.y=s}},
jB(a,b,c,d,e,f,g,h,i){var s,r=$.y
if(r===c)return d.$2(e,f)
$.y=c
s=r
try{r=d.$2(e,f)
return r}finally{$.y=s}},
dg(a,b,c,d){t.M.a(d)
if(B.i!==c){d=c.bS(d)
d=d}A.hr(d)},
e2:function e2(a){this.a=a},
e1:function e1(a,b,c){this.a=a
this.b=b
this.c=c},
e3:function e3(a){this.a=a},
e4:function e4(a){this.a=a},
eo:function eo(){},
ep:function ep(a,b){this.a=a
this.b=b},
d7:function d7(a,b){this.a=a
this.b=!1
this.$ti=b},
eM:function eM(a){this.a=a},
eN:function eN(a){this.a=a},
eQ:function eQ(a){this.a=a},
cc:function cc(a,b){var _=this
_.a=a
_.e=_.d=_.c=_.b=null
_.$ti=b},
bc:function bc(a,b){this.a=a
this.$ti=b},
a6:function a6(a,b){this.a=a
this.b=b},
dp:function dp(a,b,c){this.a=a
this.b=b
this.c=c},
aR:function aR(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
F:function F(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
e7:function e7(a,b){this.a=a
this.b=b},
ec:function ec(a,b){this.a=a
this.b=b},
eb:function eb(a,b){this.a=a
this.b=b},
e9:function e9(a,b){this.a=a
this.b=b},
e8:function e8(a,b){this.a=a
this.b=b},
ef:function ef(a,b,c){this.a=a
this.b=b
this.c=c},
eg:function eg(a,b){this.a=a
this.b=b},
eh:function eh(a){this.a=a},
ee:function ee(a,b){this.a=a
this.b=b},
ed:function ed(a,b){this.a=a
this.b=b},
d8:function d8(a){this.a=a
this.b=null},
de:function de(a){this.$ti=a},
ci:function ci(){},
eP:function eP(a,b){this.a=a
this.b=b},
dd:function dd(){},
en:function en(a,b){this.a=a
this.b=b},
ff(a,b,c){return b.h("@<0>").I(c).h("fe<1,2>").a(A.jZ(a,new A.ai(b.h("@<0>").I(c).h("ai<1,2>"))))},
bJ(a,b){return new A.ai(a.h("@<0>").I(b).h("ai<1,2>"))},
ij(a){return new A.aU(a.h("aU<0>"))},
ik(a,b){return b.h("fS<0>").a(A.k_(a,new A.aU(b.h("aU<0>"))))},
fm(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
fg(a){var s,r
if(A.fx(a))return"{...}"
s=new A.aP("")
try{r={}
B.a.k($.X,a)
s.a+="{"
r.a=!0
a.aP(0,new A.dD(r,s))
s.a+="}"}finally{if(0>=$.X.length)return A.b($.X,-1)
$.X.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
il(a){return 8},
im(a){var s
a=(a<<1>>>0)-1
for(;!0;a=s){s=(a&a-1)>>>0
if(s===0)return a}},
aU:function aU(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
dc:function dc(a){this.a=a
this.b=null},
c3:function c3(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
u:function u(){},
b3:function b3(){},
dD:function dD(a,b){this.a=a
this.b=b},
bK:function bK(a,b){var _=this
_.a=a
_.d=_.c=_.b=0
_.$ti=b},
c4:function c4(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=null
_.$ti=e},
av:function av(){},
ca:function ca(){},
fR(a,b,c){return new A.bF(a,b)},
jc(a){return a.dr()},
iL(a,b){return new A.ej(a,[],A.jV())},
iM(a,b,c){var s,r=new A.aP(""),q=A.iL(r,b)
q.aT(a)
s=r.a
return s.charCodeAt(0)==0?s:s},
cw:function cw(){},
cy:function cy(){},
bF:function bF(a,b){this.a=a
this.b=b},
cK:function cK(a,b){this.a=a
this.b=b},
dz:function dz(){},
dA:function dA(a){this.b=a},
ek:function ek(){},
el:function el(a,b){this.a=a
this.b=b},
ej:function ej(a,b,c){this.c=a
this.a=b
this.b=c},
i3(a,b){a=A.K(a,new Error())
if(a==null)a=A.aA(a)
a.stack=b.i(0)
throw a},
bL(a,b,c,d){var s,r=J.id(a,d)
if(a!==0&&b!=null)for(s=0;s<a;++s)r[s]=b
return r},
ip(a,b,c){var s,r,q=A.j([],c.h("n<0>"))
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.W)(a),++r)B.a.k(q,c.a(a[r]))
q.$flags=1
return q},
io(a,b){var s,r=A.j([],b.h("n<0>"))
for(s=a.gF(a);s.n();)B.a.k(r,s.gp())
return r},
bT(a,b){return new A.cI(a,A.fb(a,!1,b,!1,!1,""))},
fY(a,b,c){var s=J.di(b)
if(!s.n())return a
if(c.length===0){do a+=A.m(s.gp())
while(s.n())}else{a+=A.m(s.gp())
for(;s.n();)a=a+c+A.m(s.gp())}return a},
iz(){return A.bh(new Error())},
cC(a){if(typeof a=="number"||A.aq(a)||a==null)return J.co(a)
if(typeof a=="string")return JSON.stringify(a)
return A.fV(a)},
i4(a,b){A.eS(a,"error",t.K)
A.eS(b,"stackTrace",t.l)
A.i3(a,b)},
cr(a){return new A.cq(a)},
cp(a,b){return new A.ab(!1,null,b,a)},
f9(a,b,c){return new A.ab(!0,a,b,c)},
iw(a){var s=null
return new A.b6(s,s,!1,s,s,a)},
al(a,b,c,d,e){return new A.b6(b,c,!0,a,d,"Invalid value")},
fW(a,b,c){if(0>a||a>c)throw A.a(A.al(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.a(A.al(b,a,c,"end",null))
return b}return c},
b7(a,b){if(a<0)throw A.a(A.al(a,0,null,b,null))
return a},
dq(a,b,c,d,e){return new A.cD(b,!0,a,e,"Index out of range")},
e_(a){return new A.c_(a)},
h_(a){return new A.d5(a)},
iA(a){return new A.b8(a)},
Y(a){return new A.cx(a)},
fM(a,b){return new A.dk(a,b)},
ic(a,b,c){var s,r
if(A.fx(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.j([],t.s)
B.a.k($.X,a)
try{A.jx(a,s)}finally{if(0>=$.X.length)return A.b($.X,-1)
$.X.pop()}r=A.fY(b,t.a.a(s),", ")+c
return r.charCodeAt(0)==0?r:r},
dx(a,b,c){var s,r
if(A.fx(a))return b+"..."+c
s=new A.aP(b)
B.a.k($.X,a)
try{r=s
r.a=A.fY(r.a,a,", ")}finally{if(0>=$.X.length)return A.b($.X,-1)
$.X.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
jx(a,b){var s,r,q,p,o,n,m,l=a.gF(a),k=0,j=0
while(!0){if(!(k<80||j<3))break
if(!l.n())return
s=A.m(l.gp())
B.a.k(b,s)
k+=s.length+2;++j}if(!l.n()){if(j<=5)return
if(0>=b.length)return A.b(b,-1)
r=b.pop()
if(0>=b.length)return A.b(b,-1)
q=b.pop()}else{p=l.gp();++j
if(!l.n()){if(j<=4){B.a.k(b,A.m(p))
return}r=A.m(p)
if(0>=b.length)return A.b(b,-1)
q=b.pop()
k+=r.length+2}else{o=l.gp();++j
for(;l.n();p=o,o=n){n=l.gp();++j
if(j>100){while(!0){if(!(k>75&&j>3))break
if(0>=b.length)return A.b(b,-1)
k-=b.pop().length+2;--j}B.a.k(b,"...")
return}}q=A.m(p)
r=A.m(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
while(!0){if(!(k>80&&b.length>3))break
if(0>=b.length)return A.b(b,-1)
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)B.a.k(b,m)
B.a.k(b,q)
B.a.k(b,r)},
hB(a){var s=B.c.aj(a),r=A.it(s,null)
if(r==null)r=A.is(s)
if(r!=null)return r
throw A.a(A.fM(a,null))},
iq(a,b,c,d){var s
if(B.n===c){s=B.e.gE(a)
b=J.ag(b)
return A.fk(A.aw(A.aw($.f8(),s),b))}if(B.n===d){s=B.e.gE(a)
b=J.ag(b)
c=J.ag(c)
return A.fk(A.aw(A.aw(A.aw($.f8(),s),b),c))}s=B.e.gE(a)
b=J.ag(b)
c=J.ag(c)
d=J.ag(d)
d=A.fk(A.aw(A.aw(A.aw(A.aw($.f8(),s),b),c),d))
return d},
bu:function bu(a){this.a=a},
e5:function e5(){},
p:function p(){},
cq:function cq(a){this.a=a},
an:function an(){},
ab:function ab(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
b6:function b6(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
cD:function cD(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
c_:function c_(a){this.a=a},
d5:function d5(a){this.a=a},
b8:function b8(a){this.a=a},
cx:function cx(a){this.a=a},
cV:function cV(){},
bW:function bW(){},
e6:function e6(a){this.a=a},
dk:function dk(a,b){this.a=a
this.b=b},
d:function d(){},
a7:function a7(a,b,c){this.a=a
this.b=b
this.$ti=c},
H:function H(){},
i:function i(){},
df:function df(){},
d0:function d0(a){var _=this
_.a=a
_.c=_.b=0
_.d=-1},
aP:function aP(a){this.a=a},
i7(a,b){return A.hf(new v.G.Promise(A.hl(new A.dn(a))))},
dn:function dn(a){this.a=a},
dl:function dl(a){this.a=a},
dm:function dm(a){this.a=a},
db:function db(){},
aI:function aI(a,b){this.c=a
this.b=b},
q:function q(){},
r:function r(){},
ak:function ak(a,b,c){this.e=a
this.a=b
this.b=c},
bX:function bX(a,b,c){this.e=a
this.a=b
this.b=c},
bp:function bp(a,b,c){this.e=a
this.a=b
this.b=c},
a1:function a1(a,b,c){this.e=a
this.a=b
this.b=c},
a_:function a_(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
ap:function ap(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
P:function P(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
ac:function ac(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
w:function w(){},
bs:function bs(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
bm:function bm(a,b,c,d){var _=this
_.c=a
_.d=b
_.a=c
_.b=d},
bt:function bt(a,b,c){this.e=a
this.a=b
this.b=c},
bo:function bo(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
c1:function c1(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
bS:function bS(a,b,c){this.e=a
this.a=b
this.b=c},
b1:function b1(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
bY:function bY(a,b){this.a=a
this.b=b},
b9:function b9(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
c0:function c0(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
bU:function bU(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
bz:function bz(a,b,c,d,e,f,g){var _=this
_.e=a
_.f=b
_.r=c
_.w=d
_.x=e
_.a=f
_.b=g},
by:function by(a,b,c,d,e){var _=this
_.e=a
_.f=b
_.r=c
_.a=d
_.b=e},
b0:function b0(a,b,c){this.e=a
this.a=b
this.b=c},
ba:function ba(a,b,c,d){var _=this
_.e=a
_.f=b
_.a=c
_.b=d},
ct:function ct(a,b){this.a=a
this.b=b},
cW:function cW(a,b){this.a=a
this.b=b},
am:function am(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
dU:function dU(a,b){this.a=a
this.b=b},
dX:function dX(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
E(a,b,c){return new A.aF(a,b,c)},
jR(){var s=$.fC(),r=A.a4(s)
return new A.aj(s,r.h("f(1)").a(new A.eR()),r.h("aj<1,f>"))},
jG(a){var s
t.V.a(a)
s=a.O(0)
if(s<0)throw A.a(a.a3("No se puede sacar la ra\xedz cuadrada de un n\xfamero negativo ("+A.aY(s)+")."))
return Math.sqrt(s)},
hs(a){var s=a.O(0)
if(s<-1||s>1)throw A.a(a.a3(a.a.a+" solo funciona con valores entre -1 y 1."))
return s},
jK(a){var s,r,q,p,o
t.V.a(a)
s=a.a4(0)
r=a.e
q=a.az(1)-r
p=a.az(2)-r
if(q>p)return""
r=s.length
o=B.e.bT(q,0,r)
return B.c.L(s,o,B.e.bT(p+1,o,r))},
aF:function aF(a,b,c){this.a=a
this.b=b
this.c=c},
Q:function Q(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
eR:function eR(){},
et:function et(){},
eu:function eu(){},
ev:function ev(){},
eE:function eE(){},
eF:function eF(){},
eG:function eG(){},
eH:function eH(){},
eI:function eI(){},
eJ:function eJ(){},
eK:function eK(){},
eL:function eL(){},
ew:function ew(){},
ex:function ex(){},
ey:function ey(){},
ez:function ez(){},
eA:function eA(){},
eB:function eB(){},
eC:function eC(){},
eD:function eD(){},
eV(a,b){var s=300
return A.jX(a,b)},
jX(a0,a1){var s=0,r=A.C(t.W),q,p=2,o=[],n,m,l,k,j,i,h,g,f,e,d,c,b,a
var $async$eV=A.D(function(a2,a3){if(a2===1){o.push(a3)
s=p}while(true)switch(s){case 0:f={}
e=300
d=t.s
c=A.j(a0.split("\n"),d)
b=new A.bK(A.bL(A.il(null),null,!1,t.u),t.ai)
b.aw(0,a1)
n=new A.cs(b,new A.aP(""))
m=A.j([],t.k)
i=A.j([],d)
f.a=f.b=null
f.c=0
f.d=!1
l=new A.eX(f,i,n,m,c)
k=null
p=4
d=new A.dF(new A.dB(a0,A.j([],t.x)).dj(),A.j([],t.d),new A.dX(new A.T(t.E),new A.T(t.cu),new A.T(t.cP),new A.T(t.B),new A.T(t.aS)),A.ij(t.N)).dc()
b=A.j([],t.D)
h=new A.dr(d,n,B.ac,new A.eW(f,l,m,e),B.N,b,B.A)
f.b=h
s=7
return A.e(h.aR(),$async$eV)
case 7:p=2
s=6
break
case 4:p=3
a=o.pop()
d=A.aE(a)
if(d instanceof A.ah){j=d
k=j}else if(!(d instanceof A.d_))throw a
s=6
break
case 3:s=2
break
case 6:if(!f.d){d=f.b
d=d==null?null:d.x
if(d==null)d=B.A
l.$1(d)}q=new A.cz(i,m,k,f.d)
s=1
break
case 1:return A.A(q,r)
case 2:return A.z(o.at(-1),r)}})
return A.B($async$eV,r)},
cA:function cA(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
cz:function cz(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
eX:function eX(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
eW:function eW(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
aJ(a,b,c,d){return new A.ah(B.p,a,d,c)},
cB:function cB(a){this.b=a},
bw:function bw(a){this.b=a},
ah:function ah(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.e=d},
d_:function d_(){},
cs:function cs(a,b){this.a=a
this.b=b},
dV:function dV(a){this.a=a},
a2:function a2(a,b){this.a=a
this.b=b
this.c=null},
dr:function dr(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=0
_.w=!1
_.x=g},
du:function du(){},
dv:function dv(a){this.a=a},
dw:function dw(){},
ds:function ds(a,b){this.a=a
this.b=b},
dt:function dt(a){this.a=a},
dB:function dB(a,b){var _=this
_.a=a
_.b=b
_.c=0
_.e=_.d=1},
dF:function dF(a,b,c,d){var _=this
_.a=a
_.b=0
_.c=b
_.d=c
_.e=d},
dO:function dO(a){this.a=a},
dL:function dL(a){this.a=a},
dM:function dM(a){this.a=a},
dN:function dN(a){this.a=a},
dQ:function dQ(a){this.a=a},
dP:function dP(a){this.a=a},
dK:function dK(a){this.a=a},
dJ:function dJ(a){this.a=a},
dH:function dH(a){this.a=a},
dG:function dG(a){this.a=a},
dI:function dI(a){this.a=a},
dS:function dS(a){this.a=a},
dR:function dR(){},
ax:function ax(a){this.b=a},
a9:function a9(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
hW(a,b,c){return new A.M(a,b,A.bL(B.a.bW(b,1,new A.dj(),t.S),null,!1,t.X),c)},
f7(a){var s=B.c.aj(a),r=$.hS()
if(!r.b.test(s))return null
return A.hB(s)},
aY(a){var s
$label0$0:{if(A.aq(a)){s=a?"VERDADERO":"FALSO"
break $label0$0}if(A.cj(a)){s=A.m(a)
break $label0$0}if(typeof a=="number"){s=A.je(a)
break $label0$0}if(typeof a=="string"){s=a
break $label0$0}if(a instanceof A.M){s="[arreglo "+a.a+"]"
break $label0$0}s=""
break $label0$0}return s},
je(a){var s,r
if(a===(a<0?Math.ceil(a):Math.floor(a))&&Math.abs(a)<1e15)return B.e.i(B.h.ab(a))
s=B.h.di(a,10)
r=A.bT("0+$",!0)
s=A.kf(s,r,"",0)
return B.c.d4(s,".")?B.c.L(s,0,s.length-1):s},
R(a){var s
$label0$0:{if(a==null){s="un valor vac\xedo"
break $label0$0}if(A.aq(a)){s="el valor l\xf3gico "+A.aY(a)
break $label0$0}if(typeof a=="number"){s="el n\xfamero "+A.aY(a)
break $label0$0}if(typeof a=="string"){s='el texto "'+a+'"'
break $label0$0}if(a instanceof A.M){s="el arreglo '"+a.a+"'"
break $label0$0}s="un valor desconocido"
break $label0$0}return s},
hw(a){var s
$label0$0:{if(a==null){s="(sin valor)"
break $label0$0}if(typeof a=="string"){s='"'+a+'"'
break $label0$0}if(a instanceof A.M){s=A.jb(a,30)
break $label0$0}s=A.aY(a)
break $label0$0}return s},
jb(a,b){var s,r,q,p,o,n,m,l,k=new A.eO(),j=a.b,i=j.length
if(i===1){j=a.c
i=A.fj(j,0,A.eS(b,"count",t.S),A.a4(j).c)
s=i.$ti
r=new A.aj(i,s.h("f(O.E)").a(k),s.h("aj<O.E,f>")).ai(0,", ")
j=j.length>b?", \u2026":""
return"["+r+j+"]"}if(i===2){if(1>=i)return A.b(j,1)
q=j[1]
p=A.j([],t.s)
i=a.c
s=A.a4(i)
o=s.c
s=s.h("aQ<1>")
n=0
while(!0){if(0>=j.length)return A.b(j,0)
if(!(n<j[0]&&p.length*q<b))break
m=n*q
l=new A.aQ(i,m,null,s)
l.c6(i,m,null,o)
l=l.dg(0,q)
m=l.$ti
B.a.k(p,"["+new A.aj(l,m.h("f(O.E)").a(k),m.h("aj<O.E,f>")).ai(0,", ")+"]");++n}i=B.a.ai(p,", ")
s=p.length
if(0>=j.length)return A.b(j,0)
j=s<j[0]?", \u2026":""
return"["+i+j+"]"}return"[arreglo de "+B.a.ai(j," \xd7 ")+"]"},
M:function M(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dj:function dj(){},
eO:function eO(){},
eZ(a,b){var s=0,r=A.C(t.N),q,p,o,n,m,l,k,j,i,h,g,f,e,d
var $async$eZ=A.D(function(c,a0){if(c===1)return A.z(a0,r)
while(true)$async$outer:switch(s){case 0:f=A.bT("\\b(algoritmo|proceso)\\b",!1)
e=f.b.test(a)?a:"Algoritmo programa\n"+a+"\nFinAlgoritmo\n"
d=A.j(A.kc(b,"\r","").split("\n"),t.s)
while(!0){if(!(d.length!==0&&B.c.aj(B.a.gj(d)).length===0))break
if(0>=d.length){q=A.b(d,-1)
s=1
break $async$outer}d.pop()}s=3
return A.e(A.eV(e,d),$async$eZ)
case 3:p=a0
o=p.c
f=p.a
n=p.d
m=A.j([],t.J)
for(l=p.b,k=l.length,j=t.N,i=t.K,h=0;h<l.length;l.length===k||(0,A.W)(l),++h){g=l[h]
m.push(A.ff(["line",g.a,"instruction",g.b,"values",g.c,"output",g.d],j,i))}if(o==null)l=null
else{l=o.a===B.p?"Error de escritura":"Error al ejecutar"
l=A.ff(["title",l,"line",o.c,"message",o.b,"hint",o.e],j,t.X)}q=B.K.d2(A.ff(["variables",f,"truncated",n,"rows",m,"error",l],j,t.X),null)
s=1
break
case 1:return A.A(q,r)}})
return A.B($async$eZ,r)},
ka(){v.G.jaguarPruebaDeEscritorio=A.hl(new A.f5())},
f5:function f5(){},
f4:function f4(){},
kh(a){throw A.K(new A.cL("Field '"+a+"' has been assigned during initialization."),new Error())},
hl(a){var s
if(typeof a=="function")throw A.a(A.cp("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e){return b(c,d,e,arguments.length)}}(A.ja,a)
s[$.fA()]=a
return s},
ja(a,b,c,d){t.Z.a(a)
A.ae(d)
if(d>=2)return a.$2(b,c)
if(d===1)return a.$1(b)
return a.$0()},
jT(a,b,c){var s,r
if(b==null)return c.a(new a())
if(b instanceof Array)switch(b.length){case 0:return c.a(new a())
case 1:return c.a(new a(b[0]))
case 2:return c.a(new a(b[0],b[1]))
case 3:return c.a(new a(b[0],b[1],b[2]))
case 4:return c.a(new a(b[0],b[1],b[2],b[3]))}s=[null]
B.a.aw(s,b)
r=a.bind.apply(a,s)
String(r)
return c.a(new r())},
I(a){var s,r,q,p
for(s=new A.d0(a.toLowerCase()),r="";s.n();){q=A.J(s.d)
p=B.a_.C(0,q)
r+=p==null?q:p}return r.charCodeAt(0)==0?r:r},
k8(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(a===b)return 0
s=a.length
if(s===0)return b.length
r=b.length
if(r===0)return s
q=r+1
p=t.S
o=J.fP(q,p)
for(n=0;n<q;++n)o[n]=n
m=A.bL(q,0,!1,p)
for(n=1;n<=s;++n,l=m,m=o,o=l){B.a.q(m,0,n)
for(p=n-1,k=1;k<=r;++k){j=k-1
i=a.charCodeAt(p)===b.charCodeAt(j)?0:1
if(!(j<m.length))return A.b(m,j)
h=m[j]
g=o.length
if(!(k<g))return A.b(o,k)
h=Math.min(h+1,o[k]+1)
if(!(j<g))return A.b(o,j)
B.a.q(m,k,Math.min(h,o[j]+i))}}if(!(r<o.length))return A.b(o,r)
return o[r]},
eT(a,b){var s,r,q,p,o,n,m=A.I(a)
for(s=J.di(b),r=null,q=1073741824;s.n();){p=s.gp()
o=A.k8(m,A.I(p))
if(o<q){q=o
r=p}}n=m.length<=4?1:2
return q>0&&q<=n?r:null}},B={}
var w=[A,J,B]
var $={}
A.fc.prototype={}
J.cE.prototype={
a5(a,b){return a===b},
gE(a){return A.cY(a)},
i(a){return"Instance of '"+A.cZ(a)+"'"},
gv(a){return A.aa(A.fp(this))}}
J.cG.prototype={
i(a){return String(a)},
gE(a){return a?519018:218159},
gv(a){return A.aa(t.y)},
$io:1,
$iaB:1}
J.bB.prototype={
a5(a,b){return null==b},
i(a){return"null"},
gE(a){return 0},
gv(a){return A.aa(t.P)},
$io:1}
J.v.prototype={$it:1}
J.au.prototype={
gE(a){return 0},
gv(a){return B.al},
i(a){return String(a)}}
J.cX.prototype={}
J.bZ.prototype={}
J.a0.prototype={
i(a){var s=a[$.fA()]
if(s==null)return this.c5(a)
return"JavaScript function for "+J.co(s)},
$iaH:1}
J.bD.prototype={
gE(a){return 0},
i(a){return String(a)}}
J.bE.prototype={
gE(a){return 0},
i(a){return String(a)}}
J.n.prototype={
k(a,b){A.a4(a).c.a(b)
a.$flags&1&&A.dh(a,29)
a.push(b)},
aw(a,b){var s
A.a4(a).h("d<1>").a(b)
a.$flags&1&&A.dh(a,"addAll",2)
if(Array.isArray(b)){this.c9(a,b)
return}for(s=J.di(b);s.n();)a.push(s.gp())},
c9(a,b){var s,r
t.p.a(b)
s=b.length
if(s===0)return
if(a===b)throw A.a(A.Y(a))
for(r=0;r<s;++r)a.push(b[r])},
ai(a,b){var s,r=A.bL(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)this.q(r,s,A.m(a[s]))
return r.join(b)},
bW(a,b,c,d){var s,r,q
d.a(b)
A.a4(a).I(d).h("1(1,2)").a(c)
s=a.length
for(r=b,q=0;q<s;++q){r=c.$2(r,a[q])
if(a.length!==s)throw A.a(A.Y(a))}return r},
Z(a,b){if(!(b>=0&&b<a.length))return A.b(a,b)
return a[b]},
gd6(a){if(a.length>0)return a[0]
throw A.a(A.fO())},
gj(a){var s=a.length
if(s>0)return a[s-1]
throw A.a(A.fO())},
a6(a,b,c,d,e){var s,r,q,p
A.a4(a).h("d<1>").a(d)
a.$flags&2&&A.dh(a,5)
A.fW(b,c,a.length)
s=c-b
if(s===0)return
A.b7(e,"skipCount")
r=d
if(e+s>r.length)throw A.a(A.ib())
if(e<b)for(q=s-1;q>=0;--q){p=e+q
if(!(p>=0&&p<r.length))return A.b(r,p)
a[b+q]=r[p]}else for(q=0;q<s;++q){p=e+q
if(!(p>=0&&p<r.length))return A.b(r,p)
a[b+q]=r[p]}},
V(a,b){var s
for(s=0;s<a.length;++s)if(J.cn(a[s],b))return!0
return!1},
gbX(a){return a.length!==0},
i(a){return A.dx(a,"[","]")},
gF(a){return new J.bn(a,a.length,A.a4(a).h("bn<1>"))},
gE(a){return A.cY(a)},
gm(a){return a.length},
sm(a,b){a.$flags&1&&A.dh(a,"set length","change the length of")
if(b>a.length)A.a4(a).c.a(null)
a.length=b},
q(a,b,c){A.a4(a).c.a(c)
a.$flags&2&&A.dh(a)
if(!(b>=0&&b<a.length))throw A.a(A.hx(a,b))
a[b]=c},
gv(a){return A.aa(A.a4(a))},
$ih:1,
$id:1,
$il:1}
J.cF.prototype={
dk(a){var s,r,q
if(!Array.isArray(a))return null
s=a.$flags|0
if((s&4)!==0)r="const, "
else if((s&2)!==0)r="unmodifiable, "
else r=(s&1)!==0?"fixed, ":""
q="Instance of '"+A.cZ(a)+"'"
if(r==="")return q
return q+" ("+r+"length: "+a.length+")"}}
J.dy.prototype={}
J.bn.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
n(){var s,r=this,q=r.a,p=q.length
if(r.b!==p){q=A.W(q)
throw A.a(q)}s=r.c
if(s>=p){r.d=null
return!1}r.d=q[s]
r.c=s+1
return!0},
$ix:1}
J.bC.prototype={
aO(a,b){var s
if(a<b)return-1
else if(a>b)return 1
else if(a===b){if(a===0){s=this.gaQ(b)
if(this.gaQ(a)===s)return 0
if(this.gaQ(a))return-1
return 1}return 0}else if(isNaN(a)){if(isNaN(b))return 0
return 1}else return-1},
gaQ(a){return a===0?1/a<0:a<0},
ab(a){var s
if(a>=-2147483648&&a<=2147483647)return a|0
if(isFinite(a)){s=a<0?Math.ceil(a):Math.floor(a)
return s+0}throw A.a(A.e_(""+a+".toInt()"))},
c0(a){if(a>0){if(a!==1/0)return Math.round(a)}else if(a>-1/0)return 0-Math.round(0-a)
throw A.a(A.e_(""+a+".round()"))},
bT(a,b,c){if(B.e.aO(b,c)>0)throw A.a(A.jN(b))
if(this.aO(a,b)<0)return b
if(this.aO(a,c)>0)return c
return a},
di(a,b){var s
if(b>20)throw A.a(A.al(b,0,20,"fractionDigits",null))
s=a.toFixed(b)
if(a===0&&this.gaQ(a))return"-"+s
return s},
i(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gE(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
bj(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
return s+b},
aL(a,b){return(a|0)===a?a/b|0:this.cY(a,b)},
cY(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.a(A.e_("Result of truncating division is "+A.m(s)+": "+A.m(a)+" ~/ "+b))},
bO(a,b){var s
if(a>0)s=this.cU(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
cU(a,b){return b>31?0:a>>>b},
gv(a){return A.aa(t.o)},
$ik:1,
$iar:1}
J.bA.prototype={
gv(a){return A.aa(t.S)},
$io:1,
$ic:1}
J.cH.prototype={
gv(a){return A.aa(t.i)},
$io:1}
J.b2.prototype={
d4(a,b){var s=b.length,r=a.length
if(s>r)return!1
return b===this.bm(a,r-s)},
bl(a,b,c){var s,r=a.length
if(c>r)throw A.a(A.al(c,0,r,null,null))
s=c+b.length
if(s>r)return!1
return b===a.substring(c,s)},
L(a,b,c){return a.substring(b,A.fW(b,c,a.length))},
bm(a,b){return this.L(a,b,null)},
aj(a){var s,r,q,p=a.trim(),o=p.length
if(o===0)return p
if(0>=o)return A.b(p,0)
if(p.charCodeAt(0)===133){s=J.ig(p,1)
if(s===o)return""}else s=0
r=o-1
if(!(r>=0))return A.b(p,r)
q=p.charCodeAt(r)===133?J.ih(p,r):o
if(s===0&&q===o)return p
return p.substring(s,q)},
c4(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.a(B.L)
for(s=a,r="";!0;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
da(a,b,c){var s=b-a.length
if(s<=0)return a
return this.c4(c,s)+a},
i(a){return a},
gE(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gv(a){return A.aa(t.N)},
gm(a){return a.length},
$io:1,
$idT:1,
$if:1}
A.cL.prototype={
i(a){return"LateInitializationError: "+this.a}}
A.dW.prototype={}
A.h.prototype={}
A.O.prototype={
gF(a){var s=this
return new A.aN(s,s.gm(s),A.L(s).h("aN<O.E>"))},
ai(a,b){var s,r,q,p=this,o=p.gm(p)
if(b.length!==0){if(o===0)return""
s=A.m(p.Z(0,0))
if(o!==p.gm(p))throw A.a(A.Y(p))
for(r=s,q=1;q<o;++q){r=r+b+A.m(p.Z(0,q))
if(o!==p.gm(p))throw A.a(A.Y(p))}return r.charCodeAt(0)==0?r:r}else{for(q=0,r="";q<o;++q){r+=A.m(p.Z(0,q))
if(o!==p.gm(p))throw A.a(A.Y(p))}return r.charCodeAt(0)==0?r:r}}}
A.aQ.prototype={
c6(a,b,c,d){var s,r=this.b
A.b7(r,"start")
s=this.c
if(s!=null){A.b7(s,"end")
if(r>s)throw A.a(A.al(r,0,s,"start",null))}},
gcn(){var s=J.bl(this.a),r=this.c
if(r==null||r>s)return s
return r},
gcV(){var s=J.bl(this.a),r=this.b
if(r>s)return s
return r},
gm(a){var s,r=J.bl(this.a),q=this.b
if(q>=r)return 0
s=this.c
if(s==null||s>=r)return r-q
return s-q},
Z(a,b){var s=this,r=s.gcV()+b
if(b<0||r>=s.gcn())throw A.a(A.dq(b,s.gm(0),s,null,"index"))
return J.fF(s.a,r)},
dg(a,b){var s,r,q,p=this
A.b7(b,"count")
s=p.c
r=p.b
q=r+b
if(s==null)return A.fj(p.a,r,q,p.$ti.c)
else{if(s<q)return p
return A.fj(p.a,r,q,p.$ti.c)}}}
A.aN.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
n(){var s,r=this,q=r.a,p=J.hz(q),o=p.gm(q)
if(r.b!==o)throw A.a(A.Y(q))
s=r.c
if(s>=o){r.d=null
return!1}r.d=p.Z(q,s);++r.c
return!0},
$ix:1}
A.aO.prototype={
gF(a){var s=this.a
return new A.bM(s.gF(s),this.b,A.L(this).h("bM<1,2>"))},
gm(a){var s=this.a
return s.gm(s)}}
A.bv.prototype={$ih:1}
A.bM.prototype={
n(){var s=this,r=s.b
if(r.n()){s.a=s.c.$1(r.gp())
return!0}s.a=null
return!1},
gp(){var s=this.a
return s==null?this.$ti.y[1].a(s):s},
$ix:1}
A.aj.prototype={
gm(a){return J.bl(this.a)},
Z(a,b){return this.b.$1(J.fF(this.a,b))}}
A.N.prototype={}
A.ay.prototype={$r:"+(1,2)",$s:1}
A.bq.prototype={
gbe(a){return this.gm(this)===0},
i(a){return A.fg(this)},
gba(){return new A.bc(this.d5(),A.L(this).h("bc<a7<1,2>>"))},
d5(){var s=this
return function(){var r=0,q=1,p=[],o,n,m,l,k
return function $async$gba(a,b,c){if(b===1){p.push(c)
r=q}while(true)switch(r){case 0:o=s.gbf(),o=o.gF(o),n=A.L(s),m=n.y[1],n=n.h("a7<1,2>")
case 2:if(!o.n()){r=3
break}l=o.gp()
k=s.C(0,l)
r=4
return a.b=new A.a7(l,k==null?m.a(k):k,n),1
case 4:r=2
break
case 3:return 0
case 1:return a.c=p.at(-1),3}}}},
$iU:1}
A.Z.prototype={
gm(a){return this.b.length},
gbB(){var s=this.$keys
if(s==null){s=Object.keys(this.a)
this.$keys=s}return s},
b9(a){if(typeof a!="string")return!1
if("__proto__"===a)return!1
return this.a.hasOwnProperty(a)},
C(a,b){if(!this.b9(b))return null
return this.b[this.a[b]]},
aP(a,b){var s,r,q,p
this.$ti.h("~(1,2)").a(b)
s=this.gbB()
r=this.b
for(q=s.length,p=0;p<q;++p)b.$2(s[p],r[p])},
gbf(){return new A.c2(this.gbB(),this.$ti.h("c2<1>"))}}
A.c2.prototype={
gm(a){return this.a.length},
gF(a){var s=this.a
return new A.aT(s,s.length,this.$ti.h("aT<1>"))}}
A.aT.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
n(){var s=this,r=s.c
if(r>=s.b){s.d=null
return!1}s.d=s.a[r]
s.c=r+1
return!0},
$ix:1}
A.br.prototype={}
A.aG.prototype={
gm(a){return this.b},
gF(a){var s,r=this,q=r.$keys
if(q==null){q=Object.keys(r.a)
r.$keys=q}s=q
return new A.aT(s,s.length,r.$ti.h("aT<1>"))},
V(a,b){if("__proto__"===b)return!1
return this.a.hasOwnProperty(b)}}
A.bV.prototype={}
A.dY.prototype={
a_(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
if(p==null)return null
s=Object.create(null)
r=q.b
if(r!==-1)s.arguments=p[r+1]
r=q.c
if(r!==-1)s.argumentsExpr=p[r+1]
r=q.d
if(r!==-1)s.expr=p[r+1]
r=q.e
if(r!==-1)s.method=p[r+1]
r=q.f
if(r!==-1)s.receiver=p[r+1]
return s}}
A.bR.prototype={
i(a){return"Null check operator used on a null value"}}
A.cJ.prototype={
i(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.d6.prototype={
i(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.dE.prototype={
i(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.bx.prototype={}
A.cb.prototype={
i(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$iad:1}
A.as.prototype={
i(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.hF(r==null?"unknown":r)+"'"},
gv(a){var s=A.fu(this)
return A.aa(s==null?A.bi(this):s)},
$iaH:1,
gdn(){return this},
$C:"$1",
$R:1,
$D:null}
A.cu.prototype={$C:"$0",$R:0}
A.cv.prototype={$C:"$2",$R:2}
A.d4.prototype={}
A.d3.prototype={
i(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.hF(s)+"'"}}
A.b_.prototype={
a5(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.b_))return!1
return this.$_target===b.$_target&&this.a===b.a},
gE(a){return(A.fz(this.a)^A.cY(this.$_target))>>>0},
i(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.cZ(this.a)+"'")}}
A.d1.prototype={
i(a){return"RuntimeError: "+this.a}}
A.ai.prototype={
gm(a){return this.a},
gbe(a){return this.a===0},
gbf(){return new A.bI(this,A.L(this).h("bI<1>"))},
gba(){return new A.bG(this,A.L(this).h("bG<1,2>"))},
b9(a){var s=this.b
if(s==null)return!1
return s[a]!=null},
C(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.d8(b)},
d8(a){var s,r,q=this.d
if(q==null)return null
s=q[this.bb(a)]
r=this.bc(s,a)
if(r<0)return null
return s[r].b},
q(a,b,c){var s,r,q,p,o,n,m=this,l=A.L(m)
l.c.a(b)
l.y[1].a(c)
if(typeof b=="string"){s=m.b
m.bp(s==null?m.b=m.b4():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=m.c
m.bp(r==null?m.c=m.b4():r,b,c)}else{q=m.d
if(q==null)q=m.d=m.b4()
p=m.bb(b)
o=q[p]
if(o==null)q[p]=[m.b5(b,c)]
else{n=m.bc(o,b)
if(n>=0)o[n].b=c
else o.push(m.b5(b,c))}}},
bZ(a,b){var s,r,q=this,p=A.L(q)
p.c.a(a)
p.h("2()").a(b)
if(q.b9(a)){s=q.C(0,a)
return s==null?p.y[1].a(s):s}r=b.$0()
q.q(0,a,r)
return r},
aP(a,b){var s,r,q=this
A.L(q).h("~(1,2)").a(b)
s=q.e
r=q.r
for(;s!=null;){b.$2(s.a,s.b)
if(r!==q.r)throw A.a(A.Y(q))
s=s.c}},
bp(a,b,c){var s,r=A.L(this)
r.c.a(b)
r.y[1].a(c)
s=a[b]
if(s==null)a[b]=this.b5(b,c)
else s.b=c},
b5(a,b){var s=this,r=A.L(s),q=new A.dC(r.c.a(a),r.y[1].a(b))
if(s.e==null)s.e=s.f=q
else s.f=s.f.c=q;++s.a
s.r=s.r+1&1073741823
return q},
bb(a){return J.ag(a)&1073741823},
bc(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.cn(a[r].a,b))return r
return-1},
i(a){return A.fg(this)},
b4(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
$ife:1}
A.dC.prototype={}
A.bI.prototype={
gm(a){return this.a.a},
gF(a){var s=this.a
return new A.aK(s,s.r,s.e,this.$ti.h("aK<1>"))}}
A.aK.prototype={
gp(){return this.d},
n(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.a(A.Y(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.a
r.c=s.c
return!0}},
$ix:1}
A.aM.prototype={
gm(a){return this.a.a},
gF(a){var s=this.a
return new A.aL(s,s.r,s.e,this.$ti.h("aL<1>"))}}
A.aL.prototype={
gp(){return this.d},
n(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.a(A.Y(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.b
r.c=s.c
return!0}},
$ix:1}
A.bG.prototype={
gm(a){return this.a.a},
gF(a){var s=this.a
return new A.bH(s,s.r,s.e,this.$ti.h("bH<1,2>"))}}
A.bH.prototype={
gp(){var s=this.d
s.toString
return s},
n(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.a(A.Y(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=new A.a7(s.a,s.b,r.$ti.h("a7<1,2>"))
r.c=s.c
return!0}},
$ix:1}
A.T.prototype={
bb(a){return A.fz(a)&1073741823},
bc(a,b){var s,r,q
if(a==null)return-1
s=a.length
for(r=0;r<s;++r){q=a[r].a
if(q==null?b==null:q===b)return r}return-1}}
A.f0.prototype={
$1(a){return this.a(a)},
$S:11}
A.f1.prototype={
$2(a,b){return this.a(a,b)},
$S:34}
A.f2.prototype={
$1(a){return this.a(A.af(a))},
$S:25}
A.aW.prototype={
gv(a){return A.aa(this.by())},
by(){return A.jY(this.$r,this.bx())},
i(a){return this.bQ(!1)},
bQ(a){var s,r,q,p,o,n=this.cr(),m=this.bx(),l=(a?"Record ":"")+"("
for(s=n.length,r="",q=0;q<s;++q,r=", "){l+=r
p=n[q]
if(typeof p=="string")l=l+p+": "
if(!(q<m.length))return A.b(m,q)
o=m[q]
l=a?l+A.fV(o):l+A.m(o)}l+=")"
return l.charCodeAt(0)==0?l:l},
cr(){var s,r=this.$s
for(;$.em.length<=r;)B.a.k($.em,null)
s=$.em[r]
if(s==null){s=this.ci()
B.a.q($.em,r,s)}return s},
ci(){var s,r,q,p=this.$r,o=p.indexOf("("),n=p.substring(1,o),m=p.substring(o),l=m==="()"?0:m.replace(/[^,]/g,"").length+1,k=t.K,j=J.fP(l,k)
for(s=0;s<l;++s)j[s]=s
if(n!==""){r=n.split(",")
s=r.length
for(q=l;s>0;){--q;--s
B.a.q(j,q,r[s])}}j=A.ip(j,!1,k)
j.$flags=3
return j}}
A.bb.prototype={
bx(){return[this.a,this.b]},
a5(a,b){if(b==null)return!1
return b instanceof A.bb&&this.$s===b.$s&&J.cn(this.a,b.a)&&J.cn(this.b,b.b)},
gE(a){return A.iq(this.$s,this.a,this.b,B.n)}}
A.cI.prototype={
i(a){return"RegExp/"+this.a+"/"+this.b.flags},
gcv(){var s=this,r=s.c
if(r!=null)return r
r=s.b
return s.c=A.fb(s.a,r.multiline,!r.ignoreCase,r.unicode,r.dotAll,"g")},
gcu(){var s=this,r=s.d
if(r!=null)return r
r=s.b
return s.d=A.fb(s.a,r.multiline,!r.ignoreCase,r.unicode,r.dotAll,"y")},
bv(a,b){var s,r=this.gcv()
if(r==null)r=A.aA(r)
r.lastIndex=b
s=r.exec(a)
if(s==null)return null
return new A.c5(s)},
co(a,b){var s,r=this.gcu()
if(r==null)r=A.aA(r)
r.lastIndex=b
s=r.exec(a)
if(s==null)return null
return new A.c5(s)},
$idT:1,
$iix:1}
A.c5.prototype={
gbU(){var s=this.b
return s.index+s[0].length},
$ifh:1}
A.e0.prototype={
gp(){var s=this.d
return s==null?t.a0.a(s):s},
n(){var s,r,q,p,o,n,m=this,l=m.b
if(l==null)return!1
s=m.c
r=l.length
if(s<=r){q=m.a
p=q.bv(l,s)
if(p!=null){m.d=p
o=p.gbU()
if(p.b.index===o){s=!1
if(q.b.unicode){q=m.c
n=q+1
if(n<r){if(!(q>=0&&q<r))return A.b(l,q)
q=l.charCodeAt(q)
if(q>=55296&&q<=56319){if(!(n>=0))return A.b(l,n)
s=l.charCodeAt(n)
s=s>=56320&&s<=57343}}}o=(s?o+1:o)+1}m.c=o
return!0}}m.b=m.d=null
return!1},
$ix:1}
A.b4.prototype={
gv(a){return B.ae},
$io:1}
A.bP.prototype={}
A.cM.prototype={
gv(a){return B.af},
$io:1}
A.b5.prototype={
gm(a){return a.length},
$iS:1}
A.bN.prototype={$ih:1,$id:1,$il:1}
A.bO.prototype={$ih:1,$id:1,$il:1}
A.cN.prototype={
gv(a){return B.ag},
$io:1}
A.cO.prototype={
gv(a){return B.ah},
$io:1}
A.cP.prototype={
gv(a){return B.ai},
$io:1}
A.cQ.prototype={
gv(a){return B.aj},
$io:1}
A.cR.prototype={
gv(a){return B.ak},
$io:1}
A.cS.prototype={
gv(a){return B.an},
$io:1}
A.cT.prototype={
gv(a){return B.ao},
$io:1}
A.bQ.prototype={
gv(a){return B.ap},
gm(a){return a.length},
$io:1}
A.cU.prototype={
gv(a){return B.aq},
gm(a){return a.length},
$io:1}
A.c6.prototype={}
A.c7.prototype={}
A.c8.prototype={}
A.c9.prototype={}
A.a8.prototype={
h(a){return A.ch(v.typeUniverse,this,a)},
I(a){return A.hc(v.typeUniverse,this,a)}}
A.da.prototype={}
A.eq.prototype={
i(a){return A.V(this.a,null)}}
A.d9.prototype={
i(a){return this.a}}
A.cd.prototype={$ian:1}
A.e2.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:6}
A.e1.prototype={
$1(a){var s,r
this.a.a=t.M.a(a)
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:23}
A.e3.prototype={
$0(){this.a.$0()},
$S:8}
A.e4.prototype={
$0(){this.a.$0()},
$S:8}
A.eo.prototype={
c7(a,b){if(self.setTimeout!=null)self.setTimeout(A.eU(new A.ep(this,b),0),a)
else throw A.a(A.e_("`setTimeout()` not found."))}}
A.ep.prototype={
$0(){this.b.$0()},
$S:0}
A.d7.prototype={}
A.eM.prototype={
$1(a){return this.a.$2(0,a)},
$S:22}
A.eN.prototype={
$2(a,b){this.a.$2(1,new A.bx(a,t.l.a(b)))},
$S:19}
A.eQ.prototype={
$2(a,b){this.a(A.ae(a),b)},
$S:18}
A.cc.prototype={
gp(){var s=this.b
return s==null?this.$ti.c.a(s):s},
cS(a,b){var s,r,q
a=A.ae(a)
b=b
s=this.a
for(;!0;)try{r=s(this,a,b)
return r}catch(q){b=q
a=1}},
n(){var s,r,q,p,o=this,n=null,m=0
for(;!0;){s=o.d
if(s!=null)try{if(s.n()){o.b=s.gp()
return!0}else o.d=null}catch(r){n=r
m=1
o.d=null}q=o.cS(m,n)
if(1===q)return!0
if(0===q){o.b=null
p=o.e
if(p==null||p.length===0){o.a=A.h7
return!1}if(0>=p.length)return A.b(p,-1)
o.a=p.pop()
m=0
n=null
continue}if(2===q){m=0
n=null
continue}if(3===q){n=o.c
o.c=null
p=o.e
if(p==null||p.length===0){o.b=null
o.a=A.h7
throw n
return!1}if(0>=p.length)return A.b(p,-1)
o.a=p.pop()
m=1
continue}throw A.a(A.iA("sync*"))}return!1},
dq(a){var s,r,q=this
if(a instanceof A.bc){s=a.a()
r=q.e
if(r==null)r=q.e=[]
B.a.k(r,q.a)
q.a=s
return 2}else{q.d=J.di(a)
return 2}},
$ix:1}
A.bc.prototype={
gF(a){return new A.cc(this.a(),this.$ti.h("cc<1>"))}}
A.a6.prototype={
i(a){return A.m(this.a)},
$ip:1,
gaA(){return this.b}}
A.dp.prototype={
$0(){this.c.a(null)
this.b.cf(null)},
$S:0}
A.aR.prototype={
d9(a){if((this.c&15)!==6)return!0
return this.b.b.bh(t.bG.a(this.d),a.a,t.y,t.K)},
d7(a){var s,r=this,q=r.e,p=null,o=t.z,n=t.K,m=a.a,l=r.b.b
if(t.C.b(q))p=l.de(q,m,a.b,o,n,t.l)
else p=l.bh(t.v.a(q),m,o,n)
try{o=r.$ti.h("2/").a(p)
return o}catch(s){if(t.b7.b(A.aE(s))){if((r.c&1)!==0)throw A.a(A.cp("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.a(A.cp("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.F.prototype={
aS(a,b,c){var s,r,q,p=this.$ti
p.I(c).h("1/(2)").a(a)
s=$.y
if(s===B.i){if(b!=null&&!t.C.b(b)&&!t.v.b(b))throw A.a(A.f9(b,"onError",u.c))}else{c.h("@<0/>").I(p.c).h("1(2)").a(a)
if(b!=null)b=A.jA(b,s)}r=new A.F(s,c.h("F<0>"))
q=b==null?1:3
this.aV(new A.aR(r,q,a,b,p.h("@<1>").I(c).h("aR<1,2>")))
return r},
dh(a,b){return this.aS(a,null,b)},
bP(a,b,c){var s,r=this.$ti
r.I(c).h("1/(2)").a(a)
s=new A.F($.y,c.h("F<0>"))
this.aV(new A.aR(s,19,a,b,r.h("@<1>").I(c).h("aR<1,2>")))
return s},
cT(a){this.a=this.a&1|16
this.c=a},
aB(a){this.a=a.a&30|this.a&1
this.c=a.c},
aV(a){var s,r=this,q=r.a
if(q<=3){a.a=t.F.a(r.c)
r.c=a}else{if((q&4)!==0){s=t._.a(r.c)
if((s.a&24)===0){s.aV(a)
return}r.aB(s)}A.dg(null,null,r.b,t.M.a(new A.e7(r,a)))}},
bM(a){var s,r,q,p,o,n,m=this,l={}
l.a=a
if(a==null)return
s=m.a
if(s<=3){r=t.F.a(m.c)
m.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){n=t._.a(m.c)
if((n.a&24)===0){n.bM(a)
return}m.aB(n)}l.a=m.aK(a)
A.dg(null,null,m.b,t.M.a(new A.ec(l,m)))}},
au(){var s=t.F.a(this.c)
this.c=null
return this.aK(s)},
aK(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
cf(a){var s,r=this,q=r.$ti
q.h("1/").a(a)
if(q.h("at<1>").b(a))A.ea(a,r,!0)
else{s=r.au()
q.c.a(a)
r.a=8
r.c=a
A.aS(r,s)}},
bt(a){var s,r=this
r.$ti.c.a(a)
s=r.au()
r.a=8
r.c=a
A.aS(r,s)},
cg(a){var s,r,q=this
if((a.a&16)!==0){s=q.b===a.b
s=!(s||s)}else s=!1
if(s)return
r=q.au()
q.aB(a)
A.aS(q,r)},
aY(a){var s=this.au()
this.cT(a)
A.aS(this,s)},
ca(a){var s=this.$ti
s.h("1/").a(a)
if(s.h("at<1>").b(a)){this.br(a)
return}this.cb(a)},
cb(a){var s=this
s.$ti.c.a(a)
s.a^=2
A.dg(null,null,s.b,t.M.a(new A.e9(s,a)))},
br(a){A.ea(this.$ti.h("at<1>").a(a),this,!1)
return},
bq(a){this.a^=2
A.dg(null,null,this.b,t.M.a(new A.e8(this,a)))},
$iat:1}
A.e7.prototype={
$0(){A.aS(this.a,this.b)},
$S:0}
A.ec.prototype={
$0(){A.aS(this.b,this.a.a)},
$S:0}
A.eb.prototype={
$0(){A.ea(this.a.a,this.b,!0)},
$S:0}
A.e9.prototype={
$0(){this.a.bt(this.b)},
$S:0}
A.e8.prototype={
$0(){this.a.aY(this.b)},
$S:0}
A.ef.prototype={
$0(){var s,r,q,p,o,n,m,l,k=this,j=null
try{q=k.a.a
j=q.b.b.dd(t.bd.a(q.d),t.z)}catch(p){s=A.aE(p)
r=A.bh(p)
if(k.c&&t.n.a(k.b.a.c).a===s){q=k.a
q.c=t.n.a(k.b.a.c)}else{q=s
o=r
if(o==null)o=A.fa(q)
n=k.a
n.c=new A.a6(q,o)
q=n}q.b=!0
return}if(j instanceof A.F&&(j.a&24)!==0){if((j.a&16)!==0){q=k.a
q.c=t.n.a(j.c)
q.b=!0}return}if(j instanceof A.F){m=k.b.a
l=new A.F(m.b,m.$ti)
j.aS(new A.eg(l,m),new A.eh(l),t.H)
q=k.a
q.c=l
q.b=!1}},
$S:0}
A.eg.prototype={
$1(a){this.a.cg(this.b)},
$S:6}
A.eh.prototype={
$2(a,b){A.aA(a)
t.l.a(b)
this.a.aY(new A.a6(a,b))},
$S:17}
A.ee.prototype={
$0(){var s,r,q,p,o,n,m,l
try{q=this.a
p=q.a
o=p.$ti
n=o.c
m=n.a(this.b)
q.c=p.b.b.bh(o.h("2/(1)").a(p.d),m,o.h("2/"),n)}catch(l){s=A.aE(l)
r=A.bh(l)
q=s
p=r
if(p==null)p=A.fa(q)
o=this.a
o.c=new A.a6(q,p)
o.b=!0}},
$S:0}
A.ed.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=t.n.a(l.a.a.c)
p=l.b
if(p.a.d9(s)&&p.a.e!=null){p.c=p.a.d7(s)
p.b=!1}}catch(o){r=A.aE(o)
q=A.bh(o)
p=t.n.a(l.a.a.c)
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.fa(p)
m=l.b
m.c=new A.a6(p,n)
p=m}p.b=!0}},
$S:0}
A.d8.prototype={}
A.de.prototype={}
A.ci.prototype={$ih0:1}
A.eP.prototype={
$0(){A.i4(this.a,this.b)},
$S:0}
A.dd.prototype={
df(a){var s,r,q
t.M.a(a)
try{if(B.i===$.y){a.$0()
return}A.hp(null,null,this,a,t.H)}catch(q){s=A.aE(q)
r=A.bh(q)
A.fr(A.aA(s),t.l.a(r))}},
bS(a){return new A.en(this,t.M.a(a))},
dd(a,b){b.h("0()").a(a)
if($.y===B.i)return a.$0()
return A.hp(null,null,this,a,b)},
bh(a,b,c,d){c.h("@<0>").I(d).h("1(2)").a(a)
d.a(b)
if($.y===B.i)return a.$1(b)
return A.jC(null,null,this,a,b,c,d)},
de(a,b,c,d,e,f){d.h("@<0>").I(e).I(f).h("1(2,3)").a(a)
e.a(b)
f.a(c)
if($.y===B.i)return a.$2(b,c)
return A.jB(null,null,this,a,b,c,d,e,f)},
c_(a,b,c,d){return b.h("@<0>").I(c).I(d).h("1(2,3)").a(a)}}
A.en.prototype={
$0(){return this.a.df(this.b)},
$S:0}
A.aU.prototype={
gF(a){var s=this,r=new A.c3(s,s.r,s.$ti.h("c3<1>"))
r.c=s.e
return r},
gm(a){return this.a},
V(a,b){var s,r
if(b!=="__proto__"){s=this.b
if(s==null)return!1
return t.L.a(s[b])!=null}else{r=this.cj(b)
return r}},
cj(a){var s=this.d
if(s==null)return!1
return this.bw(s[B.c.gE(a)&1073741823],a)>=0},
k(a,b){var s,r,q=this
q.$ti.c.a(b)
if(typeof b=="string"&&b!=="__proto__"){s=q.b
return q.bs(s==null?q.b=A.fm():s,b)}else if(typeof b=="number"&&(b&1073741823)===b){r=q.c
return q.bs(r==null?q.c=A.fm():r,b)}else return q.c8(b)},
c8(a){var s,r,q,p=this
p.$ti.c.a(a)
s=p.d
if(s==null)s=p.d=A.fm()
r=J.ag(a)&1073741823
q=s[r]
if(q==null)s[r]=[p.aX(a)]
else{if(p.bw(q,a)>=0)return!1
q.push(p.aX(a))}return!0},
bs(a,b){this.$ti.c.a(b)
if(t.L.a(a[b])!=null)return!1
a[b]=this.aX(b)
return!0},
aX(a){var s=this,r=new A.dc(s.$ti.c.a(a))
if(s.e==null)s.e=s.f=r
else s.f=s.f.b=r;++s.a
s.r=s.r+1&1073741823
return r},
bw(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.cn(a[r].a,b))return r
return-1},
$ifS:1}
A.dc.prototype={}
A.c3.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
n(){var s=this,r=s.c,q=s.a
if(s.b!==q.r)throw A.a(A.Y(q))
else if(r==null){s.d=null
return!1}else{s.d=s.$ti.h("1?").a(r.a)
s.c=r.b
return!0}},
$ix:1}
A.u.prototype={
gF(a){return new A.aN(a,a.length,A.bi(a).h("aN<u.E>"))},
Z(a,b){if(!(b>=0&&b<a.length))return A.b(a,b)
return a[b]},
gbX(a){return a.length!==0},
i(a){return A.dx(a,"[","]")}}
A.b3.prototype={
aP(a,b){var s,r,q,p=this,o=A.L(p)
o.h("~(1,2)").a(b)
for(s=new A.aK(p,p.r,p.e,o.h("aK<1>")),o=o.y[1];s.n();){r=s.d
q=p.C(0,r)
b.$2(r,q==null?o.a(q):q)}},
gm(a){return this.a},
gbe(a){return this.a===0},
i(a){return A.fg(this)},
$iU:1}
A.dD.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.m(a)
r.a=(r.a+=s)+": "
s=A.m(b)
r.a+=s},
$S:10}
A.bK.prototype={
gF(a){var s=this
return new A.c4(s,s.c,s.d,s.b,s.$ti.h("c4<1>"))},
gm(a){return(this.c-this.b&this.a.length-1)>>>0},
Z(a,b){var s,r,q=this,p=q.gm(0)
if(0>b||b>=p)A.bk(A.dq(b,p,q,null,"index"))
p=q.a
s=p.length
r=(q.b+b&s-1)>>>0
if(!(r>=0&&r<s))return A.b(p,r)
r=p[r]
return r==null?q.$ti.c.a(r):r},
aw(a,b){var s,r,q,p,o,n,m,l,k=this,j=k.$ti
j.h("d<1>").a(b)
s=b.length
r=k.gm(0)
q=r+s
p=k.a
o=p.length
if(q>=o){n=A.bL(A.im(q+(q>>>1)),null,!1,j.h("1?"))
k.c=k.d1(n)
k.a=n
k.b=0
B.a.a6(n,r,q,b,0)
k.c+=s}else{j=k.c
m=o-j
if(s<m){B.a.a6(p,j,j+s,b,0)
k.c+=s}else{l=s-m
B.a.a6(p,j,j+m,b,0)
B.a.a6(k.a,0,l,b,m)
k.c=l}}++k.d},
i(a){return A.dx(this,"{","}")},
d1(a){var s,r,q,p,o,n=this
n.$ti.h("l<1?>").a(a)
s=n.b
r=n.c
q=n.a
if(s<=r){p=r-s
B.a.a6(a,0,p,q,s)
return p}else{o=q.length-s
B.a.a6(a,0,o,q,s)
B.a.a6(a,o,o+n.c,n.a,0)
return n.c+o}},
$iiu:1}
A.c4.prototype={
gp(){var s=this.e
return s==null?this.$ti.c.a(s):s},
n(){var s,r,q=this,p=q.a
if(q.c!==p.d)A.bk(A.Y(p))
s=q.d
if(s===q.b){q.e=null
return!1}p=p.a
r=p.length
if(!(s<r))return A.b(p,s)
q.e=p[s]
q.d=(s+1&r-1)>>>0
return!0},
$ix:1}
A.av.prototype={
i(a){return A.dx(this,"{","}")},
$ih:1,
$id:1,
$id2:1}
A.ca.prototype={}
A.cw.prototype={}
A.cy.prototype={}
A.bF.prototype={
i(a){var s=A.cC(this.a)
return(this.b!=null?"Converting object to an encodable object failed:":"Converting object did not return an encodable object:")+" "+s}}
A.cK.prototype={
i(a){return"Cyclic error in JSON stringify"}}
A.dz.prototype={
d2(a,b){var s=A.iM(a,this.gd3().b,null)
return s},
gd3(){return B.U}}
A.dA.prototype={}
A.ek.prototype={
c3(a){var s,r,q,p,o,n,m=a.length
for(s=this.c,r=0,q=0;q<m;++q){p=a.charCodeAt(q)
if(p>92){if(p>=55296){o=p&64512
if(o===55296){n=q+1
n=!(n<m&&(a.charCodeAt(n)&64512)===56320)}else n=!1
if(!n)if(o===56320){o=q-1
o=!(o>=0&&(a.charCodeAt(o)&64512)===55296)}else o=!1
else o=!0
if(o){if(q>r)s.a+=B.c.L(a,r,q)
r=q+1
o=A.J(92)
s.a+=o
o=A.J(117)
s.a+=o
o=A.J(100)
s.a+=o
o=p>>>8&15
o=A.J(o<10?48+o:87+o)
s.a+=o
o=p>>>4&15
o=A.J(o<10?48+o:87+o)
s.a+=o
o=p&15
o=A.J(o<10?48+o:87+o)
s.a+=o}}continue}if(p<32){if(q>r)s.a+=B.c.L(a,r,q)
r=q+1
o=A.J(92)
s.a+=o
switch(p){case 8:o=A.J(98)
s.a+=o
break
case 9:o=A.J(116)
s.a+=o
break
case 10:o=A.J(110)
s.a+=o
break
case 12:o=A.J(102)
s.a+=o
break
case 13:o=A.J(114)
s.a+=o
break
default:o=A.J(117)
s.a+=o
o=A.J(48)
s.a=(s.a+=o)+o
o=p>>>4&15
o=A.J(o<10?48+o:87+o)
s.a+=o
o=p&15
o=A.J(o<10?48+o:87+o)
s.a+=o
break}}else if(p===34||p===92){if(q>r)s.a+=B.c.L(a,r,q)
r=q+1
o=A.J(92)
s.a+=o
o=A.J(p)
s.a+=o}}if(r===0)s.a+=a
else if(r<m)s.a+=B.c.L(a,r,m)},
aW(a){var s,r,q,p
for(s=this.a,r=s.length,q=0;q<r;++q){p=s[q]
if(a==null?p==null:a===p)throw A.a(new A.cK(a,null))}B.a.k(s,a)},
aT(a){var s,r,q,p,o=this
if(o.c2(a))return
o.aW(a)
try{s=o.b.$1(a)
if(!o.c2(s)){q=A.fR(a,null,o.gbK())
throw A.a(q)}q=o.a
if(0>=q.length)return A.b(q,-1)
q.pop()}catch(p){r=A.aE(p)
q=A.fR(a,r,o.gbK())
throw A.a(q)}},
c2(a){var s,r,q=this
if(typeof a=="number"){if(!isFinite(a))return!1
q.c.a+=B.h.i(a)
return!0}else if(a===!0){q.c.a+="true"
return!0}else if(a===!1){q.c.a+="false"
return!0}else if(a==null){q.c.a+="null"
return!0}else if(typeof a=="string"){s=q.c
s.a+='"'
q.c3(a)
s.a+='"'
return!0}else if(t.j.b(a)){q.aW(a)
q.dl(a)
s=q.a
if(0>=s.length)return A.b(s,-1)
s.pop()
return!0}else if(t.bC.b(a)){q.aW(a)
r=q.dm(a)
s=q.a
if(0>=s.length)return A.b(s,-1)
s.pop()
return r}else return!1},
dl(a){var s,r=this.c
r.a+="["
if(J.hV(a)){if(0>=a.length)return A.b(a,0)
this.aT(a[0])
for(s=1;s<a.length;++s){r.a+=","
this.aT(a[s])}}r.a+="]"},
dm(a){var s,r,q,p,o,n,m=this,l={}
if(a.gbe(a)){m.c.a+="{}"
return!0}s=a.gm(a)*2
r=A.bL(s,null,!1,t.X)
q=l.a=0
l.b=!0
a.aP(0,new A.el(l,r))
if(!l.b)return!1
p=m.c
p.a+="{"
for(o='"';q<s;q+=2,o=',"'){p.a+=o
m.c3(A.af(r[q]))
p.a+='":'
n=q+1
if(!(n<s))return A.b(r,n)
m.aT(r[n])}p.a+="}"
return!0}}
A.el.prototype={
$2(a,b){var s,r
if(typeof a!="string")this.a.b=!1
s=this.b
r=this.a
B.a.q(s,r.a++,a)
B.a.q(s,r.a++,b)},
$S:10}
A.ej.prototype={
gbK(){var s=this.c.a
return s.charCodeAt(0)==0?s:s}}
A.bu.prototype={
a5(a,b){if(b==null)return!1
return b instanceof A.bu&&this.a===b.a},
gE(a){return B.e.gE(this.a)},
i(a){var s,r,q,p,o,n=this.a,m=B.e.aL(n,36e8),l=n%36e8
if(n<0){m=0-m
n=0-l
s="-"}else{n=l
s=""}r=B.e.aL(n,6e7)
n%=6e7
q=r<10?"0":""
p=B.e.aL(n,1e6)
o=p<10?"0":""
return s+m+":"+q+r+":"+o+p+"."+B.c.da(B.e.i(n%1e6),6,"0")}}
A.e5.prototype={
i(a){return this.aD()}}
A.p.prototype={
gaA(){return A.ir(this)}}
A.cq.prototype={
i(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.cC(s)
return"Assertion failed"}}
A.an.prototype={}
A.ab.prototype={
gb0(){return"Invalid argument"+(!this.a?"(s)":"")},
gb_(){return""},
i(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+p,n=s.gb0()+q+o
if(!s.a)return n
return n+s.gb_()+": "+A.cC(s.gbd())},
gbd(){return this.b}}
A.b6.prototype={
gbd(){return A.hh(this.b)},
gb0(){return"RangeError"},
gb_(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.m(q):""
else if(q==null)s=": Not greater than or equal to "+A.m(r)
else if(q>r)s=": Not in inclusive range "+A.m(r)+".."+A.m(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.m(r)
return s}}
A.cD.prototype={
gbd(){return A.ae(this.b)},
gb0(){return"RangeError"},
gb_(){if(A.ae(this.b)<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gm(a){return this.f}}
A.c_.prototype={
i(a){return"Unsupported operation: "+this.a}}
A.d5.prototype={
i(a){return"UnimplementedError: "+this.a}}
A.b8.prototype={
i(a){return"Bad state: "+this.a}}
A.cx.prototype={
i(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.cC(s)+"."}}
A.cV.prototype={
i(a){return"Out of Memory"},
gaA(){return null},
$ip:1}
A.bW.prototype={
i(a){return"Stack Overflow"},
gaA(){return null},
$ip:1}
A.e6.prototype={
i(a){return"Exception: "+this.a}}
A.dk.prototype={
i(a){var s=this.a,r=""!==s?"FormatException: "+s:"FormatException",q=this.b
if(typeof q=="string"){if(q.length>78)q=B.c.L(q,0,75)+"..."
return r+"\n"+q}else return r}}
A.d.prototype={
gm(a){var s,r=this.gF(this)
for(s=0;r.n();)++s
return s},
Z(a,b){var s,r
A.b7(b,"index")
s=this.gF(this)
for(r=b;s.n();){if(r===0)return s.gp();--r}throw A.a(A.dq(b,b-r,this,null,"index"))},
i(a){return A.ic(this,"(",")")}}
A.a7.prototype={
i(a){return"MapEntry("+A.m(this.a)+": "+A.m(this.b)+")"}}
A.H.prototype={
gE(a){return A.i.prototype.gE.call(this,0)},
i(a){return"null"}}
A.i.prototype={$ii:1,
a5(a,b){return this===b},
gE(a){return A.cY(this)},
i(a){return"Instance of '"+A.cZ(this)+"'"},
gv(a){return A.k1(this)},
toString(){return this.i(this)}}
A.df.prototype={
i(a){return""},
$iad:1}
A.d0.prototype={
gp(){return this.d},
n(){var s,r,q,p=this,o=p.b=p.c,n=p.a,m=n.length
if(o===m){p.d=-1
return!1}if(!(o<m))return A.b(n,o)
s=n.charCodeAt(o)
r=o+1
if((s&64512)===55296&&r<m){if(!(r<m))return A.b(n,r)
q=n.charCodeAt(r)
if((q&64512)===56320){p.c=r+1
p.d=65536+((s&1023)<<10)+(q&1023)
return!0}}p.c=r
p.d=s
return!0},
$ix:1}
A.aP.prototype={
gm(a){return this.a.length},
i(a){var s=this.a
return s.charCodeAt(0)==0?s:s},
$iiB:1}
A.dn.prototype={
$2(a,b){var s=t.g
this.a.aS(new A.dl(s.a(a)),new A.dm(s.a(b)),t.X)},
$S:16}
A.dl.prototype={
$1(a){var s=this.a
s.call(s,a)
return a},
$S:35}
A.dm.prototype={
$2(a,b){var s,r,q,p
A.aA(a)
t.l.a(b)
s=t.g.a(v.G.Error)
r=A.jT(s,["Dart exception thrown from converted Future. Use the properties 'error' to fetch the boxed error and 'stack' to recover the stack trace."],t.m)
if(t.e.b(a))A.bk("Attempting to box non-Dart object.")
q={}
q[$.hR()]=a
r.error=q
r.stack=b.i(0)
p=this.a
p.call(p,r)
return r},
$S:14}
A.db.prototype={
bY(a){if(a<=0||a>4294967296)throw A.a(A.iw("max must be in range 0 < max \u2264 2^32, was "+a))
return Math.random()*a>>>0},
$iiv:1}
A.aI.prototype={
aD(){return"JType."+this.b}}
A.q.prototype={}
A.r.prototype={}
A.ak.prototype={}
A.bX.prototype={}
A.bp.prototype={}
A.a1.prototype={}
A.a_.prototype={}
A.ap.prototype={}
A.P.prototype={}
A.ac.prototype={}
A.w.prototype={}
A.bs.prototype={}
A.bm.prototype={}
A.bt.prototype={}
A.bo.prototype={}
A.c1.prototype={}
A.bS.prototype={}
A.b1.prototype={}
A.bY.prototype={}
A.b9.prototype={}
A.c0.prototype={}
A.bU.prototype={}
A.bz.prototype={}
A.by.prototype={}
A.b0.prototype={
$1(a){return this.e.$1(a)},
$2(a,b){return this.e.$2(a,b)},
$0(){return this.e.$0()},
$1$1(a,b){return this.e.$1$1(a,b)},
$3(a,b,c){return this.e.$3(a,b,c)},
$4(a,b,c,d){return this.e.$4(a,b,c,d)},
$3$hint(a,b,c){return this.e.$3$hint(a,b,c)},
$3$cause(a,b,c){return this.e.$3$cause(a,b,c)},
$2$hint(a,b){return this.e.$2$hint(a,b)}}
A.ba.prototype={}
A.ct.prototype={}
A.cW.prototype={}
A.am.prototype={}
A.dU.prototype={}
A.dX.prototype={
bk(a,b){this.e.q(0,a,b)
return b}}
A.aF.prototype={}
A.Q.prototype={
bV(a,b){return new A.ah(B.y,a,this.c.a,b)},
a3(a){return this.bV(a,null)},
O(a){var s,r=this.b
if(!(a<r.length))return A.b(r,a)
s=r[a]
if(typeof s=="number")return s
throw A.a(this.a3(this.a.a+" necesita un n\xfamero, pero recibi\xf3 "+A.R(s)+"."))},
az(a){var s=this.O(a)
if(A.cj(s))return s
if(s===(s<0?Math.ceil(s):Math.floor(s)))return B.h.ab(s)
throw A.a(this.a3(this.a.a+" necesita un n\xfamero entero, pero recibi\xf3 "+A.R(s)+"."))},
a4(a){var s,r,q=this.b
if(!(a<q.length))return A.b(q,a)
s=q[a]
if(typeof s=="string")return s
q=A.R(s)
r=typeof s=="number"?u.d:null
throw A.a(this.bV(this.a.a+" necesita un texto, pero recibi\xf3 "+q+".",r))},
$1(a){return this.c.$1(a)},
$2(a,b){return this.c.$2(a,b)},
$0(){return this.c.$0()},
$1$1(a,b){return this.c.$1$1(a,b)},
$3(a,b,c){return this.c.$3(a,b,c)},
$4(a,b,c,d){return this.c.$4(a,b,c,d)},
$3$hint(a,b,c){return this.c.$3$hint(a,b,c)},
$3$cause(a,b,c){return this.c.$3$cause(a,b,c)},
$2$hint(a,b){return this.c.$2$hint(a,b)}}
A.eR.prototype={
$1(a){return t.t.a(a).a},
$S:15}
A.et.prototype={
$1(a){return Math.abs(t.V.a(a).O(0))},
$S:12}
A.eu.prototype={
$1(a){var s
t.V.a(a)
s=a.O(0)
if(s<=0)throw A.a(a.a3("Ln solo funciona con n\xfameros mayores que cero."))
return Math.log(s)},
$S:1}
A.ev.prototype={
$1(a){return Math.exp(t.V.a(a).O(0))},
$S:1}
A.eE.prototype={
$1(a){return Math.sin(t.V.a(a).O(0))},
$S:1}
A.eF.prototype={
$1(a){return Math.cos(t.V.a(a).O(0))},
$S:1}
A.eG.prototype={
$1(a){return Math.tan(t.V.a(a).O(0))},
$S:1}
A.eH.prototype={
$1(a){return Math.asin(A.hs(t.V.a(a)))},
$S:1}
A.eI.prototype={
$1(a){return Math.acos(A.hs(t.V.a(a)))},
$S:1}
A.eJ.prototype={
$1(a){return Math.atan(t.V.a(a).O(0))},
$S:1}
A.eK.prototype={
$1(a){return B.h.ab(t.V.a(a).O(0))},
$S:3}
A.eL.prototype={
$1(a){return B.h.c0(t.V.a(a).O(0))},
$S:3}
A.ew.prototype={
$1(a){var s
t.V.a(a)
s=a.az(0)
if(s<=0)throw A.a(a.a3("Azar necesita un n\xfamero mayor que cero."))
return a.d.bY(s)},
$S:3}
A.ex.prototype={
$1(a){var s,r
t.V.a(a)
s=a.az(0)
r=a.az(1)
if(s>r)throw A.a(a.a3("En Aleatorio(a, b) el primer n\xfamero no puede ser mayor que el segundo."))
return s+a.d.bY(r-s+1)},
$S:3}
A.ey.prototype={
$1(a){return t.V.a(a).a4(0).length},
$S:3}
A.ez.prototype={
$1(a){return t.V.a(a).a4(0).toUpperCase()},
$S:4}
A.eA.prototype={
$1(a){return t.V.a(a).a4(0).toLowerCase()},
$S:4}
A.eB.prototype={
$1(a){t.V.a(a)
return a.a4(0)+a.a4(1)},
$S:4}
A.eC.prototype={
$1(a){var s
t.V.a(a)
s=A.f7(a.a4(0))
if(s==null)throw A.a(a.a3('"'+a.a4(0)+'" no es un n\xfamero.'))
return s},
$S:12}
A.eD.prototype={
$1(a){return A.aY(t.V.a(a).O(0))},
$S:4}
A.cA.prototype={}
A.cz.prototype={}
A.eX.prototype={
$1(a){var s,r,q,p,o,n,m,l=this
t.aE.a(a)
s=l.a
r=s.a
if(r==null)return
s.a=null
for(q=a.gbf(),q=q.gF(q),p=l.b;q.n();){o=q.gp()
if(a.C(0,o)!=null&&!B.a.V(p,o))B.a.k(p,o)}q=l.c.b.a
q=q.charCodeAt(0)==0?q:q
n=B.c.bm(q,s.c)
s.c=q.length
s=r-1
q=l.e
p=q.length
if(s<p){if(!(s>=0))return A.b(q,s)
s=B.c.aj(q[s])}else s=""
q=t.N
q=A.bJ(q,q)
for(p=a.gba(),p=p.gF(p);p.n();){o=p.gp()
m=o.b
if(m!=null)q.q(0,o.a,A.hw(m))}B.a.k(l.d,new A.cA(r,s,q,n))},
$S:20}
A.eW.prototype={
$2(a,b){var s=this,r=s.a
s.b.$1(r.b.gc1())
if(s.c.length>=s.d){r.d=!0
r.b.w=!0}r.a=b},
$S:21}
A.cB.prototype={
aD(){return"ErrorKind."+this.b}}
A.bw.prototype={
aD(){return"ErrorCause."+this.b}}
A.ah.prototype={
i(a){return(this.a===B.p?"Error de escritura":"Error al ejecutar")+" (l\xednea "+this.c+"): "+this.b}}
A.d_.prototype={}
A.cs.prototype={
bg(){var s=0,r=A.C(t.u),q,p=this,o,n,m,l
var $async$bg=A.D(function(a,b){if(a===1)return A.z(b,r)
while(true)switch(s){case 0:m=p.a
l=m.b
if(l===m.c)m=null
else{++m.d
o=m.a
if(!(l<o.length)){q=A.b(o,l)
s=1
break}n=o[l]
if(n==null)n=m.$ti.c.a(n)
B.a.q(o,l,null)
m.b=(m.b+1&m.a.length-1)>>>0
m=n}q=m
s=1
break
case 1:return A.A(q,r)}})
return A.B($async$bg,r)},
bi(){var s=0,r=A.C(t.H)
var $async$bi=A.D(function(a,b){if(a===1)return A.z(b,r)
while(true)switch(s){case 0:return A.A(null,r)}})
return A.B($async$bi,r)},
aU(a){var s=0,r=A.C(t.H)
var $async$aU=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:return A.A(null,r)}})
return A.B($async$aU,r)},
$iii:1}
A.dV.prototype={}
A.a2.prototype={}
A.dr.prototype={
gc1(){var s,r=A.bJ(t.N,t.X),q=this.f
if(q.length!==0)for(q=B.a.gj(q),q=new A.aL(q,q.r,q.e,A.L(q).h("aL<2>"));q.n();){s=q.d
r.q(0,s.a,s.c)}return r},
aR(){var s=0,r=A.C(t.H),q,p=2,o=[],n=[],m=this,l
var $async$aR=A.D(function(a,b){if(a===1){o.push(b)
s=p}while(true)switch(s){case 0:l=m.f
B.a.k(l,A.bJ(t.N,t.Q))
p=3
s=6
return A.e(m.M(m.a.a.d),$async$aR)
case 6:n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
m.x=m.gc1()
if(0>=l.length){q=A.b(l,-1)
s=1
break}l.pop()
s=n.pop()
break
case 5:case 1:return A.A(q,r)
case 2:return A.z(o.at(-1),r)}})
return A.B($async$aR,r)},
M(a){return this.cp(t.ck.a(a))},
cp(a){var s=0,r=A.C(t.H),q=this,p,o
var $async$M=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:p=a.length,o=0
case 2:if(!(o<a.length)){s=4
break}s=5
return A.e(q.t(a[o]),$async$M)
case 5:case 3:a.length===p||(0,A.W)(a),++o
s=2
break
case 4:return A.A(null,r)}})
return A.B($async$M,r)},
ah(a,b){var s=0,r=A.C(t.H),q=this,p,o,n
var $async$ah=A.D(function(c,d){if(c===1)return A.z(d,r)
while(true)switch(s){case 0:if(q.w)throw A.a(B.M)
p=++q.r
o=q.c.a
if(o!=null&&p>o)throw A.a(q.aE(a,"El programa se detuvo porque llevaba demasiados pasos ("+A.m(o)+").",B.P,"Parece un ciclo que no termina. Dentro del Mientras o del Repetir debe cambiar algo, por ejemplo n <- n - 1, para que la condici\xf3n deje de cumplirse."))
p=b==null?a.a:b
n=q.d.$2(a,p)
s=n instanceof A.F?2:3
break
case 2:s=4
return A.e(n,$async$ah)
case 4:case 3:s=B.e.bj(q.r,1000)===0?5:6
break
case 5:s=7
return A.e(A.fN(B.o,t.H),$async$ah)
case 7:case 6:return A.A(null,r)}})
return A.B($async$ah,r)},
aM(a){return this.ah(a,null)},
t(a){var s=0,r=A.C(t.H),q=this,p,o,n,m,l,k,j,i
var $async$t=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:s=2
return A.e(q.aM(a),$async$t)
case 2:p=a instanceof A.bs
o=p?a:null
if(p){q.ck(o)
s=3
break}p=a instanceof A.bt
o=p?a:null
s=p?4:5
break
case 4:s=6
return A.e(q.aC(o),$async$t)
case 6:s=3
break
case 5:p=a instanceof A.bo
o=p?a:null
s=p?7:8
break
case 7:i=o.e
s=10
return A.e(q.u(o.f),$async$t)
case 10:s=9
return A.e(q.ak(i,c,o),$async$t)
case 9:s=3
break
case 8:p=a instanceof A.c1
o=p?a:null
s=p?11:12
break
case 11:p=o.e,n=p.length,m=0,l=""
case 13:if(!(m<p.length)){s=15
break}i=A
s=16
return A.e(q.u(p[m]),$async$t)
case 16:l+=i.aY(c)
case 14:p.length===n||(0,A.W)(p),++m
s=13
break
case 15:p=o.f?l+"\n":l
q.b.b.a+=p.charCodeAt(0)==0?p:p
s=3
break
case 12:p=a instanceof A.bS
o=p?a:null
s=p?17:18
break
case 17:s=19
return A.e(q.ar(o),$async$t)
case 19:s=3
break
case 18:p=a instanceof A.b1
o=p?a:null
s=p?20:21
break
case 20:s=25
return A.e(q.ac(o.e,"Si"),$async$t)
case 25:s=c?22:24
break
case 22:s=26
return A.e(q.M(o.f),$async$t)
case 26:s=23
break
case 24:p=o.r
s=p!=null?27:28
break
case 27:s=29
return A.e(q.M(p),$async$t)
case 29:case 28:case 23:s=3
break
case 21:p=a instanceof A.b9
o=p?a:null
s=p?30:31
break
case 30:s=32
return A.e(q.aa(o),$async$t)
case 32:s=3
break
case 31:p=a instanceof A.c0
o=p?a:null
s=p?33:34
break
case 33:p=o.e,n=o.f
case 35:s=37
return A.e(q.ac(p,"Mientras"),$async$t)
case 37:if(!c){s=36
break}s=38
return A.e(q.M(n),$async$t)
case 38:s=39
return A.e(q.aM(o),$async$t)
case 39:s=35
break
case 36:s=3
break
case 34:p=a instanceof A.bU
o=p?a:null
s=p?40:41
break
case 40:p=o.e,n=o.f,l=n.a,k=o.r
case 42:if(!!0){s=43
break}s=44
return A.e(q.M(p),$async$t)
case 44:s=45
return A.e(q.ah(o,l),$async$t)
case 45:s=46
return A.e(q.ac(n,k?"Hasta Que":"Mientras Que"),$async$t)
case 46:if(c===k){s=43
break}s=42
break
case 43:s=3
break
case 41:p=a instanceof A.bz
o=p?a:null
s=p?47:48
break
case 47:s=49
return A.e(q.a1(o),$async$t)
case 49:s=3
break
case 48:p=a instanceof A.by
o=p?a:null
s=p?50:51
break
case 50:s=52
return A.e(q.ao(o),$async$t)
case 52:s=3
break
case 51:p=a instanceof A.b0
o=p?a:null
s=p?53:54
break
case 53:s=55
return A.e(q.al(o.e,!0),$async$t)
case 55:s=3
break
case 54:p=a instanceof A.ba
o=p?a:null
s=p?56:57
break
case 56:p=o.e
s=p==null?58:60
break
case 58:s=61
return A.e(q.b.bi(),$async$t)
case 61:s=59
break
case 60:s=62
return A.e(q.u(p),$async$t)
case 62:j=q.J(c,p,"El tiempo de Esperar")
if(j<0)throw A.a(q.A(o,"El tiempo de Esperar no puede ser negativo."))
s=63
return A.e(q.b.aU(new A.bu(1000*B.h.c0(o.f?j:j*1000))),$async$t)
case 63:case 59:s=3
break
case 57:case 3:return A.A(null,r)}})
return A.B($async$t,r)},
ck(a){var s,r,q,p,o,n,m,l
for(s=a.e,r=s.length,q=a.f,p=0;p<s.length;s.length===r||(0,A.W)(s),++p){o=s[p]
n=this.ae(o)
m=n.b=q
l=n.c
if(l instanceof A.M)l.d=m
else if(l!=null)n.c=this.am(l,m,o,a)}},
aC(a){var s=0,r=A.C(t.H),q=this,p,o,n,m,l,k,j,i,h,g,f,e,d
var $async$aC=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:p=a.e,o=p.length,n=t.S,m=t.Y,l=0
case 2:if(!(l<p.length)){s=4
break}k=p[l]
j=A.j([],m)
i=k.d,h=i.length,g=0
case 5:if(!(g<i.length)){s=7
break}f=i[g]
s=8
return A.e(q.u(f),$async$aC)
case 8:e=q.aJ(c,f,"El tama\xf1o del arreglo")
if(e<1)throw A.a(q.A(f,"El tama\xf1o del arreglo debe ser al menos 1, pero es "+e+"."))
B.a.k(j,e)
case 6:i.length===h||(0,A.W)(i),++g
s=5
break
case 7:if(B.a.bW(j,1,new A.du(),n)>1e7)throw A.a(q.A(k,"El arreglo '"+k.c+"' es demasiado grande."))
i=k.c
d=q.ae(i)
if(d.c instanceof A.M)throw A.a(q.A(k,"El arreglo '"+i+"' ya fue dimensionado."))
d.c=A.hW(i,j,d.b)
case 3:p.length===o||(0,A.W)(p),++l
s=2
break
case 4:return A.A(null,r)}})
return A.B($async$aC,r)},
ar(a){var s=0,r=A.C(t.H),q=this,p,o,n,m,l,k,j,i
var $async$ar=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:p=a.e,o=p.length,n=t.q,m=q.b,l=0
case 2:if(!(l<p.length)){s=4
break}k=p[l]
s=5
return A.e(m.bg(),$async$ar)
case 5:j=c
if(j==null)throw A.a(q.cq(a,"El programa pidi\xf3 un dato con Leer, pero ya no hay datos de entrada.",B.Q))
i=k instanceof A.a_?k.e:n.a(k).e
s=6
return A.e(q.ak(k,q.cH(j,q.cZ(k),i,a),a),$async$ar)
case 6:case 3:p.length===o||(0,A.W)(p),++l
s=2
break
case 4:return A.A(null,r)}})
return A.B($async$ar,r)},
cZ(a){var s,r,q=null
if(a instanceof A.a1){s=B.a.gj(this.f).C(0,A.I(a.e))
return s==null?q:s.b}if(a instanceof A.a_){s=B.a.gj(this.f).C(0,A.I(a.e))
r=s==null?q:s.c
return r instanceof A.M?r.d:q}return q},
cH(a,b,c,d){var s,r,q,p="', pero se escribi\xf3 \"",o=B.c.aj(a)
switch(b){case null:case void 0:s=A.f7(o)
return s==null?a:s
case B.q:r=A.f7(o)
if(r!=null&&r===B.h.ab(r))return B.h.ab(r)
throw A.a(this.A(d,"Se esperaba un n\xfamero entero para '"+c+p+a+'".'))
case B.l:r=A.f7(o)
if(r!=null)return r
throw A.a(this.A(d,"Se esperaba un n\xfamero para '"+c+p+a+'".'))
case B.r:q=A.I(o)
if(q==="verdadero"||q==="v")return!0
if(q==="falso"||q==="f")return!1
throw A.a(this.A(d,"Se esperaba Verdadero o Falso para '"+c+p+a+'".'))
case B.j:return a}},
aa(a){var s=0,r=A.C(t.H),q,p=this,o,n,m,l,k,j,i,h,g,f
var $async$aa=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:s=3
return A.e(p.u(a.e),$async$aa)
case 3:g=c
o=a.f,n=o.length,m=0
case 4:if(!(m<o.length)){s=6
break}l=o[m]
k=l.a,j=k.length,i=0
case 7:if(!(i<k.length)){s=9
break}h=k[i]
f=g
s=12
return A.e(p.u(h),$async$aa)
case 12:s=p.aZ(f,c,h)?10:11
break
case 10:s=13
return A.e(p.M(l.b),$async$aa)
case 13:s=1
break
case 11:case 8:k.length===j||(0,A.W)(k),++i
s=7
break
case 9:case 5:o.length===n||(0,A.W)(o),++m
s=4
break
case 6:o=a.r
s=o!=null?14:15
break
case 14:s=16
return A.e(p.M(o),$async$aa)
case 16:case 15:case 1:return A.A(q,r)}})
return A.B($async$aa,r)},
a1(a){var s=0,r=A.C(t.H),q=this,p,o,n,m,l,k,j,i,h
var $async$a1=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:i=a.f
s=2
return A.e(q.u(i),$async$a1)
case 2:h=q.J(c,i,"El valor inicial del Para")
i=a.r
s=3
return A.e(q.u(i),$async$a1)
case 3:p=q.J(c,i,"El valor final del Para")
i=a.w
o=i==null
s=!o?4:6
break
case 4:s=7
return A.e(q.u(i),$async$a1)
case 7:n=q.J(c,i,"El paso del Para")
s=5
break
case 6:n=h>p?-1:1
case 5:if(n===0)throw A.a(q.A(o?a:i,"El paso del ciclo Para no puede ser 0."))
i=a.e
m=q.ae(i)
o=a.x
l="La variable '"+i+"' del Para"
k=n>0
j=h
case 8:if(!!0){s=9
break}if(!(k?j<=p:j>=p)){s=9
break}m.c=q.am(j,m.b,i,a)
s=10
return A.e(q.M(o),$async$a1)
case 10:s=11
return A.e(q.aM(a),$async$a1)
case 11:j=q.J(m.c,a,l)+n
s=8
break
case 9:return A.A(null,r)}})
return A.B($async$a1,r)},
ao(a){var s=0,r=A.C(t.H),q=this,p,o,n,m,l,k,j
var $async$ao=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:l=a.f
k=B.a.gj(q.f).C(0,A.I(l))
j=k==null?null:k.c
if(!(j instanceof A.M))throw A.a(q.R(a,"'"+l+"' no es un arreglo.","Cr\xe9alo antes con: Dimension "+l+"[tama\xf1o]"))
p=q.ae(a.e)
k=j.c,o=k.length,n=a.r,m=0
case 2:if(!(m<o)){s=4
break}p.c=k[m]
s=5
return A.e(q.M(n),$async$ao)
case 5:s=6
return A.e(q.aM(a),$async$ao)
case 6:B.a.q(k,m,q.am(p.c,j.d,l,a))
case 3:++m
s=2
break
case 4:return A.A(null,r)}})
return A.B($async$ao,r)},
ae(a){return B.a.gj(this.f).bZ(A.I(a),new A.dv(a))},
bN(a,b){var s,r,q,p=this,o=" <- 0' o con 'Leer ",n=a.e,m=p.f,l=B.a.gj(m).C(0,A.I(n))
if(l==null){if(A.I(n)==="pi")return 3.141592653589793
m=B.a.gj(m)
s=A.L(m).h("aM<2>")
r=A.eT(n,A.fT(new A.aM(m,s),s.h("f(d.E)").a(new A.dw()),s.h("d.E"),t.N))
m=r!=null?"\xbfQuisiste decir '"+r+"'?":"Revisa c\xf3mo la escribiste. Si es nueva, cr\xe9ala antes con '"+n+o+n+"'."
throw A.a(p.R(a,"No encuentro la variable '"+n+"'.",m))}q=l.c
if(q==null)throw A.a(p.R(a,"La variable '"+n+"' todav\xeda no tiene valor en este punto.","Antes de usarla dale un valor, con '"+n+o+n+"'. Esa l\xednea debe estar m\xe1s arriba que esta."))
if(q instanceof A.M&&!b)throw A.a(p.A(a,"'"+n+"' es un arreglo; indica una posici\xf3n, por ejemplo "+n+"[1]."))
return q},
cR(a){return this.bN(a,!1)},
ak(a,b,c){var s=0,r=A.C(t.H),q=this,p,o,n,m,l,k
var $async$ak=A.D(function(d,e){if(d===1)return A.z(e,r)
while(true)switch(s){case 0:if(b instanceof A.M)throw A.a(q.A(c,"No se puede asignar un arreglo completo; copia sus elementos uno por uno."))
p=a instanceof A.a1
o=p?a:null
if(p){p=o.e
n=q.ae(p)
if(n.c instanceof A.M)throw A.a(q.A(c,"'"+p+"' es un arreglo; indica la posici\xf3n, por ejemplo "+p+"[1] <- ..."))
n.c=q.am(b,n.b,p,c)
s=2
break}p=a instanceof A.a_
m=p?a:null
s=p?3:4
break
case 3:s=5
return A.e(q.ag(m),$async$ak)
case 5:l=e
k=l.a
B.a.q(k.c,l.b,q.am(b,k.d,m.e,c))
s=2
break
case 4:throw A.a(q.A(c,"Solo se puede asignar a una variable o a una posici\xf3n de un arreglo."))
case 2:return A.A(null,r)}})
return A.B($async$ak,r)},
am(a,b,c,d){var s,r,q,p="No se puede guardar "
if(b==null||a==null)return a
switch(b){case B.q:if(A.cj(a))return a
s=typeof a=="number"
if(s)r=a===(a<0?Math.ceil(a):Math.floor(a))
else r=!1
if(r)return B.h.ab(a)
r=A.R(a)
s=s?"Usa Trunc() o Redon(), o define la variable como Real.":null
throw A.a(this.R(d,p+r+" en '"+c+"' porque es de tipo Entero.",s))
case B.l:if(typeof a=="number")return a
break
case B.r:if(A.aq(a))return a
break
case B.j:if(typeof a=="string")return a
break}s=A.R(a)
r=b.c
q=b===B.j&&typeof a=="number"?u.d:null
throw A.a(this.R(d,p+s+" en '"+c+"' porque es de tipo "+r+".",q))},
ag(a){var s=0,r=A.C(t.d7),q,p=this,o,n,m,l,k,j,i,h,g,f,e,d
var $async$ag=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:g=a.e
f=B.a.gj(p.f).C(0,A.I(g))
e=f==null
d=e?null:f.c
if(!(d instanceof A.M)){e=e?"El arreglo '"+g+"' no existe.":"'"+g+"' no es un arreglo."
throw A.a(p.R(a,e,"Cr\xe9alo antes con: Dimension "+g+"[tama\xf1o]"))}e=a.f
o=e.length
n=d.b
m=n.length
if(o!==m)throw A.a(p.A(a,"El arreglo '"+g+"' tiene "+m+" dimensi\xf3n(es), pero se usaron "+o+" \xedndice(s)."))
o=m,l=0,k=0
case 3:if(!(k<o)){s=5
break}if(!(k<e.length)){q=A.b(e,k)
s=1
break}j=e[k]
s=6
return A.e(p.u(j),$async$ag)
case 6:i=p.aJ(c,j,"El \xedndice")
h=i-1
if(h>=0){if(!(k<n.length)){q=A.b(n,k)
s=1
break}o=h>=n[k]}else o=!0
if(o){if(!(k<n.length)){q=A.b(n,k)
s=1
break}throw A.a(p.R(j,"La posici\xf3n "+i+" est\xe1 fuera del arreglo '"+g+"'.","Las posiciones v\xe1lidas van de 1 a "+(n[k]-1+1)+"."))}o=n.length
if(!(k<o)){q=A.b(n,k)
s=1
break}l=l*n[k]+h
case 4:++k
s=3
break
case 5:q=new A.ay(d,l)
s=1
break
case 1:return A.A(q,r)}})
return A.B($async$ag,r)},
u(a){var s=0,r=A.C(t.X),q,p=this,o
var $async$u=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:if(a instanceof A.ak){o=a.e
s=3
break}if(a instanceof A.bX){o=a.e
s=3
break}if(a instanceof A.bp){o=a.e
s=3
break}if(a instanceof A.a1){o=p.cR(a)
s=3
break}s=a instanceof A.a_?4:5
break
case 4:s=6
return A.e(p.aI(a),$async$u)
case 6:o=c
s=3
break
case 5:s=a instanceof A.ap?7:8
break
case 7:s=9
return A.e(p.aN(a),$async$u)
case 9:o=c
s=3
break
case 8:s=a instanceof A.P?10:11
break
case 10:s=12
return A.e(p.a7(a),$async$u)
case 12:o=c
s=3
break
case 11:s=a instanceof A.ac?13:14
break
case 13:s=15
return A.e(p.cc(a),$async$u)
case 15:o=c
s=3
break
case 14:o=null
case 3:q=o
s=1
break
case 1:return A.A(q,r)}})
return A.B($async$u,r)},
aI(a){var s=0,r=A.C(t.X),q,p=this,o,n,m,l,k
var $async$aI=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:s=3
return A.e(p.ag(a),$async$aI)
case 3:n=c
m=n.a
l=n.b
k=m.c
if(!(l>=0&&l<k.length)){q=A.b(k,l)
s=1
break}o=k[l]
if(o==null)throw A.a(p.A(a,"Esa posici\xf3n del arreglo '"+a.e+"' todav\xeda no tiene valor."))
q=o
s=1
break
case 1:return A.A(q,r)}})
return A.B($async$aI,r)},
aN(a){var s=0,r=A.C(t.X),q,p=this,o
var $async$aN=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)switch(s){case 0:s=3
return A.e(p.u(a.f),$async$aN)
case 3:o=c
if(a.e==="-"){q=-p.J(o,a,"El signo '-'")
s=1
break}q=!p.b8(o,a,"'No'")
s=1
break
case 1:return A.A(q,r)}})
return A.B($async$aN,r)},
a7(a){var s=0,r=A.C(t.X),q,p=this,o,n,m,l,k,j,i,h,g
var $async$a7=A.D(function(b,c){if(b===1)return A.z(c,r)
while(true)$async$outer:switch(s){case 0:h=a.e
g=h==="y"
s=g||h==="o"?3:4
break
case 3:o=g?"'Y'":"'O'"
s=5
return A.e(p.u(a.f),$async$a7)
case 5:n=p.b8(c,a,o)
if(g&&!n){q=!1
s=1
break}if(h==="o"&&n){q=!0
s=1
break}s=6
return A.e(p.u(a.r),$async$a7)
case 6:q=p.b8(c,a,o)
s=1
break
case 4:s=7
return A.e(p.u(a.f),$async$a7)
case 7:n=c
s=8
return A.e(p.u(a.r),$async$a7)
case 8:m=c
switch(h){case"+":h=typeof n=="number"
if(h&&typeof m=="number"){q=p.af(n+m,a)
s=1
break $async$outer}g=typeof n=="string"
if(g)l=typeof m=="string"||typeof m=="number"||A.aq(m)
else l=!1
if(!l)if(typeof m=="string")h=h||A.aq(n)
else h=!1
else h=!0
if(h){q=A.aY(n)+A.aY(m)
s=1
break $async$outer}h=A.R(n)
l=A.R(m)
g=g||typeof m=="string"?'Para unir textos con valores usa +, o comas en Escribir: Escribir "Total: ", x':null
throw A.a(p.R(a,"No se puede sumar "+h+" con "+l+".",g))
case"-":q=p.af(p.J(n,a,"La resta '-'")-p.J(m,a,"La resta '-'"),a)
s=1
break $async$outer
case"*":q=p.af(p.J(n,a,"La multiplicaci\xf3n '*'")*p.J(m,a,"La multiplicaci\xf3n '*'"),a)
s=1
break $async$outer
case"/":k=p.J(n,a,"La divisi\xf3n '/'")
j=p.J(m,a,"La divisi\xf3n '/'")
if(j===0)throw A.a(p.R(a,"No se puede dividir entre cero.","El divisor val\xeda 0 al llegar aqu\xed. Revisa de d\xf3nde sale ese valor, o pregunta antes: Si divisor <> 0 Entonces ... FinSi"))
q=p.af(k/j,a)
s=1
break $async$outer
case"mod":k=p.aJ(n,a,"MOD")
j=p.aJ(m,a,"MOD")
if(j===0)throw A.a(p.R(a,"No se puede calcular MOD entre cero.","El valor de la derecha de MOD val\xeda 0. Revisa de d\xf3nde sale, o pregunta antes: Si divisor <> 0 Entonces ... FinSi"))
q=k%j
s=1
break $async$outer
case"^":q=p.af(Math.pow(p.J(n,a,"La potencia '^'"),p.J(m,a,"La potencia '^'")),a)
s=1
break $async$outer
case"=":q=p.aZ(n,m,a)
s=1
break $async$outer
case"<>":q=!p.aZ(n,m,a)
s=1
break $async$outer
default:i=p.ce(n,m,a)
$label0$1:{if("<"===h){h=i<0
break $label0$1}if(">"===h){h=i>0
break $label0$1}if("<="===h){h=i<=0
break $label0$1}h=i>=0
break $label0$1}q=h
s=1
break $async$outer}case 1:return A.A(q,r)}})
return A.B($async$a7,r)},
aZ(a,b,c){var s
if(typeof a=="number"&&typeof b=="number")return a===b
s=J.aC(a)
if(s.gv(a)===J.fG(b))return s.a5(a,b)
throw A.a(this.A(c,"No se puede comparar "+A.R(a)+" con "+A.R(b)+"."))},
ce(a,b,c){var s
if(typeof a=="number"&&typeof b=="number")return B.h.aO(a,b)
if(typeof a=="string"&&typeof b=="string"){if(a===b)s=0
else s=a<b?-1:1
return s}throw A.a(this.A(c,"No se puede comparar "+A.R(a)+" con "+A.R(b)+"."))},
al(a,b){var s=0,r=A.C(t.X),q,p=this,o,n,m,l,k,j,i,h,g
var $async$al=A.D(function(c,d){if(c===1)return A.z(d,r)
while(true)switch(s){case 0:j=a.e
i=A.I(j)
h=p.a.b.C(0,i)
if(h!=null){q=p.a8(h,a,b)
s=1
break}o=$.fE().C(0,i)
if(o==null)throw A.a(p.A(a,"No existe la funci\xf3n '"+j+"'."))
j=[]
n=a.f,m=n.length,l=0
case 3:if(!(l<n.length)){s=5
break}g=j
s=6
return A.e(p.u(n[l]),$async$al)
case 6:g.push(d)
case 4:n.length===m||(0,A.W)(n),++l
s=3
break
case 5:k=o.c.$1(new A.Q(o,j,a,p.e,1))
q=typeof k=="number"?p.af(k,a):k
s=1
break
case 1:return A.A(q,r)}})
return A.B($async$al,r)},
cc(a){return this.al(a,!1)},
a8(a,b,c){return this.cd(a,b,c)},
cd(a7,a8,a9){var s=0,r=A.C(t.X),q,p=2,o=[],n=[],m=this,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6
var $async$a8=A.D(function(b0,b1){if(b0===1){o.push(b1)
s=p}while(true)switch(s){case 0:a6=m.f
if(a6.length>=200)throw A.a(m.R(a8,"Demasiadas llamadas a funciones, una dentro de otra.","\xbfUna funci\xf3n recursiva que nunca llega a su caso base?"))
l=A.bJ(t.N,t.Q)
k=A.j([],t.A)
j=a7.b,i=a8.f,h=0
case 3:if(!(h<j.length)){s=5
break}g=j[h]
if(!(h<i.length)){q=A.b(i,h)
s=1
break}f=i[h]
e=g.a
d=A.I(e)
s=!g.b?6:8
break
case 6:s=f instanceof A.a1?9:11
break
case 9:b1=m.bN(f,!0)
s=10
break
case 11:s=12
return A.e(m.u(f),$async$a8)
case 12:case 10:c=b1
e=new A.a2(e,null)
e.c=c
l.q(0,d,e)
s=7
break
case 8:s=f instanceof A.a1?13:15
break
case 13:l.q(0,d,m.ae(f.e))
s=14
break
case 15:s=f instanceof A.a_?16:18
break
case 16:b={}
b.a=b.b=null
s=19
return A.e(m.ag(f),$async$a8)
case 19:a=b1
a0=b.b=a.a
a1=a.b
b.a=a1
a2=new A.a2(e,a0.d)
e=a0.c
if(!(a1>=0&&a1<e.length)){q=A.b(e,a1)
s=1
break}a2.c=e[a1]
l.q(0,d,a2)
B.a.k(k,new A.ds(b,a2))
s=17
break
case 18:throw A.a(m.A(f,"El par\xe1metro '"+e+"' de '"+a7.a+"' es Por Referencia, as\xed que necesita una variable, no un valor."))
case 17:case 14:case 7:case 4:++h
s=3
break
case 5:a3=a7.c
a4=a3==null?null:l.bZ(A.I(a3),new A.dt(a3))
B.a.k(a6,l)
s=B.e.bj(a6.length,32)===0?20:21
break
case 20:s=22
return A.e(A.fN(B.o,t.H),$async$a8)
case 22:case 21:p=23
s=26
return A.e(m.M(a7.d),$async$a8)
case 26:n.push(25)
s=24
break
case 23:n=[2]
case 24:p=2
if(0>=a6.length){q=A.b(a6,-1)
s=1
break}a6.pop()
s=n.pop()
break
case 25:for(a6=k.length,a5=0;a5<k.length;k.length===a6||(0,A.W)(k),++a5)k[a5].$0()
if(a9||a4==null){q=null
s=1
break}a6=a4.c
if(a6==null)throw A.a(m.A(a8,"La funci\xf3n '"+a7.a+"' termin\xf3 sin darle un valor a '"+A.m(a3)+"'."))
q=a6
s=1
break
case 1:return A.A(q,r)
case 2:return A.z(o.at(-1),r)}})
return A.B($async$a8,r)},
aE(a,b,c,d){return new A.ah(B.y,b,a.a,d)},
A(a,b){return this.aE(a,b,B.x,null)},
R(a,b,c){return this.aE(a,b,B.x,c)},
cq(a,b,c){return this.aE(a,b,c,null)},
ac(a,b){var s=0,r=A.C(t.y),q,p=this,o
var $async$ac=A.D(function(c,d){if(c===1)return A.z(d,r)
while(true)switch(s){case 0:s=3
return A.e(p.u(a),$async$ac)
case 3:o=d
if(A.aq(o)){q=o
s=1
break}throw A.a(p.R(a,"La condici\xf3n del '"+b+"' debe ser Verdadero o Falso, pero es "+A.R(o)+".","Usa una comparaci\xf3n, por ejemplo: x > 0"))
case 1:return A.A(q,r)}})
return A.B($async$ac,r)},
J(a,b,c){if(typeof a=="number")return a
throw A.a(this.A(b,c+" necesita n\xfameros, pero recibi\xf3 "+A.R(a)+"."))},
aJ(a,b,c){var s=this.J(a,b,c)
if(A.cj(s))return s
if(s===(s<0?Math.ceil(s):Math.floor(s)))return B.h.ab(s)
throw A.a(this.A(b,c+" debe ser un n\xfamero entero, pero es "+A.R(a)+"."))},
b8(a,b,c){if(A.aq(a))return a
throw A.a(this.A(b,c+" necesita valores Verdadero o Falso, pero recibi\xf3 "+A.R(a)+"."))},
af(a,b){if(!isFinite(a))throw A.a(this.A(b,"El resultado no es un n\xfamero v\xe1lido (es demasiado grande o no est\xe1 definido)."))
return a}}
A.du.prototype={
$2(a,b){return A.ae(a)*A.ae(b)},
$S:9}
A.dv.prototype={
$0(){return new A.a2(this.a,null)},
$S:13}
A.dw.prototype={
$1(a){return t.Q.a(a).a},
$S:24}
A.ds.prototype={
$0(){var s=this.a,r=s.b,q=this.b.c
B.a.q(r.c,s.a,q)
return q},
$S:0}
A.dt.prototype={
$0(){return new A.a2(this.a,null)},
$S:13}
A.dB.prototype={
dj(){var s,r,q,p,o,n,m,l,k=this,j=null
for(s=k.a,r=s.length,q=k.b;p=k.c,p<r;){o=s[p]
if(o==="\n"){p=k.d
n=k.e
B.a.k(q,new A.a9(B.k,"\n","\n",j,p,n))
k.N()}else if(o===" "||o==="\t"||o==="\r"||o==="\ufeff")k.N()
else if(B.c.bl(s,"//",p))while(!0){p=k.c
if(!(p<r&&s[p]!=="\n"))break
k.N()}else{n=o==="."
if(n){m=$.hQ()
if(p>r)A.bk(A.al(p,0,r,j,j))
p=m.co(s,p)!=null}else p=!1
if(p)k.cl()
else{p=$.cm().b
if(!p.test(o))if(n){l=k.c+1
n=l<r?s[l]:""
p=p.test(n)}else p=!1
else p=!0
if(p)k.cw()
else if(B.C.V(0,o)||o==="'")k.cW()
else{p=$.fD()
if(p.b.test(o))k.d0()
else k.cX()}}}}s=k.d
r=k.e
B.a.k(q,new A.a9(B.d,"","",j,s,r))
return q},
bL(a){var s=this.c+a,r=this.a
return s<r.length?r[s]:""},
N(){var s=this,r=s.a,q=s.c
if(!(q<r.length))return A.b(r,q)
if(r[q]==="\n"){++s.d
s.e=1}else ++s.e
s.c=q+1},
cw(){var s,r,q,p=this,o=p.d,n=p.e,m=p.c,l=p.a,k=l.length
while(!0){s=p.c
if(s<k){r=$.cm()
s=l[s]
s=r.b.test(s)}else s=!1
if(!s)break
p.N()}if(p.bL(0)==="."){s=$.cm()
r=p.bL(1)
s=s.b.test(r)}else s=!1
if(s){p.N()
while(!0){s=p.c
if(s<k){r=$.cm()
s=l[s]
s=r.b.test(s)}else s=!1
if(!s)break
p.N()}}q=B.c.L(l,m,p.c)
l=A.hB(q)
B.a.k(p.b,new A.a9(B.D,q,q,l,o,n))},
cW(){var s,r,q,p,o=this,n=o.d,m=o.e,l=o.c,k=o.a,j=k.length
if(!(l<j))return A.b(k,l)
s=k[l]
r=s==="'"?A.ik(["'"],t.N):B.C
o.N()
while(!0){q=o.c
if(!(q<j&&!r.V(0,k[q])))break
q=o.c
if(!(q<j))return A.b(k,q)
if(k[q]==="\n")break
o.N()}q=o.c
if(q<j){if(!(q<j))return A.b(k,q)
j=k[q]==="\n"}else j=!0
if(j)throw A.a(A.aJ("Falta la comilla que cierra este texto.",m,"Cierra el texto con "+s+" en la misma l\xednea.",n))
p=B.c.L(k,l+1,q)
o.N()
k=B.c.L(k,l,o.c)
B.a.k(o.b,new A.a9(B.t,k,k,p,n,m))},
d0(){var s,r,q,p=this,o=p.d,n=p.e,m=p.c,l=p.a,k=l.length
while(!0){s=p.c
if(s<k){r=$.fD()
s=l[s]
if(!r.b.test(s)){s=$.cm()
r=p.c
if(!(r<k))return A.b(l,r)
r=l[r]
s=s.b.test(r)}else s=!0}else s=!1
if(!s)break
p.N()}q=B.c.L(l,m,p.c)
l=A.I(q)
B.a.k(p.b,new A.a9(B.b,q,l,null,o,n))},
cl(){var s,r,q=this,p=q.d,o=q.e,n=q.c,m=B.c.L(q.a,n,n+3)
for(s=0;s<3;++s)q.N()
if(1>=m.length)return A.b(m,1)
r=m[1].toLowerCase()==="v"?"verdadero":"falso"
B.a.k(q.b,new A.a9(B.b,m,r,null,p,o))},
cX(){var s,r,q,p,o=this,n=o.d,m=o.e,l=o.a,k=o.c,j=l.length
if(!(k<j))return A.b(l,k)
s=B.a1.C(0,l[k])
if(s!=null){o.N()
B.a.k(o.b,new A.a9(B.f,s,s,null,n,m))
return}for(k=o.c,r=0;r<29;++r){q=B.Y[r]
if(B.c.bl(l,q,k)){for(l=q.length,p=0;p<l;++p)o.N()
B.a.k(o.b,new A.a9(B.f,q,q,null,n,m))
return}}if(!(k<j))return A.b(l,k)
throw A.a(A.aJ("No reconozco el car\xe1cter '"+l[k]+"'.",m,null,n))}}
A.dF.prototype={
gb7(){var s=this.a,r=this.b
r=r>0?r-1:0
if(!(r<s.length))return A.b(s,r)
return s[r].e},
dc(){var s,r,q,p,o,n,m,l,k=this,j='Empieza con "Algoritmo mi_programa" y termina con "FinAlgoritmo".',i=A.bJ(t.N,t.f)
k.av()
s=k.a
r=null
while(!0){q=k.b
p=s.length
if(!(q<p))return A.b(s,q)
o=s[q]
if(!(o.a!==B.d))break
o=q<p?o:B.a.gj(s)
if(!(o.a===B.b&&o.c==="algoritmo")){n=k.b
o=n<s.length?s[n]:B.a.gj(s)
q=o.a===B.b&&o.c==="proceso"}else q=!0
if(q){m=k.cI()
if(r!=null)throw A.a(A.aJ("Solo puede haber un Algoritmo por archivo; ya hay uno en la l\xednea "+r.e+".",0,null,m.e))
r=m}else{n=k.b
o=n<s.length?s[n]:B.a.gj(s)
q=!0
if(!(o.a===B.b&&o.c==="funcion")){n=k.b
o=n<s.length?s[n]:B.a.gj(s)
if(!(o.a===B.b&&o.c==="subproceso")){n=k.b
o=n<s.length?s[n]:B.a.gj(s)
q=o.a===B.b&&o.c==="subalgoritmo"}}if(q){m=k.cF()
q=m.a
l=i.C(0,A.I(q))
if(l!=null)throw A.a(A.aJ("La funci\xf3n '"+q+"' ya fue definida en la l\xednea "+l.e+".",0,null,m.e))
i.q(0,A.I(q),m)}else throw A.a(k.K("El c\xf3digo debe ir dentro de 'Algoritmo' ... 'FinAlgoritmo'.",j))}k.av()}if(r==null)throw A.a(A.aJ("Falta el bloque principal 'Algoritmo ... FinAlgoritmo'.",0,j,1))
k.d_(i)
return new A.dU(r,i)},
ga0(){var s=this.a,r=this.b
if(!(r<s.length))return A.b(s,r)
return s[r]},
ap(a){var s=this.b+a,r=this.a,q=r.length
if(s<q){if(!(s>=0))return A.b(r,s)
r=r[s]}else r=B.a.gj(r)
return r},
l(){var s,r=this.a,q=this.b
if(!(q<r.length))return A.b(r,q)
s=r[q]
if(s.a!==B.d)this.b=q+1
return s},
U(a,b){var s=this.ap(b)
return s.a===B.b&&s.c===a},
G(a){return this.U(a,0)},
S(a,b){var s=this.ap(b)
return s.a===B.f&&s.b===a},
Y(a){return this.S(a,0)},
bz(a){var s=this.ap(a).a
return s===B.k||s===B.d||this.S(";",a)},
aF(){return this.bz(0)},
D(a){if(!this.G(a))return!1
this.l()
return!0},
B(a){if(!this.Y(a))return!1
this.l()
return!0},
bn(){return this.B("<-")||this.B("=")||this.B(":=")},
av(){var s,r,q,p=this,o=p.a
while(!0){s=p.b
r=o.length
if(!(s<r))return A.b(o,s)
q=o[s]
if(q.a!==B.k){q=s<r?q:B.a.gj(o)
s=q.a===B.f&&q.b===";"}else s=!0
if(!s)break
s=p.b
if(!(s<o.length))return A.b(o,s)
if(o[s].a!==B.d)p.b=s+1}},
K(a,b){var s,r=this.a,q=this.b
if(!(q<r.length))return A.b(r,q)
s=r[q]
return A.aJ(a,s.f,b,s.e)},
P(a){return this.K(a,null)},
b1(a,b,c){if(this.D(a))return
throw A.a(this.P("Se esperaba '"+b+"' "+c+", pero encontr\xe9 "+this.ga0().T()+"."))},
ad(a,b){if(this.B(a))return
throw A.a(this.P("Se esperaba '"+a+"' "+b+", pero encontr\xe9 "+this.ga0().T()+"."))},
W(a){var s,r=this,q=r.a,p=r.b
if(!(p<q.length))return A.b(q,p)
s=q[p]
q=s.a===B.b
if(q&&!B.m.V(0,s.c))return r.l()
if(q){q=s.b
throw A.a(r.K("'"+q+"' es una palabra reservada (el lenguaje ya la usa) y no puede ser un nombre "+a+".","Elige otro nombre, por ejemplo '"+q+"1' o uno que describa el dato, como 'total'."))}throw A.a(r.P("Se esperaba un nombre "+a+", pero encontr\xe9 "+s.T()+"."))},
X(a){var s
if(!this.G("fin"+a))s=this.G("fin")&&this.U(a,1)
else s=!0
return s},
a9(){if(this.G("fin"))this.l()
this.l()},
bA(){var s=this,r=s.a,q=s.b
if(!(q<r.length))return A.b(r,q)
q=r[q]
r=!0
if(!(q.a===B.b&&B.ad.V(0,q.c)))if(!(s.G("hasta")&&s.U("que",1)))r=s.G("mientras")&&s.U("que",1)||s.cs()
return r},
cs(){return this.G("de")&&this.U("otro",1)&&this.U("modo",2)},
an(){var s,r,q=this
if(q.aF())return
s=q.a
r=q.b
if(!(r<s.length))return A.b(s,r)
r=s[r]
if(r.a===B.b&&B.m.V(0,r.c))return
if(q.ct("escribir"))throw A.a(q.K("Sobra "+q.ga0().T()+" en esta l\xednea: falta una coma o una comilla.",'Separa con comas lo que muestras y pon los textos entre comillas: Escribir "Hola ", nombre'))
throw A.a(q.K("Sobra "+q.ga0().T()+" al final de la instrucci\xf3n.",'Pon cada instrucci\xf3n en su propia l\xednea o sep\xe1ralas con ";".'))},
ct(a){var s,r=this.b,q=this.a,p=q.length,o=r
while(!0){if(o>0){s=o-1
if(!(s<p))return A.b(q,s)
s=q[s]
if(!(r<p))return A.b(q,r)
s=s.e===q[r].e}else s=!1
if(!s)break;--o}if(!(o>=0&&o<p))return A.b(q,o)
q=q[o]
return q.a===B.b&&q.c===a},
cI(){var s,r,q,p,o=this,n=o.l(),m=n.c==="algoritmo",l=m?"Algoritmo":"Proceso"
if(!o.aF())l=o.W("para el algoritmo").b
o.an()
s=m?"FinAlgoritmo":"FinProceso"
r=o.a2(s,new A.dO(o),n)
o.a9()
q=o.gb7()
o.an()
p=new A.am(l,B.W,null,r,n.e)
o.d.bk(p,q)
return p},
cF(){var s,r,q,p,o,n,m,l=this,k="para la funci\xf3n",j=l.l(),i=l.W(k)
if(l.B("<-")||l.B("=")){s=i.b
i=l.W(k)}else s=null
r=A.j([],t.c)
if(l.B("(")){if(!l.Y(")"))do{q=l.W("para el par\xe1metro")
if(l.D("por")){p=l.D("referencia")
if(!p)if(!l.D("valor"))throw A.a(l.P("Despu\xe9s de 'Por' se esperaba 'Referencia' o 'Valor'."))}else p=!1
B.a.k(r,new A.cW(q.b,p))}while(l.B(","))
l.ad(")","para cerrar la lista de par\xe1metros")}l.an()
o=l.a2("Fin"+j.b,new A.dL(l),j)
l.a9()
n=l.gb7()
l.an()
m=new A.am(i.b,r,s,o,j.e)
l.d.bk(m,n)
return m},
a2(a,b,c){var s,r,q,p=this
t.cN.a(b)
s=A.j([],t.b)
for(r=p.a;!0;){p.av()
q=p.b
if(!(q<r.length))return A.b(r,q)
if(r[q].a===B.d)throw A.a(p.b3(c,a))
if(b.$0())return s
if(p.bA()){r=c.b
throw A.a(p.K("Encontr\xe9 "+p.ga0().T()+", pero antes falta '"+a+"' para cerrar el '"+r+"' de la l\xednea "+c.e+".","Cierra primero el '"+r+"' con '"+a+"'. Despu\xe9s va "+p.ga0().T()+"."))}B.a.k(s,p.bI())}},
b3(a,b){var s=a.b,r=a.e
return A.aJ("Falta '"+b+"' para cerrar el '"+s+"' de la l\xednea "+r+".",a.f,"Cada '"+s+"' necesita su '"+b+"'. Escr\xedbelo en su propia l\xednea, debajo de lo que va dentro del bloque.",r)},
bI(){var s,r,q=this,p=q.a,o=q.b
if(!(o<p.length))return A.b(p,o)
s=p[o]
if(s.a!==B.b)throw A.a(q.P("Esta l\xednea no empieza con una instrucci\xf3n v\xe1lida (encontr\xe9 "+s.T()+")."))
r=s.c
$label0$0:{if("definir"===r){p=q.cB()
break $label0$0}if("dimension"===r||"dimensionar"===r){p=q.cC()
break $label0$0}if("escribir"===r||"imprimir"===r||"mostrar"===r){p=q.cQ()
break $label0$0}if("leer"===r){p=q.cL()
break $label0$0}if("si"===r){p=q.cG()
break $label0$0}if("segun"===r){p=q.cN()
break $label0$0}if("mientras"===r){p=q.cP()
break $label0$0}if("repetir"===r){p=q.cM()
break $label0$0}if("para"===r){p=q.U("cada",1)?q.cE():q.cD()
break $label0$0}if("esperar"===r){p=q.cO()
break $label0$0}if("borrarpantalla"===r||"limpiarpantalla"===r){p=q.bF()
break $label0$0}if(("borrar"===r||"limpiar"===r)&&q.U("pantalla",1)){p=q.bF()
break $label0$0}p=q.cz()
break $label0$0}q.d.a.q(0,p,q.gb7())
q.an()
return p},
cz(){var s,r,q,p,o=this,n=o.a,m=o.b
if(!(m<n.length))return A.b(n,m)
s=n[m]
n=s.c
if(B.m.V(0,n)){if(o.S("<-",1)||o.S("=",1)||o.S("[",1)){m=s.b
$label0$0:{if("y"===n){n="'Y' es el operador l\xf3gico. Usa otro nombre, por ejemplo 'y1' o 'coordY'."
break $label0$0}if("o"===n){n="'O' es el operador l\xf3gico. Usa otro nombre, por ejemplo 'o1'."
break $label0$0}n="Elige otro nombre, por ejemplo '"+m+"1'."
break $label0$0}throw A.a(o.K("'"+m+"' es una palabra reservada (el lenguaje ya la usa) y no puede ser el nombre de una variable.",n))}throw A.a(o.P("No se esperaba '"+s.b+"' aqu\xed."))}if(o.S("<-",1)||o.S("=",1)||o.S(":=",1)||o.S("[",1)||o.b2(1)){r=o.bJ()
if(!o.bn())throw A.a(o.P("Se esperaba '<-' para asignar un valor a '"+s.b+"'."))
return new A.bo(r,o.H(),s.e,s.f)}if(o.S("(",1)){o.l()
o.l()
q=o.bD(s)
B.a.k(o.c,new A.ay(q,!0))
return new A.b0(q,s.e,s.f)}if(o.bz(1)){o.l()
n=s.e
m=s.f
q=new A.ac(s.b,B.V,n,m)
B.a.k(o.c,new A.ay(q,!0))
return new A.b0(q,n,m)}n=s.b
p=A.eT(n,B.z)
m=p!=null?"\xbfQuisiste decir '"+p+"'?":"Revisa que est\xe9 bien escrita. Si quer\xedas guardar un valor, usa '"+n+" <- valor'."
throw A.a(o.K("No entiendo la instrucci\xf3n '"+n+"'.",m))},
bJ(){var s=this,r=s.b2(1),q=s.W("de variable")
if(s.Y("["))return new A.a_(q.b,s.b6(),q.e,q.f)
if(r)return new A.a_(q.b,s.bH(),q.e,q.f)
return new A.a1(q.b,q.e,q.f)},
b2(a){var s,r=this
if(r.S("(",a)){s=a-1
s=r.e.V(0,r.ap(s).c)&&r.ap(s).a===B.b}else s=!1
return s},
bH(){var s,r=this
r.ad("(","para el \xedndice")
s=A.j([r.H()],t.I)
for(;r.B(",");)B.a.k(s,r.H())
r.ad(")","para cerrar el \xedndice")
return s},
b6(){var s=this,r=A.j([],t.I)
for(;s.B("[");){B.a.k(r,s.H())
for(;s.B(",");)B.a.k(r,s.H())
s.ad("]","para cerrar el \xedndice")}return r},
cB(){var s,r,q,p,o,n=this,m=n.l(),l=A.j([],t.s)
do B.a.k(l,n.W("de variable").b)
while(n.B(","))
if(!(n.D("como")||n.D("es")))throw A.a(n.P("Se esperaba 'Como' y un tipo, por ejemplo: Definir "+B.a.gd6(l)+" Como Entero."))
s=n.a
r=n.b
if(!(r<s.length))return A.b(s,r)
q=s[r]
s=q.a===B.b
p=s?B.Z.C(0,q.c):null
if(p==null){o=s?A.eT(q.b,B.X):null
s=q.T()
r=o!=null?"\xbfQuisiste decir '"+o+"'?":"Los tipos son Entero, Real, Logico, Caracter y Texto."
throw A.a(n.K(s+" no es un tipo de dato v\xe1lido.",r))}n.l()
return new A.bs(l,p,m.e,m.f)},
cC(){var s,r=this,q=r.l(),p=A.j([],t.h),o=r.e
do{s=r.W("de arreglo")
if(!r.Y("["))throw A.a(r.P("Se esperaba '[' con el tama\xf1o del arreglo, por ejemplo: Dimension "+s.b+"[10]."))
B.a.k(p,new A.bm(s.b,r.b6(),s.e,s.f))
o.k(0,s.c)}while(r.B(","))
return new A.bt(p,q.e,q.f)},
bo(){var s,r=this
if(r.G("sin"))s=r.U("saltar",1)||r.U("bajar",1)
else s=!1
if(s){r.l()
r.l()
return!0}return r.D("sinsaltar")||r.D("sinbajar")},
cQ(){var s,r,q,p,o,n,m,l=this,k=l.l(),j=!l.bo(),i=A.j([],t.I)
if(!l.aF()&&!l.G("sin"))do B.a.k(i,l.H())
while(l.B(","))
if(l.bo())j=!1
s=!1
if(i.length!==0)if(B.a.gj(i) instanceof A.a1){s=l.a
r=l.b
if(!(r<s.length))return A.b(s,r)
s=s[r].a===B.b&&!l.aF()}if(s){q=A.j([t.q.a(B.a.gj(i)).e],t.s)
s=l.a
p=0
while(!0){o=l.b+p
r=(o<s.length?s[o]:B.a.gj(s)).a
n=!0
if(r!==B.k)if(r!==B.d){o=l.b+p
m=o<s.length?s[o]:B.a.gj(s)
r=m.a===B.f&&m.b===";"}else r=n
else r=n
if(!r){o=l.b+p
r=(o<s.length?s[o]:B.a.gj(s)).a===B.b}else r=!1
if(!r)break
o=l.b+p
B.a.k(q,(o<s.length?s[o]:B.a.gj(s)).b);++p}throw A.a(l.K("Falta poner el texto entre comillas.",'Los textos van entre comillas: Escribir "'+B.a.ai(q," ")+'"'))}return new A.c1(i,j,k.e,k.f)},
cL(){var s=this.l(),r=A.j([],t.I)
do B.a.k(r,this.bJ())
while(this.B(","))
return new A.bS(r,s.e,s.f)},
cG(){var s,r,q,p,o=this,n=o.l(),m=o.H()
o.D("entonces")
s=o.a2("FinSi",new A.dM(o),n)
if(o.G("sino")){r=o.l().e
q=o.a2("FinSi",new A.dN(o),n)}else{q=null
r=null}o.a9()
p=new A.b1(m,s,q,n.e,n.f)
if(r!=null)o.d.b.q(0,p,r)
return p},
cN(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e=f.l(),d=f.H()
f.D("hacer")
s=A.j([],t.r)
r=A.j([],t.Y)
for(q=f.a,p=null,o=null;!0;){f.av()
n=f.b
m=q.length
if(!(n<m))return A.b(q,n)
l=q[n]
if(l.a===B.d)throw A.a(f.b3(e,"FinSegun"))
l=n<m?l:B.a.gj(q)
if(!(l.a===B.b&&l.c==="finsegun")){k=f.b
l=k<q.length?q[k]:B.a.gj(q)
if(l.a===B.b&&l.c==="fin"){k=f.b+1
l=k<q.length?q[k]:B.a.gj(q)
n=l.a===B.b&&l.c==="segun"}else n=!1}else n=!0
if(n)break
k=f.b
l=k<q.length?q[k]:B.a.gj(q)
n=!1
if(l.a===B.b&&l.c==="de"){k=f.b+1
l=k<q.length?q[k]:B.a.gj(q)
if(l.a===B.b&&l.c==="otro"){k=f.b+2
l=k<q.length?q[k]:B.a.gj(q)
n=l.a===B.b&&l.c==="modo"}}if(n){n=f.b
m=q.length
if(!(n<m))return A.b(q,n)
j=q[n]
o=j.e
if(j.a!==B.d){++n
f.b=n}if(!(n<m))return A.b(q,n)
if(q[n].a!==B.d)n=f.b=n+1
if(!(n<m))return A.b(q,n)
if(q[n].a!==B.d)f.b=n+1
f.B(":")
p=f.bE(e)
continue}n=f.b
if(!(n<q.length))return A.b(q,n)
B.a.k(r,q[n].e)
i=f.bR()
if(i==null)throw A.a(f.K("Dentro de 'Segun' cada opci\xf3n empieza con un valor seguido de ':'.",'Por ejemplo:  1: Escribir "uno"'))
B.a.k(s,new A.bY(i,f.bE(e)))}f.a9()
h=new A.b9(d,s,p,e.e,e.f)
for(q=f.d,n=q.c,g=0;g<s.length;++g){m=s[g]
if(!(g<r.length))return A.b(r,g)
n.q(0,m,r[g])}if(o!=null)q.d.q(0,h,o)
return h},
bR(){var s,r,q=this,p=q.b,o=q.c,n=o.length
try{if((q.G("caso")||q.G("opcion"))&&!q.S("<-",1))q.l()
s=A.j([q.H()],t.I)
for(;q.B(",");)J.hU(s,q.H())
if(q.B(":"))return s}catch(r){if(!(A.aE(r) instanceof A.ah))throw r}q.b=p
B.a.sm(o,n)
return null},
bE(a){var s,r,q,p,o,n,m,l,k=this,j=A.j([],t.b)
for(s=k.c,r=k.a;!0;){k.av()
q=k.b
p=r.length
if(!(q<p))return A.b(r,q)
o=r[q]
if(o.a===B.d)throw A.a(k.b3(a,"FinSegun"))
o=q<p?o:B.a.gj(r)
if(!(o.a===B.b&&o.c==="finsegun")){n=k.b
o=n<r.length?r[n]:B.a.gj(r)
if(o.a===B.b&&o.c==="fin"){n=k.b+1
o=n<r.length?r[n]:B.a.gj(r)
q=o.a===B.b&&o.c==="segun"}else q=!1}else q=!0
if(!q){n=k.b
q=!1
o=n<r.length?r[n]:B.a.gj(r)
if(o.a===B.b&&o.c==="de"){n=k.b+1
o=n<r.length?r[n]:B.a.gj(r)
if(o.a===B.b&&o.c==="otro"){n=k.b+2
o=n<r.length?r[n]:B.a.gj(r)
q=o.a===B.b&&o.c==="modo"}}}else q=!0
if(q)return j
m=k.b
l=s.length
q=k.bR()
k.b=m
B.a.sm(s,l)
if(q!=null)return j
if(k.bA()){s=a.b
throw A.a(k.K("Encontr\xe9 "+k.ga0().T()+", pero antes falta 'FinSegun' para cerrar el '"+s+"' de la l\xednea "+a.e+".","Cierra primero el '"+s+"' con 'FinSegun'. Despu\xe9s va "+k.ga0().T()+"."))}B.a.k(j,k.bI())}},
cP(){var s,r=this,q=r.l(),p=r.H()
r.D("hacer")
s=r.a2("FinMientras",new A.dQ(r),q)
r.a9()
return new A.c0(p,s,q.e,q.f)},
cM(){var s=this,r=s.l(),q=s.a2("Hasta Que",new A.dP(s),r),p=s.G("hasta")
s.l()
s.l()
return new A.bU(q,s.H(),p,r.e,r.f)},
cD(){var s,r,q,p,o,n=this,m=n.l(),l=n.W("para la variable del ciclo")
if(!n.bn()){s=l.b
throw A.a(n.K("Se esperaba '<-' despu\xe9s de '"+s+"'.","Por ejemplo: Para "+s+" <- 1 Hasta 10 Hacer"))}r=n.H()
n.b1("hasta","Hasta","en el ciclo Para")
q=n.H()
if(n.D("con")){n.b1("paso","Paso","despu\xe9s de 'Con'")
p=n.H()}else p=null
n.D("hacer")
o=n.a2("FinPara",new A.dK(n),m)
n.a9()
return new A.bz(l.b,r,q,p,o,m.e,m.f)},
cE(){var s,r,q,p=this,o=p.l()
p.l()
s=p.W("para la variable del ciclo")
p.b1("de","De","en el ciclo Para Cada")
r=p.W("de arreglo")
p.D("hacer")
q=p.a2("FinPara",new A.dJ(p),o)
p.a9()
return new A.by(s.b,r.b,q,o.e,o.f)},
cO(){var s,r,q=this,p=q.l()
if(q.D("tecla"))return new A.ba(null,!1,p.e,p.f)
s=q.H()
r=q.D("milisegundo")||q.D("milisegundos")
if(!r)if(!(q.D("segundo")||q.D("segundos")))throw A.a(q.P("Se esperaba 'Segundos' o 'Milisegundos', por ejemplo: Esperar 2 Segundos."))
return new A.ba(s,r,p.e,p.f)},
bF(){var s=this.l()
this.D("pantalla")
return new A.ct(s.e,s.f)},
H(){var s,r,q,p,o,n,m=this,l=m.aG()
for(s=m.a;!0;){r=m.b
q=s.length
if(!(r<q))return A.b(s,r)
p=s[r]
o=r<q?p:B.a.gj(s)
r=!0
if(!(o.a===B.b&&o.c==="o")){n=m.b
o=n<s.length?s[n]:B.a.gj(s)
if(!(o.a===B.b&&o.c==="or")){n=m.b
o=n<s.length?s[n]:B.a.gj(s)
if(!(o.a===B.f&&o.b==="|")){n=m.b
o=n<s.length?s[n]:B.a.gj(s)
r=o.a===B.f&&o.b==="||"}}}if(r){r=m.b
if(!(r<s.length))return A.b(s,r)
if(s[r].a!==B.d)m.b=r+1
l=new A.P("o",l,m.aG(),p.e,p.f)}else{n=m.b
o=n<s.length?s[n]:B.a.gj(s)
if(!(o.a===B.b&&o.c==="xor")){n=m.b
o=n<s.length?s[n]:B.a.gj(s)
r=o.a===B.b&&o.c==="xnor"}else r=!0
if(r){r=m.b
if(!(r<s.length))return A.b(s,r)
if(s[r].a!==B.d)m.b=r+1
r=p.c==="xor"?"<>":"="
l=new A.P(r,l,m.aG(),p.e,p.f)}else{n=m.b
o=n<s.length?s[n]:B.a.gj(s)
if(o.a===B.b&&o.c==="nor"){r=m.b
if(!(r<s.length))return A.b(s,r)
if(s[r].a!==B.d)m.b=r+1
r=p.e
q=p.f
l=new A.ap("no",new A.P("o",l,m.aG(),r,q),r,q)}else return l}}}},
aG(){var s,r,q,p,o,n,m=this,l=m.aH()
for(s=m.a;!0;){r=m.b
q=s.length
if(!(r<q))return A.b(s,r)
p=s[r]
o=r<q?p:B.a.gj(s)
r=!0
if(!(o.a===B.b&&o.c==="y")){n=m.b
o=n<s.length?s[n]:B.a.gj(s)
if(!(o.a===B.b&&o.c==="and")){n=m.b
o=n<s.length?s[n]:B.a.gj(s)
if(!(o.a===B.f&&o.b==="&")){n=m.b
o=n<s.length?s[n]:B.a.gj(s)
r=o.a===B.f&&o.b==="&&"}}}if(r){r=m.b
if(!(r<s.length))return A.b(s,r)
if(s[r].a!==B.d)m.b=r+1
l=new A.P("y",l,m.aH(),p.e,p.f)}else{n=m.b
o=n<s.length?s[n]:B.a.gj(s)
if(o.a===B.b&&o.c==="nand"){r=m.b
if(!(r<s.length))return A.b(s,r)
if(s[r].a!==B.d)m.b=r+1
r=p.e
q=p.f
l=new A.ap("no",new A.P("y",l,m.aH(),r,q),r,q)}else return l}}},
aH(){var s,r=this
if(r.G("no")||r.G("not")||r.Y("~")||r.Y("!")){s=r.l()
return new A.ap("no",r.aH(),s.e,s.f)}return r.cA()},
cA(){var s,r,q=this,p=q.bC(),o=q.a,n=q.b
if(!(n<o.length))return A.b(o,n)
s=o[n]
r=s.a===B.f?B.a0.C(0,s.b):null
if(r==null)return p
q.l()
return new A.P(r,p,q.bC(),s.e,s.f)},
bC(){var s,r,q,p=this,o=p.bG(),n=p.a
while(!0){s=p.b
r=s<n.length?n[s]:B.a.gj(n)
if(!(r.a===B.f&&r.b==="+")){s=p.b
r=s<n.length?n[s]:B.a.gj(n)
q=r.a===B.f&&r.b==="-"}else q=!0
if(!q)break
q=p.b
if(!(q<n.length))return A.b(n,q)
r=n[q]
if(r.a!==B.d)p.b=q+1
o=new A.P(r.b,o,p.bG(),r.e,r.f)}return o},
bG(){var s,r,q,p,o,n,m,l=this,k=l.aq()
for(s=l.a;!0;){r=l.b
q=s.length
if(!(r<q))return A.b(s,r)
p=s[r]
o=r<q?p:B.a.gj(s)
if(!(o.a===B.f&&o.b==="*")){n=l.b
o=n<s.length?s[n]:B.a.gj(s)
r=o.a===B.f&&o.b==="/"}else r=!0
if(r)m=p.b
else{n=l.b
o=n<s.length?s[n]:B.a.gj(s)
if(!(o.a===B.f&&o.b==="%")){n=l.b
o=n<s.length?s[n]:B.a.gj(s)
r=o.a===B.b&&o.c==="mod"}else r=!0
if(!r)return k
m="mod"}r=l.b
if(!(r<s.length))return A.b(s,r)
if(s[r].a!==B.d)l.b=r+1
k=new A.P(m,k,l.aq(),p.e,p.f)}},
aq(){var s,r=this
if(r.Y("-")){s=r.l()
return new A.ap("-",r.aq(),s.e,s.f)}if(r.B("+"))return r.aq()
return r.cJ()},
cJ(){var s,r=this,q=r.cK()
if(r.Y("^")){s=r.l()
return new A.P("^",q,r.aq(),s.e,s.f)}return q},
cK(){var s,r,q,p,o,n=this,m=n.a,l=n.b
if(!(l<m.length))return A.b(m,l)
s=m[l]
r=s.a
if(B.D===r){n.l()
m=s.d
m.toString
return new A.ak(A.hg(m),s.e,s.f)}if(B.t===r){n.l()
m=s.d
m.toString
return new A.bX(A.af(m),s.e,s.f)}if(B.f===r&&s.b==="("){n.l()
q=n.H()
n.ad(")","para cerrar el par\xe9ntesis")
return q}if(B.b===r){m=s.c
l=m==="verdadero"
if(l||m==="falso"){n.l()
return new A.bp(l,s.e,s.f)}if(B.m.V(0,m)){l=s.b
m=m==="entonces"||m==="hacer"?"Parece que falta la condici\xf3n antes de '"+l+"'.":null
throw A.a(n.K("Se esperaba un valor, pero encontr\xe9 la palabra '"+l+"'.",m))}if(n.b2(1)){n.l()
return new A.a_(s.b,n.bH(),s.e,s.f)}n.l()
if(n.B("(")){p=n.bD(s)
o=n.cm(p)
if(o!=null)return o
B.a.k(n.c,new A.ay(p,!1))
return p}if(n.Y("["))return new A.a_(s.b,n.b6(),s.e,s.f)
return new A.a1(s.b,s.e,s.f)}if(B.k===r||B.d===r)throw A.a(n.P("Falta un valor: la instrucci\xf3n termina antes de tiempo."))
throw A.a(n.P("Se esperaba un valor, pero encontr\xe9 "+s.T()+"."))},
bD(a){var s,r=this,q=A.j([],t.I)
if(!r.Y(")"))do B.a.k(q,r.H())
while(r.B(","))
s=a.b
r.ad(")","para cerrar la llamada a "+s)
return new A.ac(s,q,a.e,a.f)},
cm(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=null,e="Exp",d={},c=a.f
d.a=d.b=null
d.b=a.a
d.a=a.b
s=new A.dH(d)
r=new A.dG(d)
q=new A.dI(d)
p=a.e
o=B.a2.C(0,A.I(p))
if(o!=null)return c.length===1?s.$2(o,c):f
n=A.I(p)
m=c.length
l="log"===n
if(l){k=1===m
p=k
j=m}else{j=f
k=j
p=!1}if(p)return r.$3("/",s.$2("Ln",c),s.$2("Ln",A.j([new A.ak(10,d.b,d.a)],t.I)))
if("sinh"===n)if(l){p=k
i=l}else{k=1===m
p=k
j=m
l=!0
i=!0}else{i=l
p=!1}if(p){p=s.$2(e,c)
if(0>=c.length)return A.b(c,0)
return r.$3("/",r.$3("-",p,s.$2(e,A.j([q.$1(c[0])],t.I))),new A.ak(2,d.b,d.a))}if("cosh"===n)if(l)p=k
else{if(i)p=j
else{p=m
j=p
i=!0}k=1===p
p=k
l=!0}else p=!1
if(p){p=s.$2(e,c)
if(0>=c.length)return A.b(c,0)
return r.$3("/",r.$3("+",p,s.$2(e,A.j([q.$1(c[0])],t.I))),new A.ak(2,d.b,d.a))}if("tanh"===n)if(l)p=k
else{if(i)p=j
else{p=m
j=p
i=!0}k=1===p
p=k}else p=!1
if(p){d=s.$2(e,c)
if(0>=c.length)return A.b(c,0)
p=t.I
d=r.$3("-",d,s.$2(e,A.j([q.$1(c[0])],p)))
h=s.$2(e,c)
if(0>=c.length)return A.b(c,0)
return r.$3("/",d,r.$3("+",h,s.$2(e,A.j([q.$1(c[0])],p))))}if("substring"===n)q=3===(i?j:m)
else q=!1
if(q){if(1>=m)return A.b(c,1)
q=c[1]
if(2>=m)return A.b(c,2)
g=r.$3("-",r.$3("+",q,c[2]),new A.ak(1,d.b,d.a))
d=c.length
if(0>=d)return A.b(c,0)
q=c[0]
if(1>=d)return A.b(c,1)
return s.$2("Subcadena",A.j([q,c[1],g],t.I))}return f},
d_(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=", pero se le dieron "
t.bV.a(a)
for(s=this.c,r=s.length,q=0;q<s.length;s.length===r||(0,A.W)(s),++q){p={}
o=s[q]
p.a=null
n=p.a=o.a
m=o.b
o=n.e
l=A.I(o)
k=a.C(0,l)
j=$.fE().C(0,l)
i=new A.dS(p)
if(k!=null){o=n.f.length
h=k.b.length
if(o!==h)throw A.a(i.$1("'"+k.a+"' recibe "+this.bu(h)+f+p.a.f.length+"."))
if(!m&&k.c==null){s=k.a
throw A.a(i.$2$hint("'"+s+"' no devuelve ning\xfan valor, as\xed que no puede usarse dentro de una expresi\xf3n.","Para que devuelva un valor def\xednela como 'Funcion resultado <- "+s+"(...)'."))}}else if(j!=null){o=n.f.length
h=j.b
if(o!==h)throw A.a(i.$1("'"+j.a+"' recibe "+this.bu(h)+f+p.a.f.length+"."))}else{s=A.L(a).h("aM<2>")
r=t.N
s=A.io(A.fT(new A.aM(a,s),s.h("f(d.E)").a(new A.dR()),s.h("d.E"),r),r)
B.a.aw(s,A.jR())
if(m)B.a.aw(s,B.z)
g=A.eT(o,s)
s=p.a.e
s=m?"No entiendo la instrucci\xf3n '"+s+"'.":"No existe ninguna funci\xf3n llamada '"+s+"'."
throw A.a(i.$2$hint(s,g!=null?"\xbfQuisiste decir '"+g+"'?":null))}}},
bu(a){return a===1?"1 valor":""+a+" valores"}}
A.dO.prototype={
$0(){var s=this.a
return s.X("algoritmo")||s.X("proceso")},
$S:2}
A.dL.prototype={
$0(){var s=this.a
return s.X("funcion")||s.X("subproceso")||s.X("subalgoritmo")},
$S:2}
A.dM.prototype={
$0(){var s=this.a
return s.G("sino")||s.X("si")},
$S:2}
A.dN.prototype={
$0(){return this.a.X("si")},
$S:2}
A.dQ.prototype={
$0(){return this.a.X("mientras")},
$S:2}
A.dP.prototype={
$0(){var s=this.a
return(s.G("hasta")||s.G("mientras"))&&s.U("que",1)},
$S:2}
A.dK.prototype={
$0(){return this.a.X("para")},
$S:2}
A.dJ.prototype={
$0(){return this.a.X("para")},
$S:2}
A.dH.prototype={
$2(a,b){var s=this.a
return new A.ac(a,t.cQ.a(b),s.b,s.a)},
$S:26}
A.dG.prototype={
$3(a,b,c){var s=this.a
return new A.P(a,b,c,s.b,s.a)},
$S:27}
A.dI.prototype={
$1(a){var s=this.a
return new A.ap("-",a,s.b,s.a)},
$S:28}
A.dS.prototype={
$2$hint(a,b){var s=this.a.a
return A.aJ(a,s.b,b,s.a)},
$1(a){return this.$2$hint(a,null)},
$S:29}
A.dR.prototype={
$1(a){return t.f.a(a).a},
$S:30}
A.ax.prototype={
aD(){return"TokenType."+this.b}}
A.a9.prototype={
T(){var s,r=this.a
$label0$0:{if(B.k===r){s="el fin de la l\xednea"
break $label0$0}if(B.d===r){s="el fin del archivo"
break $label0$0}if(B.t===r){s='el texto "'+A.m(this.d)+'"'
break $label0$0}s="'"+this.b+"'"
break $label0$0}return s}}
A.M.prototype={}
A.dj.prototype={
$2(a,b){return A.ae(a)*A.ae(b)},
$S:9}
A.eO.prototype={
$1(a){return a==null?"\xb7":A.hw(a)},
$S:31}
A.f5.prototype={
$2(a,b){var s=t.N
return A.i7(A.eZ(A.af(a),A.af(b)).dh(new A.f4(),s),s)},
$S:32}
A.f4.prototype={
$1(a){return A.af(a)},
$S:33};(function aliases(){var s=J.au.prototype
s.c5=s.i})();(function installTearOffs(){var s=hunkHelpers._static_1,r=hunkHelpers._static_0
s(A,"jO","iI",5)
s(A,"jP","iJ",5)
s(A,"jQ","iK",5)
r(A,"hu","jH",0)
s(A,"jV","jc",11)
s(A,"hv","jG",7)
s(A,"jS","jK",7)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.i,null)
q(A.i,[A.fc,J.cE,A.bV,J.bn,A.p,A.dW,A.d,A.aN,A.bM,A.N,A.aW,A.bq,A.aT,A.av,A.dY,A.dE,A.bx,A.cb,A.as,A.b3,A.dC,A.aK,A.aL,A.bH,A.cI,A.c5,A.e0,A.a8,A.da,A.eq,A.eo,A.d7,A.cc,A.a6,A.aR,A.F,A.d8,A.de,A.ci,A.dc,A.c3,A.u,A.c4,A.cw,A.cy,A.ek,A.bu,A.e5,A.cV,A.bW,A.e6,A.dk,A.a7,A.H,A.df,A.d0,A.aP,A.db,A.q,A.bY,A.cW,A.am,A.dU,A.dX,A.aF,A.Q,A.cA,A.cz,A.ah,A.d_,A.cs,A.dV,A.a2,A.dr,A.dB,A.dF,A.a9,A.M])
q(J.cE,[J.cG,J.bB,J.v,J.bD,J.bE,J.bC,J.b2])
q(J.v,[J.au,J.n,A.b4,A.bP])
q(J.au,[J.cX,J.bZ,J.a0])
r(J.cF,A.bV)
r(J.dy,J.n)
q(J.bC,[J.bA,J.cH])
q(A.p,[A.cL,A.an,A.cJ,A.d6,A.d1,A.d9,A.bF,A.cq,A.ab,A.c_,A.d5,A.b8,A.cx])
q(A.d,[A.h,A.aO,A.c2,A.bc])
q(A.h,[A.O,A.bI,A.aM,A.bG])
q(A.O,[A.aQ,A.aj,A.bK])
r(A.bv,A.aO)
r(A.bb,A.aW)
r(A.ay,A.bb)
r(A.Z,A.bq)
q(A.av,[A.br,A.ca])
r(A.aG,A.br)
r(A.bR,A.an)
q(A.as,[A.cu,A.cv,A.d4,A.f0,A.f2,A.e2,A.e1,A.eM,A.eg,A.dl,A.eR,A.et,A.eu,A.ev,A.eE,A.eF,A.eG,A.eH,A.eI,A.eJ,A.eK,A.eL,A.ew,A.ex,A.ey,A.ez,A.eA,A.eB,A.eC,A.eD,A.eX,A.dw,A.dG,A.dI,A.dS,A.dR,A.eO,A.f4])
q(A.d4,[A.d3,A.b_])
r(A.ai,A.b3)
r(A.T,A.ai)
q(A.cv,[A.f1,A.eN,A.eQ,A.eh,A.dD,A.el,A.dn,A.dm,A.eW,A.du,A.dH,A.dj,A.f5])
q(A.bP,[A.cM,A.b5])
q(A.b5,[A.c6,A.c8])
r(A.c7,A.c6)
r(A.bN,A.c7)
r(A.c9,A.c8)
r(A.bO,A.c9)
q(A.bN,[A.cN,A.cO])
q(A.bO,[A.cP,A.cQ,A.cR,A.cS,A.cT,A.bQ,A.cU])
r(A.cd,A.d9)
q(A.cu,[A.e3,A.e4,A.ep,A.dp,A.e7,A.ec,A.eb,A.e9,A.e8,A.ef,A.ee,A.ed,A.eP,A.en,A.dv,A.ds,A.dt,A.dO,A.dL,A.dM,A.dN,A.dQ,A.dP,A.dK,A.dJ])
r(A.dd,A.ci)
r(A.aU,A.ca)
r(A.cK,A.bF)
r(A.dz,A.cw)
r(A.dA,A.cy)
r(A.ej,A.ek)
q(A.ab,[A.b6,A.cD])
q(A.e5,[A.aI,A.cB,A.bw,A.ax])
q(A.q,[A.r,A.w,A.bm])
q(A.r,[A.ak,A.bX,A.bp,A.a1,A.a_,A.ap,A.P,A.ac])
q(A.w,[A.bs,A.bt,A.bo,A.c1,A.bS,A.b1,A.b9,A.c0,A.bU,A.bz,A.by,A.b0,A.ba,A.ct])
s(A.c6,A.u)
s(A.c7,A.N)
s(A.c8,A.u)
s(A.c9,A.N)})()
var v={G:typeof self!="undefined"?self:globalThis,typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{c:"int",k:"double",ar:"num",f:"String",aB:"bool",H:"Null",l:"List",i:"Object",U:"Map",t:"JSObject"},mangledNames:{},types:["~()","k(Q)","aB()","c(Q)","f(Q)","~(~())","H(@)","i(Q)","H()","c(c,c)","~(i?,i?)","@(@)","ar(Q)","a2()","t(i,ad)","f(aF)","H(a0,a0)","H(i,ad)","~(c,@)","H(@,ad)","~(U<f,i?>)","H(w,c)","~(@)","H(~())","f(a2)","@(f)","ac(f,l<r>)","r(f,r,r)","r(r)","ah(f{hint:f?})","f(am)","f(i?)","t(f,f)","f(f)","@(@,f)","i?(i?)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{"2;":(a,b)=>c=>c instanceof A.ay&&a.b(c.a)&&b.b(c.b)}}
A.j_(v.typeUniverse,JSON.parse('{"a0":"au","cX":"au","bZ":"au","km":"b4","cG":{"aB":[],"o":[]},"bB":{"o":[]},"v":{"t":[]},"au":{"v":[],"t":[]},"n":{"l":["1"],"v":[],"h":["1"],"t":[],"d":["1"]},"cF":{"bV":[]},"dy":{"n":["1"],"l":["1"],"v":[],"h":["1"],"t":[],"d":["1"]},"bn":{"x":["1"]},"bC":{"k":[],"ar":[]},"bA":{"k":[],"c":[],"ar":[],"o":[]},"cH":{"k":[],"ar":[],"o":[]},"b2":{"f":[],"dT":[],"o":[]},"cL":{"p":[]},"h":{"d":["1"]},"O":{"h":["1"],"d":["1"]},"aQ":{"O":["1"],"h":["1"],"d":["1"],"O.E":"1","d.E":"1"},"aN":{"x":["1"]},"aO":{"d":["2"],"d.E":"2"},"bv":{"aO":["1","2"],"h":["2"],"d":["2"],"d.E":"2"},"bM":{"x":["2"]},"aj":{"O":["2"],"h":["2"],"d":["2"],"O.E":"2","d.E":"2"},"ay":{"bb":[],"aW":[]},"bq":{"U":["1","2"]},"Z":{"bq":["1","2"],"U":["1","2"]},"c2":{"d":["1"],"d.E":"1"},"aT":{"x":["1"]},"br":{"av":["1"],"d2":["1"],"h":["1"],"d":["1"]},"aG":{"br":["1"],"av":["1"],"d2":["1"],"h":["1"],"d":["1"]},"bR":{"an":[],"p":[]},"cJ":{"p":[]},"d6":{"p":[]},"cb":{"ad":[]},"as":{"aH":[]},"cu":{"aH":[]},"cv":{"aH":[]},"d4":{"aH":[]},"d3":{"aH":[]},"b_":{"aH":[]},"d1":{"p":[]},"ai":{"b3":["1","2"],"fe":["1","2"],"U":["1","2"]},"bI":{"h":["1"],"d":["1"],"d.E":"1"},"aK":{"x":["1"]},"aM":{"h":["1"],"d":["1"],"d.E":"1"},"aL":{"x":["1"]},"bG":{"h":["a7<1,2>"],"d":["a7<1,2>"],"d.E":"a7<1,2>"},"bH":{"x":["a7<1,2>"]},"T":{"ai":["1","2"],"b3":["1","2"],"fe":["1","2"],"U":["1","2"]},"bb":{"aW":[]},"cI":{"ix":[],"dT":[]},"c5":{"fh":[]},"e0":{"x":["fh"]},"b4":{"v":[],"t":[],"o":[]},"bP":{"v":[],"t":[]},"cM":{"v":[],"t":[],"o":[]},"b5":{"S":["1"],"v":[],"t":[]},"bN":{"u":["k"],"l":["k"],"S":["k"],"v":[],"h":["k"],"t":[],"d":["k"],"N":["k"]},"bO":{"u":["c"],"l":["c"],"S":["c"],"v":[],"h":["c"],"t":[],"d":["c"],"N":["c"]},"cN":{"u":["k"],"l":["k"],"S":["k"],"v":[],"h":["k"],"t":[],"d":["k"],"N":["k"],"o":[],"u.E":"k"},"cO":{"u":["k"],"l":["k"],"S":["k"],"v":[],"h":["k"],"t":[],"d":["k"],"N":["k"],"o":[],"u.E":"k"},"cP":{"u":["c"],"l":["c"],"S":["c"],"v":[],"h":["c"],"t":[],"d":["c"],"N":["c"],"o":[],"u.E":"c"},"cQ":{"u":["c"],"l":["c"],"S":["c"],"v":[],"h":["c"],"t":[],"d":["c"],"N":["c"],"o":[],"u.E":"c"},"cR":{"u":["c"],"l":["c"],"S":["c"],"v":[],"h":["c"],"t":[],"d":["c"],"N":["c"],"o":[],"u.E":"c"},"cS":{"u":["c"],"l":["c"],"S":["c"],"v":[],"h":["c"],"t":[],"d":["c"],"N":["c"],"o":[],"u.E":"c"},"cT":{"u":["c"],"l":["c"],"S":["c"],"v":[],"h":["c"],"t":[],"d":["c"],"N":["c"],"o":[],"u.E":"c"},"bQ":{"u":["c"],"l":["c"],"S":["c"],"v":[],"h":["c"],"t":[],"d":["c"],"N":["c"],"o":[],"u.E":"c"},"cU":{"u":["c"],"l":["c"],"S":["c"],"v":[],"h":["c"],"t":[],"d":["c"],"N":["c"],"o":[],"u.E":"c"},"d9":{"p":[]},"cd":{"an":[],"p":[]},"cc":{"x":["1"]},"bc":{"d":["1"],"d.E":"1"},"a6":{"p":[]},"F":{"at":["1"]},"ci":{"h0":[]},"dd":{"ci":[],"h0":[]},"aU":{"av":["1"],"fS":["1"],"d2":["1"],"h":["1"],"d":["1"]},"c3":{"x":["1"]},"b3":{"U":["1","2"]},"bK":{"iu":["1"],"O":["1"],"h":["1"],"d":["1"],"O.E":"1","d.E":"1"},"c4":{"x":["1"]},"av":{"d2":["1"],"h":["1"],"d":["1"]},"ca":{"av":["1"],"d2":["1"],"h":["1"],"d":["1"]},"bF":{"p":[]},"cK":{"p":[]},"k":{"ar":[]},"c":{"ar":[]},"l":{"h":["1"],"d":["1"]},"f":{"dT":[]},"cq":{"p":[]},"an":{"p":[]},"ab":{"p":[]},"b6":{"p":[]},"cD":{"p":[]},"c_":{"p":[]},"d5":{"p":[]},"b8":{"p":[]},"cx":{"p":[]},"cV":{"p":[]},"bW":{"p":[]},"df":{"ad":[]},"d0":{"x":["c"]},"aP":{"iB":[]},"db":{"iv":[]},"r":{"q":[]},"ac":{"r":[],"q":[]},"w":{"q":[]},"bm":{"q":[]},"b1":{"w":[],"q":[]},"b9":{"w":[],"q":[]},"ak":{"r":[],"q":[]},"bX":{"r":[],"q":[]},"bp":{"r":[],"q":[]},"a1":{"r":[],"q":[]},"a_":{"r":[],"q":[]},"ap":{"r":[],"q":[]},"P":{"r":[],"q":[]},"bs":{"w":[],"q":[]},"bt":{"w":[],"q":[]},"bo":{"w":[],"q":[]},"c1":{"w":[],"q":[]},"bS":{"w":[],"q":[]},"c0":{"w":[],"q":[]},"bU":{"w":[],"q":[]},"bz":{"w":[],"q":[]},"by":{"w":[],"q":[]},"b0":{"w":[],"q":[]},"ba":{"w":[],"q":[]},"ct":{"w":[],"q":[]},"cs":{"ii":[]},"ia":{"l":["c"],"h":["c"],"d":["c"]},"iG":{"l":["c"],"h":["c"],"d":["c"]},"iF":{"l":["c"],"h":["c"],"d":["c"]},"i8":{"l":["c"],"h":["c"],"d":["c"]},"iD":{"l":["c"],"h":["c"],"d":["c"]},"i9":{"l":["c"],"h":["c"],"d":["c"]},"iE":{"l":["c"],"h":["c"],"d":["c"]},"i5":{"l":["k"],"h":["k"],"d":["k"]},"i6":{"l":["k"],"h":["k"],"d":["k"]}}'))
A.iZ(v.typeUniverse,JSON.parse('{"h":1,"b5":1,"ca":1,"cw":2,"cy":2}'))
var u={c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type",d:"Usa ConvertirATexto() para convertir un n\xfamero en texto."}
var t=(function rtii(){var s=A.bg
return{n:s("a6"),t:s("aF"),V:s("Q"),w:s("Z<f,f>"),O:s("aG<f>"),W:s("cz"),U:s("h<@>"),R:s("p"),Z:s("aH"),a:s("d<@>"),h:s("n<bm>"),k:s("n<cA>"),I:s("n<r>"),J:s("n<U<f,i>>"),D:s("n<U<f,a2>>"),c:s("n<cW>"),d:s("n<+(ac,aB)>"),b:s("n<w>"),s:s("n<f>"),r:s("n<bY>"),x:s("n<a9>"),p:s("n<@>"),Y:s("n<c>"),A:s("n<~()>"),T:s("bB"),m:s("t"),g:s("a0"),G:s("S<@>"),e:s("v"),cu:s("T<b1,c>"),E:s("T<w,c>"),aS:s("T<am,c>"),cP:s("T<bY,c>"),B:s("T<b9,c>"),ai:s("bK<f>"),cQ:s("l<r>"),ck:s("l<w>"),j:s("l<@>"),bV:s("U<f,am>"),bC:s("U<@,@>"),aE:s("U<f,i?>"),P:s("H"),K:s("i"),cY:s("kn"),cD:s("+()"),d7:s("+(M,c)"),a0:s("fh"),l:s("ad"),N:s("f"),f:s("am"),bW:s("o"),b7:s("an"),cr:s("bZ"),q:s("a1"),Q:s("a2"),_:s("F<@>"),y:s("aB"),cN:s("aB()"),bG:s("aB(i)"),i:s("k"),z:s("@"),bd:s("@()"),v:s("@(i)"),C:s("@(i,ad)"),S:s("c"),bc:s("at<H>?"),aQ:s("t?"),X:s("i?"),u:s("f?"),F:s("aR<@,@>?"),L:s("dc?"),cG:s("aB?"),dd:s("k?"),a3:s("c?"),ae:s("ar?"),o:s("ar"),H:s("~"),M:s("~()")}})();(function constants(){var s=hunkHelpers.makeConstList
B.R=J.cE.prototype
B.a=J.n.prototype
B.e=J.bA.prototype
B.h=J.bC.prototype
B.c=J.b2.prototype
B.S=J.a0.prototype
B.T=J.v.prototype
B.B=J.cX.prototype
B.u=J.bZ.prototype
B.v=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.E=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof HTMLElement == "function";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.J=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var userAgent = navigator.userAgent;
    if (typeof userAgent != "string") return hooks;
    if (userAgent.indexOf("DumpRenderTree") >= 0) return hooks;
    if (userAgent.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.F=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.I=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.H=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.G=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.w=function(hooks) { return hooks; }

B.K=new A.dz()
B.L=new A.cV()
B.M=new A.d_()
B.n=new A.dW()
B.N=new A.db()
B.i=new A.dd()
B.O=new A.df()
B.o=new A.bu(0)
B.x=new A.bw("other")
B.P=new A.bw("stepLimit")
B.Q=new A.bw("noMoreInput")
B.p=new A.cB("syntax")
B.y=new A.cB("runtime")
B.q=new A.aI("Entero","entero")
B.l=new A.aI("Real","real")
B.j=new A.aI("Texto","texto")
B.r=new A.aI("L\xf3gico","logico")
B.U=new A.dA(null)
B.V=s([],t.I)
B.W=s([],t.c)
B.ar=s([],t.s)
B.z=s(["Definir","Dimension","Escribir","Leer","Si","Sino","Segun","Mientras","Repetir","Para","Esperar","FinSi","FinMientras","FinPara","FinSegun","FinAlgoritmo","FinFuncion","FinSubProceso"],t.s)
B.X=s(["Entero","Real","Numero","Logico","Caracter","Texto","Cadena"],t.s)
B.Y=s(["<-","<=",">=","<>","==","!=",":=","&&","||","+","-","*","/","^","%","(",")","[","]",",",";",":","=","<",">","&","|","~","!"],t.s)
B.aa={entero:0,real:1,numero:2,numerico:3,logico:4,caracter:5,texto:6,cadena:7}
B.Z=new A.Z(B.aa,[B.q,B.l,B.l,B.l,B.r,B.j,B.j,B.j],A.bg("Z<f,aI>"))
B.a8={"\xe1":0,"\xe9":1,"\xed":2,"\xf3":3,"\xfa":4,"\xfc":5}
B.a_=new A.Z(B.a8,["a","e","i","o","u","u"],t.w)
B.a4={"=":0,"==":1,"<>":2,"!=":3,"<":4,">":5,"<=":6,">=":7}
B.a0=new A.Z(B.a4,["=","=","<>","<>","<",">","<=",">="],t.w)
B.a9={"\u2190":0,"\u2260":1,"\u2264":2,"\u2265":3}
B.a1=new A.Z(B.a9,["<-","<>","<=",">="],t.w)
B.a7={}
B.A=new A.Z(B.a7,[],A.bg("Z<f,i?>"))
B.ab={sqrt:0,abs:1,len:2,round:3,trunc:4,ln:5,exp:6,sin:7,cos:8,tan:9,asin:10,acos:11,atan:12,random:13}
B.a2=new A.Z(B.ab,["Raiz","Abs","Longitud","Redon","Trunc","Ln","Exp","Sen","Cos","Tan","ASen","ACos","ATan","Azar"],t.w)
B.ac=new A.dV(1e5)
B.a5={'"':0,"\u201c":1,"\u201d":2}
B.C=new A.aG(B.a5,3,t.O)
B.a6={finalgoritmo:0,finproceso:1,finfuncion:2,finsubproceso:3,finsubalgoritmo:4,finsi:5,sino:6,finsegun:7,finmientras:8,finpara:9,fin:10,algoritmo:11,proceso:12,funcion:13,subproceso:14,subalgoritmo:15}
B.ad=new A.aG(B.a6,16,t.O)
B.a3={algoritmo:0,finalgoritmo:1,proceso:2,finproceso:3,funcion:4,finfuncion:5,subproceso:6,finsubproceso:7,subalgoritmo:8,finsubalgoritmo:9,definir:10,como:11,dimension:12,dimensionar:13,escribir:14,imprimir:15,mostrar:16,leer:17,si:18,entonces:19,sino:20,finsi:21,segun:22,hacer:23,finsegun:24,mientras:25,finmientras:26,repetir:27,hasta:28,que:29,para:30,con:31,paso:32,finpara:33,cada:34,esperar:35,fin:36,y:37,o:38,no:39,mod:40,verdadero:41,falso:42}
B.m=new A.aG(B.a3,43,t.O)
B.b=new A.ax("word")
B.D=new A.ax("number")
B.t=new A.ax("string")
B.f=new A.ax("symbol")
B.k=new A.ax("newline")
B.d=new A.ax("eof")
B.ae=A.a5("kj")
B.af=A.a5("kk")
B.ag=A.a5("i5")
B.ah=A.a5("i6")
B.ai=A.a5("i8")
B.aj=A.a5("i9")
B.ak=A.a5("ia")
B.al=A.a5("t")
B.am=A.a5("i")
B.an=A.a5("iD")
B.ao=A.a5("iE")
B.ap=A.a5("iF")
B.aq=A.a5("iG")})();(function staticFields(){$.ei=null
$.X=A.j([],A.bg("n<i>"))
$.fU=null
$.fJ=null
$.fI=null
$.hA=null
$.ht=null
$.hD=null
$.eY=null
$.f3=null
$.fw=null
$.em=A.j([],A.bg("n<l<i>?>"))
$.bd=null
$.ck=null
$.cl=null
$.fq=!1
$.y=B.i})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal
s($,"kl","fA",()=>A.k0("_$dart_dartClosure"))
s($,"kH","hT",()=>A.j([new J.cF()],A.bg("n<bV>")))
s($,"kp","hG",()=>A.ao(A.dZ({
toString:function(){return"$receiver$"}})))
s($,"kq","hH",()=>A.ao(A.dZ({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"kr","hI",()=>A.ao(A.dZ(null)))
s($,"ks","hJ",()=>A.ao(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kv","hM",()=>A.ao(A.dZ(void 0)))
s($,"kw","hN",()=>A.ao(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"ku","hL",()=>A.ao(A.fZ(null)))
s($,"kt","hK",()=>A.ao(function(){try{null.$method$}catch(r){return r.message}}()))
s($,"ky","hP",()=>A.ao(A.fZ(void 0)))
s($,"kx","hO",()=>A.ao(function(){try{(void 0).$method$}catch(r){return r.message}}()))
s($,"kz","fB",()=>A.iH())
s($,"kD","f8",()=>A.fz(B.am))
s($,"kE","hR",()=>Symbol("jsBoxedDartObjectProperty"))
s($,"kI","fE",()=>{var r,q,p,o=A.bJ(t.N,t.t)
for(r=$.fC(),q=0;q<22;++q){p=r[q]
o.q(0,A.I(p.a),p)}return o})
s($,"kA","fC",()=>A.j([A.E("Raiz",1,A.hv()),A.E("RC",1,A.hv()),A.E("Abs",1,new A.et()),A.E("Ln",1,new A.eu()),A.E("Exp",1,new A.ev()),A.E("Sen",1,new A.eE()),A.E("Cos",1,new A.eF()),A.E("Tan",1,new A.eG()),A.E("ASen",1,new A.eH()),A.E("ACos",1,new A.eI()),A.E("ATan",1,new A.eJ()),A.E("Trunc",1,new A.eK()),A.E("Redon",1,new A.eL()),A.E("Azar",1,new A.ew()),A.E("Aleatorio",2,new A.ex()),A.E("Longitud",1,new A.ey()),A.E("Mayusculas",1,new A.ez()),A.E("Minusculas",1,new A.eA()),A.E("Subcadena",3,A.jS()),A.E("Concatenar",2,new A.eB()),A.E("ConvertirANumero",1,new A.eC()),A.E("ConvertirATexto",1,new A.eD())],A.bg("n<aF>")))
s($,"kF","fD",()=>A.bT("[A-Za-z\xc1\xc9\xcd\xd3\xda\xdc\xd1\xe1\xe9\xed\xf3\xfa\xfc\xf1_]",!0))
s($,"kC","cm",()=>A.bT("[0-9]",!0))
s($,"kB","hQ",()=>A.bT("\\.([VvFf])\\.",!0))
s($,"kG","hS",()=>A.bT("^[+-]?(\\d+\\.?\\d*|\\.\\d+)([eE][+-]?\\d+)?$",!0))})();(function nativeSupport(){!function(){var s=function(a){var m={}
m[a]=1
return Object.keys(hunkHelpers.convertToFastObject(m))[0]}
v.getIsolateTag=function(a){return s("___dart_"+a+v.isolateTag)}
var r="___dart_isolate_tags_"
var q=Object[r]||(Object[r]=Object.create(null))
var p="_ZxYxX"
for(var o=0;;o++){var n=s(p+"_"+o+"_")
if(!(n in q)){q[n]=1
v.isolateTag=n
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.b4,SharedArrayBuffer:A.b4,ArrayBufferView:A.bP,DataView:A.cM,Float32Array:A.cN,Float64Array:A.cO,Int16Array:A.cP,Int32Array:A.cQ,Int8Array:A.cR,Uint16Array:A.cS,Uint32Array:A.cT,Uint8ClampedArray:A.bQ,CanvasPixelArray:A.bQ,Uint8Array:A.cU})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,SharedArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.b5.$nativeSuperclassTag="ArrayBufferView"
A.c6.$nativeSuperclassTag="ArrayBufferView"
A.c7.$nativeSuperclassTag="ArrayBufferView"
A.bN.$nativeSuperclassTag="ArrayBufferView"
A.c8.$nativeSuperclassTag="ArrayBufferView"
A.c9.$nativeSuperclassTag="ArrayBufferView"
A.bO.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$0=function(){return this()}
Function.prototype.$1$1=function(a){return this(a)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=A.ka
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()