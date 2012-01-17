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

XPT doc hint=Two\ column\ article\ document
% Configuration Preamble {{{1
\documentclass[letterpaper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{listings}
\usepackage[pdftex]{graphicx}
\usepackage{multicol}
\usepackage{fullpage}
\usepackage{enumerate}
\DeclareGraphicsExtensions{.eps,.pdf,.png}
\usepackage{amsmath,amsthm,amssymb}
\usepackage{float}

% Title {{{1
\title{`title^}
\author{Derek Wyatt (dwyatt@rim.com)}
\date{\today}
\begin{document}
\maketitle

% Abstract {{{1
\begin{abstract}
\end{abstract}

% Table of Contents {{{1
\tableofcontents
\setcounter{tocdepth}{3}
\begin{center}
\line(1,0){400}
\end{center}

% Document {{{1
\begin{multicols}{2}
`cursor^
\end{multicols}
\end{document}
% vim:sw=2 ft=tex fdl=0 fdm=marker:

