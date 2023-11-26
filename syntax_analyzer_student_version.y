%{
#include <iostream>
#include <fstream>
#include"symbol_info.h"

#define YYSTYPE symbol_info*

int yyparse(void);
int yylex(void);

extern FILE *yyin;


ofstream outlog;

int lines = 1;

// declare any other variables or functions needed here

%token LCURL RCURL SEMICOLON CONST_INT ID
class StatementList {
private:
    std::vector<std::string> statements;

public:
    void addStatement(const std::string& statement) {
        statements.push_back(statement);
    }

    int getNumStatements() const {
        return statements.size();
    }

    std::string getStatement(int index) const {
        if (index >= 0 && index < statements.size()) {
            return statements[index];
        }
        return ""; // Or throw an exception for an invalid index
    }
};
%}

%token IF ELSE FOR

%%

start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1->getname()+"\n"+$2->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"program");
	}
	| unit
	{

	}
	;
unit : var_declaration
	{
		outlog << "At line no: " << lines << " unit : var_declaration " << endl << endl;
        outlog << "int " << $1->getname() << ";" << endl << endl;
	}
    | func_definition
    {
		
	}
    ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
		{	
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl<<endl;
			outlog<<"int "<<$2->getname()<<"()\n"<<$6->getname()<<endl<<endl;
		
			$$ = new symbol_info("int "+$2->getname()+"()\n"+$6->getname(), "func_def");
		}
		| type_specifier ID LPAREN RPAREN compound_statement
		{
			
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<"()\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+"()\n"+$5->getname(),"func_def");	
		}
 		;

parameter_list : parameter_list COMMA type_specifier ID
		{
			outlog << "At line no: " << lines << " parameter_list : parameter_list COMMA type_specifier ID" << endl << endl;
    		outlog << $1->getname() << "," << $3->getname() << " " << $4->getname() << endl << endl;
    		$$ = new symbol_info($1->getname() + "," + $3->getname() + " " + $4->getname(), "parameter_list");
		}
		| parameter_list COMMA type_specifier
		{
			outlog << "At line no: " << lines << " parameter_list : parameter_list COMMA type_specifier" << endl << endl;
    		outlog << $1->getname() << "," << $3->getname() << endl << endl;
    		$$ = new symbol_info($1->getname() + "," + $3->getname(), "parameter_list");

		}
 		| type_specifier ID
 		{
			outlog << "At line no: " << lines << " parameter_list : type_specifier ID" << endl << endl;
    		outlog << $1->getname() << " " << $2->getname() << endl << endl;
    		$$ = new symbol_info($1->getname() + " " + $2->getname(), "parameter_list");

		}
		| type_specifier
		{
			outlog << "At line no: " << lines << " parameter_list : type_specifier" << endl << endl;
    		outlog << $1->getname() << endl << endl;
		}
 		;
compound_statement : LCURL statements RCURL
		{ 
 			outlog << "At line no: " << lines << " compound_statement : LCURL statements RCURL" << endl << endl;
    		outlog << "{\n";
    		for (int i = 0; i < $2->getNumStatements(); ++i) {
        	outlog << "\t" << $2->getStatement(i) << ";\n"; // Get and log each statement
    		}
    		outlog << "}\n";
		}
		| LCURL RCURL
		{ 
			outlog << "At line no: " << lines << " compound_statement : LCURL RCURL" << endl << endl;
    		outlog << "{ }\n";
		}
		;
var_declaration : type_specifier declaration_list SEMICOLON
		{
			outlog << "At line no: " << lines << " var_declaration : type_specifier declaration_list SEMICOLON" << endl << endl;
    		outlog << $1->getname();
        	for (int i = 0; i < $2->getSize(); ++i) {
            	outlog << " " << $2->getSymbolAt(i)->getname();
            	if (i < $2->getSize() - 1) {
                	outlog << ",";
				}
			}
			outlog << ";" << endl << endl;
		}
		;

type_specifier : INT
		{
			outlog << "At line no: " << lines << " type_specifier : INT " << endl << endl;
        	outlog << "int" << endl << endl;
        	$$ = new symbol_info("int", "type", nullptr);
		}
		| FLOAT
		{
			outlog << "At line no: " << lines << " type_specifier : FLOAT " << endl << endl;
        	outlog << "float" << endl << endl;
        	$$ = new symbol_info("float", "type", nullptr);
		}
		| VOID
		{
			outlog << "At line no: " << lines << " type_specifier : VOID " << endl << endl;
        	outlog << "void" << endl << endl;
        	$$ = new symbol_info("void", "type", nullptr);
		}
		;
declaration_list : declaration_list COMMA id_name
		{
			outlog << "At line no: " << lines << " declaration_list : declaration_list COMMA ID" << endl << endl;
    		outlog << $1->getname() << "," << $3->getname() << endl << endl;
    		$$ = $1;
    		$$->addSymbol($3);
		}
		| declaration_list COMMA id_name LTHIRD CONST_INT RTHIRD //array after some declaration
		{
			outlog << "At line no: " << lines << " declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD" << endl << endl;
			$$ = $1;
			$$->addSymbol($3);
		}
		| id_name
		{
			outlog << "At line no: " << lines << " declaration_list : ID" << endl << endl;
    		outlog << $1->getname() << endl << endl;
    		$$ = new symbol_info($1->getname(), "declaration_list");
    		$$->addSymbol($1);

		}
		| id_name LTHIRD CONST_INT RTHIRD //array
		{
			outlog << "At line no: " << lines << " declaration_list : ID LTHIRD CONST_INT RTHIRD" << endl << endl;
			$$ = new symbol_info($1->getname(), "declaration_list");
			$$->addSymbol($1);

		}
		;
statements : statement
		{
			$$ = $1;
    		$1->addStatement($2->getname());
		}
		| statements statement
		{
			$$ = new StatementList();
    		$$->addStatement($1->getname());
		}
		;
statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  	{
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3->getname()<<$4->getname()<<$5->getname()<<")\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("for("+$3->getname()+$4->getname()+$5->getname()+")\n"+$7->getname(),"stmnt");
	  	}

statement : var_declaration
	  {
	    	outlog << "At line no: " << lines << " var_declaration" << endl << endl;
            outlog << $1->getDetails() << ";" << endl << endl;
	  }
	  | expression_statement
	  {
	    	outlog << "At line no: " << lines << " expression_statement" << endl << endl;
            outlog << $1->getExpression() << ";" << endl << endl;

	  }
	  | compound_statement
	  {
	    	outlog << "At line no: " << lines << " compound_statement" << endl << endl;
            outlog << $1->getStatements() << endl;
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
	    	outlog << "At line no: " << lines << " FOR loop" << endl << endl;
            outlog << "for (" << $3->getExpression() << "; " << $4->getExpression() << "; " << $5->getExpression() << ")" << endl;
            outlog << $7->getStatement() << endl;
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
	    	outlog << "At line no: " << lines << " IF statement" << endl << endl;
            outlog << "if (" << $3->getExpression() << ")" << endl;
            outlog << $5->getStatement() << endl;
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
	    	outlog << "At line no: " << lines << " IF-ELSE statement" << endl << endl;
            outlog << "if (" << $3->getExpression() << ")" << endl;
            outlog << $5->getStatement() << endl;
            outlog << "else" << endl;
            outlog << $7->getStatement() << endl;

	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
	    	outlog << "At line no: " << lines << " WHILE loop" << endl << endl;
            outlog << "while (" << $3->getExpression() << ")" << endl;
            outlog << $5->getStatement() << endl;
	  }
	  | PRINTF LPAREN id_name RPAREN SEMICOLON
	  {
	    	outlog << "At line no: " << lines << " PRINTF statement" << endl << endl;
            outlog << "printf(" << $3->getName() << ");" << endl << endl;
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog << "At line no: " << lines << " RETURN statement" << endl << endl;
            outlog << "return " << $2->getExpression() << ";" << endl << endl;
	  }
	  ;
expression_statement : SEMICOLON
			{
				outlog << "At line no: " << lines << " Empty Expression Statement" << endl << endl;
	        }			
			| expression SEMICOLON 
			{
				outlog << "At line no: " << lines << " Expression Statement" << endl << endl;
    			outlog << $1->getExpression() << ";" << endl << endl;
	        }
			;
variable : id_name 	
     {
	    $$ = $1;
	 }	
	 | id_name LTHIRD expression RTHIRD 
	 {
	 	
	 }
	 ;

expression : logic_expression //expr can be void
	   {
	    	
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	
	   }
	   ;

logic_expression : rel_expression //lgc_expr can be void
	     {
	    	
	     }	
		 | rel_expression LOGICOP rel_expression 
		 {
	    	
	     }	
		 ;
rel_expression	: simple_expression //rel_expr can be void
		{
	    	$$ = $1;
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog << "At line no: " << lines << " rel_expression : simple_expression RELOP simple_expression" << endl << endl;
    		outlog << $1->getname() << " " << $2 << " " << $3->getname() << endl << endl;
			int leftValue = $1->getValue(); 
    		int rightValue = $3->getValue();
			bool result;
    		if ($2 == "<") {
        	result = leftValue < rightValue;
    		} else if ($2 == ">") {
        	result = leftValue > rightValue;
    		} else if ($2 == "<=") {
        	result = leftValue <= rightValue;
    		} else if ($2 == ">=") {
        	result = leftValue >= rightValue;
    		} else if ($2 == "==") {
        	result = leftValue == rightValue;
    		} else if ($2 == "!=") {
        	result = leftValue != rightValue;
    		}
			outlog << "Result: " << (result ? "true" : "false") << endl;
			$$ = new symbol_info(result ? "true" : "false", "rel_expr");
	    }
		;

simple_expression : term //simp_expr can be void /// WILL THERE
          {
	    	
	      }
		  | simple_expression ADDOP term 
		  {
	    	
	      }
		  ;            

term :	unary_expression //term can be void because of un_expr->factor
     {
	    	
	 }
     |  term MULOP unary_expression
     {
	    	
	 }
     ;
unary_expression : ADDOP unary_expression
		{
	    	outlog << "At line no: " << lines << " unary_expression : ADDOP unary_expression" << endl << endl;
    		outlog << $1->getname() << $2->getname() << endl << endl;
    		$$ = new symbol_info($1->getname() + $2->getname(), "unary_expression");
	    }
		| NOT unary_expression 
		{
	    	outlog << "At line no: " << lines << " unary_expression : NOT unary_expression" << endl << endl;
    		outlog << $1->getname() << $2->getname() << endl << endl;
    		$$ = new symbol_info($1->getname() + $2->getname(), "unary_expression");
	    }
		| factor 
		{
	    	outlog << "At line no: " << lines << " unary_expression : factor" << endl << endl;
    		outlog << $1->getname() << endl << endl;
    		$$ = new symbol_info($1->getname(), "unary_expression");
	    }
		;

factor : variable  // factor can be void
    {
	    outlog << "At line no: " << lines << " factor : variable" << endl << endl;
    	outlog << $1->getname() << endl << endl;
    	$$ = new symbol_info($1->getname(), "factor");
	}
	| id_name LPAREN argument_list RPAREN
	{
	   
	}
	| LPAREN expression RPAREN
	{
	   
	}
	| CONST_INT 
	{
	    outlog << "At line no: " << lines << " factor : CONST_INT" << endl << endl;
    	outlog << $1->getname() << endl << endl;
    	$$ = new symbol_info($1->getname(), "factor");
	}
	| CONST_FLOAT
	{
	    
	}
	| variable INCOP 
	{
	    
	}
	| variable DECOP
	{
	    
	}
	;
argument_list : arguments        
			  {
					$$ = $1;
			  }
			  |
			  {
			  }
			  ;

arguments : arguments COMMA logic_expression
		{
			outlog << $1->getname() << ", " << $3->getname() << endl;
    		$$ = new symbol_info($1->getname() + ", " + $3->getname(), "arguments");
		}
	    | logic_expression
	    {
			outlog << $1->getname() << endl;
    		$$ = new symbol_info($1->getname(), "arguments");
		}
	    ;

%%

int main(int argc, char *argv[])
{
	if(argc != 2) 
	{
        std::cout << "Please input file name" << std::endl;
        return 0;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("my_log.txt", ios::trunc);
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}
    int ch;
    while ((ch = fgetc(yyin)) != EOF) 
	{
        if (ch == '\n') {
            lines++; // Increment line count when encountering a newline
        }
    }
	yyparse();
	
	std::cout << "Number of lines in the file: " << lines << std::endl;
	
	outlog.close();
	
	fclose(yyin);
	
	return 0;
}