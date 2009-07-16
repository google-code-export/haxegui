$estr = function() { return js.Boot.__string_rec(this,''); }
js = {}
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = (i != null?i.fileName + ":" + i.lineNumber + ": ":"");
	msg += js.Boot.__unhtml(js.Boot.__string_rec(v,"")) + "<br/>";
	var d = document.getElementById("haxe:trace");
	if(d == null) alert("No haxe:trace element defined\n" + msg);
	else d.innerHTML += msg;
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
	else null;
}
js.Boot.__closure = function(o,f) {
	var m = o[f];
	if(m == null) return null;
	var f1 = function() {
		return m.apply(o,arguments);
	}
	f1.scope = o;
	f1.method = m;
	return f1;
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":{
		if(o instanceof Array) {
			if(o.__enum__ != null) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				{
					var _g1 = 2, _g = o.length;
					while(_g1 < _g) {
						var i = _g1++;
						if(i != 2) str += "," + js.Boot.__string_rec(o[i],s);
						else str += js.Boot.__string_rec(o[i],s);
					}
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			{
				var _g = 0;
				while(_g < l) {
					var i1 = _g++;
					str += ((i1 > 0?",":"")) + js.Boot.__string_rec(o[i1],s);
				}
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		}
		catch( $e0 ) {
			{
				var e = $e0;
				{
					return "???";
				}
			}
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = (o.hasOwnProperty != null);
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) continue;
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__") continue;
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	}break;
	case "function":{
		return "<function>";
	}break;
	case "string":{
		return o;
	}break;
	default:{
		return String(o);
	}break;
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return (o.__enum__ == null);
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	}
	catch( $e1 ) {
		{
			var e = $e1;
			{
				if(cl == null) return false;
			}
		}
	}
	switch(cl) {
	case Int:{
		return Math.ceil(o%2147483648.0) === o;
	}break;
	case Float:{
		return typeof(o) == "number";
	}break;
	case Bool:{
		return o === true || o === false;
	}break;
	case String:{
		return typeof(o) == "string";
	}break;
	case Dynamic:{
		return true;
	}break;
	default:{
		if(o == null) return false;
		return o.__enum__ == cl || (cl == Class && o.__name__ != null) || (cl == Enum && o.__ename__ != null);
	}break;
	}
}
js.Boot.__init = function() {
	js.Lib.isIE = (document.all != null && window.opera == null);
	js.Lib.isOpera = (window.opera != null);
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		this.splice(i,0,x);
	}
	Array.prototype.remove = function(obj) {
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				return true;
			}
			i++;
		}
		return false;
	}
	Array.prototype.iterator = function() {
		return { cur : 0, arr : this, hasNext : function() {
			return this.cur < this.arr.length;
		}, next : function() {
			return this.arr[this.cur++];
		}}
	}
	var cca = String.prototype.charCodeAt;
	String.prototype.cca = cca;
	String.prototype.charCodeAt = function(i) {
		var x = cca.call(this,i);
		if(isNaN(x)) return null;
		return x;
	}
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		if(pos != null && pos != 0 && len != null && len < 0) return "";
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		}
		else if(len < 0) {
			len = this.length + len - pos;
		}
		return oldsub.apply(this,[pos,len]);
	}
	$closure = js.Boot.__closure;
}
js.Boot.prototype.__class__ = js.Boot;
js.Lib = function() { }
js.Lib.__name__ = ["js","Lib"];
js.Lib.isIE = null;
js.Lib.isOpera = null;
js.Lib.document = null;
js.Lib.window = null;
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
js.Lib.eval = function(code) {
	return eval(code);
}
js.Lib.setErrorHandler = function(f) {
	js.Lib.onerror = f;
}
js.Lib.prototype.__class__ = js.Lib;
Std = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	if(x < 0) return Math.ceil(x);
	return Math.floor(x);
}
Std.parseInt = function(x) {
	var v = parseInt(x);
	if(Math.isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return Math.floor(Math.random() * x);
}
Std.prototype.__class__ = Std;
haxe = {}
haxe.Timer = function(time_ms) { if( time_ms === $_ ) return; {
	this.id = haxe.Timer.arr.length;
	haxe.Timer.arr[this.id] = this;
	this.timerId = window.setInterval("haxe.Timer.arr[" + this.id + "].run();",time_ms);
}}
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.delay = function(f,time_ms) {
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	}
}
haxe.Timer.stamp = function() {
	return Date.now().getTime() / 1000;
}
haxe.Timer.prototype.id = null;
haxe.Timer.prototype.run = function() {
	null;
}
haxe.Timer.prototype.stop = function() {
	if(this.id == null) return;
	window.clearInterval(this.timerId);
	haxe.Timer.arr[this.id] = null;
	if(this.id > 100 && this.id == haxe.Timer.arr.length - 1) {
		var p = this.id - 1;
		while(p >= 0 && haxe.Timer.arr[p] == null) p--;
		haxe.Timer.arr = haxe.Timer.arr.slice(0,p + 1);
	}
	this.id = null;
}
haxe.Timer.prototype.timerId = null;
haxe.Timer.prototype.__class__ = haxe.Timer;
StringTools = function() { }
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	return encodeURIComponent(s);
}
StringTools.urlDecode = function(s) {
	return decodeURIComponent(s.split("+").join(" "));
}
StringTools.htmlEscape = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
StringTools.htmlUnescape = function(s) {
	return s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
}
StringTools.startsWith = function(s,start) {
	return (s.length >= start.length && s.substr(0,start.length) == start);
}
StringTools.endsWith = function(s,end) {
	var elen = end.length;
	var slen = s.length;
	return (slen >= elen && s.substr(slen - elen,elen) == end);
}
StringTools.isSpace = function(s,pos) {
	var c = s.charCodeAt(pos);
	return (c >= 9 && c <= 13) || c == 32;
}
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) {
		r++;
	}
	if(r > 0) return s.substr(r,l - r);
	else return s;
}
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) {
		r++;
	}
	if(r > 0) {
		return s.substr(0,l - r);
	}
	else {
		return s;
	}
}
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
}
StringTools.rpad = function(s,c,l) {
	var sl = s.length;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			s += c.substr(0,l - sl);
			sl = l;
		}
		else {
			s += c;
			sl += cl;
		}
	}
	return s;
}
StringTools.lpad = function(s,c,l) {
	var ns = "";
	var sl = s.length;
	if(sl >= l) return s;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			ns += c.substr(0,l - sl);
			sl = l;
		}
		else {
			ns += c;
			sl += cl;
		}
	}
	return ns + s;
}
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
}
StringTools.hex = function(n,digits) {
	var neg = false;
	if(n < 0) {
		neg = true;
		n = -n;
	}
	var s = n.toString(16);
	s = s.toUpperCase();
	if(digits != null) while(s.length < digits) s = "0" + s;
	if(neg) s = "-" + s;
	return s;
}
StringTools.prototype.__class__ = StringTools;
EReg = function(r,opt) { if( r === $_ ) return; {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
}}
EReg.__name__ = ["EReg"];
EReg.prototype.customReplace = function(s,f) {
	var buf = new StringBuf();
	while(true) {
		if(!this.match(s)) break;
		buf.b += this.matchedLeft();
		buf.b += f(this);
		s = this.matchedRight();
	}
	buf.b += s;
	return buf.b;
}
EReg.prototype.match = function(s) {
	this.r.m = this.r.exec(s);
	this.r.s = s;
	this.r.l = RegExp.leftContext;
	this.r.r = RegExp.rightContext;
	return (this.r.m != null);
}
EReg.prototype.matched = function(n) {
	return (this.r.m != null && n >= 0 && n < this.r.m.length?this.r.m[n]:function($this) {
		var $r;
		throw "EReg::matched";
		return $r;
	}(this));
}
EReg.prototype.matchedLeft = function() {
	if(this.r.m == null) throw "No string matched";
	if(this.r.l == null) return this.r.s.substr(0,this.r.m.index);
	return this.r.l;
}
EReg.prototype.matchedPos = function() {
	if(this.r.m == null) throw "No string matched";
	return { pos : this.r.m.index, len : this.r.m[0].length}
}
EReg.prototype.matchedRight = function() {
	if(this.r.m == null) throw "No string matched";
	if(this.r.r == null) {
		var sz = this.r.m.index + this.r.m[0].length;
		return this.r.s.substr(sz,this.r.s.length - sz);
	}
	return this.r.r;
}
EReg.prototype.r = null;
EReg.prototype.replace = function(s,by) {
	return s.replace(this.r,by);
}
EReg.prototype.split = function(s) {
	var d = "#__delim__#";
	return s.replace(this.r,d).split(d);
}
EReg.prototype.__class__ = EReg;
StringBuf = function(p) { if( p === $_ ) return; {
	this.b = "";
}}
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype.add = function(x) {
	this.b += x;
}
StringBuf.prototype.addChar = function(c) {
	this.b += String.fromCharCode(c);
}
StringBuf.prototype.addSub = function(s,pos,len) {
	this.b += s.substr(pos,len);
}
StringBuf.prototype.b = null;
StringBuf.prototype.toString = function() {
	return this.b;
}
StringBuf.prototype.__class__ = StringBuf;
_CodeHighlighter = {}
_CodeHighlighter.Rule = { __ename__ : ["_CodeHighlighter","Rule"], __constructs__ : ["Flat","Nested"] }
_CodeHighlighter.Rule.Flat = function(type,pattern) { var $x = ["Flat",0,type,pattern]; $x.__enum__ = _CodeHighlighter.Rule; $x.toString = $estr; return $x; }
_CodeHighlighter.Rule.Nested = function(language,start,end) { var $x = ["Nested",1,language,start,end]; $x.__enum__ = _CodeHighlighter.Rule; $x.toString = $estr; return $x; }
CodeHighlighter = function() { }
CodeHighlighter.__name__ = ["CodeHighlighter"];
CodeHighlighter.main = function() {
	null;
}
CodeHighlighter.getLanguages = function() {
	var ls = [];
	{
		var _g = 0, _g1 = CodeHighlighter.languages;
		while(_g < _g1.length) {
			var l = _g1[_g];
			++_g;
			ls.push(l.names);
		}
	}
	return ls;
}
CodeHighlighter.highlightAll = function(addLineNumbers) {
	var pattern = new EReg("^code\\s*(.*)$","");
	var elements = [];
	var pres = js.Lib.document.getElementsByTagName("pre");
	{
		var _g1 = 0, _g = pres.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(pattern.match(pres[i].className)) {
				elements.push({ element : pres[i], language : pattern.matched(1)});
			}
		}
	}
	var iterate = null;
	iterate = function() {
		var element = elements.pop();
		if(element == null) {
			if(addLineNumbers) {
				var es = js.Lib.document.getElementsByName("code-line-numbers");
				{
					var _g1 = 0, _g = es.length;
					while(_g1 < _g) {
						var i = _g1++;
						var e = es[i];
						e.onselectstart = function() {
							return false;
						}
						e.unselectable = "on";
						e.style.MozUserSelect = "none";
						e.style.cursor = "default";
					}
				}
			}
			return;
		}
		var result = CodeHighlighter.highlight(StringTools.htmlUnescape(element.element.innerHTML),element.language,addLineNumbers);
		result = "<pre style=\"margin:0;padding:0;\">" + result + "</pre>";
		if(element.language != null && element.language.length != 0) element.element.innerHTML = result;
		haxe.Timer.delay(iterate,1);
	}
	haxe.Timer.delay(iterate,1);
}
CodeHighlighter.highlight = function(code,languageName,addLineNumbers) {
	return ((addLineNumbers?CodeHighlighter.lineNumbers(code):"")) + "<div class=\"code-code\">" + CodeHighlighter.highlightUntil(_CodeHighlighter.Rule.Flat("",new EReg("^$","")),code,languageName).html + "</div>";
}
CodeHighlighter.highlightUntil = function(stopRule,code,languageName) {
	var language = null;
	{
		var _g = 0, _g1 = CodeHighlighter.languages;
		while(_g < _g1.length) {
			var l = _g1[_g];
			++_g;
			{
				var _g2 = 0, _g3 = l.names;
				while(_g2 < _g3.length) {
					var n = _g3[_g2];
					++_g2;
					if(n.toLowerCase() == languageName.toLowerCase()) language = l;
				}
			}
		}
	}
	if(language == null) return { html : code, rest : ""}
	var rules = (stopRule == null?function($this) {
		var $r;
		stopRule = _CodeHighlighter.Rule.Flat("",new EReg("^",""));
		$r = language.rules.concat([stopRule]);
		return $r;
	}(this):[stopRule].concat(language.rules));
	var html = new StringBuf();
	var tryRule = null;
	tryRule = function(rule) {
		var $e = (rule);
		switch( $e[1] ) {
		case 0:
		var pattern = $e[3], type = $e[2];
		{
			if(!pattern.match(code)) return _CodeHighlighter.Match.NotMatched;
			var s = pattern.matched(0);
			if(s.length == 0 && rule != stopRule) return _CodeHighlighter.Match.NotMatched;
			html.b += CodeHighlighter.markup(s,type);
			code = code.substr(s.length);
		}break;
		case 1:
		var stop = $e[4], start = $e[3], language1 = $e[2];
		{
			var match = tryRule(start);
			var $e = (match);
			switch( $e[1] ) {
			case 1:
			{
				var h = CodeHighlighter.highlightUntil(stop,code,language1);
				html.b += h.html;
				code = h.rest;
			}break;
			default:{
				return match;
			}break;
			}
		}break;
		}
		if(rule == stopRule) return _CodeHighlighter.Match.Done;
		return _CodeHighlighter.Match.Matched;
	}
	while(true) {
		var next = false;
		{
			var _g = 0;
			while(_g < rules.length) {
				var rule = rules[_g];
				++_g;
				var $e = (tryRule(rule));
				switch( $e[1] ) {
				case 0:
				{
					return { html : html.b, rest : code}
				}break;
				case 1:
				{
					next = true;
				}break;
				case 2:
				{
					null;
				}break;
				}
				if(next) break;
			}
		}
		if(!next) {
			html.b += StringTools.htmlEscape(code.substr(0,1));
			code = code.substr(1);
		}
	}
	return null;
}
CodeHighlighter.markup = function(code,type) {
	if(type.length == 0) return StringTools.htmlEscape(code);
	return "<span class=\"code-" + type + "\">" + StringTools.htmlEscape(code) + "</span>";
}
CodeHighlighter.lineNumbers = function(code) {
	var ns = code.split("\n");
	var rs = code.split("\r");
	var lines = (ns.length > rs.length?ns:rs);
	var count = lines.length;
	var last = lines.pop();
	if(last != null && (last.length == 0 || last == "\n" || last == "\r")) {
		count -= 1;
	}
	var html = new StringBuf();
	html.b += "<div class=\"code-line-numbers\" name=\"code-line-numbers\">";
	{
		var _g = 0;
		while(_g < count) {
			var i = _g++;
			if(i != 0) html.b += "\n";
			html.b += i + 1;
		}
	}
	html.b += "</div>";
	return html.b;
}
CodeHighlighter.prototype.__class__ = CodeHighlighter;
_CodeHighlighter.Match = { __ename__ : ["_CodeHighlighter","Match"], __constructs__ : ["Done","Matched","NotMatched"] }
_CodeHighlighter.Match.Done = ["Done",0];
_CodeHighlighter.Match.Done.toString = $estr;
_CodeHighlighter.Match.Done.__enum__ = _CodeHighlighter.Match;
_CodeHighlighter.Match.Matched = ["Matched",1];
_CodeHighlighter.Match.Matched.toString = $estr;
_CodeHighlighter.Match.Matched.__enum__ = _CodeHighlighter.Match;
_CodeHighlighter.Match.NotMatched = ["NotMatched",2];
_CodeHighlighter.Match.NotMatched.toString = $estr;
_CodeHighlighter.Match.NotMatched.__enum__ = _CodeHighlighter.Match;
IntIter = function(min,max) { if( min === $_ ) return; {
	this.min = min;
	this.max = max;
}}
IntIter.__name__ = ["IntIter"];
IntIter.prototype.hasNext = function() {
	return this.min < this.max;
}
IntIter.prototype.max = null;
IntIter.prototype.min = null;
IntIter.prototype.next = function() {
	return this.min++;
}
IntIter.prototype.__class__ = IntIter;
$Main = function() { }
$Main.__name__ = ["@Main"];
$Main.prototype.__class__ = $Main;
$_ = {}
js.Boot.__res = {}
js.Boot.__init();
{
	Date.now = function() {
		return new Date();
	}
	Date.fromTime = function(t) {
		var d = new Date();
		d["setTime"](t);
		return d;
	}
	Date.fromString = function(s) {
		switch(s.length) {
		case 8:{
			var k = s.split(":");
			var d = new Date();
			d["setTime"](0);
			d["setUTCHours"](k[0]);
			d["setUTCMinutes"](k[1]);
			d["setUTCSeconds"](k[2]);
			return d;
		}break;
		case 10:{
			var k = s.split("-");
			return new Date(k[0],k[1] - 1,k[2],0,0,0);
		}break;
		case 19:{
			var k = s.split(" ");
			var y = k[0].split("-");
			var t = k[1].split(":");
			return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
		}break;
		default:{
			throw "Invalid date format : " + s;
		}break;
		}
	}
	Date.prototype["toString"] = function() {
		var date = this;
		var m = date.getMonth() + 1;
		var d = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		return date.getFullYear() + "-" + ((m < 10?"0" + m:"" + m)) + "-" + ((d < 10?"0" + d:"" + d)) + " " + ((h < 10?"0" + h:"" + h)) + ":" + ((mi < 10?"0" + mi:"" + mi)) + ":" + ((s < 10?"0" + s:"" + s));
	}
	Date.prototype.__class__ = Date;
	Date.__name__ = ["Date"];
}
{
	js.Lib.document = document;
	js.Lib.window = window;
	onerror = function(msg,url,line) {
		var f = js.Lib.onerror;
		if( f == null )
			return false;
		return f(msg,[url+":"+line]);
	}
}
{
	String.prototype.__class__ = String;
	String.__name__ = ["String"];
	Array.prototype.__class__ = Array;
	Array.__name__ = ["Array"];
	Int = { __name__ : ["Int"]}
	Dynamic = { __name__ : ["Dynamic"]}
	Float = Number;
	Float.__name__ = ["Float"];
	Bool = { __ename__ : ["Bool"]}
	Class = { __name__ : ["Class"]}
	Enum = { }
	Void = { __ename__ : ["Void"]}
}
{
	Math.NaN = Number["NaN"];
	Math.NEGATIVE_INFINITY = Number["NEGATIVE_INFINITY"];
	Math.POSITIVE_INFINITY = Number["POSITIVE_INFINITY"];
	Math.isFinite = function(i) {
		return isFinite(i);
	}
	Math.isNaN = function(i) {
		return isNaN(i);
	}
	Math.__name__ = ["Math"];
}
js.Lib.onerror = null;
haxe.Timer.arr = new Array();
CodeHighlighter.patterns = { ignorable : new EReg("^[ \\t\\r\\n]+",""), tripleString : new EReg("^([\"]{3}([\"]{0,2}[^\\\\\"]|\\\\.)*[\"]{3})",""), doubleString : new EReg("^([\"]([^\\\\\"]|\\\\.)*[\"])",""), singleString : new EReg("^([']([^'\\\\]|['][']|\\\\.)*['])",""), number : new EReg("^(0x[0-9a-fA-F]+|([0-9]+([.][0-9]+)?([eE][+-]?[0-9]+)?)[a-zA-Z]?)",""), dollarIdentifier : new EReg("^([$][a-zA-Z0-9_]*)",""), identifier : new EReg("^([a-zA-Z_][a-zA-Z0-9_]*)",""), upperIdentifier : new EReg("^([A-Z][a-zA-Z0-9_]*)",""), lowerIdentifier : new EReg("^([a-z_][a-zA-Z0-9_]*)",""), docCommentBegin : new EReg("^/\\*\\*",""), docCommentEnd : new EReg("^\\*/",""), blockComment : new EReg("^([/][*]([^*]|[*][^/])*[*][/])",""), lineComment : new EReg("^([/][/][^\\r\\n]*(\\r\\n|\\r|\\n)?)",""), entity : new EReg("^([&][^;]+[;])","")}
CodeHighlighter.common = { ignorable : _CodeHighlighter.Rule.Flat("",CodeHighlighter.patterns.ignorable), docComment : _CodeHighlighter.Rule.Nested("doc-comment",_CodeHighlighter.Rule.Flat("comment",CodeHighlighter.patterns.docCommentBegin),_CodeHighlighter.Rule.Flat("comment",CodeHighlighter.patterns.docCommentEnd)), blockComment : _CodeHighlighter.Rule.Flat("comment",CodeHighlighter.patterns.blockComment), lineComment : _CodeHighlighter.Rule.Flat("comment",CodeHighlighter.patterns.lineComment), dashComment : _CodeHighlighter.Rule.Flat("comment",new EReg("^([-][-][^\\n]*)","")), dashBlockComment : _CodeHighlighter.Rule.Flat("comment",new EReg("^([{][-]([^-]|[-][^}])*[-][}])","")), hashComment : _CodeHighlighter.Rule.Flat("comment",new EReg("^([#][^\\n\\r]*)","")), number : _CodeHighlighter.Rule.Flat("number",CodeHighlighter.patterns.number), tripleString : _CodeHighlighter.Rule.Flat("string",CodeHighlighter.patterns.tripleString), doubleString : _CodeHighlighter.Rule.Flat("string",CodeHighlighter.patterns.doubleString), singleString : _CodeHighlighter.Rule.Flat("string",CodeHighlighter.patterns.singleString), functionName : _CodeHighlighter.Rule.Flat("",new EReg("^([a-zA-Z_][a-zA-Z0-9_]*\\s*[(])","")), regex : _CodeHighlighter.Rule.Flat("string",new EReg("^\\~/([^\\\\/]|\\\\.)*/[a-zA-Z]*",""))}
CodeHighlighter.languages = [{ names : ["xml-attributes"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("type",new EReg("^[a-zA-Z0-9_.-]+","")),CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString]},{ names : ["html","xhtml","xml"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("comment",new EReg("^(<[!]--([^-]|[-][^-]|[-][-][^>])*-->)","")),_CodeHighlighter.Rule.Flat("variable",new EReg("^(<[!]\\[CDATA\\[([^\\]]|\\][^\\]]|\\]\\][^>])*\\]\\]>)","i")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(<[%]([^%]|[%][^>])*[%]>)","")),_CodeHighlighter.Rule.Nested("css",_CodeHighlighter.Rule.Nested("xml-attributes",_CodeHighlighter.Rule.Flat("keyword",new EReg("^<\\s*style\\b","i")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^>",""))),_CodeHighlighter.Rule.Flat("keyword",new EReg("^<\\s*/\\s*style\\s*>","i"))),_CodeHighlighter.Rule.Nested("javascript",_CodeHighlighter.Rule.Nested("xml-attributes",_CodeHighlighter.Rule.Flat("keyword",new EReg("^<\\s*script\\b","i")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^>",""))),_CodeHighlighter.Rule.Flat("keyword",new EReg("^<\\s*/\\s*script\\s*>","i"))),_CodeHighlighter.Rule.Nested("php",_CodeHighlighter.Rule.Flat("keyword",new EReg("^<[?](php[0-9]*)?","i")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^[?]>",""))),_CodeHighlighter.Rule.Nested("xml-attributes",_CodeHighlighter.Rule.Flat("keyword",new EReg("^<\\s*[a-zA-Z0-9_.-]+","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^>",""))),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(<\\s*/\\s*[a-zA-Z0-9_.-]+)\\s*(>)","")),_CodeHighlighter.Rule.Flat("variable",CodeHighlighter.patterns.entity),_CodeHighlighter.Rule.Flat("",new EReg("^[^<&]+",""))]},{ names : ["css"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("variable",new EReg("^([a-zA-Z-]+[:])","")),_CodeHighlighter.Rule.Flat("number",new EReg("^([#][0-9a-fA-F]{6}|[0-9]+[a-zA-Z%]*)","")),_CodeHighlighter.Rule.Flat("type",new EReg("^([#.:]?[a-zA-Z>-][a-zA-Z0-9>-]*)","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(url|rgb|rect|inherit)\\b","")),_CodeHighlighter.Rule.Flat("comment",new EReg("^(<!--|-->)","")),CodeHighlighter.common.blockComment]},{ names : ["wikitalis","wiki"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(\\\\[a-zA-Z]+)","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(\\{|\\})","")),_CodeHighlighter.Rule.Flat("",new EReg("^[^\\\\{}]+",""))]},{ names : ["ebnf","bnf"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(\\:\\:\\=|\\[|\\]|\\{|\\})","")),_CodeHighlighter.Rule.Flat("type",new EReg("^(<[a-zA-Z0-9 _-]+>)","")),_CodeHighlighter.Rule.Flat("comment",new EReg("^([?][^?]*[?])","")),CodeHighlighter.common.doubleString,_CodeHighlighter.Rule.Flat("string",CodeHighlighter.patterns.identifier)]},{ names : ["doc-comment"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("type",new EReg("^[@][a-zA-Z0-9_-]+","")),_CodeHighlighter.Rule.Flat("variable",new EReg("^[<]/?[a-zA-Z0-9_.-]+[^>]*[>]","")),_CodeHighlighter.Rule.Flat("comment",new EReg("^([^@<*\\r\\n]+|.)",""))]},{ names : ["php"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(and|or|xor|__FILE__|exception|__LINE__|array|as|break|case|class|const|continue|declare|default|die|do|echo|else|elseif|empty|enddeclare|endfor|endforeach|endif|endswitch|endwhile|eval|exit|extends|for|foreach|function|global|if|include|include_once|isset|list|new|print|require|require_once|return|static|switch|unset|use|var|while|__FUNCTION__|__CLASS__|__METHOD__|final|php_user_filter|interface|implements|instanceof|public|private|protected|abstract|clone|try|catch|throw|cfunction|old_function|this|final|__NAMESPACE__|namespace|goto|__DIR__)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(<\\?(php[0-9]*)?\\b|\\?>)","")),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Flat("variable",CodeHighlighter.patterns.dollarIdentifier),CodeHighlighter.common.docComment,CodeHighlighter.common.blockComment,CodeHighlighter.common.lineComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString,_CodeHighlighter.Rule.Flat("",new EReg("^[a-zA-Z0-9]+",""))]},{ names : ["javascript","jscript","js"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(abstract|boolean|break|byte|case|catch|char|class|const|continue|debugger|default|delete|do|double)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(else|enum|export|extends|false|final|finally|float|for|function|goto|if|implements|import|in)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(instanceof|int|interface|long|native|new|null|package|private|protected|public|return|short|static|super)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(switch|synchronized|this|throw|throws|transient|true|try|typeof|var|void|volatile|while|with)\\b","")),_CodeHighlighter.Rule.Flat("type",CodeHighlighter.patterns.entity),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Flat("variable",new EReg("^[a-zA-Z_$][a-zA-Z0-9_]*","")),_CodeHighlighter.Rule.Flat("comment",new EReg("^(<!--|-->)","")),CodeHighlighter.common.docComment,CodeHighlighter.common.blockComment,CodeHighlighter.common.lineComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString]},{ names : ["perl"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("string",new EReg("^(m|q|qq|qw|qx)/([^\\\\/]|\\\\.)*/[a-zA-Z]*","")),_CodeHighlighter.Rule.Flat("string",new EReg("^(y|tr|s)/([^\\\\/]|\\\\.)*/([^\\\\/]|\\\\.)*/[a-zA-Z]*","")),_CodeHighlighter.Rule.Flat("string",new EReg("^/(([^\\s/\\\\]|\\\\.)([^\\\\/]|\\\\.)*)?/[a-zA-Z]*","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(abs|accept|alarm|Answer|Ask|atan2|bind|binmode|bless|caller|chdir|chmod|chomp|Choose|chop|chown|chr|chroot|close|closedir|connect|continue|cos|crypt|dbmclose|dbmopen|defined|delete|die|Directory|do|DoAppleScript|dump)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(each|else|elsif|endgrent|endhostent|endnetent|endprotoent|endpwent|eof|eval|exec|exists|exit|exp|FAccess|fcntl|fileno|find|flock|for|foreach|fork|format|formline)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(getc|GetFileInfo|getgrent|getgrgid|getgrnam|gethostbyaddr|gethostbyname|gethostent|getlogin|getnetbyaddr|getnetbyname|getnetent|getpeername|getpgrp|getppid|getpriority|getprotobyname|getprotobynumber|getprotoent|getpwent|getpwnam|getpwuid|getservbyaddr|getservbyname|getservbyport|getservent|getsockname|getsockopt|glob|gmtime|goto|grep)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(hex|hostname|if|import|index|int|ioctl|join|keys|kill|last|lc|lcfirst|length|link|listen|LoadExternals|local|localtime|log|lstat|MakeFSSpec|MakePath|map|mkdir|msgctl|msgget|msgrcv|msgsnd|my|next|no|oct|open|opendir|ord)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(pack|package|Pick|pipe|pop|pos|print|printf|push|pwd|Quit|quotemeta|rand|read|readdir|readlink|recv|redo|ref|rename|Reply|require|reset|return|reverse|rewinddir|rindex|rmdir)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(scalar|seek|seekdir|select|semctl|semget|semop|send|SetFileInfo|setgrent|sethostent|setnetent|setpgrp|setpriority|setprotoent|setpwent|setservent|setsockopt|shift|shmctl|shmget|shmread|shmwrite|shutdown|sin|sleep|socket|socketpair|sort|splice|split|sprintf|sqrt|srand|stat|stty|study|sub|substr|symlink|syscall|sysopen|sysread|system|syswrite)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(tell|telldir|tie|tied|time|times|truncate|uc|ucfirst|umask|undef|unless|unlink|until|unpack|unshift|untie|use|utime|values|vec|Volumes|wait|waitpid|wantarray|warn|while|write)\\b","")),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Flat("variable",new EReg("^(\\@|\\$|)[a-zA-Z_][a-zA-Z0-9_]*","")),CodeHighlighter.common.hashComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString]},{ names : ["ruby"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("",new EReg("^::","")),_CodeHighlighter.Rule.Flat("string",new EReg("^/(([^\\s/\\\\]|\\\\.)([^\\\\/]|\\\\.)*)?/[a-zA-Z]*","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(alias|and|BEGIN|begin|break|case|class|def|defined|do|else|elsif|END|end|ensure|false|for|if|in|module|next|nil|not|or|redo|rescue|retry|return|self|super|then|true|undef|unless|until|when|while|yield)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(require|include|raise|public|protected|private|)\\b","")),_CodeHighlighter.Rule.Flat("string",new EReg("^:[a-zA-Z_][a-zA-Z0-9_]*","")),_CodeHighlighter.Rule.Flat("type",CodeHighlighter.patterns.upperIdentifier),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Flat("variable",new EReg("^(\\@|\\$|)[a-zA-Z_][a-zA-Z0-9_]*","")),CodeHighlighter.common.hashComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString]},{ names : ["c++","cpp","c"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(asm|auto|bool|break|case|catch|class|const|const_cast|continue|default|delete|do|double|dynamic_cast|else|enum|explicit|export|extern|false|float|for|friend|goto|if|inline|int|long|mutable|namespace|new|operator|private|protected|public|register|reinterpret_cast|return|short|signed|sizeof|static|static_cast|struct|switch|template|this|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|while)\\b","")),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Flat("variable",CodeHighlighter.patterns.identifier),_CodeHighlighter.Rule.Flat("type",new EReg("^#[a-zA-Z0-9_]+([^\\r\\n\\\\]|\\\\(\\r\\n|\\r|\\n|.))*","")),CodeHighlighter.common.docComment,CodeHighlighter.common.blockComment,CodeHighlighter.common.lineComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString]},{ names : ["c#","csharp","c-sharp","cs"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(abstract|event|new|struct|as|explicit|null|switch|base|extern|object|this|bool|false|operator|throw|break|finally|out|true|byte|fixed|override|try|case|float|params|typeof|catch|for|private|uint|char|foreach|protected|ulong|checked|goto|public|unchecked|class|if|readonly|unsafe|const|implicit|ref|ushort|continue|in|return|using|decimal|int|sbyte|virtual|default|interface|sealed|volatile|delegate|internal|short|void|do|is|sizeof|while|double|lock|stackalloc|else|long|static|enum|namespace|string)\\b","")),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Flat("variable",CodeHighlighter.patterns.identifier),CodeHighlighter.common.docComment,CodeHighlighter.common.blockComment,CodeHighlighter.common.lineComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString]},{ names : ["java"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(abstract|assert|break|case|catch|class|continue|default|do|else|enum|extends|final|finally|for|if|implements|import|instanceof|interface|native|new|package|private|protected|public|return|static|strictfp|super|switch|synchronized|this|throw|throws|transient|try|volatile|while|true|false|null)\\b","")),_CodeHighlighter.Rule.Flat("type",new EReg("^(boolean|byte|char|double|float|int|long|short|void)","")),_CodeHighlighter.Rule.Flat("type",CodeHighlighter.patterns.upperIdentifier),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Flat("variable",CodeHighlighter.patterns.lowerIdentifier),CodeHighlighter.common.docComment,CodeHighlighter.common.blockComment,CodeHighlighter.common.lineComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString]},{ names : ["scala"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(true|false|this|super|forSome|type|val|var|with|if|else|while|try|catch|finally|yield|do|for|throw|return|match|new|implicit|lazy|case|override|abstract|final|sealed|private|protected|public|package|import|def|class|object|trait|extends|null)\\b","")),_CodeHighlighter.Rule.Flat("type",new EReg("^(boolean|byte|char|double|float|int|long|short|void)","")),_CodeHighlighter.Rule.Flat("type",CodeHighlighter.patterns.upperIdentifier),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Nested("xml-attributes",_CodeHighlighter.Rule.Flat("keyword",new EReg("^</?[a-zA-Z0-9]+","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^>",""))),_CodeHighlighter.Rule.Flat("variable",CodeHighlighter.patterns.lowerIdentifier),CodeHighlighter.common.docComment,CodeHighlighter.common.blockComment,CodeHighlighter.common.lineComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.tripleString,CodeHighlighter.common.singleString]},{ names : ["haxe"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(public|private|package|import|enum|class|interface|typedef|implements|extends|if|else|switch|case|default|for|in|do|while|continue|break|dynamic|untyped|cast|static|inline|extern|override|var|function|new|return|trace|try|catch|throw|this|null|true|false|super|typeof|undefined)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(\\#((if|elseif)(\\s+[a-zA-Z_]+)?|(else|end)))\\b","")),_CodeHighlighter.Rule.Flat("type",CodeHighlighter.patterns.upperIdentifier),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Flat("variable",CodeHighlighter.patterns.lowerIdentifier),CodeHighlighter.common.docComment,CodeHighlighter.common.blockComment,CodeHighlighter.common.lineComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString,CodeHighlighter.common.regex]},{ names : ["python"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(and|del|from|not|while|as|elif|global|or|with|assert|else|if|pass|yield|break|except|import|print|class|exec|in|raise|continue|finally|is|return|def|for|lambda|try|[:])\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(__[A-Za-z0-9_]+)","")),CodeHighlighter.common.number,CodeHighlighter.common.tripleString,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString,_CodeHighlighter.Rule.Flat("string",new EReg("^((r|u|ur|R|U|UR|Ur|uR)?[\"]{3}([\"]{0,2}[^\"])*[\"]{3})","")),_CodeHighlighter.Rule.Flat("string",new EReg("^((r|u|ur|R|U|UR|Ur|uR)?[\"][^\"]*[\"])","")),_CodeHighlighter.Rule.Flat("string",new EReg("^((r|u|ur|R|U|UR|Ur|uR)?['][^']*['])","")),_CodeHighlighter.Rule.Flat("variable",CodeHighlighter.patterns.lowerIdentifier),_CodeHighlighter.Rule.Flat("type",CodeHighlighter.patterns.upperIdentifier),CodeHighlighter.common.hashComment]},{ names : ["droid"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(package|using|where|class|object|interface|enum|methods|pure|do|end)\\b","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(scope|if|else|elseif|while|for|in|throw|catch|var|val|fun|switch|and|or|not|true|false|none|this)\\b","")),CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString,_CodeHighlighter.Rule.Flat("type",CodeHighlighter.patterns.upperIdentifier),CodeHighlighter.common.functionName,_CodeHighlighter.Rule.Flat("variable",new EReg("^([a-z][a-zA-Z0-9]*)","")),_CodeHighlighter.Rule.Nested("doc-comment",_CodeHighlighter.Rule.Flat("comment",new EReg("^##","")),_CodeHighlighter.Rule.Flat("comment",new EReg("^(\\r|\\n|\\r\\n)",""))),CodeHighlighter.common.regex,CodeHighlighter.common.hashComment]},{ names : ["funk"], rules : [CodeHighlighter.common.ignorable,CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString,_CodeHighlighter.Rule.Flat("string",new EReg("^([A-Z][a-zA-Z0-9]*)","")),_CodeHighlighter.Rule.Flat("variable",new EReg("^([a-z][a-zA-Z0-9]*|_)","")),_CodeHighlighter.Rule.Nested("funk-pattern",_CodeHighlighter.Rule.Flat("",new EReg("^\\|","")),_CodeHighlighter.Rule.Flat("",new EReg("^\\|",""))),_CodeHighlighter.Rule.Nested("funk-pattern",_CodeHighlighter.Rule.Flat("",new EReg("^\\:","")),null),CodeHighlighter.common.hashComment]},{ names : ["funk-pattern"], rules : [CodeHighlighter.common.number,CodeHighlighter.common.doubleString,CodeHighlighter.common.singleString,_CodeHighlighter.Rule.Flat("string",new EReg("^([A-Z][a-zA-Z0-9]*)","")),_CodeHighlighter.Rule.Flat("type",new EReg("^([a-z][a-zA-Z0-9]*|_)","")),_CodeHighlighter.Rule.Nested("funk-pattern",_CodeHighlighter.Rule.Flat("",new EReg("^\\[","")),_CodeHighlighter.Rule.Flat("",new EReg("^\\]",""))),_CodeHighlighter.Rule.Nested("funk-pattern",_CodeHighlighter.Rule.Flat("",new EReg("^\\{","")),_CodeHighlighter.Rule.Flat("",new EReg("^\\}",""))),_CodeHighlighter.Rule.Nested("funk-pattern",_CodeHighlighter.Rule.Flat("",new EReg("^\\(","")),_CodeHighlighter.Rule.Flat("",new EReg("^\\)",""))),_CodeHighlighter.Rule.Flat("",new EReg("^(\\,|\\@)",""))]},{ names : ["haskell"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(as|of|case|class|data|default|deriving|do|forall|hiding|if|then|else|import|infix|infixl|infixr|instance|let|in|module|newtype|qualified|type|where)","")),_CodeHighlighter.Rule.Flat("type",CodeHighlighter.patterns.upperIdentifier),_CodeHighlighter.Rule.Flat("variable",new EReg("^([a-z][a-zA-Z0-9']*)","")),CodeHighlighter.common.dashComment,CodeHighlighter.common.dashBlockComment,CodeHighlighter.common.number,CodeHighlighter.common.doubleString]},{ names : ["tex","latex"], rules : [CodeHighlighter.common.ignorable,_CodeHighlighter.Rule.Flat("keyword",new EReg("^(\\{|\\}|\\[|\\]|\\$|\\&)","")),_CodeHighlighter.Rule.Flat("keyword",new EReg("^(\\\\[a-zA-Z]*)","")),_CodeHighlighter.Rule.Flat("comment",new EReg("^([%][^\\n]*)","")),_CodeHighlighter.Rule.Flat("",new EReg("^[-a-zA-Z0-9_+=* \\r\\n\\t.;,?!'`'|]+",""))]}];
$Main.init = CodeHighlighter.main();
