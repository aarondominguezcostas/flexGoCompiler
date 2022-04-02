/*carga de librerias*/
%{
#include "definiciones.h"
#include "tablaSimbolos.h"
#include "errores.h"
%}
%option noyywrap

/* delimitadores y espacios */
DELIM       [ \t\n]
ESPACIO     {DELIM}+

/* otros datos que se van a usar despues, letras, digitos ... */
LETRA       [A-Za-z]
DIGITO      [0-9]
BINARIO     [01]
OCTAL       [0-7]
HEXADECIMAL [0-9A-Fa-f]

/* comentarios */
COMMENTLINE \/\/[^\n]*     
COMMENTBLOCK \/\*(.|\n)*\*\/


/* strings */
UNICODE_CHAR .
LITTLE_U_VALUE \\u{HEXADECIMAL}{4}
BIG_U_VALUE    \\U{HEXADECIMAL}{8}
ESCAPED_CHAR    \\[{LETRA}\\\'\"]

OCTAL_BYTE_VALUE \\{OCTAL}{3}
HEX_BYTE_VALUE    \\x{HEXADECIMAL}{2}

UNICODE_VALUE  {LITTLE_U_VALUE}|{BIG_U_VALUE}|{ESCAPED_CHAR}|{UNICODE_CHAR}
BYTE_VALUE     {OCTAL_BYTE_VALUE}|{HEX_BYTE_VALUE}


RAW_STRING   \'({UNICODE_CHAR}|\n)+\'
INTERPRETED_STRING \"({UNICODE_VALUE}|{BYTE_VALUE})+\"

STRING      {RAW_STRING}|{INTERPRETED_STRING}

/* operadores */
OPERATOR    (\&\^\=|\&\^|\>\>\=|\%\=|\:\=|\<\<\=|\/\=|\<\-|\>\=|\*\=|\^\=|\<\=|\-\=|\|\=|\!\=|\+\=|\&\=|\+{1,2}|\&{1,2}|\={1,2}|\(|\)|\-{1,2}|\|{1,2}|\<{1,2}|\>{1,2}|\[|\]|\{|\}|\*|\^|\/|\%|\!|\.\.\.|\,|\.|\:|\;|\~)

/* ID -> palabras reservadas e identificadores */
ID          ({LETRA}|\_)({LETRA}|{DIGITO}|\_)*


/* los numeros se definen como en la documentacion de go: */
DECIMALES   {DIGITO}(\_?{DIGITO})*
BINARIOS    {BINARIO}(\_?{BINARIO})*
OCTALES     {OCTAL}(\_?{OCTAL})*
HEXADECIMALES {HEXADECIMAL}(\_?{HEXADECIMAL})*

NUM_DECIMAL  {DIGITO}(\_?{DECIMALES})?
NUM_BINARIO  0(b|B)\_?{BINARIOS}
NUM_OCTAL    0(o|O)\_?{OCTALES}
NUM_HEXADECIMAL 0(x|X)\_?{HEXADECIMALES}

ENTERO      ({NUM_DECIMAL}|{NUM_BINARIO}|{NUM_OCTAL}|{NUM_HEXADECIMAL})

/*con los numeros en punto flotante se hace lo mismo*/
EXP_DECIMAL   (e|E)(\+|\-)?{DECIMALES}
DECIMAL_FLOTANTE1      {DECIMALES}\.{DECIMALES}?{EXP_DECIMAL}?
DECIMAL_FLOTANTE2      {DECIMALES}{EXP_DECIMAL}
DECIMAL_FLOTANTE3      \.{DECIMALES}{EXP_DECIMAL}?

DECIMAL_FLOTANTE      ({DECIMAL_FLOTANTE1}|{DECIMAL_FLOTANTE2}|{DECIMAL_FLOTANTE3})

EXPONENTE_HEXADECIMAL (p|P)(\+|\-)?{HEXADECIMALES}
MANTISSA_HEXADECIMAL1  \_?{HEXADECIMALES}\.{HEXADECIMALES}?
MANTISSA_HEXADECIMAL2  \_?{HEXADECIMALES}
MANTISSA_HEXADECIMAL3  \.{HEXADECIMALES}
MANTISSA_HEXADECIMAL    ({MANTISSA_HEXADECIMAL1}|{MANTISSA_HEXADECIMAL2}|{MANTISSA_HEXADECIMAL3})

HEX_FLOTANTE            0(x|X){MANTISSA_HEXADECIMAL}{EXPONENTE_HEXADECIMAL}

FLOAT               ({DECIMAL_FLOTANTE}|{HEX_FLOTANTE})

/* Numeros imaginarios */
IMAGINARIO        ({ENTERO}|{FLOAT})i

%%

{ESPACIO}   /* No se hace nada */
{COMMENTLINE} /* No se hace nada */
{COMMENTBLOCK} /* No se hace nada */

{ID}        {return ID;}
{STRING}    {return STRING;}
{OPERATOR}  {return OPERATOR;}
{ENTERO}    {return INTEGER;}
{FLOAT}     {return FLOAT;}
{IMAGINARIO} {return IMAGINARY;}
.           {return 0;}
<<EOF>>     {return EOFVALUE;}

%%

// se intenta abrir el archivo dado su nombre
void abrirArchivo(char *nombreArchivo){
    FILE *archivo;
    archivo = fopen(nombreArchivo, "r");
    if(archivo == NULL){
        printf("No se pudo abrir el archivo\n");
        exit(1);
    }
    yyin = archivo;
}

void nextComponent(tipoelem *actual){
    actual->valor = yylex();
    strcpy(actual->identificador, yytext);

    if(actual->valor == ID){
        //buscar en la tabla de simbolos
        findElement(actual);
    }else if(actual->valor == 0){
        //componente lexico no reconocido
        showError(8);
    }
}

void cerrarArchivo(){
    fclose(yyin);
}