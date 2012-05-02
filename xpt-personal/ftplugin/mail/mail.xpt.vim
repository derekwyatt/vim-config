XPTemplate priority=personal

XPTinclude
    \ _common/personal

XPT href wrap=link hint=\\<a\ href...
<a href="http://`link^">`title^</a>

XPT p wrap=paragraph hint=<p>...</p>
<p>`paragraph^</p>

XPT i wrap=phrase hint=<i>...</i>
<i>`phrase^</i>

XPT b wrap=phrase hint=<b>...</b>
<b>`phrase^</b>

XPT t wrap=phrase hint=<sometag>...</sometag>
<`tag^>`phrase^</`tag^>

XPT pre hint=<pre\ class="brush:...">
<pre class="brush:`scala^">
`cursor^
</pre>
