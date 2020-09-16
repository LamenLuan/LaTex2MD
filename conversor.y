%{
    #include "conversor.h"
%}
%union {
    char *c;
    struct wordList *l;
    struct ast *a;
}

%token <c> WORD
%token CLASS PACKAGE TITLE AUTHOR START MAKETITLE END CHAPTER
PARAGRAPH BOLD UNDERLINE ITALIC

%type <a> configuration identification documentClass usePackage title 
author main bodyList chapter body text stylizedText
%type <l> wordList
%type <c> wordConcat

%%
latexDocument: configuration identification main {
    callMakeOutput( newAST( $1, newAST($2, $3) ) );
}
;

configuration: documentClass usePackage { $$ = newAST($1, $2); }
    | documentClass
;

identification: title author { $$ = newAST($1, $2); }
    | title
;

title: TITLE '{' wordConcat '}' { $$ = newElement(NULL, $3, Ttitle); }
;

author: AUTHOR '{' wordConcat '}' { $$ = newElement(NULL, $3, Tauthor); }
;

documentClass: CLASS '[' wordList ']' '{' WORD '}' {
        $$ = newElement($3, $6, Tclass);
    }
    | CLASS '{' WORD '}' { $$ = newElement(NULL, $3, Tclass); }
;

usePackage: PACKAGE '[' wordList ']' '{' WORD '}' {
    $$ = newElement($3, $6, Tpackage);
}
    | PACKAGE '{' WORD '}' { $$ = newElement(NULL, $3, Tpackage); }
;

wordList: WORD ',' wordList { $$ = newWordList($1, $3); }
    | WORD { $$ = newWordList($1, NULL); }
;

main: START MAKETITLE bodyList END { $$ = $3; }
;

bodyList: chapter
;

chapter: CHAPTER '{' wordConcat '}' body chapter {
       $$ = newAST( newElement(NULL, $3, Tchapter), newAST($5, $6) );
    }
    | CHAPTER '{' wordConcat '}' { $$ = newElement(NULL, $3, Tchapter); }
;

body: text
    | text body { $$ = newAST($1, $2); }
    | stylizedText body { $$ = newAST($1, $2); }
;

text: PARAGRAPH '{' wordConcat '}' { $$ = newElement(NULL, $3, Tparagraph); }
;

stylizedText: BOLD '{' wordConcat '}' { $$ = newElement(NULL, $3, Tbold); }
    | UNDERLINE '{' wordConcat '}' { $$ = newElement(NULL, $3, Tunderline); }
    | ITALIC '{' wordConcat '}' { $$ = newElement(NULL, $3, Titalic); }
;

wordConcat: WORD wordConcat { strcat($1, " "); strcat($1, $2); $$ = $1; }
    | WORD
;