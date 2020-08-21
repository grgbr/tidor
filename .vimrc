" Find tag files recursively and register them to vim tag handling by setting
" the tags option.
set notagrelative
let tag_files = glob("`find out/$(make show-platform | tr '-' '/') -name tags -print`")
let &tags .= "," . substitute(tag_files, "\n", ",", "g")

" Find cscope database recursively and register them to cscope handling
set nocscoperelative
let builddir = glob("out/" . "`make show-platform | tr '-' '/'`" . "/build")
let cscope_files = glob("`find out/$(make show-platform | tr '-' '/') -name cscope.out -printf '%h\n'`")
" For each found cscope file, replace build directory path component with it
" corresponding source directory path component, i.e:
"   /home/grb/dev/icfw/out/cometh4582a_v100/devel/build/bridgehigh/cscope.out
" Will give:
"   /home/grb/dev/icfw/src/bridgehigh/cscope.out
for f in split(cscope_files, "\n")
"	let srcdir = fnamemodify(f, ":p:h:s?" . builddir . "?src/?")
"	execute("cscope add " . f . " " . srcdir)
	execute("cscope add " . f)
endfor

"let builddir = fnamemodify(glob("out/`make show-platform | tr '-' '/'`/build"), ':p')
"let cscope_file = glob(builddir . "cpss/cscope.out")
"let cscope_srcdir = system("cat " . glob(builddir . "cpss/cscope.srcdir"))
"let cscope_srcdir = fnamemodify(cscope_srcdir, ':p')
"echo cscope_file
"echo cscope_srcdir
"echo "cscope add " . cscope_file . " " . cscope_srcdir
"execute("cscope add " . cscope_file)
