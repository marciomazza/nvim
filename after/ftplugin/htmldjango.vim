
" TODO
" for andymass/vim-matchup to work with django template tags
" should work simply by using tweekmonster/django-plus.vim
" based on
" https://github.com/andymass/vim-matchup/issues/240
" https://github.com/tweekmonster/django-plus.vim/blob/master/after/ftplugin/htmldjango.vim#L16
"
let b:match_ignorecase = 1
let b:match_skip = 's:Comment'
let b:match_words = '<:>,' .
      \ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
      \ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
      \ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>,'  .
      \ '{% *if .*%}:{% *else *%}:{% *endif *%},' .
      \ '\%({% *\)\@<=\%(end\)\@!\(\i\+\) .*%}:\%({% *\)\@<=end\1 .*%}'
