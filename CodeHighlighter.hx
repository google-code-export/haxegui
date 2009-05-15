// By Joakim Ahnfelt-Rønne, August 2008

#if js
import haxe.Timer;
#end    

/**
 * This is a highlighter that takes in a piece of code and
 * spits out highlighted HTML. It's meant to be compiled to
 * JavaScript and used to dynamically highlight code on 
 * websites. This can be done by including this at the 
 * bottom of your HTML, just before </html>:
 *     <script type="text/javascript" src="highlighter.js"></script>
 *     <script type="text/javascript">
 *         Highlighter.highlightAll();
 *     </script>
 * The second script element highlights all <pre> elements 
 * that have a class name starting with code and ending in
 * a supported language name, for example:
 *     <pre class="code java">
 *         class Main {
 *             public static void main(String[] args) {
 *                 System.out.println("Hello, highlighting!");
 *             }
 *         }
 *     </pre>
 * The above will automatically be highlighted as Java when
 * highlightAll is called. You can also highlight manually
 * with the highlight method. Add your own languages at the
 * bottom, it's pretty easy.
 */
class CodeHighlighter {
    public static function main() {
    }

    public static function getLanguages(): Array<Array<String>> {
        var ls = [];
        for(l in languages) {
            ls.push(l.names);
        }
        return ls;
    }

    // DOM stuff to find the <pre> elements, boring stuff
#if js
    /**
     * Finds all <pre class="code XXX">CCC</pre> where XXX is a language name
     * and CCC is some code and highlights it.
     * @param addLineNumbers Insert line numbers (off by default).
     */
    public static function highlightAll(?addLineNumbers: Bool): Void {
        var pattern = ~/^code\s*(.*)$/;
        var elements = [];
        var pres = js.Lib.document.getElementsByTagName('pre');
        for(i in 0...pres.length) {
            if(pattern.match(pres[i].className)) {
                elements.push({ element: pres[i], language: pattern.matched(1) });
            }
        }
        var iterate = null;
        iterate = function() {
            var element = elements.pop();
            if(element == null) {
                if(addLineNumbers) {
                    var es = js.Lib.document.getElementsByName('code-line-numbers');
                    for(i in 0...es.length) {
                        // Disables text selection (in FF and IE at least)
                        var e: Dynamic = es[i];
                        e.onselectstart = function() {
                            return false;
                        };
                        e.unselectable = "on";
                        e.style.MozUserSelect = "none";
                        e.style.cursor = "default";
                    }
                }
                return;
            }
            var result = highlight(
                StringTools.htmlUnescape(element.element.innerHTML), 
                element.language,
                addLineNumbers);
            // IE workaround for innerHTML/pre browser bug
            result = "<pre style=\"margin:0;padding:0;\">" + 
                result + 
                "</pre>";
            if(element.language != null && element.language.length != 0)
                element.element.innerHTML = result;
            Timer.delay(iterate, 1);
        }
        Timer.delay(iterate, 1);
    }
#end    

    /**
     * Highlights some code according to a language and returns the HTML.
     * @param code The source code that should be highlighted.
     * @param languageName The name of the computer language.
     * @param addLineNumbers Insert line numbers (off by default).
     * @return HTML for the highlighted code.
     */
    public static function highlight(code: String, languageName: String, ?addLineNumbers: Bool): String {
        return (if(addLineNumbers) lineNumbers(code) else "") +
            //~ "<div class=\"code-code\">" +
            highlightUntil(Flat("", ~/^$/), code, languageName).html +
            //~ "</div>";
            "";
    }
    
    // Highlighting algorithm
    private static function highlightUntil(
        stopRule: Rule, 
        code: String, 
        languageName: String): 
        { html: String, rest: String } {
        var language = null;
        for(l in languages) {
            for(n in l.names) {
                if(n.toLowerCase() == languageName.toLowerCase()) language = l;
            }
        }
        if(language == null) return { html: code, rest: "" };
        var rules = if(stopRule == null) {
            stopRule = Flat("", ~/^/);
            language.rules.concat([stopRule]);
        } else {
            [stopRule].concat(language.rules);
        }
        var html = new StringBuf();
        // Try a rule - mutates state on success!
        var tryRule = null;
        tryRule = function(rule) {
            switch(rule) {
                case Flat(type, pattern):
                    if(!pattern.match(code)) return NotMatched;
                    var s = pattern.matched(0);
                    if(s.length == 0 && rule != stopRule) return NotMatched;
                    html.add(markup(s, type));
                    code = code.substr(s.length);
                case Nested(language, start, stop):
                    var match = tryRule(start);
                    switch(match) {
                        case Matched:
                            var h = highlightUntil(stop, code, language);
                            html.add(h.html);
                            code = h.rest;
                        default:
                            return match;
                    }
            }
            if(rule == stopRule) return Done;
            return Matched;
        };
        // Keep trying until the stopRule matches.
        while(true) {
            var next = false;
            for(rule in rules) {
                switch(tryRule(rule)) {
                    case Done:
                        return { html: html.toString(), rest: code };
                    case Matched:
                        next = true;
                    case NotMatched:
                }
                if(next) break;
            }
            if(!next) {
                html.add(StringTools.htmlEscape(code.substr(0, 1)));
                code = code.substr(1);
            }
        }
        // This statement is unreachable, but makes the compiler happy.
        return null;
    }
    
    // Highlights one token (or list of tokens)
    private static function markup(code: String, type: String) {
        if(type.length == 0) return StringTools.htmlEscape(code);
        return "<span class=\"code-" + type + "\">" +
            StringTools.htmlEscape(code) +
            "</span>";
            
    }
    
    // Generate line numbers
    private static function lineNumbers(code: String): String {
        var ns = code.split("\n");
        var rs = code.split("\r");
        var lines = if(ns.length > rs.length) ns else rs;
        var count = lines.length;
        var last = lines.pop();
        if(last != null && (last.length == 0 || last == "\n" || last == "\r")) {
            count -= 1;
        }
        var html = new StringBuf();
        html.add("<div class=\"code-line-numbers\" name=\"code-line-numbers\">");
        for(i in 0...count) {
            if(i != 0) html.add("\n");
            html.add(i + 1);
        }
        html.add("</div>");
        return html.toString();
    }
    
    // Common patterns
    private static var patterns = {
        ignorable: ~/^[ \t\r\n]+/,
        tripleString: ~/^(["]{3}(["]{0,2}[^\\"]|\\.)*["]{3})/,
        doubleString: ~/^(["]([^\\"]|\\.)*["])/,
        singleString: ~/^([']([^'\\]|['][']|\\.)*['])/,
        number: ~/^(0x[0-9a-fA-F]+|([0-9]+([.][0-9]+)?([eE][+-]?[0-9]+)?)[a-zA-Z]?)/,
        dollarIdentifier: ~/^([$][a-zA-Z0-9_]*)/,
        identifier: ~/^([a-zA-Z_][a-zA-Z0-9_]*)/,
        upperIdentifier: ~/^([A-Z][a-zA-Z0-9_]*)/,
        lowerIdentifier: ~/^([a-z_][a-zA-Z0-9_]*)/,
        docCommentBegin: ~/^\/\*\*/,
        docCommentEnd: ~/^\*\//,
        blockComment: ~/^([\/][*]([^*]|[*][^\/])*[*][\/])/,
        lineComment: ~/^([\/][\/][^\r\n]*(\r\n|\r|\n)?)/,
        entity: ~/^([&][^;]+[;])/,
    };
    
    // Common rules
    private static var common = {
        ignorable:
            Flat("", patterns.ignorable),
        docComment: 
            Nested("doc-comment", 
                Flat("comment", patterns.docCommentBegin), 
                Flat("comment", patterns.docCommentEnd)
            ),
        blockComment:
            Flat("comment", patterns.blockComment),
        lineComment:
            Flat("comment", patterns.lineComment),
        dashComment:
            Flat("comment", ~/^([-][-][^\n]*)/),
        dashBlockComment:
            Flat("comment", ~/^([{][-]([^-]|[-][^}])*[-][}])/),
        hashComment:
            Flat("comment", ~/^([#][^\n\r]*)/),
        number:
            Flat("number", patterns.number),
        tripleString:
            Flat("string", patterns.tripleString),
        doubleString:
            Flat("string", patterns.doubleString),
        singleString:
            Flat("string", patterns.singleString),
        functionName:
            Flat("", ~/^([a-zA-Z_][a-zA-Z0-9_]*\s*[(])/),
        regex:
            Flat("string", ~/^\~\/([^\\\/]|\\.)*\/[a-zA-Z]*/),
    };
    
    // Highlighing rules, one for each language
    // Note that the types are also the css class postfixes,
    // for example "keyword" is of class "code-keyword". CSS:
    //     .code { ... }
    //     .code-keyword { ... }
    // The regular expressions should start with ^. They 
    // should also match most of the valid source code, since
    // the default coloring when no patterns match is very
    // slow. That's all, get started already!
    private static var languages = [
        {
            names: ["xml-attributes"],
            rules: [
                common.ignorable,
                Flat("type", ~/^[a-zA-Z0-9_.-]+/),
                common.doubleString, common.singleString
            ],
        },
        {
            names: ["html", "xhtml", "xml"],
            rules: [
                common.ignorable,
                Flat("comment", ~/^(<[!]--([^-]|[-][^-]|[-][-][^>])*-->)/),
                Flat("variable", ~/^(<[!]\[CDATA\[([^\]]|\][^\]]|\]\][^>])*\]\]>)/i),
                Flat("keyword", ~/^(<[%]([^%]|[%][^>])*[%]>)/),
                Nested("css", 
                    Nested("xml-attributes", 
                        Flat("keyword", ~/^<\s*style\b/i), 
                        Flat("keyword", ~/^>/)
                    ),
                    Flat("keyword", ~/^<\s*\/\s*style\s*>/i)
                ),
                Nested("javascript", 
                    Nested("xml-attributes", 
                        Flat("keyword", ~/^<\s*script\b/i), 
                        Flat("keyword", ~/^>/)
                    ),
                    Flat("keyword", ~/^<\s*\/\s*script\s*>/i)
                ),
                Nested("php", 
                    Flat("keyword", ~/^<[?](php[0-9]*)?/i), 
                    Flat("keyword", ~/^[?]>/)
                ),
                Nested("xml-attributes", 
                    Flat("keyword", ~/^<\s*[a-zA-Z0-9_.-]+/), 
                    Flat("keyword", ~/^>/)
                ),
                Flat("keyword", ~/^(<\s*\/\s*[a-zA-Z0-9_.-]+)\s*(>)/),
                Flat("variable", patterns.entity),
                Flat("", ~/^[^<&]+/),
            ],
        },    
        {
            names: ["css"],
            rules: [
                common.ignorable,
                Flat("variable", ~/^([a-zA-Z-]+[:])/),
                Flat("number", ~/^([#][0-9a-fA-F]{6}|[0-9]+[a-zA-Z%]*)/),
                Flat("type", ~/^([#.:]?[a-zA-Z>-][a-zA-Z0-9>-]*)/),
                Flat("keyword", ~/^(url|rgb|rect|inherit)\b/),
                Flat("comment", ~/^(<!--|-->)/),
                common.blockComment,
            ],
        },    
        {
            names: ["wikitalis", "wiki"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(\\[a-zA-Z]+)/),
                Flat("keyword", ~/^(\{|\})/),
                Flat("", ~/^[^\\{}]+/),
            ],
        },    
        {
            names: ["ebnf", "bnf"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(\:\:\=|\[|\]|\{|\})/),
                Flat("type", ~/^(<[a-zA-Z0-9 _-]+>)/),
                Flat("comment", ~/^([?][^?]*[?])/),
                common.doubleString,
                Flat("string", patterns.identifier),
            ],
        },    
        {
            names: ["doc-comment"],
            rules: [
                common.ignorable,
                Flat("type", ~/^[@][a-zA-Z0-9_-]+/),
                Flat("variable", ~/^[<]\/?[a-zA-Z0-9_.-]+[^>]*[>]/),
                Flat("comment", ~/^([^@<*\r\n]+|.)/),
            ],
        },    
        {
            names: ["php"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(and|or|xor|__FILE__|exception|__LINE__|array|as|break|case|class|const|continue|declare|default|die|do|echo|else|elseif|empty|enddeclare|endfor|endforeach|endif|endswitch|endwhile|eval|exit|extends|for|foreach|function|global|if|include|include_once|isset|list|new|print|require|require_once|return|static|switch|unset|use|var|while|__FUNCTION__|__CLASS__|__METHOD__|final|php_user_filter|interface|implements|instanceof|public|private|protected|abstract|clone|try|catch|throw|cfunction|old_function|this|final|__NAMESPACE__|namespace|goto|__DIR__)\b/),
                Flat("keyword", ~/^(<\?(php[0-9]*)?\b|\?>)/),
                common.functionName,
                Flat("variable", patterns.dollarIdentifier),
                common.docComment, common.blockComment, common.lineComment,
                common.number, common.doubleString, common.singleString,
                Flat("", ~/^[a-zA-Z0-9]+/),
            ],
        },  
        {
            names: ["javascript", "jscript", "js"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(abstract|boolean|break|byte|case|catch|char|class|const|continue|debugger|default|delete|do|double)\b/),
                Flat("keyword", ~/^(else|enum|export|extends|false|final|finally|float|for|function|goto|if|implements|import|in)\b/),
                Flat("keyword", ~/^(instanceof|int|interface|long|native|new|null|package|private|protected|public|return|short|static|super)\b/),
                Flat("keyword", ~/^(switch|synchronized|this|throw|throws|transient|true|try|typeof|var|void|volatile|while|with)\b/),
                Flat("type", patterns.entity),
                common.functionName,
                Flat("variable", ~/^[a-zA-Z_$][a-zA-Z0-9_]*/),
                Flat("comment", ~/^(<!--|-->)/),
                common.docComment, common.blockComment, common.lineComment,
                common.number, common.doubleString, common.singleString,
            ],
        },
        {
            names: ["perl"],
            rules: [
                common.ignorable,
                Flat("string", ~/^(m|q|qq|qw|qx)\/([^\\\/]|\\.)*\/[a-zA-Z]*/),
                Flat("string", ~/^(y|tr|s)\/([^\\\/]|\\.)*\/([^\\\/]|\\.)*\/[a-zA-Z]*/),
                Flat("string", ~/^\/(([^\s\/\\]|\\.)([^\\\/]|\\.)*)?\/[a-zA-Z]*/),
                Flat("keyword", ~/^(abs|accept|alarm|Answer|Ask|atan2|bind|binmode|bless|caller|chdir|chmod|chomp|Choose|chop|chown|chr|chroot|close|closedir|connect|continue|cos|crypt|dbmclose|dbmopen|defined|delete|die|Directory|do|DoAppleScript|dump)\b/),
                Flat("keyword", ~/^(each|else|elsif|endgrent|endhostent|endnetent|endprotoent|endpwent|eof|eval|exec|exists|exit|exp|FAccess|fcntl|fileno|find|flock|for|foreach|fork|format|formline)\b/),
                Flat("keyword", ~/^(getc|GetFileInfo|getgrent|getgrgid|getgrnam|gethostbyaddr|gethostbyname|gethostent|getlogin|getnetbyaddr|getnetbyname|getnetent|getpeername|getpgrp|getppid|getpriority|getprotobyname|getprotobynumber|getprotoent|getpwent|getpwnam|getpwuid|getservbyaddr|getservbyname|getservbyport|getservent|getsockname|getsockopt|glob|gmtime|goto|grep)\b/),
                Flat("keyword", ~/^(hex|hostname|if|import|index|int|ioctl|join|keys|kill|last|lc|lcfirst|length|link|listen|LoadExternals|local|localtime|log|lstat|MakeFSSpec|MakePath|map|mkdir|msgctl|msgget|msgrcv|msgsnd|my|next|no|oct|open|opendir|ord)\b/),
                Flat("keyword", ~/^(pack|package|Pick|pipe|pop|pos|print|printf|push|pwd|Quit|quotemeta|rand|read|readdir|readlink|recv|redo|ref|rename|Reply|require|reset|return|reverse|rewinddir|rindex|rmdir)\b/),
                Flat("keyword", ~/^(scalar|seek|seekdir|select|semctl|semget|semop|send|SetFileInfo|setgrent|sethostent|setnetent|setpgrp|setpriority|setprotoent|setpwent|setservent|setsockopt|shift|shmctl|shmget|shmread|shmwrite|shutdown|sin|sleep|socket|socketpair|sort|splice|split|sprintf|sqrt|srand|stat|stty|study|sub|substr|symlink|syscall|sysopen|sysread|system|syswrite)\b/),
                Flat("keyword", ~/^(tell|telldir|tie|tied|time|times|truncate|uc|ucfirst|umask|undef|unless|unlink|until|unpack|unshift|untie|use|utime|values|vec|Volumes|wait|waitpid|wantarray|warn|while|write)\b/),
                common.functionName,
                Flat("variable", ~/^(\@|\$|)[a-zA-Z_][a-zA-Z0-9_]*/),
                common.hashComment,
                common.number, common.doubleString, common.singleString,
            ],
        },
        {
            names: ["ruby"],
            rules: [
                common.ignorable,
                Flat("", ~/^::/),
                Flat("string", ~/^\/(([^\s\/\\]|\\.)([^\\\/]|\\.)*)?\/[a-zA-Z]*/),
                Flat("keyword", ~/^(alias|and|BEGIN|begin|break|case|class|def|defined|do|else|elsif|END|end|ensure|false|for|if|in|module|next|nil|not|or|redo|rescue|retry|return|self|super|then|true|undef|unless|until|when|while|yield)\b/),
                Flat("keyword", ~/^(require|include|raise|public|protected|private|)\b/),
                Flat("string", ~/^:[a-zA-Z_][a-zA-Z0-9_]*/),
                Flat("type", patterns.upperIdentifier),
                common.functionName,
                Flat("variable", ~/^(\@|\$|)[a-zA-Z_][a-zA-Z0-9_]*/),
                common.hashComment,
                common.number, common.doubleString, common.singleString,
            ],
        },
        {
            names: ["c++", "cpp", "c"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(asm|auto|bool|break|case|catch|class|const|const_cast|continue|default|delete|do|double|dynamic_cast|else|enum|explicit|export|extern|false|float|for|friend|goto|if|inline|int|long|mutable|namespace|new|operator|private|protected|public|register|reinterpret_cast|return|short|signed|sizeof|static|static_cast|struct|switch|template|this|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|while)\b/),
                common.functionName,
                Flat("variable", patterns.identifier),
                Flat("type", ~/^#[a-zA-Z0-9_]+([^\r\n\\]|\\(\r\n|\r|\n|.))*/),
                common.docComment, common.blockComment, common.lineComment,
                common.number, common.doubleString, common.singleString,
            ],
        },
        {
            names: ["c#", "csharp", "c-sharp", "cs"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(abstract|event|new|struct|as|explicit|null|switch|base|extern|object|this|bool|false|operator|throw|break|finally|out|true|byte|fixed|override|try|case|float|params|typeof|catch|for|private|uint|char|foreach|protected|ulong|checked|goto|public|unchecked|class|if|readonly|unsafe|const|implicit|ref|ushort|continue|in|return|using|decimal|int|sbyte|virtual|default|interface|sealed|volatile|delegate|internal|short|void|do|is|sizeof|while|double|lock|stackalloc|else|long|static|enum|namespace|string)\b/),
                common.functionName,
                Flat("variable", patterns.identifier),
                common.docComment, common.blockComment, common.lineComment,
                common.number, common.doubleString, common.singleString,
            ],
        },
        {
            names: ["java"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(abstract|assert|break|case|catch|class|continue|default|do|else|enum|extends|final|finally|for|if|implements|import|instanceof|interface|native|new|package|private|protected|public|return|static|strictfp|super|switch|synchronized|this|throw|throws|transient|try|volatile|while|true|false|null)\b/),
                Flat("type", ~/^(boolean|byte|char|double|float|int|long|short|void)/),
                Flat("type", patterns.upperIdentifier),
                common.functionName,
                Flat("variable", patterns.lowerIdentifier),
                common.docComment, common.blockComment, common.lineComment,
                common.number, common.doubleString, common.singleString,
            ],
        },    
        {
            names: ["scala"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(true|false|this|super|forSome|type|val|var|with|if|else|while|try|catch|finally|yield|do|for|throw|return|match|new|implicit|lazy|case|override|abstract|final|sealed|private|protected|public|package|import|def|class|object|trait|extends|null)\b/),
                Flat("type", ~/^(boolean|byte|char|double|float|int|long|short|void)/),
                Flat("type", patterns.upperIdentifier),
                common.functionName,
                Nested("xml-attributes", 
                    Flat("keyword", ~/^<\/?[a-zA-Z0-9]+/), 
                    Flat("keyword", ~/^>/)
                ),
                Flat("variable", patterns.lowerIdentifier),
                common.docComment, common.blockComment, common.lineComment,
                common.number, common.doubleString, common.tripleString, common.singleString,
            ],
        },    
        {
            names: ["haxe"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(public|private|package|import|enum|class|interface|typedef|implements|extends|if|else|switch|case|default|for|in|do|while|continue|break|dynamic|untyped|cast|static|inline|extern|override|var|function|new|return|trace|try|catch|throw|this|null|true|false|super|typeof|undefined)\b/),
                Flat("keyword", ~/^(\#((if|elseif)(\s+[a-zA-Z_]+)?|(else|end)))\b/),
                Flat("type", patterns.upperIdentifier),
                common.functionName,
                Flat("variable", patterns.lowerIdentifier),
                common.docComment, common.blockComment, common.lineComment,
                common.number, common.doubleString, common.singleString,
                common.regex,
            ],
        },    
        {
            names: ["python"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(and|del|from|not|while|as|elif|global|or|with|assert|else|if|pass|yield|break|except|import|print|class|exec|in|raise|continue|finally|is|return|def|for|lambda|try|[:])\b/),
                Flat("keyword", ~/^(__[A-Za-z0-9_]+)/),
                common.number, common.tripleString, common.doubleString, common.singleString,
                Flat("string", ~/^((r|u|ur|R|U|UR|Ur|uR)?["]{3}(["]{0,2}[^"])*["]{3})/),
                Flat("string", ~/^((r|u|ur|R|U|UR|Ur|uR)?["][^"]*["])/),
                Flat("string", ~/^((r|u|ur|R|U|UR|Ur|uR)?['][^']*['])/),
                Flat("variable", patterns.lowerIdentifier),
                Flat("type", patterns.upperIdentifier),
                common.hashComment,
            ],
        },
        {
            names: ["droid"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(package|using|where|class|object|interface|enum|methods|pure|do|end)\b/),
                Flat("keyword", ~/^(scope|if|else|elseif|while|for|in|throw|catch|var|val|fun|switch|and|or|not|true|false|none|this)\b/), 
                common.number, common.doubleString, common.singleString,
                Flat("type", patterns.upperIdentifier), 
                common.functionName,
                Flat("variable", ~/^([a-z][a-zA-Z0-9]*)/),
                Nested("doc-comment", 
                    Flat("comment", ~/^##/),
                    Flat("comment", ~/^(\r|\n|\r\n)/)
                ), 
                common.regex,
                common.hashComment,
            ],
        },
        {
            names: ["funk"],
            rules: [
                common.ignorable,
                common.number, common.doubleString, common.singleString,
                Flat("string", ~/^([A-Z][a-zA-Z0-9]*)/),
                Flat("variable", ~/^([a-z][a-zA-Z0-9]*|_)/),
                Nested("funk-pattern", 
                    Flat("", ~/^\|/),
                    Flat("", ~/^\|/)
                ), 
                Nested("funk-pattern", 
                    Flat("", ~/^\:/),
                    null
                ), 
                common.hashComment,
            ],
        },
        {
            names: ["funk-pattern"],
            rules: [
                common.number, common.doubleString, common.singleString,
                Flat("string", ~/^([A-Z][a-zA-Z0-9]*)/),
                Flat("type", ~/^([a-z][a-zA-Z0-9]*|_)/),
                Nested("funk-pattern", 
                    Flat("", ~/^\[/),
                    Flat("", ~/^\]/)
                ), 
                Nested("funk-pattern", 
                    Flat("", ~/^\{/),
                    Flat("", ~/^\}/)
                ), 
                Nested("funk-pattern", 
                    Flat("", ~/^\(/),
                    Flat("", ~/^\)/)
                ), 
                Flat("", ~/^(\,|\@)/),
            ],
        },
        {
            names: ["haskell"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(as|of|case|class|data|default|deriving|do|forall|hiding|if|then|else|import|infix|infixl|infixr|instance|let|in|module|newtype|qualified|type|where)/),
                Flat("type", patterns.upperIdentifier),
                Flat("variable", ~/^([a-z][a-zA-Z0-9']*)/),
                common.dashComment, common.dashBlockComment,
                common.number, common.doubleString
            ]
        },
        {
            names: ["tex", "latex"],
            rules: [
                common.ignorable,
                Flat("keyword", ~/^(\{|\}|\[|\]|\$|\&)/),
                Flat("keyword", ~/^(\\[a-zA-Z]*)/),
                Flat("comment", ~/^([%][^\n]*)/),
                Flat("", ~/^[-a-zA-Z0-9_+=* \r\n\t.;,?!'`'|]+/),
            ],
        }
    ];
}

private enum Rule {
    Flat(type: String, pattern: EReg);
    Nested(language: String, start: Rule, end: Rule);
}

private enum Match {
    Done;
    Matched;
    NotMatched;
}

