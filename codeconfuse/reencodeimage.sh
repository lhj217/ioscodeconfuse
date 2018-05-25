#
if [ ! -f /usr/local/bin/convert ]; then
  	brew install imagemagick
fi
#brew install imagemagick
#find . -iname "*.png" -exec echo {} \; -exec convert {} {} \;
find $1 -iname "*.png" -exec echo {} \; -exec convert {} -quality 95 {} \;
