XPTemplate priority=personal

XPTinclude
    \ _common/personal

XPT tt wrap=text hint=\\texttt{...}
\texttt{`text^}`cursor^

XPT ss hint=\\subsection{...}
\subsection{`^}`cursor^

XPT sss hint=\\subsubsection{...}
\subsubsection{`^}`cursor^

XPT s hint=\\section{...}
\section{`^}`cursor^

XPT code hint=\\begin{lstlisting}...\\end{lstlisting}
\begin{lstlisting}
`cursor^
\end{lstlisting}

XPT fn hint=\\footnote{...}
\footnote{`^}`cursor^

XPT e wrap=text hint=\\emph
\emph{`text^}`cursor^

XPT b wrap=text hint=\\emph
\textbf{`text^}`cursor^

XPT enumerate hint=\\begin{enumerate}...\\end{enumerate}
\begin{enumerate}
\item `cursor^
\end{enumerate}

XPT itemize hint=\\begin{itemize}...\\end{itemize}
\begin{itemize}
\item `cursor^
\end{itemize}

XPT description hint=\\begin{description}...\\end{description}
\begin{description}
\item [`description^] `cursor^
\end{description}

XPT i hint=\\item
\item `cursor^
