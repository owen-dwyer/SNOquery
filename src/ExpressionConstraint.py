class ExpressionConstraint:
    def getString(self, bracket=True):
        if bracket:
            return '( ' + self.string + ' )'
        else:
            return self.string
    
    # Resolve a mixed list of strings and expressionConstraints into a single list of strings
    def argsToStrings(self, args):
        arg_strings = []
        for a in args:
            if isinstance(a, str):
                arg_strings = arg_strings + [a]
            elif isinstance(a, expressionConstraint):
                arg_strings = arg_strings + [a.getString()]

        return arg_strings

class RefinedExpressionConstraint( ExpressionConstraint ):
    # subExpressionConstraint ws ":" ws eclRefinement
    pass
class CompoundExpressionConstraint( ExpressionConstraint ):
    pass
class DottedExpressionConstraint( ExpressionConstraint ):
    # subExpressionConstraint 1*(ws dottedExpressionAttribute)
    pass
class SubExpressionConstraint( ExpressionConstraint ):
    pass




class ConjunctionExpressionConstraint( CompoundExpressionConstraint ):
    # subExpressionConstraint 1*(ws conjunction ws subExpressionConstraint)
    def __init__(self, *args):
        # Convert arguments to strings
        arg_strings = self.argsToStrings(args)
        self.string = (' '+CONJUCTION+' ').join(arg_strings)
                
            

class DisjunctionExpressionConstraint( CompoundExpressionConstraint ):
    # subExpressionConstraint 1*(ws disjunction ws subExpressionConstraint)
    def __init__(self, *args):
        # Convert arguments to strings
        arg_strings = self.argsToStrings(args)
        self.string = (' '+DISJUNCTION+' ').join(arg_strings)

class ExclusionExpressionConstraint( CompoundExpressionConstraint ):
    # subExpressionConstraint ws exclusion ws subExpressionConstraint
    def __init__(self, x, y):
        if (isinstance(x, ExpressionConstraint) ):
            x = x.getString()
        if (isinstance(y, ExpressionConstraint) ):
            y = y.getString()

        self.string = x + ' ' + EXCLUSION + ' ' + y

    pass

EXCLUSION = 'MINUS'
CONJUCTION = 'AND'
DISJUNCTION = 'OR'


ecl_and = ConjunctionExpressionConstraint
ecl_or = DisjunctionExpressionConstraint