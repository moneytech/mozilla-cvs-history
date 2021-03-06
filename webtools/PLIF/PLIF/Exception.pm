# -*- Mode: perl; tab-width: 4; indent-tabs-mode: nil; -*-
#
# This file is MPL/GPL dual-licensed under the following terms:
# 
# The contents of this file are subject to the Mozilla Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and
# limitations under the License.
#
# The Original Code is PLIF 1.0.
# The Initial Developer of the Original Code is Ian Hickson.
#
# Alternatively, the contents of this file may be used under the terms
# of the GNU General Public License Version 2 or later (the "GPL"), in
# which case the provisions of the GPL are applicable instead of those
# above. If you wish to allow use of your version of this file only
# under the terms of the GPL and not to allow others to use your
# version of this file under the MPL, indicate your decision by
# deleting the provisions above and replace them with the notice and
# other provisions required by the GPL. If you do not delete the
# provisions above, a recipient may use your version of this file
# under either the MPL or the GPL.

package PLIF::Exception;
use strict;
use vars qw(@ISA @EXPORT);
use overload '""' => 'stringify', 'cmp' => 'comparison';
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(try catch with fallthrough except otherwise finally syntaxError evalString);
my %EVALS = ();

# Make warnings 
$SIG{__WARN__} = sub {
    my $message = shift;
    $message =~ s/\(eval ([0-9]+)\)/ exists $EVALS{$1} ? $EVALS{$1} : $1 /gose;
    $message =~ s/, <DATA> line [0-9]+//gos; # clean up irrelevant useless junk...
    $message =~ s/, at EOF//gos;
    warn $message; # reraise the updated message
};


# To use this package, you first have to define your own exceptions:
#
#     package MyException; @ISA = qw(PLIF::Exception);
#     package MemoryException; @ISA = qw(PLIF::Exception);
#     package IOException; @ISA = qw(PLIF::Exception);
#
# You can then use them as follows (the order must be as follows):
#
#     try {
#         # some code that might raise an exception:
#         raise MyException if $condition;
#         # ... more code ...
#     } catch MemoryException with {
#         my($exception) = @_;
#         raise $exception; # reraise
#     } catch IOException with {
#         my($exception) = @_;
#         return fallthrough; # fall through to the following handlers
#         fallthrough; # alternative form if the directive is the last one in the block
#     } catch DBError with {
#         my($exception) = @_;
#     } except {
#         my($exception) = @_;
#         # catch all, called if the exception wasn't handled
#     } otherwise {
#         # only executed if no exception was raised
#     } finally {
#         # always called after try block and any handlers
#     };
#
# You can also raise exceptions as warnings by doing:
#
#     report MyException;
#
# The report method also returns a valid exception, should you wish to
# later raise it for real.
#
# If you want to evaluate a string, call evalString($string,
# $filename). This will take a note of the eval number for stack
# traces and warnings. All warnings in blocks evaluated by this will
# be updated automatically.

sub evalString($$) {
    my($string, $filename) = @_;
    my $evalID;
    my $test = eval "sub { (undef eq 0) }";
    local $^W = 1;
    local $SIG{__WARN__} = sub { $_[0] =~ m/^Use of uninitialized value in string eq at \(eval ([0-9]+)\) line 1/os; $evalID = $1; };
    &$test();
    $EVALS{++$evalID} = $filename;
    # print STDERR "evaluating eval $evalID = $EVALS{$evalID}\n";
    eval $string;
    if ($@ ne '') {
        $@ =~ s/\n$//os; # lose the trailing newline for now
        $@ =~ s/( at \(eval [0-9]+\) line [0-9]+, (?:at EOF|<DATA> line [0-9]+))\n/$1; also, /gos; # string multiple errors into one
        $@ =~ s/"\n/"; also, /gos; # same
        $@ =~ s/, <DATA> line [0-9]+//gos; # clean up irrelevant useless junk...
        $@ =~ s/, at EOF//gos; # same
        $@ =~ s/$/\n/os; # put the trailing newline back
    }
}

# constants for stringifying exceptions
sub seMaxLength() { 80 }
sub seMaxSubLength() { 20 }
sub seMaxArguments() { 10 }
sub seMaxDepth() { 2 }
sub seEllipsis() { '...' }

sub syntaxError($;$) {
    my($message, $offset) = @_;
    $offset = 0 unless defined($offset);
    my($package, $filename, $line) = caller(1 + $offset);
    $filename =~ s/\(eval ([0-9]+)\)/ exists $EVALS{$1} ? $EVALS{$1} : $1 /ose;
    die "$message at $filename line $line\n";
}

sub getFrames() {
    package DB;
    my @frames;
    my $index = 0;
    while (my @data = caller($index++)) {
        # expand knows eval numbers (max one per frame, so /ose not /gose)
        $data[1] =~ s/\(eval ([0-9]+)\)/ exists $EVALS{$1} ? $EVALS{$1} : $1 /ose;
        # push frame onto stack
        push(@frames, {
            'package' => $data[0],
            'filename' => $data[1],
            'line' => $data[2],
            'subroutine' => $data[3], # set to '(eval)' for eval, require, and use statements
            'hasargs' => $data[4],
            'wantarray' => $data[5],
            'evaltext' => $data[6], # undef for eval {}, EXPR for eval EXPR
            'is_require' => $data[7], # true if eval was caused by require or use statement
            'arguments' => [@DB::args], # take a copy since the same array is used each time
        });        
    }
    return @frames;
}

sub stacktrace() {
    my $count;
    my $filename;
    my $line;
    my @stacktrace;
    foreach my $frame (getFrames) {
        if ($frame->{'filename'} ne __FILE__) {
            if ($count++) {
                push(@stacktrace, $frame);
            } else {
                $filename = $frame->{'filename'};
                $line = $frame->{'line'};
            }
        }
    }
    return $filename, $line, \@stacktrace;
}

sub create {
    my $class = shift;
    return bless({@_}, $class);
}

sub init {
    my($exception, @data) = @_;
    if (not ref($exception)) {
        # in case we were called as a constructor
        syntaxError 'odd number of elements passed to exception constructor', 1 if @data % 2;
        $exception = $exception->create(@data);
    }
    # set up the exception and return it
    if (not defined($exception->{'stacktrace'})) {
        my($filename, $line, $stacktrace) = stacktrace;
        $exception->{'filename'} = $filename;
        $exception->{'line'} = $line;
        $exception->{'stacktrace'} = $stacktrace;
    }
    if (defined($exception->{'message'})) {
        # expand knows eval numbers (could be several, so /gose not /ose)
        $exception->{'message'} =~ s/\(eval ([0-9]+)\)/ exists $EVALS{$1} ? $EVALS{$1} : $1 /gose;
        $exception->{'message'} =~ s/\.?\n$/, reraised/os;
    }
    return $exception;
}

sub raise {
    my($exception, @data) = @_;
    syntaxError "Syntax error in \"raise\": \"$exception\" is not a PLIF::Exception class", 1 unless UNIVERSAL::isa($exception, __PACKAGE__);
    die $exception->init(@data);
}

# similar to raise, but only warns instead of dying
sub report {
    my($exception, @data) = @_;
    syntaxError "Syntax error in \"report\": \"$exception\" is not a PLIF::Exception class", 1 unless UNIVERSAL::isa($exception, __PACKAGE__);
    $exception = $exception->init(@data);
    local $SIG{__WARN__} = 'DEFAULT'; # don't want this warning going through our processor
    warn $exception;
    return $exception;
}

sub try(&;$) {
    my($code, $continuation) = @_;
    if (defined($continuation) and
        (not ref($continuation) or not $continuation->isa('PLIF::Exception::Internal::Continuation'))) {
        syntaxError 'Syntax error in continuation of "try" clause';
    }
    my $context = wantarray;
    my @result; # for array context
    my $result; # for scalar context
    eval {
        if ($context) {
            # array context
            @result = &$code;
        } elsif (defined($context)) {
            # scalar context
            $result = &$code;
        } else {
            # void context
            &$code;
        }
    };
    if (defined($continuation)) {
        $continuation->handle($@);
    }
    return $context ? @result : $result;
}

sub catch($$) {
    my($class, $continuation, @more) = @_;
    syntaxError "Syntax error in \"catch ... with\" clause: \"$class\" is not a PLIF::Exception class" unless $class->isa('PLIF::Exception');
    if (not defined($continuation) or
        not ref($continuation) or
        not $continuation->isa('PLIF::Exception::Internal::With')) {
        syntaxError 'Syntax error: missing "with" operator in "catch" clause';
    }
    { local $" = '\', \'';
      syntaxError "Syntax error after \"catch ... with\" clause ('@_'?)" if (scalar(@more)); }
    $continuation->{'resolved'} = 1;
    my $handler = $continuation->{'handler'};
    $continuation = $continuation->{'continuation'};
    if (not defined($continuation)) {
        $continuation = PLIF::Exception::Internal::Continuation->create();
    }
    unshift(@{$continuation->{'handlers'}}, [$class, $handler]);
    return $continuation;
}

sub with(&;$) {
    my($handler, $continuation) = @_;
    if (defined($continuation) and
        (not ref($continuation) or
         not $continuation->isa('PLIF::Exception::Internal::Continuation'))) {
        syntaxError 'Syntax error after "catch ... with" clause';
    }
    return PLIF::Exception::Internal::With->create($handler, $continuation);
}

sub except(&;$) {
    my($handler, $continuation) = @_;
    if (defined($continuation) and
        (not ref($continuation) or
         not $continuation->isa('PLIF::Exception::Internal::Continuation') or
         defined($continuation->{'except'}) or
         scalar(@{$continuation->{'handlers'}}))) {
        syntaxError 'Syntax error after "except" clause';
    }
    if (not defined($continuation)) {
        $continuation = PLIF::Exception::Internal::Continuation->create();
    }
    $continuation->{'except'} = $handler;
    return $continuation;
}

sub otherwise(&;$) {
    my($handler, $continuation) = @_;
    if (defined($continuation) and
        (not ref($continuation) or
         not $continuation->isa('PLIF::Exception::Internal::Continuation') or
         defined($continuation->{'otherwise'}) or
         defined($continuation->{'except'}) or
         scalar(@{$continuation->{'handlers'}}))) {
        syntaxError 'Syntax error after "otherwise" clause';
    }
    if (not defined($continuation)) {
        $continuation = PLIF::Exception::Internal::Continuation->create();
    }
    $continuation->{'otherwise'} = $handler;
    return $continuation;
}

sub finally(&;@) {
    my($handler, @continuation) = @_;
    syntaxError 'Missing semicolon after "finally" clause' if (scalar(@continuation));
    my $continuation = PLIF::Exception::Internal::Continuation->create();
    $continuation->{'finally'} = $handler;
    return $continuation;
}

sub fallthrough() {
    return PLIF::Exception::Internal::Fallthrough->create();
}

sub stringify {
    my $self = shift;
    my $value;
    if (defined($self->{'message'})) {
        $value = "$self->{'message'} at $self->{'filename'} line $self->{'line'}\n";
    } else {
        $value = ref($self) . " exception raised at $self->{'filename'} line $self->{'line'}\n";
    }
    $value .= "\nStack Trace:\n";
    foreach my $frame (@{$self->{'stacktrace'}}) {
        my $where;
        if ($frame->{'filename'} =~ m/^\(eval ([0-9]+)\)$/os) {
            $where = "line $frame->{'line'} of eval '...' $1 created in $frame->{'package'} context";
        } else {
            $where = "$frame->{'filename'} line $frame->{'line'}";
        }
        if ($frame->{'subroutine'} eq 'PLIF::Exception::try') {
            $value .= "  try { ... } in $where";
        } elsif ($frame->{'subroutine'} =~ m/^(.+)::__ANON__$/os) {
            $value .= "  sub { ... } in $1 in $where";
        } elsif ($frame->{'subroutine'} eq '(eval)') {
            if ($frame->{'is_require'}) {
                $value .= "  require $frame->{'evaltext'} in $where";
            } elsif (defined($frame->{'evaltext'})) {
                my $eval = $frame->{'evaltext'};
                $eval =~ s/([\\\'])/\\$1/gos;
                if (length($eval) > seMaxLength) {
                    substr($eval, seMaxLength) = seEllipsis;
                }
                $value .= "  eval '$eval' in $where";
            } else {
                $value .= "  eval { ... } in $where";
            }
        } elsif ($frame->{'hasargs'}) {
            my @arguments = arguments(0, @{$frame->{'arguments'}});
            local $" = ', ';
            $value .= "  $frame->{'subroutine'}(@arguments) called from $where";
        } else {
            $value .= "  $frame->{'subroutine'}() called from $where";
        }
        $value .= "\n";
    }
    $value .= "\nEnvironment:\n";
    foreach my $key (sort keys %ENV) {
        $value .= "  $key = $ENV{$key}\n";
    }
    return $value;
}

sub arguments {
    return "..."; # disable argument stringification
    my($depth, @values) = @_;
    ++$depth;
    my @arguments;
    foreach my $value (@values) {
        my $argument;
        if (ref($value)) {
            # some object
            if (UNIVERSAL::isa($value, 'UNIVERSAL')) {
                $argument = ref($value) . ' object';
            } elsif (ref($value) eq 'ARRAY' and $depth < seMaxDepth) {
                my @items = arguments($depth, @$value);
                local $" = ', ';
                $argument = "[@items]";
            } elsif (ref($value) eq 'HASH' and $depth < seMaxDepth) {
                my @items;
                my $count = 0;
                foreach my $key (sort keys %$value) {
                    if (++$count > seMaxArguments) {
                        push(@items, seEllipsis);
                        last;
                    }
                    my($keyName, $valueName) = arguments($depth, $key, $value->{$key});
                    push(@items, "$keyName => $valueName");
                }
                local $" = ', ';
                $argument = "{@items}";
            } elsif (ref($value) eq 'SCALAR') {
                my @items = arguments($depth, $$value);
                $argument = "\\@items";
            } elsif (ref($value) eq 'CODE') {
                $argument = 'sub { ... }';
            } else {
                # deeply nested HASH or ARRAY, probably
                $argument = ref($value);
            }
        } else {
            # scalar
            if (not defined($value)) {
                $argument = 'undef';
            } elsif ($value =~ m/^-?[0-9]+(?:\.[0-9]+)?$/os) {
                $argument = $value;
            } else {
                $argument = $value;
                $argument =~ s/([\\\'])/\\$1/gos;
                $argument =~ s/\n/\\n/gos;
                $argument =~ s/([\x00-\x1f])/'\\x' . sprintf('%04x', ord($1))/gose;
                if (length($argument) > seMaxLength) {
                    substr($argument, seMaxLength) = seEllipsis;
                }
                $argument = "'$argument'";
            }
        }
        push(@arguments, $argument);
    }
    if (@arguments > seMaxArguments) {
        @arguments = (@arguments[0..seMaxArguments], seEllipsis);
    }
    return @arguments;
}

sub comparison {
    my($a, $b, $reverse) = @_;
    my $result = ((defined($a) and defined($b)) ? ("$a" cmp "$b") :
                  defined($a) ? 1 :
                  defined($b) ? -1 :
                  0);
    return $reverse ? !$result : $result;
}


package PLIF::Exception::Internal::Continuation;

sub wrap($) {
    my($exception) = @_;
    if ($exception ne '') {
        if (not ref($exception) or
            not $exception->isa('PLIF::Exception')) {
            # an unexpected exception
            # note: if you want pretty syntax errors back from eval
            # "...", use evalString, not eval followed by raising $@.
            # expand knows eval numberss (could be several, so /gose not /ose)
            $exception =~ s/\(eval ([0-9]+)\)/ exists $EVALS{$1} ? $EVALS{$1} : $1 /gose;
            $exception =~ s/, <DATA> line [0-9]+//gos; # clean up irrelevant useless junk
            $exception =~ s/, at EOF+//gos;
            $exception =~ s/\.?\n$/, reraised/os;
            $exception = PLIF::Exception->create('message' => $exception);
        }
        if (not exists $exception->{'stacktrace'}) {
            my($filename, $line, $stacktrace) = PLIF::Exception::stacktrace;
            $exception->{'filename'} = $filename;
            $exception->{'line'} = $line;
            $exception->{'stacktrace'} = $stacktrace;
        }
    } else {
        $exception = undef;
    }
    return $exception;
}

sub create {
    my($package, $filename, $line) = caller(1);
    return bless {
        'handlers' => [],
        'except' => undef,
        'otherwise' => undef,
        'finally' => undef,
        'filename' => $filename,
        'line' => $line,
        'resolved' => 0,
    }, $_[0];
}

sub handle {
    my $self = shift;
    my($exception) = @_;
    $self->{'resolved'} = 1;
    my $reraise = undef;
    $exception = wrap($exception);
    handler: while (1) {
        if (defined($exception)) {
            foreach my $handler (@{$self->{'handlers'}}) {
                if ($exception->isa($handler->[0])) {
                    my $result = eval { &{$handler->[1]}($exception) };
                    $reraise = wrap($@);
                    if (not defined($result) or # $result is not defined if $reraise is now defined
                        not ref($result) or
                        not UNIVERSAL::isa($result, 'PLIF::Exception::Internal::Fallthrough')) {
                        last handler;
                    }
                    # else, it's the result of an "fallthrough" function call
                    $result->{'resolved'} = 1;
                }
            }
            if (defined($self->{'except'})) {
                my $result = eval { &{$self->{'except'}}($exception) };
                $reraise = wrap($@);
            } else {
                # fallthrough exception
                $reraise = $exception;
            }
        } else {
            if (defined($self->{'otherwise'})) {
                my $result = eval { &{$self->{'otherwise'}}($exception) };
                $reraise = wrap($@);
            }
        }
        last;
    }
    if (defined($self->{'finally'})) {
        &{$self->{'finally'}}();
    }
    if (defined($reraise)) {
        # note that if the finally block raises an exception, we drop this one
        $reraise->raise();
    }
}

sub DESTROY {
    my $self = shift;
    return if $self->{'resolved'};
    my $parts = 0x00;
    $parts |= 0x01 if scalar(@{$self->{'handlers'}});
    $parts |= 0x02 if defined($self->{'except'});
    $parts |= 0x04 if defined($self->{'finally'});
    my $messages = ["Incorrectly used PLIF::Exception::Internal::Continuation object at $self->{'filename'} line $self->{'line'}\n",
                    "Incorrectly used \"catch ... with\" clause at $self->{'filename'} line $self->{'line'}\n",
                    "Incorrectly used \"except\" clause at $self->{'filename'} line $self->{'line'}\n",
                    "Incorrectly used \"catch ... with\" and \"except\" clauses at $self->{'filename'} line $self->{'line'}\n",
                    "Incorrectly used \"finally\" clause at $self->{'filename'} line $self->{'line'}\n",
                    "Incorrectly used \"catch ... with\" and \"finally\" clauses at $self->{'filename'} line $self->{'line'}\n",
                    "Incorrectly used \"except\" and \"finally\" clauses at $self->{'filename'} line $self->{'line'}\n",
                    "Incorrectly used \"catch ... with\", \"except\", and \"finally\" clauses at $self->{'filename'} line $self->{'line'}\n",];
    warn $messages->[$parts]; # XXX can't raise an exception in a destructor
}


package PLIF::Exception::Internal::With;

sub create {
    my($package, $filename, $line) = caller(1);
    return bless {
        'handler' => $_[1],
        'continuation' => $_[2],
        'filename' => $filename,
        'line' => $line,
        'resolved' => 0,
    }, $_[0];
}

sub DESTROY {
    my $self = shift;
    return if $self->{'resolved'};
    warn "Incorrectly used \"with\" operator at $self->{'filename'} line $self->{'line'}\n"; # XXX can't raise an exception in a destructor
}


package PLIF::Exception::Internal::Fallthrough;

sub create {
    my($package, $filename, $line) = caller(1);
    return bless {
        'filename' => $filename,
        'line' => $line,
        'resolved' => 0,
    }, $_[0];
}

sub DESTROY {
    my $self = shift;
    return if $self->{'resolved'};
    warn "Incorrectly used \"fallthrough\" function at $self->{'filename'} line $self->{'line'}\n"; # XXX can't raise an exception in a destructor
}


package PLIF::Exception::Alarm; use vars qw(@ISA); @ISA = qw(PLIF::Exception);
