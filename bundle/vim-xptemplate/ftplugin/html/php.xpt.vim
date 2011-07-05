" These snippets work only in html context of php file
if &filetype != 'php'
    finish
endif

XPTemplate priority=lang-2

" this is html-scope variable independent
if exists( 'php_noShortTags' )
    XPTvar $PHP_TAG php
else
    XPTvar $PHP_TAG
endif


XPT shebang " #!/usr/bin/env php
#!/usr/bin/env php

..XPT

XPT sb alias=shebang


XPT php " <?$PHP_TAG ?>
<?`$PHP_TAG^ `cursor^ ?>

XPT pe " <?= ?>
<?=`cursor^?>



