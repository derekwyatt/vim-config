XPTemplate priority=personal

XPTinclude
    \ _common/personal

XPT tt wrap=text hint=\\texttt{...}
\texttt{`text^}`cursor^

XPT s hint=\\section{...}
% `title^ {{{1
\section{`title^}
\label{sec:`label^}
`cursor^

XPT ss hint=\\subsection{...}
% - `title^ {{{1
\subsection{`title^}
\label{sec:`label^}
`cursor^

XPT sss hint=\\subsubsection{...}
% -- `title^ {{{1
\subsubsection{`title^}
\label{sec:`label^}
`cursor^

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

XPT table hint=\\begin{tabular}...\\end{tabular}
\begin{center}
\begin{tabular}{`columnspec^}
`^
\end{tabular}
\end{center}

XPT figure hint=\\begin{figure*}...\\end{figure*}
\begin{figure*}
\centering
\includegraphics[scale=0.5, viewport = 0 0 0 0]{target/`name^.pdf}
\caption{`cursor^}
\label{fig:`name^}
\end{figure*}

XPT eqnarray hint=\\begin{eqnarray*}...\\end{eqnarray*}
\begin{eqnarray*}
`cursor^
\end{eqnarray*}
