XPTemplate priority=lang

let s:f = g:XPTfuncs()


XPTinclude
      \ _common/common


XPT branch " [branch "..."]
[branch "`branchName^"]`remote...{{^
    remote = `remote^`}}^`merge...{{^
    merge = refs/heads/`branchName^`}}^ 

XPT remote " [remote "..."]
[remote "`remoteName^"]
    url = `fetchUrl^
    fetch = `fetchRef^ 

XPT user " Basic user configuration
[user]
    name = `$Author^
    email = `$Email^

