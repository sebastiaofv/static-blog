#!/bin/bash

# Build script for simple markdown based website.
# Write a head.html and foot.html, which will wrap each page generated from your
# markdown files.

# Remove html files from the _site directory
rm _site/*.html

# Create an empty file for the listing page.
#echo > listing.md

# Prep index for listing to be appended
cat index.md > index_tmp.md

# Get all of the Markdown files in the posts folder.
files=`ls -v posts/*.md`
echo "Markdown files: " $files

for md_file in $files
do
    # Strip '.md' from the file name.
    file_base=`basename $md_file .md`

    # Get the post creation date from the "date:" metadata on top
    #lastmodified=`date -d @$(stat -c %Y $md_file ) "+%Y-%m-%d %H:%M"`
    created=`sed -n -e 's/^.*date: //p' $md_file`

    # Get the title from the "title:" metadata on top
    doc_title=`sed -n -e 's/^.*title: //p' $md_file` 
    
    # Write this page to the site map, ignoring any that don't have a title.
    if [[ -n "$doc_title" ]]
    then
        printf "$created --- [$doc_title]($file_base.html)\n\n" >> index_tmp.md
    fi
    
    cp templates/post_head.html templates/post_head_tmp.html
    sed -i "s/{TITLE}/$doc_title/g" templates/post_head_tmp.html

    # Generate HTML version of post
    pandoc $md_file > body.html
    cat templates/post_head_tmp.html body.html templates/tail.html > tmp.html
    mv tmp.html _site/$file_base.html
    rm body.html
    rm templates/post_head_tmp.html
done

pandoc index_tmp.md > index_tmp.html
cat templates/head.html index_tmp.html templates/tail.html > index.html
sed -i "s/{TITLE}/Homepage/g" index.html

mv index.html _site/index.html
rm index_tmp.html
rm index_tmp.md


