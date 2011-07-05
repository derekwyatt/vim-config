XPTemplate priority=lang mark=`~

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL
XPTvar $VOID_LINE     /* void */;
XPTvar $BRif \n

XPTinclude
      \ _common/common
      \ _common/personal


" ========================= Function and Variables =============================


" ================================= Snippets ===================================


XPT eq " \\begin{equation} .. \\end{equation}
\begin{equation}
`cursor~
\end{equation}
..XPT

XPT info " title author date
\title{`title~}
\author{`$author~}
\date{`date()~}
..XPT

XPT doc " begin{document} .. end{document}
\begin{document}
    `cursor~
\end{document}
..XPT

XPT abstract " begin{abstract} .. end{abstract}
\begin{abstract}
    `cursor~
\end{abstract}
..XPT

XPT array " begin{array}{..}... end{array}
\begin{array}{`kind~rcl~}
`what~` `...0~ & `what~` `...0~ \\\\` `...1~
`what~` `...2~ & `what~` `...2~ \\\\` `...1~
\end{array}
..XPT

XPT table " begin{tabular}{..}... end{tabular}
XSET hline..|post=\hline
XSET what*|post=ExpandIfNotEmpty( ' & ', 'what*' )
\begin{tabular}{`kind~|r|c|l|~}
`hline..~
`what*~ \\\\` `...1~
`hline..~
`what*~ \\\\` `...1~
\end{tabular}

..XPT

XPT section " section{..}
\section{`sectionTitle~}
..XPT

XPT frame " \begin{frame}{..} .. \end{frame}
\begin{frame}{`title~}
    `cursor~
\end{frame}

XPT block " \begin{block}{..} .. \end{block}
\begin{block}{`title~}
    `cursor~
\end{block}

XPT frac " frac{..}{..}
\frac{`a~}{`b~}
..XPT

XPT lbl " label{..}
\label{`cursor~}
..XPT

XPT ref " ref{..}
\ref{`cursor~}
..XPT

XPT integral " int_..^..
\int_`begin~^`end~{`cursor~}
..XPT

XPT lim " lim_....
\lim_{`what~}
..XPT

XPT itemize " begin{itemize} ... end{itemize}
\begin{itemize}
\item `what~~`...~
\item `what~~`...~
\end{itemize}
..XPT

XPT enumerate " begin{enumerate} ... end{enumerate}
\begin{enumerate}
\item `what~~`...~
\item `what~~`...~
\end{enumerate}
..XPT

XPT sqrt " sqrt[..]{..}
\sqrt`n...{{~[`nth~]`}}~{`cursor~}
..XPT

XPT sum " sum{..}~..{}
\sum_{`init~}^`end~{`cursor~}
..XPT

XPT slide " begin{slide} .. end{slide}
\begin{slide}
`cursor~
\end{slide}
..XPT

XPT documentclass " documentclass[..]{..}
XSET kind=Choose(['article','book','report', 'letter','slides'])
\documentclass[`size~11~pt]{`kind~}
..XPT

XPT toc " \tableofcontents
\tableofcontents
..XPT

XPT beg " begin{..} .. end{..}
\begin{`something~}
`cursor~
\end{`something~}
..XPT

XPT columns " \begin{columns}...
\begin{columns}
    \begin{column}[l]{`size~5cm~}
    \end{column}`...~

    \begin{column}[l]{`size~5cm~}
    \end{column}`...~
    `cursor~
\end{columns}
..XPT

XPT enclose_ wraponly=wrapped " \begin{..} SEL \end{..}
\begin{`something~}
    `wrapped~
\end{`something~}

XPT as_ wraponly=wrapped " SEL{..}
\\`wrapped~{`cursor~}
..XPT

XPT with_ wraponly=wrapped " \\.. {SEL}
\\`cursor~{`wrapped~}
..XPT

