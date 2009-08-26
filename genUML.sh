haxeumlgen -b "#88B3C1" -c -o docs/uml/ output.xml
cd docs/uml
svn propset svn:mime-type text/html *.html
svn propset svn:mime-type text/png *.png

