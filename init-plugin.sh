#!/bin/bash
# Usage: ./foo-bar/init-plugin.sh "Hello World"
# Creates a directory "hello-world" in the current working directory,
# performing substitutions on the scaffold "foo-bar" plugin at https://github.com/xwp/wp-foo-bar

set -e

if [ $# != 1 ]; then
	echo "You must only supply one argument, the plugin name."
	exit 1
fi

name="$1"
if [ -z "$name" ]; then
	echo "Provide name argument"
	exit 1
fi

valid="^[A-Z][a-z0-9]*( [A-Z][a-z0-9]*)*$"
if [[ ! "$name" =~ $valid ]]; then
	echo "Malformed name argument '$name'. Please use title case words separated by spaces. No hyphens."
	exit 1
fi

slug="$( echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/' )"
prefix="$( echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/' )"
namespace="$( echo "$name" | sed 's/ //' )"
class="$( echo "$name" | sed 's/ /_/' )"

cwd="$(pwd)"
cd "$(dirname "$0")"
cd "$cwd"

src_repo="foo-bar"

if [ ! -d "$src_repo" ]; then
	echo "Downloading Foo Bar plugin template"
	wget -O master.tar.gz https://api.github.com/repos/xwp/wp-foo-bar/tarball/master -q
	echo "Extracting Foo Bar plugin template"
	tar -zxvf master.tar.gz --exclude=.git --exclude=.gitignore --exclude=.gitmodules --exclude=dev-lib --exclude=init-plugin.sh --exclude=.jscsrc --exclude=.jshintignore --exclude=.jshintrc --exclude=phpunit.xml.dist > /dev/null
	rm master.tar.gz
	mv xwp-wp-foo-bar-* "$src_repo"
fi

if [ -e "$slug" ]; then
	echo "The $slug directory already exists"
	exit
fi

if [ -e "$slug.tar.gz" ]; then
	echo "Plugin archive is located at:"
	echo "$(pwd)/$slug.tar.gz"
	exit 0
fi

echo "Name: $name"
echo "Slug: $slug"
echo "Prefix: $prefix"
echo "NS: $namespace"
echo "Class: $class"

echo "Copying $src_repo into $slug"
cp -r "$src_repo" "$slug"

echo "Moving into $slug"
cd "$slug"

echo "Removing symlinks"
find * -type l -delete

echo "Renaming Foo Bar to $name"
mv foo-bar.php "$slug.php"
cd tests
mv test-foo-bar.php "test-$slug.php"
cd ..

grep -lrI --null "Foo Bar" * | xargs -0 sed -i'' -e "s/Foo Bar/$name/g"
grep -lrI --null "foo-bar" * | xargs -0 sed -i'' -e "s/foo-bar/$slug/g"
grep -lrI --null "foo_bar" * | xargs -0 sed -i'' -e "s/foo_bar/$prefix/g"
grep -lrI --null "FooBar" * | xargs -0 sed -i'' -e "s/FooBar/$namespace/g"
grep -lrI --null "Foo_Bar" * | xargs -0 sed -i'' -e "s/Foo_Bar/$class/g"

echo "Plugin is located at:"
pwd

echo "Moving up one directory outside of $slug"
cd ..

echo "Compressing $slug"
tar czf "$slug".tar.gz "$slug"
rm -r "$slug"

echo "Plugin archive is located at:"
echo "$(pwd)/$slug.tar.gz"
