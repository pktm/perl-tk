#!/usr/bin/perl -w
# -*- perl -*-

# This file is a Tcl script to test the code in the file tkText.c.
# This file is organized in the standard fashion for Tcl tests.
#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994-1996 Sun Microsystems, Inc.
# Copyright (c) 1998-1999 by Scriptics Corporation.
# All rights reserved.
#
# RCS: @(#) $Id: text.test,v 1.46 2006/10/17 10:21:50 patthoyts Exp $
#
# Translated to Perl/Tk by Slaven Rezic

use strict;
no warnings 'qw';

use Tk;

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

plan tests => 119;

use_ok('Tk::Text');

my $mw = MainWindow->new;
$mw->geometry("+10+10");

# Create entries in the option database to be sure that geometry options
# like border width have predictable values.

$mw->optionAdd('*Text.borderWidth', 2);
$mw->optionAdd('*Text.highlightThickness', 2);
$mw->optionAdd('*Text.font', 'Courier -12');

my $t = $mw->Text(qw(Name t -width 20 -height 10));
isa_ok($t, "Tk::Text");
isa_ok($t, "Tk::Widget");
$t->pack(qw(-expand 1 -fill both));
# XXX what's the meaning of:
# pack append . .t {top expand fill}
#?
$t->update;
$t->debug("on");

# The statements below reset the main window;  it's needed if the window
# manager is mwm to make mwm forget about a previous minimum size setting.

$mw->withdraw;
$mw->minsize(1,1);
$mw->positionfrom("user");
$mw->deiconify;

my $te = $t->Entry(qw(Name e));
$te->insert(qw(end abcdefg));
$te->selection(qw(from 0));

$t->insert("1.0", "Line 1
abcdefghijklm
12345
Line 4
bOy GIrl .#@? x_yz
!@#$%
Line 7");

my $t2 = $mw->Text(qw(Name t2));

my @tests =
   (
    [qw(-autoseparators yes 1)], # other booleans in Perl (was: nah)
    [qw(-background #ff00ff #ff00ff <gorp>)],
    [qw(-bd 4 4 foo)],
    [qw(-bg blue blue #xx)],
    #[qw(-blockcursor 0 0 xx)], # XXX not yet implemented???
    [qw(-borderwidth 7 7 ++)],
    [qw(-cursor watch watch lousy)],
    [qw(-exportselection no 0)], # other booleans in Perl (was: maybe) 
    [qw(-fg red red stupid)],
    #[qw(-font fixed fixed {})], # XXX cannot test for returned Font object
    [qw(-foreground #012 #012 bogus)],
    [qw(-height 5 5 bad)],
    [qw(-highlightbackground #123 #123 bogus)],
    [qw(-highlightcolor #234 #234 bogus)],
    [qw(-highlightthickness -2 0 bad)],
    #[qw(-inactiveselectbackground #ffff01234567 #ffff01234567 bogus)], # XXX not yet implemented?
    [qw(-insertbackground green green <bogus>)],
    [qw(-insertborderwidth 45 45 bogus)],
    [qw(-insertofftime 100 100)], # no strict integer check in Perl (was: 2.4)
    [qw(-insertontime 47 47 e1)],
    [qw(-insertwidth 2.3 2 47d)],
    [qw(-maxundo 5 5 noway)],
    [qw(-padx 3.4 3 2.4.)],
    [qw(-pady 82 82 bogus)],
    [qw(-relief raised raised bumpy)],
    [qw(-selectbackground #ffff01234567 #ffff01234567 bogus)],
    [qw(-selectborderwidth 21 21 3x)],
    [qw(-selectforeground yellow yellow #12345)],
    [qw(-spacing1 20 20 1.3x)],
    [qw(-spacing1 -5 0 bogus)],
    [qw(-spacing2 5 5 bogus)],
    [qw(-spacing2 -1 0 bogus)],
    [qw(-spacing3 20 20 bogus)],
    [qw(-spacing3 -10 0 bogus)],
    [qw(-state d disabled foo)],
#    [qw(-tabs), [qw{1i 2i 3i 4i}], [qw{1i 2i 3i 4i}], qw(bad_tabs)], # XXX things seem to screw up...
    #[qw(-tabstyle wordprocessor wordprocessor garbage)], # XXX not yet implemented?
    [qw(-undo 1 1)], # other booleans in Perl (was: eh)
    [qw(-width 73 73)], # no strict integer check in Perl (was: 2.4)
    [qw(-wrap w word bad_wrap)],
   );

foreach my $test (@tests) {
    my $name = $test->[0];
    $t2->configure($name, $test->[1]);
    is_deeply([$t2->cget($name)], [$test->[2]], "cget $name");
    is(($t2->configure($name))[4], $t2->cget($name), "Comparing configure and cget values for $name");
 SKIP: {
	skip("No error test for $name", 1)
	    if !defined $test->[3];
	eval {
	    $t2->configure($name, $test->[3]);
	};
	isnt($@, "", "Got error message for invalid $name");
    }
}

{
    $t2->configure(-takefocus => "any old thing");
    is($t2->cget(-takefocus), q{any old thing}, "text options");

    my @return;

    $t2->configure(-xscrollcommand => "x scroll command");
    @return = $t2->configure(-xscrollcommand);
    isa_ok(pop @return, 'Tk::Callback', "callback not comparable in perl");
    is_deeply([@return],
	      [qw{-xscrollcommand xScrollCommand ScrollCommand}, '']);

    $t2->configure(-yscrollcommand => "test command");
    @return = $t2->configure(-yscrollcommand);
    isa_ok(pop @return, 'Tk::Callback');
    is_deeply([@return],
	      [qw{-yscrollcommand yScrollCommand ScrollCommand}, '']);
}

{
    eval { $t2->destroy } if Tk::Exists($t2);
    eval { $t2 = $mw->Text(-gorp => "nofun") };
    like($@, qr{Bad option `-gorp'}, "Tk_TextCmd procedure");
    ok(!Tk::Exists($t2));
}

{
    eval { $t2->destroy } if Tk::Exists($t2);
    $t2 = $mw->Text(qw(-bd 2 -fg red));
    is($t2->configure(-bd)->[4], 2);
    is($t2->configure(-fg)->[4], 'red');
}

{
    eval { $t2->destroy } if Tk::Exists($t2);
    my $relief = ($Tk::platform eq 'MSWin32' ? 'flat'  :
		  $Tk::platform eq 'aqua'    ? 'solid' : 'raised');
    $t2 = $mw->Text;
    is($t2->tagCget('sel', -relief), $relief);
}

{
    eval { $t2->destroy } if Tk::Exists($t2);
    $t2 = $mw->Text;
    is($t2->Class, 'Text');
}
	      
__END__

test text-3.1 {TextWidgetCmd procedure, basics} {
    list [catch {.t} msg] $msg
} {1 {wrong # args: should be ".t option ?arg arg ...?"}}
test text-3.2 {TextWidgetCmd procedure} {
    list [catch {.t gorp 1.0 z 1.2} msg] $msg
} {1 {bad option "gorp": must be bbox, cget, compare, configure, count, debug, delete, dlineinfo, dump, edit, get, image, index, insert, mark, peer, replace, scan, search, see, tag, window, xview, or yview}}

test text-4.1 {TextWidgetCmd procedure, "bbox" option} {
    list [catch {.t bbox} msg] $msg
} {1 {wrong # args: should be ".t bbox index"}}
test text-4.2 {TextWidgetCmd procedure, "bbox" option} {
    list [catch {.t bbox a b} msg] $msg
} {1 {wrong # args: should be ".t bbox index"}}
test text-4.3 {TextWidgetCmd procedure, "bbox" option} {
    list [catch {.t bbox bad_mark} msg] $msg
} {1 {bad text index "bad_mark"}}

test text-5.1 {TextWidgetCmd procedure, "cget" option} {
    list [catch {.t cget} msg] $msg
} {1 {wrong # args: should be ".t cget option"}}
test text-5.2 {TextWidgetCmd procedure, "cget" option} {
    list [catch {.t cget a b} msg] $msg
} {1 {wrong # args: should be ".t cget option"}}
test text-5.3 {TextWidgetCmd procedure, "cget" option} {
    list [catch {.t cget -gorp} msg] $msg
} {1 {unknown option "-gorp"}}
test text-5.4 {TextWidgetCmd procedure, "cget" option} {
    .t configure -bd 17
    .t cget -bd
} {17}
.t configure -bd [lindex [.t configure -bd] 3]

test text-6.1 {TextWidgetCmd procedure, "compare" option} {
    list [catch {.t compare a b} msg] $msg
} {1 {wrong # args: should be ".t compare index1 op index2"}}
test text-6.2 {TextWidgetCmd procedure, "compare" option} {
    list [catch {.t compare a b c d} msg] $msg
} {1 {wrong # args: should be ".t compare index1 op index2"}}
test text-6.3 {TextWidgetCmd procedure, "compare" option} {
    list [catch {.t compare @x == 1.0} msg] $msg
} {1 {bad text index "@x"}}
test text-6.4 {TextWidgetCmd procedure, "compare" option} {
    list [catch {.t compare 1.0 < @y} msg] $msg
} {1 {bad text index "@y"}}
test text-6.5 {TextWidgetCmd procedure, "compare" option} {
    list [.t compare 1.1 < 1.0] [.t compare 1.1 < 1.1] [.t compare 1.1 < 1.2]
} {0 0 1}
test text-6.6 {TextWidgetCmd procedure, "compare" option} {
    list [.t compare 1.1 <= 1.0] [.t compare 1.1 <= 1.1] [.t compare 1.1 <= 1.2]
} {0 1 1}
test text-6.7 {TextWidgetCmd procedure, "compare" option} {
    list [.t compare 1.1 == 1.0] [.t compare 1.1 == 1.1] [.t compare 1.1 == 1.2]
} {0 1 0}
test text-6.8 {TextWidgetCmd procedure, "compare" option} {
    list [.t compare 1.1 >= 1.0] [.t compare 1.1 >= 1.1] [.t compare 1.1 >= 1.2]
} {1 1 0}
test text-6.9 {TextWidgetCmd procedure, "compare" option} {
    list [.t compare 1.1 > 1.0] [.t compare 1.1 > 1.1] [.t compare 1.1 > 1.2]
} {1 0 0}
test text-6.10 {TextWidgetCmd procedure, "compare" option} {
    list [.t com 1.1 != 1.0] [.t compare 1.1 != 1.1] [.t compare 1.1 != 1.2]
} {1 0 1}
test text-6.11 {TextWidgetCmd procedure, "compare" option} {
    list [catch {.t compare 1.0 <x 1.2} msg] $msg
} {1 {bad comparison operator "<x": must be <, <=, ==, >=, >, or !=}}
test text-6.12 {TextWidgetCmd procedure, "compare" option} {
    list [catch {.t compare 1.0 >> 1.2} msg] $msg
} {1 {bad comparison operator ">>": must be <, <=, ==, >=, >, or !=}}
test text-6.13 {TextWidgetCmd procedure, "compare" option} {
    list [catch {.t compare 1.0 z 1.2} msg] $msg
} {1 {bad comparison operator "z": must be <, <=, ==, >=, >, or !=}}
test text-6.14 {TextWidgetCmd procedure, "compare" option} {
    list [catch {.t co 1.0 z 1.2} msg] $msg
} {1 {ambiguous option "co": must be bbox, cget, compare, configure, count, debug, delete, dlineinfo, dump, edit, get, image, index, insert, mark, peer, replace, scan, search, see, tag, window, xview, or yview}}

# "configure" option is already covered above

test text-7.1 {TextWidgetCmd procedure, "debug" option} {
    list [catch {.t debug 0 1} msg] $msg
} {1 {wrong # args: should be ".t debug boolean"}}
test text-7.2 {TextWidgetCmd procedure, "debug" option} {
    list [catch {.t de 0 1} msg] $msg
} {1 {ambiguous option "de": must be bbox, cget, compare, configure, count, debug, delete, dlineinfo, dump, edit, get, image, index, insert, mark, peer, replace, scan, search, see, tag, window, xview, or yview}}
test text-7.3 {TextWidgetCmd procedure, "debug" option} {
    .t debug true
    .t deb
} 1
test text-7.4 {TextWidgetCmd procedure, "debug" option} {
    .t debug false
    .t debug
} 0
.t debug

test text-8.1 {TextWidgetCmd procedure, "delete" option} {
    list [catch {.t delete} msg] $msg
} {1 {wrong # args: should be ".t delete index1 ?index2 ...?"}}
test text-8.2 {TextWidgetCmd procedure, "delete" option} {
    list [catch {.t delete a b c} msg] $msg
} {1 {bad text index "a"}}
test text-8.3 {TextWidgetCmd procedure, "delete" option} {
    list [catch {.t delete @x 2.2} msg] $msg
} {1 {bad text index "@x"}}
test text-8.4 {TextWidgetCmd procedure, "delete" option} {
    list [catch {.t delete 2.3 @y} msg] $msg
} {1 {bad text index "@y"}}
test text-8.5 {TextWidgetCmd procedure, "delete" option} {
    .t configure -state disabled
    .t delete 2.3
    .t g 2.0 2.end
} abcdefghijklm
.t configure -state normal
test text-8.6 {TextWidgetCmd procedure, "delete" option} {
    .t delete 2.3
    .t get 2.0 2.end
} abcefghijklm
test text-8.7 {TextWidgetCmd procedure, "delete" option} {
    .t delete 2.1 2.3
    .t get 2.0 2.end
} aefghijklm
test text-8.8 {TextWidgetCmd procedure, "delete" option} {
    # All indices are checked before we actually delete anything
    list [catch {.t delete 2.1 2.3 foo} msg] $msg \
	    [.t get 2.0 2.end]
} {1 {bad text index "foo"} aefghijklm}
set prevtext [.t get 1.0 end-1c]
test text-8.9 {TextWidgetCmd procedure, "delete" option} {
    # auto-forward one byte if the last "pair" is just one
    .t delete 1.0 end; .t insert 1.0 "foo\nabcdefghijklm"
    .t delete 2.1 2.3 2.3
    .t get 1.0 end-1c
} foo\naefghijklm
test text-8.10 {TextWidgetCmd procedure, "delete" option} {
    # all indices will be ordered before deletion
    .t delete 1.0 end; .t insert 1.0 "foo\nabcdefghijklm"
    .t delete 2.0 2.3 2.7 2.9 2.4
    .t get 1.0 end-1c
} foo\ndfgjklm
test text-8.11 {TextWidgetCmd procedure, "delete" option} {
    # and check again with even pairs
    .t delete 1.0 end; .t insert 1.0 "foo\nabcdefghijklm"
    .t delete 2.0 2.2 2.7 2.9 2.4 2.5
    .t get 1.0 end-1c
} foo\ncdfgjklm
test text-8.12 {TextWidgetCmd procedure, "delete" option} {
    # we should get the longest range on equal start indices
    .t delete 1.0 end; .t insert 1.0 "foo\nabcdefghijklm"
    .t delete 2.0 2.2 2.0 2.5 2.0 2.3 2.8 2.7
    .t get 1.0 end-1c
} foo\nfghijklm
test text-8.13 {TextWidgetCmd procedure, "delete" option} {
    # we should get the longest range on equal start indices
    .t delete 1.0 end; .t insert 1.0 "foo\nabcdefghijklm"
    .t delete 2.0 2.2 1.2 2.6 2.0 2.5
    .t get 1.0 end-1c
} foghijklm
test text-8.14 {TextWidgetCmd procedure, "delete" option} {
    # we should get the longest range on equal start indices
    .t delete 1.0 end; .t insert 1.0 "foo\nabcdefghijklm"
    .t delete 2.0 2.2 2.0 2.5 1.1 2.3 2.8 2.7
    .t get 1.0 end-1c
} ffghijklm
test text-8.15 {TextWidgetCmd procedure, "delete" option} {
    # we should get the watch for overlapping ranges - they should
    # essentially be merged into one span.
    .t delete 1.0 end; .t insert 1.0 "foo\nabcdefghijklm"
    .t delete 2.0 2.6 2.2 2.8
    .t get 1.0 end-1c
} foo\nijklm
test text-8.16 {TextWidgetCmd procedure, "delete" option} {
    # we should get the watch for overlapping ranges - they should
    # essentially be merged into one span.
    .t delete 1.0 end; .t insert 1.0 "foo\nabcdefghijklm"
    .t delete 2.0 2.6 2.2 2.4
    .t get 1.0 end-1c
} foo\nghijklm
.t delete 1.0 end; .t insert 1.0 $prevtext
test text-8.17 {TextWidgetCmd procedure, "replace" option} {
    list [catch {.t replace 1.3 2.3} err] $err
} {1 {wrong # args: should be ".t replace index1 index2 chars ?tagList chars tagList ...?"}}
test text-8.18 {TextWidgetCmd procedure, "replace" option} {
    list [catch {.t replace 3.1 2.3 foo} err] $err
} {1 {Index "2.3" before "3.1" in the text}}
test text-8.19 {TextWidgetCmd procedure, "replace" option} {
    list [catch {.t replace 2.1 2.3 foo} err] $err
} {0 {}}
.t delete 1.0 end; .t insert 1.0 $prevtext
test text-8.20 {TextWidgetCmd procedure, "replace" option with undo} {
    .t configure -undo 0
    .t configure -undo 1
    # Ensure it is treated as a single undo action
    .t replace 2.1 2.3 foo
    .t edit undo
    .t configure -undo 0
    string equal [.t get 1.0 end-1c] $prevtext
} {1}
test text-8.21 {TextWidgetCmd procedure, "replace" option with undo} {
    .t configure -undo 0
    .t configure -undo 1
    .t replace 2.1 2.3 foo
    # Ensure we can override a text widget and intercept undo
    # actions.  If in the future a different mechanism is available
    # to do this, then we should be able to change this test.  The
    # behaviour tested for here is not, strictly speaking, documented.
    rename .t test.t
    set res {}
    proc .t {args} { lappend ::res $args ; uplevel 1 test.t $args }
    .t edit undo
    rename .t {}
    rename test.t .t
    .t configure -undo 0
    set res
} {{edit undo} {delete 2.1 2.4} {mark set insert 2.1} {see insert} {insert 2.1 ef} {mark set insert 2.3} {see insert}}
test text-8.22 {TextWidgetCmd procedure, "replace" option with undo} {
    .t configure -undo 0
    .t configure -undo 1
    # Ensure that undo (even composite undo like 'replace')
    # works when the widget shows nothing useful.
    .t replace 2.1 2.3 foo
    .t configure -start 1 -end 1
    .t edit undo
    .t configure -start {} -end {}
    .t configure -undo 0
    if {![string equal [.t get 1.0 end-1c] $prevtext]} {
	set res [list [.t get 1.0 end-1c] ne $prevtext]
    } else {
	set res 1
    }
} {1}
.t delete 1.0 end; .t insert 1.0 $prevtext
test text-8.23 {TextWidgetCmd procedure, "replace" option with peers, undo} {
    .t configure -undo 0
    .t configure -undo 1
    .t peer create .tt -undo 1
    # Ensure that undo (even composite undo like 'replace')
    # works when the the event took place in one peer, which
    # is then deleted, before the undo takes place in another peer.
    .tt replace 2.1 2.3 foo
    .tt configure -start 1 -end 1
    destroy .tt
    .t edit undo
    .t configure -start {} -end {}
    .t configure -undo 0
    if {![string equal [.t get 1.0 end-1c] $prevtext]} {
	set res [list [.t get 1.0 end-1c] ne $prevtext]
    } else {
        set res 1
    }
} {1}
.t delete 1.0 end; .t insert 1.0 $prevtext
test text-8.24 {TextWidgetCmd procedure, "replace" option with peers, undo} {
    .t configure -undo 0
    .t configure -undo 1
    .t peer create .tt -undo 1
    # Ensure that undo (even composite undo like 'replace')
    # works when the the event took place in one peer, which
    # is then deleted, before the undo takes place in another peer
    # which isn't showing everything.
    .tt replace 2.1 2.3 foo
    set res [.tt get 2.1 2.4]
    .tt configure -start 1 -end 1
    destroy .tt
    .t configure -start 3 -end 4
    # msg will actually be set to a silently ignored error message here,
    # (that the .tt command doesn't exist), but that is not important.
    lappend res [catch {.t edit undo} msg]
    .t configure -undo 0
    .t configure -start {} -end {}
    if {![string equal [.t get 1.0 end-1c] $prevtext]} {
	lappend res [list [.t get 1.0 end-1c] ne $prevtext]
    } else {
	lappend res 1
    }
} {foo 0 1}

.t delete 1.0 end; .t insert 1.0 $prevtext

test text-9.1 {TextWidgetCmd procedure, "get" option} {
    list [catch {.t get} msg] $msg
} {1 {wrong # args: should be ".t get ?-displaychars? ?--? index1 ?index2 ...?"}}
test text-9.2 {TextWidgetCmd procedure, "get" option} {
    list [catch {.t get a b c} msg] $msg
} {1 {bad text index "a"}}
test text-9.3 {TextWidgetCmd procedure, "get" option} {
    list [catch {.t get @q 3.1} msg] $msg
} {1 {bad text index "@q"}}
test text-9.4 {TextWidgetCmd procedure, "get" option} {
    list [catch {.t get 3.1 @r} msg] $msg
} {1 {bad text index "@r"}}
test text-9.5 {TextWidgetCmd procedure, "get" option} {
    .t get 5.7 5.3
} {}
test text-9.6 {TextWidgetCmd procedure, "get" option} {
    .t get 5.3 5.5
} { G}
test text-9.7 {TextWidgetCmd procedure, "get" option} {
    .t get 5.3 end
} { GIrl .#@? x_yz
!@#$%
Line 7
}
.t mark set a 5.3
.t mark set b 5.3
.t mark set c 5.5
test text-9.8 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2 5.7
} {y GIr}
test text-9.9 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2
} {y}
test text-9.10 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2 5.4
} {y }
test text-9.11 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2 5.4 5.4
} {{y } G}
test text-9.12 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2 5.4 5.4 5.5
} {{y } G}
test text-9.13 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2 5.4 5.5 "5.5+5c"
} {{y } {Irl .}}
test text-9.14 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2 5.4 5.4 5.5 end-3c
} {{y } G { }}
test text-9.15 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2 5.4 5.4 5.5 end-3c end
} {{y } G { 7
}}
test text-9.16 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2 5.3 5.4 5.3
} {y}
test text-9.17 {TextWidgetCmd procedure, "get" option} {
    .t index "5.2 +3 indices"
} {5.5}
test text-9.17a {TextWidgetCmd procedure, "get" option} {
    .t index "5.2 +3chars"
} {5.5}
test text-9.17b {TextWidgetCmd procedure, "get" option} {
    .t index "5.2 +3displayindices"
} {5.5}
.t tag configure elide -elide 1
.t tag add elide 5.2 5.4
test text-9.18 {TextWidgetCmd procedure, "get" option} {
    list [catch {.t get 5.2 5.4 5.5 foo} msg] $msg
} {1 {bad text index "foo"}}
test text-9.19 {TextWidgetCmd procedure, "get" option} {
    .t get 5.2 5.4 5.4 5.5 end-3c end
} {{y } G { 7
}}
test text-9.20 {TextWidgetCmd procedure, "get" option} {
    .t get -displaychars 5.2 5.4 5.4 5.5 end-3c end
} {{} G { 7
}}
test text-9.21 {TextWidgetCmd procedure, "get" option} {
    list [.t index "5.1 +4indices"] [.t index "5.1+4d indices"]
} {5.5 5.7}
test text-9.22 {TextWidgetCmd procedure, "get" option} {
    list [.t index "5.1 +4a chars"] [.t index "5.1+4d chars"]
} {5.5 5.7}
test text-9.23 {TextWidgetCmd procedure, "get" option} {
    list [.t index "5.5 -4indices"] [.t index "5.7-4d indices"]
} {5.1 5.1}
test text-9.24 {TextWidgetCmd procedure, "get" option} {
    list [.t index "5.5 -4a chars"] [.t index "5.7-4d chars"]
} {5.1 5.1}
.t window create 5.4
test text-9.25 {TextWidgetCmd procedure, "get" option} {
    list [.t index "5.1 +4indices"] [.t index "5.1+4d indices"]
} {5.5 5.7}
test text-9.25a {TextWidgetCmd procedure, "get" option} {
    list [.t index "5.1 +4a chars"] [.t index "5.1+4d chars"]
} {5.6 5.8}
test text-9.26 {TextWidgetCmd procedure, "get" option} {
    list [.t index "5.5 -4indices"] [.t index "5.7-4d indices"]
} {5.1 5.1}
test text-9.26a {TextWidgetCmd procedure, "get" option} {
    list [.t index "5.6 -4a chars"] [.t index "5.8-4d chars"]
} {5.1 5.1}
.t delete 5.4 
.t tag add elide 5.5 5.6
test text-9.27 {TextWidgetCmd procedure, "get" option} {
    .t get -displaychars 5.2 5.8
} {Grl}
.t tag delete elide
.t mark unset a
.t mark unset b
.t mark unset c
test text-9.2.1 {TextWidgetCmd procedure, "count" option} {
    list [catch {.t count} msg] $msg
} {1 {wrong # args: should be ".t count ?options? index1 index2"}}
test text-9.2.2.1 {TextWidgetCmd procedure, "count" option} {
    list [catch {.t count blah 1.0 2.0} msg] $msg
} {1 {bad option "blah" must be -chars, -displaychars, -displayindices, -displaylines, -indices, -lines, -update, -xpixels, or -ypixels}}
test text-9.2.2 {TextWidgetCmd procedure, "count" option} {
    list [catch {.t count a b} msg] $msg
} {1 {bad text index "a"}}
test text-9.2.3 {TextWidgetCmd procedure, "count" option} {
    list [catch {.t count @q 3.1} msg] $msg
} {1 {bad text index "@q"}}
test text-9.2.4 {TextWidgetCmd procedure, "count" option} {
    list [catch {.t count 3.1 @r} msg] $msg
} {1 {bad text index "@r"}}
test text-9.2.5 {TextWidgetCmd procedure, "count" option} {
    .t count 5.7 5.3
} {-4}
test text-9.2.6 {TextWidgetCmd procedure, "count" option} {
    .t count 5.3 5.5
} {2}
test text-9.2.7 {TextWidgetCmd procedure, "count" option} {
    .t count 5.3 end
} {29}
.t mark set a 5.3
.t mark set b 5.3
.t mark set c 5.5
test text-9.2.8 {TextWidgetCmd procedure, "count" option} {
    .t count 5.2 5.7
} {5}
test text-9.2.9 {TextWidgetCmd procedure, "count" option} {
    .t count 5.2 5.3
} {1}
test text-9.2.10 {TextWidgetCmd procedure, "count" option} {
    .t count 5.2 5.4
} {2}
test text-9.2.17 {TextWidgetCmd procedure, "count" option} {
    list [catch {.t count 5.2 foo} msg] $msg
} {1 {bad text index "foo"}}
.t tag configure elide -elide 1
.t tag add elide 2.2 3.4
.t tag add elide 4.0 4.1
test text-9.2.18 {TextWidgetCmd procedure, "count" option} {
    .t count -displayindices 2.0 3.0
} {2}
test text-9.2.19 {TextWidgetCmd procedure, "count" option} {
    .t count -displayindices 2.2 3.0
} {0}
test text-9.2.20 {TextWidgetCmd procedure, "count" option} {
    .t count -displayindices 2.0 4.2
} {5}
# Create one visible and one invisible window
frame .t.w1
frame .t.w2
.t mark set a 2.2
# Creating this window here means that the elidden text
# now starts at 2.3, but 'a' is automatically moved to 2.3
.t window create 2.1 -window .t.w1
.t window create 3.1 -window .t.w2
test text-9.2.21 {TextWidgetCmd procedure, "count" option} {
    .t count -displayindices 2.0 3.0
} {3}
test text-9.2.22 {TextWidgetCmd procedure, "count" option} {
    .t count -displayindices 2.2 3.0
} {1}
test text-9.2.23 {TextWidgetCmd procedure, "count" option} {
    .t count -displayindices a 3.0
} {0}
test text-9.2.24 {TextWidgetCmd procedure, "count" option} {
    .t count -displayindices 2.0 4.2
} {6}
test text-9.2.25 {TextWidgetCmd procedure, "count" option} {
    .t count -displaychars 2.0 3.0
} {2}
test text-9.2.26 {TextWidgetCmd procedure, "count" option} {
    .t count -displaychars 2.2 3.0
} {1}
test text-9.2.27 {TextWidgetCmd procedure, "count" option} {
    .t count -displaychars a 3.0
} {0}
test text-9.2.28 {TextWidgetCmd procedure, "count" option} {
    .t count -displaychars 2.0 4.2
} {5}
test text-9.2.29 {TextWidgetCmd procedure, "count" option} {
    list [.t count -indices 2.2 3.0] [.t count 2.2 3.0]
} {10 10}
test text-9.2.30 {TextWidgetCmd procedure, "count" option} {
    list [.t count -indices a 3.0] [.t count a 3.0]
} {9 9}
test text-9.2.31 {TextWidgetCmd procedure, "count" option} {
    .t count -indices 2.0 4.2
} {21}
test text-9.2.32 {TextWidgetCmd procedure, "count" option} {
    .t count -chars 2.2 3.0
} {10}
test text-9.2.33 {TextWidgetCmd procedure, "count" option} {
    .t count -chars a 3.0
} {9}
test text-9.2.34 {TextWidgetCmd procedure, "count" option} {
    .t count -chars 2.0 4.2
} {19}
destroy .t.w1
destroy .t.w2
set current [.t get 1.0 end-1c]
.t delete 1.0 end
.t insert end [string repeat "abcde " 50]\n
.t insert end [string repeat "fghij " 50]\n
.t insert end [string repeat "klmno " 50]
test text-9.2.35 {TextWidgetCmd procedure, "count" option} {
    .t count -lines 1.0 end
} {3}
test text-9.2.36 {TextWidgetCmd procedure, "count" option} {
    .t count -lines end 1.0
} {-3}
test text-9.2.37 {TextWidgetCmd procedure, "count" option} {
    list [catch {.t count -lines 1.0 2.0 3.0} res] $res
} {1 {bad option "1.0" must be -chars, -displaychars, -displayindices, -displaylines, -indices, -lines, -update, -xpixels, or -ypixels}}
test text-9.2.38 {TextWidgetCmd procedure, "count" option} {
    .t count -lines end end
} {0}
test text-9.2.39 {TextWidgetCmd procedure, "count" option} {
    .t count -lines 1.5 2.5
} {1}
test text-9.2.40 {TextWidgetCmd procedure, "count" option} {
    .t count -lines 2.5 "2.5 lineend"
} {0}
test text-9.2.41 {TextWidgetCmd procedure, "count" option} {
    .t count -lines 2.7 "1.0 lineend"
} {-1}
test text-9.2.42 {TextWidgetCmd procedure, "count" option} {
    set old_wrap [.t cget -wrap]
    .t configure -wrap none
    set res [.t count -displaylines 1.0 end]
    .t configure -wrap $old_wrap
    set res
} {3}
test text-9.2.43 {TextWidgetCmd procedure, "count" option} {
    .t count -lines -chars -indices -displaylines 1.0 end
} {3 903 903 45}
.t configure -wrap none

# Newer tags are higher priority
.t tag configure elide1 -elide 0
.t tag configure elide2 -elide 1
.t tag configure elide3 -elide 0
.t tag configure elide4 -elide 1

test text-0.2.44.0 {counting with tag priority eliding} {
    .t delete 1.0 end
    .t insert end "hello"
    list [.t count -displaychars 1.0 1.0] \
      [.t count -displaychars 1.0 1.1] \
      [.t count -displaychars 1.0 1.2] \
      [.t count -displaychars 1.0 1.3] \
      [.t count -displaychars 1.0 1.4] \
      [.t count -displaychars 1.0 1.5] \
      [.t count -displaychars 1.0 1.6] \
      [.t count -displaychars 1.0 2.6] \
} {0 1 2 3 4 5 5 6}
test text-0.2.44 {counting with tag priority eliding} {
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide1 1.2 1.4
    .t count -displaychars 1.0 1.5
} {5}
test text-0.2.45 {counting with tag priority eliding} {
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide2 1.2 1.4
    .t count -displaychars 1.0 1.5
} {3}
test text-0.2.46 {counting with tag priority eliding} {
    set res {}
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide2 1.2 1.4
    .t tag add elide1 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide1 1.2 1.4
    .t tag add elide2 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
} {3 3}
test text-0.2.47 {counting with tag priority eliding} {
    set res {}
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide2 1.2 1.4
    .t tag add elide3 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide3 1.2 1.4
    .t tag add elide3 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
} {5 5}
test text-0.2.48 {counting with tag priority eliding} {
    set res {}
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide2 1.2 1.4
    .t tag add elide3 1.2 1.4
    .t tag add elide4 1.2 1.4
    .t tag add elide1 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide1 1.2 1.4
    .t tag add elide4 1.2 1.4
    .t tag add elide2 1.2 1.4
    .t tag add elide3 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
} {3 3}
test text-0.2.49 {counting with tag priority eliding} {
    set res {}
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide2 1.2 1.4
    .t tag add elide3 1.2 1.4
    .t tag add elide1 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide1 1.2 1.4
    .t tag add elide2 1.2 1.4
    .t tag add elide3 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
} {5 5}
test text-0.2.50 {counting with tag priority eliding} {
    set res {}
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide2 1.0 1.5
    .t tag add elide1 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
    lappend res [.t count -displaychars 1.1 1.5]
    lappend res [.t count -displaychars 1.2 1.5]
    lappend res [.t count -displaychars 1.3 1.5]
    .t delete 1.0 end
    .t insert end "hello"
    .t tag add elide1 1.0 1.5
    .t tag add elide2 1.2 1.4
    lappend res [.t count -displaychars 1.0 1.5]
    lappend res [.t count -displaychars 1.1 1.5]
    lappend res [.t count -displaychars 1.2 1.5]
    lappend res [.t count -displaychars 1.3 1.5]
} {0 0 0 0 3 2 1 1}
test text-0.2.51 {counting with tag priority eliding} {
    set res {}
    .t delete 1.0 end
    .t tag configure WELCOME -elide 1
    .t tag configure SYSTEM -elide 0
    .t tag configure TRAFFIC -elide 1
    .t insert end "\n" {SYSTEM TRAFFIC}
    .t insert end "\n" WELCOME
    lappend res [.t count -displaychars 1.0 end]
    lappend res [.t count -displaychars 1.0 end-1c]
    lappend res [.t count -displaychars 1.0 1.2]
    lappend res [.t count -displaychars 2.0 end]
    lappend res [.t count -displaychars 2.0 end-1c]
    lappend res [.t index "1.0 +1 indices"]
    lappend res [.t index "1.0 +1 display indices"]
    lappend res [.t index "1.0 +1 display chars"]
    lappend res [.t index end] 
    lappend res [.t index "end -1 indices"]
    lappend res [.t index "end -1 display indices"]
    lappend res [.t index "end -1 display chars"]
    lappend res [.t index "end -2 indices"]
    lappend res [.t index "end -2 display indices"]
    lappend res [.t index "end -2 display chars"]
} {1 0 0 1 0 2.0 4.0 4.0 4.0 3.0 3.0 3.0 2.0 1.0 1.0}

.t delete 1.0 end
.t insert end $current
unset current

test text-10.1 {TextWidgetCmd procedure, "index" option} {
    list [catch {.t index} msg] $msg
} {1 {wrong # args: should be ".t index index"}}
test text-10.2 {TextWidgetCmd procedure, "index" option} {
    list [catch {.t ind a b} msg] $msg
} {1 {wrong # args: should be ".t index index"}}
test text-10.3 {TextWidgetCmd procedure, "index" option} {
    list [catch {.t in a b} msg] $msg
} {1 {ambiguous option "in": must be bbox, cget, compare, configure, count, debug, delete, dlineinfo, dump, edit, get, image, index, insert, mark, peer, replace, scan, search, see, tag, window, xview, or yview}}
test text-10.4 {TextWidgetCmd procedure, "index" option} {
    list [catch {.t index @xyz} msg] $msg
} {1 {bad text index "@xyz"}}
test text-10.5 {TextWidgetCmd procedure, "index" option} {
    .t index 1.2
} 1.2

test text-11.1 {TextWidgetCmd procedure, "insert" option} {
    list [catch {.t insert 1.2} msg] $msg
} {1 {wrong # args: should be ".t insert index chars ?tagList chars tagList ...?"}}
test text-11.2 {TextWidgetCmd procedure, "insert" option} {
    .t config -state disabled
    .t insert 1.2 xyzzy
    .t get 1.0 1.end
} {Line 1}
.t config -state normal
test text-11.3 {TextWidgetCmd procedure, "insert" option} {
    .t insert 1.2 xyzzy
    .t get 1.0 1.end
} {Lixyzzyne 1}
test text-11.4 {TextWidgetCmd procedure, "insert" option} {
    .t delete 1.0 end
    .t insert 1.0 "Sample text" x
    .t tag ranges x
} {1.0 1.11}
test text-11.5 {TextWidgetCmd procedure, "insert" option} {
    .t delete 1.0 end
    .t insert 1.0 "Sample text" x
    .t insert 1.2 "XYZ" y
    list [.t tag ranges x] [.t tag ranges y]
} {{1.0 1.2 1.5 1.14} {1.2 1.5}}
test text-11.6 {TextWidgetCmd procedure, "insert" option} {
    .t delete 1.0 end
    .t insert 1.0 "Sample text" {x y z}
    list [.t tag ranges x] [.t tag ranges y] [.t tag ranges z]
} {{1.0 1.11} {1.0 1.11} {1.0 1.11}}
test text-11.7 {TextWidgetCmd procedure, "insert" option} {
    .t delete 1.0 end
    .t insert 1.0 "Sample text" {x y z}
    .t insert 1.3 "A" {a b z}
    list [.t tag ranges a] [.t tag ranges b] [.t tag ranges x] [.t tag ranges y] [.t tag ranges z]
} {{1.3 1.4} {1.3 1.4} {1.0 1.3 1.4 1.12} {1.0 1.3 1.4 1.12} {1.0 1.12}}
test text-11.8 {TextWidgetCmd procedure, "insert" option} {
    .t delete 1.0 end
    list [catch {.t insert 1.0 "Sample text" "a \{b"} msg] $msg
} {1 {unmatched open brace in list}}
test text-11.9 {TextWidgetCmd procedure, "insert" option} {
    .t delete 1.0 end
    .t insert 1.0 "First" bold " " {} second "x y z" " third"
    list [.t get 1.0 1.end] [.t tag ranges bold] [.t tag ranges x] \
	    [.t tag ranges y] [.t tag ranges z]
} {{First second third} {1.0 1.5} {1.6 1.12} {1.6 1.12} {1.6 1.12}}
test text-11.10 {TextWidgetCmd procedure, "insert" option} {
    .t delete 1.0 end
    .t insert 1.0 "First" bold " second" silly
    list [.t get 1.0 1.end] [.t tag ranges bold] [.t tag ranges silly]
} {{First second} {1.0 1.5} {1.5 1.12}}

# Edit, mark, scan, search, see, tag, window, xview, and yview actions are tested elsewhere.

test text-12.1 {ConfigureText procedure} {
    list [catch {.t2 configure -state foobar} msg] $msg
} {1 {bad state "foobar": must be disabled or normal}}
test text-12.2 {ConfigureText procedure} {
    .t2 configure -spacing1 -2 -spacing2 1 -spacing3 1
    list [.t2 cget -spacing1] [.t2 cget -spacing2] [.t2 cget -spacing3]
} {0 1 1}
test text-12.3 {ConfigureText procedure} {
    .t2 configure -spacing1 1 -spacing2 -1 -spacing3 1
    list [.t2 cget -spacing1] [.t2 cget -spacing2] [.t2 cget -spacing3]
} {1 0 1}
test text-12.4 {ConfigureText procedure} {
    .t2 configure -spacing1 1 -spacing2 1 -spacing3 -3
    list [.t2 cget -spacing1] [.t2 cget -spacing2] [.t2 cget -spacing3]
} {1 1 0}
test text-12.5 {ConfigureText procedure} {
    set x [list [catch {.t2 configure -tabs {30 foo}} msg] $msg $errorInfo]
    .t2 configure -tabs {10 20 30}
    set x
} {1 {bad tab alignment "foo": must be left, right, center, or numeric} {bad tab alignment "foo": must be left, right, center, or numeric
    (while processing -tabs option)
    invoked from within
".t2 configure -tabs {30 foo}"}}
test text-12.6 {ConfigureText procedure} {
    .t2 configure -tabs {10 20 30}
    .t2 configure -tabs {}
    .t2 cget -tabs
} {}
test text-12.7 {ConfigureText procedure} {
    list [catch {.t2 configure -wrap bogus} msg] $msg
} {1 {bad wrap "bogus": must be char, none, or word}}
test text-12.8 {ConfigureText procedure} {
    .t2 configure -selectborderwidth 17 -selectforeground #332211 \
	    -selectbackground #abc
    list [lindex [.t2 tag config sel -borderwidth] 4] \
	[lindex [.t2 tag config sel -foreground] 4] \
	[lindex [.t2 tag config sel -background] 4]
} {17 #332211 #abc}
test text-12.9 {ConfigureText procedure} {
    .t2 configure -selectborderwidth {}
    .t2 tag cget sel -borderwidth
} {}
test text-12.10 {ConfigureText procedure} {
    list [catch {.t2 configure -selectborderwidth foo} msg] $msg
} {1 {bad screen distance "foo"}}
test text-12.11 {ConfigureText procedure} {
    catch {destroy .t2}
    .t.e select to 2
    text .t2 -exportselection 1
    selection get
} {ab}
test text-12.12 {ConfigureText procedure} {
    catch {destroy .t2}
    .t.e select to 2
    text .t2 -exportselection 0
    .t2 insert insert 1234657890
    .t2 tag add sel 1.0 1.4
    selection get
} {ab}
test text-12.13 {ConfigureText procedure} {
    catch {destroy .t2}
    .t.e select to 1
    text .t2 -exportselection 1
    .t2 insert insert 1234657890
    .t2 tag add sel 1.0 1.4
    selection get
} {1234}
test text-12.14 {ConfigureText procedure} {
    catch {destroy .t2}
    .t.e select to 1
    text .t2 -exportselection 0
    .t2 insert insert 1234657890
    .t2 tag add sel 1.0 1.4
    .t2 configure -exportselection 1
    selection get
} {1234}
test text-12.15 {ConfigureText procedure} {
    catch {destroy .t2}
    text .t2 -exportselection 1
    .t2 insert insert 1234657890
    .t2 tag add sel 1.0 1.4
    set result [selection get]
    .t2 configure -exportselection 0
    lappend result [catch {selection get} msg] $msg
} {1234 1 {PRIMARY selection doesn't exist or form "STRING" not defined}}
test text-12.16 {ConfigureText procedure} {fonts} {
    # This test is non-portable because the window size will vary depending
    # on the font size, which can vary.
    catch {destroy .t2}
    toplevel .t2
    text .t2.t -width 20 -height 10
    pack append .t2 .t2.t top
    wm geometry .t2 +0+0
    update
    wm geometry .t2
} {150x140+0+0}
test text-12.17 {ConfigureText procedure} {
    # This test was failing Windows because the title bar on .t2
    # was a certain minimum size and it was interfering with the size
    # requested by the -setgrid.  The "overrideredirect" gets rid of the
    # titlebar so the toplevel can shrink to the appropriate size.
    catch {destroy .t2}
    toplevel .t2
    wm overrideredirect .t2 1
    text .t2.t -width 20 -height 10 -setgrid 1
    pack append .t2 .t2.t top
    wm geometry .t2 +0+0
    update
    wm geometry .t2
} {20x10+0+0}
test text-12.18 {ConfigureText procedure} {
    # This test was failing on Windows because the title bar on .t2
    # was a certain minimum size and it was interfering with the size
    # requested by the -setgrid.  The "overrideredirect" gets rid of the
    # titlebar so the toplevel can shrink to the appropriate size.
    catch {destroy .t2}
    toplevel .t2
    wm overrideredirect .t2 1
    text .t2.t -width 20 -height 10 -setgrid 1
    pack append .t2 .t2.t top
    wm geometry .t2 +0+0
    update
    set result [wm geometry .t2]
    wm geometry .t2 15x8
    update
    lappend result [wm geometry .t2]
    .t2.t configure -wrap word
    update
    lappend result [wm geometry .t2]
} {20x10+0+0 15x8+0+0 15x8+0+0}

test text-13.1 {TextWorldChanged procedure, spacing options} fonts {
    catch {destroy .t2}
    text .t2 -width 20 -height 10
    set result [winfo reqheight .t2]
    .t2 configure -spacing1 2
    lappend result [winfo reqheight .t2]
    .t2  configure -spacing3 1
    lappend result [winfo reqheight .t2]
    .t2 configure -spacing1 0
    lappend result [winfo reqheight .t2]
} {140 160 170 150}

test text-14.1 {TextEventProc procedure} {
    text .tx1 -bg #543210
    rename .tx1 .tx2
    set x {}
    lappend x [winfo exists .tx1]
    lappend x [.tx2 cget -bg]
    destroy .tx1
    lappend x [info command .tx*] [winfo exists .tx1] [winfo exists .tx2]
} {1 #543210 {} 0 0}

test text-15.1 {TextCmdDeletedProc procedure} {
    text .tx1
    rename .tx1 {}
    list [info command .tx*] [winfo exists .tx1]
} {{} 0}
test text-15.2 {TextCmdDeletedProc procedure, disabling -setgrid} fonts {
    catch {destroy .top}
    toplevel .top
    wm geom .top +0+0
    text .top.t -setgrid 1 -width 20 -height 10
    pack .top.t
    update
    set x [wm geometry .top]
    rename .top.t {}
    update
    lappend x [wm geometry .top]
    destroy .top
    set x
} {20x10+0+0 150x140+0+0}

test text-16.1 {InsertChars procedure} {
    catch {destroy .t2}
    text .t2
    .t2 insert 2.0 abcd\n
    .t2 get 1.0 end
} {abcd

}
test text-16.2 {InsertChars procedure} {
    catch {destroy .t2}
    text .t2
    .t2 insert 1.0 abcd\n
    .t2 insert end 123\n
    .t2 get 1.0 end
} {abcd
123

}
test text-16.3 {InsertChars procedure} {
    catch {destroy .t2}
    text .t2
    .t2 insert 1.0 abcd\n
    .t2 insert 10.0 123
    .t2 get 1.0 end
} {abcd
123
}
test text-16.4 {InsertChars procedure, inserting on top visible line} {
    catch {destroy .t2}
    text .t2 -width 20 -height 4 -wrap word
    pack .t2
    .t2 insert insert "Now is the time for all great men to come to the "
    .t2 insert insert "aid of their party.\n"
    .t2 insert insert "Now is the time for all great men.\n"
    .t2 see end
    update
    .t2 insert 1.0 "Short\n"
    .t2 index @0,0
} {2.56}
test text-16.5 {InsertChars procedure, inserting on top visible line} {
    catch {destroy .t2}
    text .t2 -width 20 -height 4 -wrap word
    pack .t2
    .t2 insert insert "Now is the time for all great men to come to the "
    .t2 insert insert "aid of their party.\n"
    .t2 insert insert "Now is the time for all great men.\n"
    .t2 see end
    update
    .t2 insert 1.55 "Short\n"
    .t2 index @0,0
} {2.0}
test text-16.6 {InsertChars procedure, inserting on top visible line} {
    catch {destroy .t2}
    text .t2 -width 20 -height 4 -wrap word
    pack .t2
    .t2 insert insert "Now is the time for all great men to come to the "
    .t2 insert insert "aid of their party.\n"
    .t2 insert insert "Now is the time for all great men.\n"
    .t2 see end
    update
    .t2 insert 1.56 "Short\n"
    .t2 index @0,0
} {1.56}
test text-16.7 {InsertChars procedure, inserting on top visible line} {
    catch {destroy .t2}
    text .t2 -width 20 -height 4 -wrap word
    pack .t2
    .t2 insert insert "Now is the time for all great men to come to the "
    .t2 insert insert "aid of their party.\n"
    .t2 insert insert "Now is the time for all great men.\n"
    .t2 see end
    update
    .t2 insert 1.57 "Short\n"
    .t2 index @0,0
} {1.56}
catch {destroy .t2}

proc setup {} {
    .t delete 1.0 end
    .t insert 1.0 "Line 1
abcde
12345
Line 4"
}

.t delete 1.0 end
test text-17.1 {DeleteChars procedure} {
    .t get 1.0 end
} {
}
test text-17.2 {DeleteChars procedure} {
    list [catch {.t delete foobar} msg] $msg
} {1 {bad text index "foobar"}}
test text-17.3 {DeleteChars procedure} {
    list [catch {.t delete 1.0 lousy} msg] $msg
} {1 {bad text index "lousy"}}
test text-17.4 {DeleteChars procedure} {
    setup
    .t delete 2.1
    .t get 1.0 end
} {Line 1
acde
12345
Line 4
}
test text-17.5 {DeleteChars procedure} {
    setup
    .t delete 2.3
    .t get 1.0 end
} {Line 1
abce
12345
Line 4
}
test text-17.6 {DeleteChars procedure} {
    setup
    .t delete 2.end
    .t get 1.0 end
} {Line 1
abcde12345
Line 4
}
test text-17.7 {DeleteChars procedure} {
    setup
    .t tag add sel 4.2 end
    .t delete 4.2 end
    list [.t tag ranges sel] [.t get 1.0 end]
} {{} {Line 1
abcde
12345
Li
}}
test text-17.8 {DeleteChars procedure} {
    setup
    .t tag add sel 1.0 end
    .t delete 4.0 end
    list [.t tag ranges sel] [.t get 1.0 end]
} {{1.0 3.5} {Line 1
abcde
12345
}}
test text-17.9 {DeleteChars procedure} {
    setup
    .t delete 2.2 2.2
    .t get 1.0 end
} {Line 1
abcde
12345
Line 4
}
test text-17.10 {DeleteChars procedure} {
    setup
    .t delete 2.3 2.1
    .t get 1.0 end
} {Line 1
abcde
12345
Line 4
}
test text-17.11 {DeleteChars procedure} {
    catch {destroy .t2}
    toplevel .t2
    text .t2.t -width 20 -height 5
    pack append .t2 .t2.t top
    wm geometry .t2 +0+0
    .t2.t insert 1.0 "abc\n123\nx\ny\nz\nq\nr\ns"
    update
    .t2.t delete 1.0 3.0
    list [.t2.t index @0,0] [.t2.t get @0,0]
} {1.0 x}
test text-17.12 {DeleteChars procedure} {
    catch {destroy .t2}
    toplevel .t2
    text .t2.t -width 20 -height 5
    pack append .t2 .t2.t top
    wm geometry .t2 +0+0
    .t2.t insert 1.0 "abc\n123\nx\ny\nz\nq\nr\ns"
    .t2.t yview 3.0
    update
    .t2.t delete 2.0 4.0
    list [.t2.t index @0,0] [.t2.t get @0,0]
} {2.0 y}
catch {destroy .t2}
toplevel .t2
text .t2.t -width 1 -height 10 -wrap char
frame .t2.f -width 200 -height 20 -relief raised -bd 2
pack .t2.f .t2.t -side left
wm geometry .t2 +0+0
update
test text-17.13 {DeleteChars procedure, updates affecting topIndex} {
    .t2.t delete 1.0 end
    .t2.t insert end "abcde\n12345\nqrstuv"
    .t2.t yview 2.1
    .t2.t delete 1.4 2.3
    .t2.t index @0,0
} {1.2}
test text-17.14 {DeleteChars procedure, updates affecting topIndex} {
    .t2.t delete 1.0 end
    .t2.t insert end "abcde\n12345\nqrstuv"
    .t2.t yview 2.1
    .t2.t delete 2.3 2.4
    .t2.t index @0,0
} {2.0}
test text-17.15 {DeleteChars procedure, updates affecting topIndex} {
    .t2.t delete 1.0 end
    .t2.t insert end "abcde\n12345\nqrstuv"
    .t2.t yview 1.3
    .t2.t delete 1.0 1.2
    .t2.t index @0,0
} {1.1}
test text-17.16 {DeleteChars procedure, updates affecting topIndex} {
    catch {destroy .t2}
    toplevel .t2
    text .t2.t -width 6 -height 10 -wrap word
    frame .t2.f -width 200 -height 20 -relief raised -bd 2
    pack .t2.f .t2.t -side left
    wm geometry .t2 +0+0
    update
    .t2.t insert end "abc def\n01 2345 678 9101112\nLine 3\nLine 4\nLine 5\n6\n7\n8\n"
    .t2.t yview 2.4
    .t2.t delete 2.5
    set x [.t2.t index @0,0]
    .t2.t delete 2.5
    list $x [.t2.t index @0,0]
} {2.3 2.0}

.t delete 1.0 end
foreach i {a b c d e f g h i j k l m n o p q r s t u v w x y z} {
    .t insert end $i.0$i.1$i.2$i.3$i.4\n
}
test text-18.1 {TextFetchSelection procedure} {
    .t tag add sel 1.3 3.4
    selection get
} {a.1a.2a.3a.4
b.0b.1b.2b.3b.4
c.0c}
test text-18.2 {TextFetchSelection procedure} {
    .t tag add x 1.2
    .t tag add x 1.4
    .t tag add x 2.0
    .t tag add x 2.3
    .t tag remove sel 1.0 end
    .t tag add sel 1.0 3.4
    selection get
} {a.0a.1a.2a.3a.4
b.0b.1b.2b.3b.4
c.0c}
test text-18.3 {TextFetchSelection procedure} {
    .t tag remove sel 1.0 end
    .t tag add sel 13.3
    selection get
} {m}
test text-18.4 {TextFetchSelection procedure} {
    .t tag remove x 1.0 end
    .t tag add sel 1.0 3.4
    .t tag remove sel 1.0 end
    .t tag add sel 1.2 1.5
    .t tag add sel 2.4 3.1
    .t tag add sel 10.0 10.end
    .t tag add sel 13.3
    selection get
} {0a..1b.2b.3b.4
cj.0j.1j.2j.3j.4m}
set x ""
for {set i 1} {$i < 200} {incr i} {
    append x "This is line $i, padded to just about 53 characters.\n"
}
test text-18.5 {TextFetchSelection procedure, long selections} {
    .t delete 1.0 end
    .t insert end $x
    .t tag add sel 1.0 end
    selection get
} $x\n

test text-19.1 {TkTextLostSelection procedure} unix {
    catch {destroy .t2}
    text .t2
    .t2 insert 1.0 "abc\ndef\nghijk\n1234"
    .t2 tag add sel 1.2 3.3
    .t.e select to 1
    .t2 tag ranges sel
} {}
test text-19.2 {TkTextLostSelection procedure} win {
    catch {destroy .t2}
    text .t2
    .t2 insert 1.0 "abc\ndef\nghijk\n1234"
    .t2 tag add sel 1.2 3.3
    .t.e select to 1
    .t2 tag ranges sel
} {1.2 3.3}
catch {destroy .t2}
test text-19.3 {TkTextLostSelection procedure} {
    catch {destroy .t2}
    text .t2
    .t2 insert 1.0 "abcdef\nghijk\n1234"
    .t2 tag add sel 1.0 1.3
    set x [selection get]
    selection clear
    lappend x [catch {selection get} msg] $msg
    .t2 tag add sel 1.0 1.3
    lappend x [selection get]
} {abc 1 {PRIMARY selection doesn't exist or form "STRING" not defined} abc}

.t delete 1.0 end
.t insert end "xxyz xyz x. the\nfoo -forward bar xxxxx BaR foo\nxyz xxyzx"
test text-20.1 {TextSearchCmd procedure, argument parsing} {
    list [catch {.t search -} msg] $msg
} {1 {bad switch "-": must be --, -all, -backward, -count, -elide, -exact, -forward, -nocase, -nolinestop, -overlap, -regexp, or -strictlimits}}
test text-20.2 {TextSearchCmd procedure, -backwards option} {
    .t search -backwards xyz 1.4
} {1.1}
test text-20.2.1 {TextSearchCmd procedure, -all option} {
    .t search -all xyz 1.4
} {1.5 3.0 3.5 1.1}
test text-20.3 {TextSearchCmd procedure, -forwards option} {
    .t search -forwards xyz 1.4
} {1.5}
test text-20.4 {TextSearchCmd procedure, -exact option} {
    .t search -f -exact x. 1.0
} {1.9}
test text-20.5 {TextSearchCmd procedure, -regexp option} {
    .t search -b -regexp x.z 1.4
} {1.1}
test text-20.6 {TextSearchCmd procedure, -count option} {
    set length unmodified
    list [.t search -count length x. 1.4] $length
} {1.9 2}
test text-20.7 {TextSearchCmd procedure, -count option} {
    list [catch {.t search -count} msg] $msg
} {1 {no value given for "-count" option}}
test text-20.8 {TextSearchCmd procedure, -nocase option} {
    list [.t search -nocase BaR 1.1] [.t search BaR 1.1]
} {2.13 2.23}
test text-20.9 {TextSearchCmd procedure, -n ambiguous option} {
    list [catch {.t search -n BaR 1.1} msg] $msg
} {1 {bad switch "-n": must be --, -all, -backward, -count, -elide, -exact, -forward, -nocase, -nolinestop, -overlap, -regexp, or -strictlimits}}
test text-20.9.1 {TextSearchCmd procedure, -nocase option} {
    .t search -noc BaR 1.1
} {2.13}
test text-20.9.2 {TextSearchCmd procedure, -nolinestop option} {
    list [catch {.t search -nolinestop BaR 1.1} msg] $msg
} {1 {the "-nolinestop" option requires the "-regexp" option to be present}}
test text-20.9.3 {TextSearchCmd procedure, -nolinestop option} {
    set msg ""
    list [.t search -nolinestop -regexp -count msg e.*o 1.1] $msg
} {1.14 32}
test text-20.10 {TextSearchCmd procedure, -- option} {
    .t search -- -forward 1.0
} {2.4}
test text-20.11 {TextSearchCmd procedure, argument parsing} {
    list [catch {.t search abc} msg] $msg
} {1 {wrong # args: should be ".t search ?switches? pattern index ?stopIndex?"}}
test text-20.12 {TextSearchCmd procedure, argument parsing} {
    list [catch {.t search abc d e f} msg] $msg
} {1 {wrong # args: should be ".t search ?switches? pattern index ?stopIndex?"}}
test text-20.13 {TextSearchCmd procedure, check index} {
    list [catch {.t search abc gorp} msg] $msg
} {1 {bad text index "gorp"}}
test text-20.14 {TextSearchCmd procedure, startIndex == "end"} {
    .t search non-existent end
} {}
test text-20.15 {TextSearchCmd procedure, startIndex == "end"} {
    .t search non-existent end
} {}
test text-20.16 {TextSearchCmd procedure, bad stopIndex} {
    list [catch {.t search abc 1.0 lousy} msg] $msg
} {1 {bad text index "lousy"}}
test text-20.17 {TextSearchCmd procedure, pattern case conversion} {
    list [.t search -nocase BAR 1.1] [.t search BAR 1.1]
} {2.13 {}}
test text-20.18 {TextSearchCmd procedure, bad regular expression pattern} {
    list [catch {.t search -regexp a( 1.0} msg] $msg
} {1 {couldn't compile regular expression pattern: parentheses () not balanced}}
test text-20.19 {TextSearchCmd procedure, skip dummy last line} {
    .t search -backwards BaR end 1.0
} {2.23}
test text-20.20 {TextSearchCmd procedure, skip dummy last line} {
    .t search -backwards \n end 1.0
} {3.9}
test text-20.21 {TextSearchCmd procedure, skip dummy last line} {
    .t search \n end
} {1.15}
test text-20.22 {TextSearchCmd procedure, skip dummy last line} {
    .t search -back \n 1.0
} {3.9}
test text-20.23 {TextSearchCmd procedure, extract line contents} {
    .t tag add foo 1.2
    .t tag add x 1.3
    .t mark set silly 1.2
    .t search xyz 3.6
} {1.1}
test text-20.24 {TextSearchCmd procedure, stripping newlines} {
    .t search the\n 1.0
} {1.12}
test text-20.25 {TextSearchCmd procedure, handling newlines} {
    .t search -regexp the\n 1.0
} {1.12}
test text-20.26 {TextSearchCmd procedure, stripping newlines} {
    .t search -regexp {the$} 1.0
} {1.12}
test text-20.27 {TextSearchCmd procedure, handling newlines} {
    .t search -regexp \n 1.0
} {1.15}
test text-20.28 {TextSearchCmd procedure, line case conversion} {
    list [.t search -nocase bar 2.18] [.t search bar 2.18]
} {2.23 2.13}
test text-20.29 {TextSearchCmd procedure, firstChar and lastChar} {
    .t search -backwards xyz 1.6
} {1.5}
test text-20.30 {TextSearchCmd procedure, firstChar and lastChar} {
    .t search -backwards xyz 1.5
} {1.1}
test text-20.31 {TextSearchCmd procedure, firstChar and lastChar} {
    .t search xyz 1.5
} {1.5}
test text-20.32 {TextSearchCmd procedure, firstChar and lastChar} {
    .t search xyz 1.6
} {3.0}
test text-20.33 {TextSearchCmd procedure, firstChar and lastChar} {
    .t search {} 1.end
} {1.15}
test text-20.34 {TextSearchCmd procedure, firstChar and lastChar} {
    .t search f 1.end
} {2.0}
test text-20.35 {TextSearchCmd procedure, firstChar and lastChar} {
    .t search {} end
} {1.0}
test text-20.35a {TextSearchCmd procedure, regexp finds empty lines} {
    # Test for fix of bug #1643
    .t insert end "\n"
    tk::TextSetCursor .t 4.0
    .t search -forward -regexp {^$} insert end
} {4.0}
    
catch {destroy .t2}
toplevel .t2
wm geometry .t2 +0+0
text .t2.t -width 30 -height 10
pack .t2.t
.t2.t insert 1.0 "This is a line\nand this is another"
.t2.t insert end "\nand this is yet another"
frame .t2.f -width 20 -height 20 -bd 2 -relief raised
.t2.t window create 2.5 -window .t2.f
test text-20.36 {TextSearchCmd procedure, firstChar and lastChar} {
    .t2.t search his 2.6
} {2.6}
test text-20.37 {TextSearchCmd procedure, firstChar and lastChar} {
    .t2.t search this 2.6
} {3.4}
test text-20.38 {TextSearchCmd procedure, firstChar and lastChar} {
    .t2.t search is 2.6
} {2.7}
test text-20.39 {TextSearchCmd procedure, firstChar and lastChar} {
    .t2.t search his 2.7
} {3.5}
test text-20.40 {TextSearchCmd procedure, firstChar and lastChar} {
    .t2.t search -backwards "his is another" 2.6
} {2.6}
test text-20.41 {TextSearchCmd procedure, firstChar and lastChar} {
    .t2.t search -backwards "his is" 2.6
} {1.1}
destroy .t2
test text-20.42 {TextSearchCmd procedure, firstChar and lastChar} {
    .t search -backwards forw 2.5
} {2.5}
test text-20.43 {TextSearchCmd procedure, firstChar and lastChar} {
    .t search forw 2.5
} {2.5}
test text-20.44 {TextSearchCmd procedure, firstChar and lastChar} {
    catch {destroy .t2}
    text .t2
    list [.t2 search a 1.0] [.t2 search -backward a 1.0]
} {{} {}}
test text-20.45 {TextSearchCmd procedure, regexp match length} {
    set length unchanged
    list [.t search -regexp -count length x(.)(.*)z 1.1] $length
} {1.1 7}
test text-20.46 {TextSearchCmd procedure, regexp match length} {
    set length unchanged
    list [.t search -regexp -backward -count length fo* 2.5] $length
} {2.0 3}
test text-20.47 {TextSearchCmd procedure, checking stopIndex} {
    list [.t search bar 2.1 2.13] [.t search bar 2.1 2.14] \
	    [.t search bar 2.12 2.14] [.t search bar 2.14 2.14]
} {{} 2.13 2.13 {}}
test text-20.48 {TextSearchCmd procedure, checking stopIndex} {
    list [.t search -backwards bar 2.20 2.13] \
      [.t search -backwards bar 2.20 2.14] \
      [.t search -backwards bar 2.14 2.13] \
      [.t search -backwards bar 2.13 2.13]
} {2.13 {} 2.13 {}}
test text-20.48.1 {TextSearchCmd procedure, checking stopIndex} {
    list [.t search -backwards -strict bar 2.20 2.13] \
      [.t search -backwards -strict bar 2.20 2.14] \
      [.t search -backwards -strict bar 2.14 2.13] \
      [.t search -backwards -strict bar 2.13 2.13]
} {2.13 {} {} {}}
test text-20.49 {TextSearchCmd procedure, embedded windows and index/count} {
    frame .t.f1 -width 20 -height 20 -relief raised -bd 2
    frame .t.f2 -width 20 -height 20 -relief raised -bd 2
    frame .t.f3 -width 20 -height 20 -relief raised -bd 2
    frame .t.f4 -width 20 -height 20 -relief raised -bd 2
    .t window create 2.10 -window .t.f3
    .t window create 2.8 -window .t.f2
    .t window create 2.8 -window .t.f1
    .t window create 2.1 -window .t.f4
    set result ""
    lappend result [.t search -count x forward 1.0] $x
    lappend result [.t search -count x wa 1.0] $x
    .t delete 2.1
    .t delete 2.8 2.10
    .t delete 2.10
    set result
} {2.6 10 2.11 2}
test text-20.50 {TextSearchCmd procedure, error setting variable} {
    catch {unset a}
    set a 44
    list [catch {.t search -count a(2) xyz 1.0} msg] $msg
} {1 {can't set "a(2)": variable isn't array}}
test text-20.51 {TextSearchCmd procedure, wrap-around} {
    .t search -backwards xyz 1.1
} {3.5}
test text-20.52 {TextSearchCmd procedure, wrap-around} {
    .t search -backwards xyz 1.1 1.0
} {}
test text-20.53 {TextSearchCmd procedure, wrap-around} {
    .t search xyz 3.6
} {1.1}
test text-20.54 {TextSearchCmd procedure, wrap-around} {
    .t search xyz 3.6 end
} {}
test text-20.55 {TextSearchCmd procedure, no match} {
    .t search non_existent 3.5
} {}
test text-20.56 {TextSearchCmd procedure, no match} {
    .t search -regexp non_existent 3.5
} {}
test text-20.57 {TextSearchCmd procedure, special cases} {
    .t search -back x 1.1
} {1.0}
test text-20.58 {TextSearchCmd procedure, special cases} {
    .t search -back x 1.0
} {3.8}
test text-20.59 {TextSearchCmd procedure, special cases} {
    .t search \n {end-2c}
} {3.9}
test text-20.60 {TextSearchCmd procedure, special cases} {
    .t search \n end
} {1.15}
test text-20.61 {TextSearchCmd procedure, special cases} {
    .t search x 1.0
} {1.0}
test text-20.62 {TextSearchCmd, freeing copy of pattern} {
    # This test doesn't return a result, but it will generate
    # a core leak if the pattern copy isn't properly freed.
    # (actually in Tk 8.5 objectification means there is no
    # longer a copy of the pattern, but we leave this test in
    # anyway).
    set p abcdefg1234567890
    set p $p$p$p$p$p$p$p$p
    set p $p$p$p$p$p
    .t search -nocase $p 1.0
} {}
test text-20.63 {TextSearchCmd, unicode} {
    .t delete 1.0 end
    .t insert end "foo\u30c9\u30cabar"
    .t search \u30c9\u30ca 1.0
} 1.3
test text-20.64 {TextSearchCmd, unicode} {
    .t delete 1.0 end
    .t insert end "foo\u30c9\u30cabar"
    list [.t search -count n \u30c9\u30ca 1.0] $n
} {1.3 2}
test text-20.65 {TextSearchCmd, unicode with non-text segments} {
    .t delete 1.0 end
    button .b1 -text baz
    .t insert end "foo\u30c9"
    .t window create end -window .b1
    .t insert end "\u30cabar"
    set result [list [.t search -count n \u30c9\u30ca 1.0] $n]
    destroy .b1
    set result
} {1.3 3}
test text-20.66 {TextSearchCmd, hidden text does not affect match index} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "12345H7890"
    .t2 search 7 1.0
} 1.6
test text-20.67 {TextSearchCmd, hidden text does not affect match index} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "12345H7890"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.5
    .t2 search 7 1.0
} 1.6
test text-20.68 {TextSearchCmd, hidden text does not affect match index} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nbarbaz\nbazboo"
    .t2 search boo 1.0
} 3.3
test text-20.69 {TextSearchCmd, hidden text does not affect match index} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nbarbaz\nbazboo"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 2.0 3.0
    .t2 search boo 1.0
} 3.3
test text-20.70 {TextSearchCmd, -regexp -nocase searches} {
    catch {destroy .t}
    pack [text .t]
    .t insert end "word1 word2"
    set res [.t search -nocase -regexp {\mword.} 1.0 end]
    destroy .t
    set res
} 1.0
test text-20.71 {TextSearchCmd, -regexp -nocase searches} {
    catch {destroy .t}
    pack [text .t]
    .t insert end "word1 word2"
    set res [.t search -nocase -regexp {word.\M} 1.0 end]
    destroy .t
    set res
} 1.0
test text-20.72 {TextSearchCmd, -regexp -nocase searches} {
    catch {destroy .t}
    pack [text .t]
    .t insert end "word1 word2"
    set res [.t search -nocase -regexp {word.\W} 1.0 end]
    destroy .t
    set res
} 1.0
test text-20.73 {TextSearchCmd, hidden text and start index} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search bar 1.3
} 1.3
test text-20.74 {TextSearchCmd, hidden text shouldn't influence start index} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.0 1.2
    .t2 search bar 1.3
} 1.3
test text-20.75 {TextSearchCmd, hidden text inside match must count in length} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.2 1.4
    list [.t2 search -count foo foar 1.3] $foo
} {1.0 6}
test text-20.75.1 {TextSearchCmd, hidden text inside match must count in length} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.2 1.4
    list \
      [.t2 search -strict -count foo foar 1.3] \
      [.t2 search -strict -count foo foar 2.3] $foo
} {{} 1.0 6}
test text-20.76 {TextSearchCmd, hidden text and start index} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search -regexp bar 1.3
} 1.3
test text-20.77 {TextSearchCmd, hidden text shouldn't influence start index} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.0 1.2
    .t2 search -regexp bar 1.3
} 1.3
test text-20.78 {TextSearchCmd, hidden text inside match must count in length} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.2 1.4
    list [.t2 search -regexp -count foo foar 1.3] $foo
} {1.0 6}
test text-20.78.1 {TextSearchCmd, hidden text inside match must count in length} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.2 1.4
    list [.t2 search -count foo foar 1.3] $foo
} {1.0 6}
test text-20.78.2 {TextSearchCmd, hidden text inside match must count in length} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.2 1.4
    .t2 search -strict -count foo foar 1.3
} {}
test text-20.78.3 {TextSearchCmd, hidden text inside match must count in length} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.2 1.4
    .t2 tag add hidden 2.2 2.4
    list [.t2 search -regexp -all -count foo foar 1.3] $foo
} {{2.0 3.0 1.0} {6 4 6}}
test text-20.78.4 {TextSearchCmd, hidden text inside match must count in length} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.2 1.4
    .t2 tag add hidden 2.2 2.4
    list [.t2 search -all -count foo foar 1.3] $foo
} {{2.0 3.0 1.0} {6 4 6}}
test text-20.78.5 {TextSearchCmd, hidden text inside match must count in length} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoar"
    .t2 tag configure hidden -elide true
    .t2 tag add hidden 1.2 1.4
    .t2 tag add hidden 2.2 2.4
    list [.t2 search -strict -all -count foo foar 1.3] $foo
} {{2.0 3.0} {6 4}}
test text-20.78.6 {TextSearchCmd, single line with -all} {
    deleteWindows
    pack [text .t2]
    .t2 insert end " X\n X\n X\n X\n X\n X\n"
    .t2 search -all -regexp { +| *\n} 1.0 end
} {1.0 1.2 2.0 2.2 3.0 3.2 4.0 4.2 5.0 5.2 6.0 6.2 7.0}
test text-20.79 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -count foo foobar\nfoo 1.0] $foo
} {1.0 10}
test text-20.80 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -count foo bar\nfoo 1.0] $foo
} {1.3 7}
test text-20.81 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -count foo \nfoo 1.0] $foo
} {1.6 4}
test text-20.82 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -count foo bar\nfoobar\nfoo 1.0] $foo
} {1.3 14}
test text-20.83 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search -count foo bar\nfoobar\nfoobanearly 1.0
} {}
test text-20.84 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -regexp -count foo foobar\nfoo 1.0] $foo
} {1.0 10}
test text-20.85 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -regexp -count foo bar\nfoo 1.0] $foo
} {1.3 7}
test text-20.86 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -regexp -count foo \nfoo 1.0] $foo
} {1.6 4}
test text-20.87 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -regexp -count foo bar\nfoobar\nfoo 1.0] $foo
} {1.3 14}
test text-20.88 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search -regexp -count foo bar\nfoobar\nfoobanearly 1.0
} {}
test text-20.89 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfaoobar\nfoobar"
    .t2 search -regexp -count foo bar\nfoo 1.0
} {2.4}
test text-20.90 {TextSearchCmd, multiline matching end of window} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfaoobar\nfoobar"
    .t2 search -regexp -count foo bar\nfoobar\n\n 1.0
} {}
test text-20.91 {TextSearchCmd, multiline matching end of window} {
    deleteWindows
    pack [text .t2]
    .t2 search "\n\n" 1.0
} {}
test text-20.92 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -backwards -count foo foobar\nfoo end] $foo
} {2.0 10}
test text-20.93 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -backwards -count foo bar\nfoo 1.0] $foo
} {2.3 7}
test text-20.94 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -backwards -count foo \nfoo 1.0] $foo
} {2.6 4}
test text-20.95 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -backwards -count foo bar\nfoobar\nfoo 1.0] $foo
} {1.3 14}
test text-20.96 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search -backwards -count foo bar\nfoobar\nfoobanearly 1.0
} {}
test text-20.97 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -backwards -regexp -count foo foobar\nfoo end] $foo
} {2.0 10}
test text-20.97.1 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -backwards -regexp -count foo foobar\nfo end] $foo
} {2.0 9}
test text-20.98 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -backwards -regexp -count foo bar\nfoo 1.0] $foo
} {2.3 7}
test text-20.99 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -backwards -regexp -count foo \nfoo 1.0] $foo
} {2.6 4}
test text-20.100 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    list [.t2 search -backwards -regexp -count foo bar\nfoobar\nfoo 1.0] $foo
} {1.3 14}
test text-20.101 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search -backwards -regexp -count foo bar\nfoobar\nfoobanearly 1.0
} {}
test text-20.102 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfaoobar\nfoobar"
    .t2 search -backwards -regexp -count foo bar\nfoo 1.0
} {2.4}
test text-20.103 {TextSearchCmd, multiline matching end of window} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfaoobar\nfoobar"
    .t2 search -backwards -regexp -count foo bar\nfoobar\n\n 1.0
} {}
test text-20.104 {TextSearchCmd, multiline matching end of window} {
    deleteWindows
    pack [text .t2]
    .t2 search -backwards "\n\n" 1.0
} {}
test text-20.105 {TextSearchCmd, multiline regexp matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 {    Tcl_Obj *objPtr));
static Tcl_Obj*         FSNormalizeAbsolutePath 
			    _ANSI_ARGS_((Tcl_Interp* interp, Tcl_Obj *pathPtr));}
    set markExpr "^(\[A-Za-z0-9~_\]+\[ \t\n\r\]*\\(|(\[^ \t\(#\n\r/@:\*\]\[^=\(\r\n\]*\[ \t\]+\\*?)?"
    append markExpr "(\[A-Za-z0-9~_\]+(<\[^>\]*>)?(::)?(\[A-Za-z0-9~_\]+::)*\[-A-Za-z0-9~_+ <>\|\\*/\]+|\[A-Za-z0-9~_\]+)"
    append markExpr "\[ \n\t\r\]*\\()"
    .t2 search -forwards -regexp $markExpr 1.41 end
} {}
test text-20.106 {TextSearchCmd, multiline regexp matching} {
    # Practical example which used to crash Tk, but only after the
    # search is complete.  This is memory corruption caused by
    # a bug in Tcl's handling of string objects.
    # (Tcl bug 635200)
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 {static int		SetFsPathFromAny _ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *objPtr));
static Tcl_Obj*         FSNormalizeAbsolutePath 
			    _ANSI_ARGS_((Tcl_Interp* interp, Tcl_Obj *pathPtr));}
    set markExpr "^(\[A-Za-z0-9~_\]+\[ \t\n\r\]*\\(|(\[^ \t\(#\n\r/@:\*\]\[^=\(\r\n\]*\[ \t\]+\\*?)?"
    append markExpr "(\[A-Za-z0-9~_\]+(<\[^>\]*>)?(::)?(\[A-Za-z0-9~_\]+::)*\[-A-Za-z0-9~_+ <>\|\\*/\]+|\[A-Za-z0-9~_\]+)"
    append markExpr "\[ \n\t\r\]*\\()"
    .t2 search -forwards -regexp $markExpr 1.41 end
} {}
test text-20.107 {TextSearchCmd, multiline regexp matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 {
static int		SetFsPathFromAny _ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *objPtr));
static Tcl_Obj*         FSNormalizeAbsolutePath 
			    _ANSI_ARGS_((Tcl_Interp* interp, Tcl_Obj *pathPtr));}
    set markExpr "^(\[A-Za-z0-9~_\]+\[ \t\n\r\]*\\(|(\[^ \t\(#\n\r/@:\*\]\[^=\(\r\n\]*\[ \t\]+\\*?)?"
    append markExpr "(\[A-Za-z0-9~_\]+(<\[^>\]*>)?(::)?(\[A-Za-z0-9~_\]+::)*\[-A-Za-z0-9~_+ <>\|\\*/\]+|\[A-Za-z0-9~_\]+)"
    append markExpr "\[ \n\t\r\]*\\()"
    .t2 search -backwards -all -regexp $markExpr end
} {2.0}
test text-20.108 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search -all -regexp -count foo bar\nfoo 1.0
} {1.3 2.3}
test text-20.109 {TextSearchCmd, multiline matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search -all -backwards -regexp -count foo bar\nfoo 1.0
} {2.3 1.3}
test text-20.110 {TextSearchCmd, wrapping and limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search -- "blah" 3.3 1.3
} {}
test text-20.111 {TextSearchCmd, wrapping and limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "foobar\nfoobar\nfoobar"
    .t2 search -backwards -- "blah" 1.3 3.3
} {}
test text-20.112 {TextSearchCmd, wrapping and limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "if (stringPtr->uallocated > 0) \{x"
    .t2 search -backwards -regexp -- "\[\]\")\}\[(\{\]" "1.32" 1.0
} {1.31}
test text-20.113 {TextSearchCmd, wrapping and limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "if (stringPtr->uallocated > 0) \{x"
    .t2 search -regexp -- "\[\]\")\}\[(\{\]" 1.30 "1.0 lineend"
} {1.31}
test text-20.114 {TextSearchCmd, wrapping and limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "if (stringPtr->uallocated > 0) \{x"
    .t2 search -backwards -all -regexp -- "\[\]\")\}\[(\{\]" "1.32" 1.0
} {1.31 1.29 1.3}
test text-20.115 {TextSearchCmd, wrapping and limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "if (stringPtr->uallocated > 0) \{x"
    .t2 search -all -regexp -- "\[\]\")\}\[(\{\]" 1.0 "1.0 lineend"
} {1.3 1.29 1.31}
test text-20.116 {TextSearchCmd, wrapping and limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "if (stringPtr->uallocated > 0) \{x"
    .t2 search -backwards -- "\{" "1.32" 1.0
} {1.31}
test text-20.117 {TextSearchCmd, wrapping and limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert end "if (stringPtr->uallocated > 0) \{x"
    .t2 search -- "\{" 1.30 "1.0 lineend"
} {1.31}
test text-20.118 {TextSearchCmd, multiline regexp matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 {

void
Tcl_SetObjLength(objPtr, length)
    register Tcl_Obj *objPtr;	/* Pointer to object.  This object must
				 * not currently be shared. */
    register int length;	/* Number of bytes desired for string
				 * representation of object, not including
				 * terminating null byte. */
\{
    char *new;
}
    set markExpr "^(\[A-Za-z0-9~_\]+\[ \t\n\r\]*\\(|(\[^ \t\(#\n\r/@:\*\]\[^=\(\r\n\]*\[ \t\]+\\*?)?"
    append markExpr "(\[A-Za-z0-9~_\]+(<\[^>\]*>)?(::)?(\[A-Za-z0-9~_\]+::)*\[-A-Za-z0-9~_+ <>\|\\*/\]+|\[A-Za-z0-9~_\]+)"
    append markExpr "\[ \n\t\r\]*\\()"
    .t2 search -all -regexp -- $markExpr 1.0
} {4.0}
test text-20.119 {TextSearchCmd, multiline regexp matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "first line\nlast line of text"
    set markExpr {^[a-z]+}
    # This should not match, and should not wrap
    .t2 search -regexp -- $markExpr end end
} {}
test text-20.120 {TextSearchCmd, multiline regexp matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "first line\nlast line of text"
    set markExpr {^[a-z]+}
    # This should not match, and should not wrap
    .t2 search -regexp -- $markExpr end+10c end
} {}
test text-20.121 {TextSearchCmd, multiline regexp matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "first line\nlast line of text"
    set markExpr {^[a-z]+}
    # This should not match, and should not wrap
    .t2 search -regexp -backwards -- $markExpr 1.0 1.0
} {}
test text-20.122 {TextSearchCmd, regexp linestop} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "first line\nlast line of text"
    .t2 search -regexp -- {i.*x} 1.0
} {2.6}
test text-20.123 {TextSearchCmd, multiline regexp nolinestop matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "first line\nlast line of text"
    .t2 search -regexp -nolinestop -- {i.*x} 1.0
} {1.1}
test text-20.124 {TextSearchCmd, regexp linestop} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "first line\nlast line of text"
    .t2 search -regexp -all -overlap -- {i.*x} 1.0
} {2.6}
test text-20.124.1 {TextSearchCmd, regexp linestop} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "first line\nlast line of text"
    .t2 search -regexp -all -- {i.*x} 1.0
} {2.6}
test text-20.125 {TextSearchCmd, multiline regexp nolinestop matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "first line\nlast line of text"
    list [.t2 search -regexp -all -overlap -count c -nolinestop -- {i.*x} 1.0] $c
} {{1.1 2.6} {26 10}}
test text-20.125.1 {TextSearchCmd, multiline regexp nolinestop matching} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "first line\nlast line of text"
    list [.t2 search -regexp -all -count c -nolinestop -- {i.*x} 1.0] $c
} {1.1 26}
test text-20.126 {TextSearchCmd, stop at end of line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "  \t\n   last line of text"
    .t2 search -regexp -nolinestop -- {[^ \t]} 1.0
} {1.3}
test text-20.127 {TextSearchCmd, overlapping all matches} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde abcde"
    list [.t2 search -regexp -all -overlap -count c -- {\w+} 1.0] $c
} {{1.0 1.6} {5 5}}
test text-20.127.1 {TextSearchCmd, non-overlapping all matches} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde abcde"
    list [.t2 search -regexp -all -count c -- {\w+} 1.0] $c
} {{1.0 1.6} {5 5}}
test text-20.128 {TextSearchCmd, stop at end of line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde abcde"
    list [.t2 search -backwards -regexp -all -count c -- {\w+} 1.0] $c
} {{1.6 1.0} {5 5}}
test text-20.129 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    list [.t2 search -backwards -regexp -count c -- {Z\w+} 1.21 1.5] $c
} {1.8 8}
test text-20.130 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    list [.t2 search -backwards -all -overlap -regexp -count c -- {Z\w+} 1.21 1.5] $c
} {1.8 8}
test text-20.130.1 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    list [.t2 search -backwards -all -regexp -count c -- {Z\w+} 1.21 1.5] $c
} {1.8 8}
test text-20.131 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    list [.t2 search -backwards -overlap -all -regexp -count c -- {Z\w+} 1.21 1.1] $c
} {1.4 12}
test text-20.131.1 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    list [.t2 search -backwards -overlap -all -regexp -count c -- {Z[^Z]+Z} 1.21 1.1] $c
} {{1.8 1.4} {5 5}}
test text-20.131.2 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    list [.t2 search -backwards -all -regexp -count c -- {Z\w+} 1.21 1.1] $c
} {1.4 12}
test text-20.132 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again\n"
    list [.t2 search -backwards -all -overlap -regexp -count c -- {Z\w+} 2.21 1.5] $c
} {{2.4 1.8} {12 8}}
test text-20.132.1 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again\n"
    list [.t2 search -backwards -all -regexp -count c -- {Z\w+} 2.21 1.5] $c
} {{2.4 1.8} {12 8}}
test text-20.133 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again\n"
    list [.t2 search -backwards -overlap -all -regexp -count c -- {Z\w+} 2.21 1.1] $c
} {{2.4 1.4} {12 12}}
test text-20.133.1 {TextSearchCmd, backwards search stop index } {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again"
    .t2 insert 1.0 "bla ZabcZdefZghi and some text again\n"
    list [.t2 search -backwards -all -regexp -count c -- {Z\w+} 2.21 1.1] $c
} {{2.4 1.4} {12 12}}
test text-20.134 {TextSearchCmd, search -all example} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 {

See the package: supersearch for more information.


See the package: incrementalSearch for more information.

package: Brws .


See the package: marks for more information.

}
    set pat {package: ([a-zA-Z0-9][-a-zA-Z0-9._+#/]*)}
    list [.t2 search -nolinestop -regexp -nocase -all -forwards \
      -count c -- $pat 1.0 end] $c
} {{3.8 6.8 8.0 11.8} {20 26 13 14}}
test text-20.135 {TextSearchCmd, backwards search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foobarfoobaaaaaaaaaaarfoo"
    .t2 search -backwards -regexp {fooba+rfoo} end
} {1.6}
test text-20.135.1 {TextSearchCmd, backwards search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foobarfoobaaaaaaaaaaarfoo"
    .t2 search -backwards -overlap -all -regexp {fooba+rfoo} end
} {1.6 1.0}
test text-20.135.2 {TextSearchCmd, backwards search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foobarfoobaaaaaaaaaaarfoo"
    .t2 search -backwards -all -regexp {fooba+rfoo} end
} {1.6}
test text-20.135.3 {TextSearchCmd, forwards search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foobarfoobaaaaaaaaaaarfoo"
    .t2 search -all -overlap -regexp {fooba+rfoo} end
} {1.0 1.6}
test text-20.135.4 {TextSearchCmd, forwards search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foobarfoobaaaaaaaaaaarfoo"
    .t2 search -all -regexp {fooba+rfoo} end
} {1.0}
test text-20.136 {TextSearchCmd, forward exact search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abababab"
    .t2 search -exact -overlap -all {abab} 1.0
} {1.0 1.2 1.4}
test text-20.136.1 {TextSearchCmd, forward exact search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abababab"
    .t2 search -exact -all {abab} 1.0
} {1.0 1.4}
test text-20.137 {TextSearchCmd, backward exact search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "ababababab"
    .t2 search -exact -overlap -backwards -all {abab} end
} {1.6 1.4 1.2 1.0}
test text-20.137.1 {TextSearchCmd, backward exact search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "ababababab"
    .t2 search -exact -backwards -all {abab} end
} {1.6 1.2}
test text-20.137.2 {TextSearchCmd, backward exact search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abababababab"
    .t2 search -exact -backwards -all {abab} end
} {1.8 1.4 1.0}
test text-20.138 {TextSearchCmd, forward exact search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foo\nbar\nfoo\nbar\nfoo\nbar\nfoo\n"
    .t2 search -exact -overlap -all "foo\nbar\nfoo" 1.0
} {1.0 3.0 5.0}
test text-20.138.1 {TextSearchCmd, forward exact search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foo\nbar\nfoo\nbar\nfoo\nbar\nfoo\n"
    .t2 search -exact -all "foo\nbar\nfoo" 1.0
} {1.0 5.0}
test text-20.139 {TextSearchCmd, backward exact search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foo\nbar\nfoo\nbar\nfoo\nbar\nfoo\n"
    .t2 search -exact -overlap -backward -all "foo\nbar\nfoo" end
} {5.0 3.0 1.0}
test text-20.140 {TextSearchCmd, backward exact search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foo\nbar\nfoo\nbar\nfoo\nbar\nfoo\n"
    .t2 search -exact -backward -all "foo\nbar\nfoo" end
} {5.0 1.0}
test text-20.141 {TextSearchCmd, backward exact search overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foo\nbar\nfoo\nbar\nfoo\nbar\nfoo\n"
    .t2 search -regexp -backward -overlap -all "foo\nbar\nfoo" end
} {5.0 3.0 1.0}
test text-20.142 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "foo\nbar\nfoo\nbar\nfoo\nbar\nfoo\n"
    .t2 search -regexp -backward -all "foo\nbar\nfoo" end
} {5.0 1.0}
test text-20.142a {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 " aasda asdj werwer"
    .t2 search -regexp -backward -- {(\$)?[\w:_]+} 1.9
} {1.7}
test text-20.143 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 " aasda asdj werwer"
    .t2 search -regexp -backward -- {(\$)?[\w:_]+} 1.9 1.5
} {1.7}
test text-20.144 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 " aasda asdj werwer"
    .t2 search -regexp -backward -- {(\$)?[\w:_]+} 1.9 1.7
} {1.7}
test text-20.145 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 " aasda asdj werwer"
    .t2 search -regexp -backward -- {(\$)?[\w:_]+} 1.9 1.8
} {1.8}
test text-20.146 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 " aasda asdj werwer"
    .t2 search -regexp -backward -all -- {(\$)?[\w:_]+} 1.9 1.3
} {1.7 1.3}
test text-20.147 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 " aasda asdj werwer"
    .t2 search -regexp -backward -all -- {(\$)?[\w:_]+} 1.9 1.13
} {}
test text-20.148 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 " aasda asdj werwer"
    .t2 search -regexp -backward -all -- {(\$)?[\w:_]+} 2.0 1.3
} {1.12 1.7 1.3}
test text-20.149 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 " aasda asdj werwer"
    .t2 search -regexp -backward -all -- {(\$)?[\w:_]+} 1.3
} {1.1 1.12 1.7 1.3}
test text-20.150 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\n"
    .t2 search -regexp -backward -all -- {(\w+\n)+} end
} {1.0}
test text-20.151 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\n"
    .t2 search -regexp -backward -all -- {(\w+\n)+} end 1.5
} {2.0}
test text-20.152 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    .t2 search -regexp -backward -all -- {(\w+\n\w)+} end 1.5
} {2.0}
test text-20.153 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    list [.t2 search -regexp -all -count foo -- {(\w+\n)+} 1.0] $foo
} {1.0 20}
test text-20.154 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    set res {}
    lappend res \
      [list [.t2 search -regexp -all -count foo -- {(\w+\n)+} 1.0] $foo] \
      [list [.t2 search -regexp -all -count foo -- {(\w+)+} 1.0] $foo]
} {{1.0 20} {{1.0 2.0 3.0 4.0} {5 5 5 1}}}
test text-20.155 {TextSearchCmd, regexp search greedy} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    list [.t2 search -regexp -all -nolinestop -count foo -- {.*} 1.0] $foo
} {1.0 20}
test text-20.156 {TextSearchCmd, regexp search greedy} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    list [.t2 search -regexp -all -count foo -- {.*} 1.0] $foo
} {{1.0 2.0 3.0 4.0} {5 5 5 1}}
test text-20.157 {TextSearchCmd, regexp search greedy multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    list [.t2 search -regexp -count foo -- {(\w+\n\w)+} 1.0] $foo
} {1.0 19}
test text-20.158 {TextSearchCmd, regexp search greedy multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    list [.t2 search -regexp -backwards -count foo -- {(\w+\n\w)+} end] $foo
} {1.0 19}
test text-20.159 {TextSearchCmd, regexp search greedy multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    list [.t2 search -regexp -all -backwards -count foo -- {(\w+\n\w)+} end] $foo
} {1.0 19}
test text-20.160 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    .t2 search -regexp -backward -all -- {(\w+\n\w)+} end 1.5
} {2.0}
test text-20.161 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    .t2 search -regexp -backward -all -- {(\w+\n\w)+} end 1.3
} {1.3}
test text-20.162 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    list [.t2 search -regexp -forward -count foo -- {(\w+\n\w)+} 1.3] $foo
} {1.3 16}
test text-20.163 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    list [.t2 search -regexp -forward -all -count foo -- {(\w+\n\w)+} 1.3] $foo
    # This result is somewhat debatable -- the two results do overlap,
    # but only because the search has totally wrapped around back to
    # the start.
} {{1.3 1.0} {16 19}}
test text-20.164 {TextSearchCmd, backward regexp search no-overlaps} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "abcde\nabcde\nabcde\na"
    list [.t2 search -regexp -forward -all -count foo -- {(\w+\n\w)+} 1.0 1.3] $foo
} {1.0 19}
test text-20.165 {TextSearchCmd, regexp search multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aaaa\nbbbb\naaaa\nbbbb\n"
    list [.t2 search -regexp -forward -all -count foo -- {(a+\n(b+\n))+} 1.0] $foo
} {1.0 20}
test text-20.166 {TextSearchCmd, regexp search complex cases} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aaaa\nbbbb\naaaa\nbbbb\n"
    list [.t2 search -regexp -forward -all -count foo \
      -- {(a+\n(b+\n))+} 1.0] $foo
} {1.0 20}
test text-20.167 {TextSearchCmd, regexp search multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aaaa\nbbbb\ncccc\nbbbb\naaaa\n"
    set foo {}
    list [.t2 search -regexp -forward -all -count foo \
      -- {(b+\nc+\nb+)\na+} 1.0] $foo
} {2.0 19}
test text-20.168 {TextSearchCmd, regexp search multi-line} {knownBug} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aaaa\nbbbb\ncccc\nbbbb\naaaa\n"
    set foo {}
    list [.t2 search -regexp -forward -all -count foo \
      -- {(a+|b+\nc+\nb+)\na+} 1.0] $foo
} {2.0 19}
test text-20.169 {TextSearchCmd, regexp search multi-line} {knownBug} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aaaa\nbbbb\ncccc\nbbbb\naaaa\n"
    set foo {}
    list [.t2 search -regexp -forward -all -count foo \
      -- {(a+|b+\nc+\nb+)+\na+} 1.0] $foo
} {2.0 19}
test text-20.170 {TextSearchCmd, regexp search multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aaaa\nbbbb\ncccc\nbbbb\naaaa\n"
    set foo {}
    list [.t2 search -regexp -forward -all -count foo \
      -- {((a+|b+\nc+\nb+)+\n)+a+} 1.0] $foo
} {1.0 24}
test text-20.171 {TextSearchCmd, regexp search multi-line} {knownBug} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aaaa\nbbbb\nbbbb\nbbbb\nbbbb\n"
    list [.t2 search -regexp -backward -all -count foo \
      -- {b+\n|a+\n(b+\n)+} end] $foo
} {1.0 25}
test text-20.172 {TextSearchCmd, regexp search multi-line} {knownBug} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aaaa\nbbbb\nbbbb\nbbbb\nbbbb\n"
    .t2 search -regexp -backward -- {b+\n|a+\n(b+\n)+} end
    # Should match at 1.0 for a true greedy match
} {1.0}
test text-20.172.1 {TextSearchCmd, regexp search multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "line0\nline1\nline1\nline1\nline1\nline2\nline2\nline2\nline3\n"
    .t2 search -nolinestop -regexp -nocase -forwards -- {^(.*)\n(\1\n)+} 1.0 end
    # Matches at 6.0 currently
} {2.0}
test text-20.173 {TextSearchCmd, regexp search multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "\naaaxxx\nyyy\n"
    set res {}
    lappend res [.t2 search -count c -regexp -- {x*\ny*} 2.0] $c
    lappend res [.t2 search -count c -regexp -- {x*\ny*} 2.1] $c
    set res
} {2.3 7 2.3 7}
test text-20.174 {TextSearchCmd, regexp search multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "\naaa\n\n\n\n\nxxx\n"
    set res {}
    lappend res [.t2 search -count c -regexp -- {\n+} 2.0] $c
    lappend res [.t2 search -count c -regexp -- {\n+} 2.1] $c
    set res
} {2.3 5 2.3 5}
test text-20.175 {TextSearchCmd, regexp search multi-line} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "\naaa\n\n\t  \n\t\t\t  \n\nxxx\n"
    set res {}
    lappend res [.t2 search -count c -regexp -- {(\n+(\t+ *)*)+} 2.0] $c
    set res
} {2.3 13}
test text-20.176 {TextSearchCmd, empty search range} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "a\na\na\n"
    .t2 search -- a 2.0 1.0
} {}
test text-20.177 {TextSearchCmd, empty search range} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "a\na\na\n"
    .t2 search -backwards -- a 1.0 2.0
} {}
test text-20.178 {TextSearchCmd, empty search range} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "a\na\na\n"
    .t2 search -- a 1.0 1.0
} {}
test text-20.179 {TextSearchCmd, empty search range} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "a\na\na\n"
    .t2 search -backwards -- a 2.0 2.0
} {}
test text-20.180 {TextSearchCmd, elide up to match} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "a\nb\nc"
    .t2 tag configure e -elide 1
    set res {}
    lappend res [.t2 search -regexp a 1.0]
    lappend res [.t2 search -regexp b 1.0]
    lappend res [.t2 search -regexp c 1.0]
    .t2 tag add e 1.0 2.0
    lappend res [.t2 search -regexp a 1.0]
    lappend res [.t2 search -regexp b 1.0]
    lappend res [.t2 search -regexp c 1.0]
    lappend res [.t2 search -elide -regexp a 1.0]
    lappend res [.t2 search -elide -regexp b 1.0]
    lappend res [.t2 search -elide -regexp c 1.0]
} {1.0 2.0 3.0 {} 2.0 3.0 1.0 2.0 3.0}
test text-20.181 {TextSearchCmd, elide up to match, backwards} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "a\nb\nc"
    .t2 tag configure e -elide 1
    set res {}
    lappend res [.t2 search -backward -regexp a 1.0]
    lappend res [.t2 search -backward -regexp b 1.0]
    lappend res [.t2 search -backward -regexp c 1.0]
    .t2 tag add e 1.0 2.0
    lappend res [.t2 search -backward -regexp a 1.0]
    lappend res [.t2 search -backward -regexp b 1.0]
    lappend res [.t2 search -backward -regexp c 1.0]
    lappend res [.t2 search -backward -elide -regexp a 1.0]
    lappend res [.t2 search -backward -elide -regexp b 1.0]
    lappend res [.t2 search -backward -elide -regexp c 1.0]
} {1.0 2.0 3.0 {} 2.0 3.0 1.0 2.0 3.0}
test text-20.182 {TextSearchCmd, elide up to match} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "a\nb\nc"
    .t2 tag configure e -elide 1
    set res {}
    lappend res [.t2 search a 1.0]
    lappend res [.t2 search b 1.0]
    lappend res [.t2 search c 1.0]
    .t2 tag add e 1.0 2.0
    lappend res [.t2 search a 1.0]
    lappend res [.t2 search b 1.0]
    lappend res [.t2 search c 1.0]
    lappend res [.t2 search -elide a 1.0]
    lappend res [.t2 search -elide b 1.0]
    lappend res [.t2 search -elide c 1.0]
} {1.0 2.0 3.0 {} 2.0 3.0 1.0 2.0 3.0}
test text-20.183 {TextSearchCmd, elide up to match, backwards} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "a\nb\nc"
    .t2 tag configure e -elide 1
    set res {}
    lappend res [.t2 search -backward a 1.0]
    lappend res [.t2 search -backward b 1.0]
    lappend res [.t2 search -backward c 1.0]
    .t2 tag add e 1.0 2.0
    lappend res [.t2 search -backward a 1.0]
    lappend res [.t2 search -backward b 1.0]
    lappend res [.t2 search -backward c 1.0]
    lappend res [.t2 search -backward -elide a 1.0]
    lappend res [.t2 search -backward -elide b 1.0]
    lappend res [.t2 search -backward -elide c 1.0]
} {1.0 2.0 3.0 {} 2.0 3.0 1.0 2.0 3.0}
test text-20.184 {TextSearchCmd, elide up to match} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aa\nbb\ncc"
    .t2 tag configure e -elide 1
    set res {}
    lappend res [.t2 search ab 1.0]
    lappend res [.t2 search bc 1.0]
    .t2 tag add e 1.1 2.1
    lappend res [.t2 search ab 1.0]
    lappend res [.t2 search b 1.0]
    .t2 tag remove e 1.0 end
    .t2 tag add e 2.1 3.1
    lappend res [.t2 search bc 1.0]
    lappend res [.t2 search c 1.0]
    .t2 tag remove e 1.0 end
    .t2 tag add e 2.1 3.0
    lappend res [.t2 search bc 1.0]
    lappend res [.t2 search c 1.0]
} {{} {} 1.0 2.1 2.0 3.1 2.0 3.0}
test text-20.185 {TextSearchCmd, elide up to match} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "aa\nbb\ncc"
    .t2 tag configure e -elide 1
    set res {}
    lappend res [.t2 search -regexp ab 1.0]
    lappend res [.t2 search -regexp bc 1.0]
    .t2 tag add e 1.1 2.1
    lappend res [.t2 search -regexp ab 1.0]
    lappend res [.t2 search -regexp b 1.0]
    .t2 tag remove e 1.0 end
    .t2 tag add e 2.1 3.1
    lappend res [.t2 search -regexp bc 1.0]
    lappend res [.t2 search -regexp c 1.0]
    .t2 tag remove e 1.0 end
    .t2 tag add e 2.1 3.0
    lappend res [.t2 search -regexp bc 1.0]
    lappend res [.t2 search -regexp c 1.0]
} {{} {} 1.0 2.1 2.0 3.1 2.0 3.0}
test text-20.186 {TextSearchCmd, strict limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "Hello world!\nThis is a test\n"
    .t2 search -strictlimits -- "world" 1.3 1.8
} {}
test text-20.187 {TextSearchCmd, strict limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "Hello world!\nThis is a test\n"
    .t2 search -strictlimits -- "world" 1.3 1.10
} {}
test text-20.188 {TextSearchCmd, strict limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "Hello world!\nThis is a test\n"
    .t2 search -strictlimits -- "world" 1.3 1.11
} {1.6}
test text-20.189 {TextSearchCmd, strict limits backwards} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "Hello world!\nThis is a test\n"
    .t2 search -strictlimits -backward -- "world" 2.3 1.8
} {}
test text-20.190 {TextSearchCmd, strict limits backwards} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "Hello world!\nThis is a test\n"
    .t2 search -strictlimits -backward -- "world" 2.3 1.6
} {1.6}
test text-20.191 {TextSearchCmd, strict limits backwards} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "Hello world!\nThis is a test\n"
    .t2 search -strictlimits -backward -- "world" 2.3 1.7
} {}
test text-20.192 {TextSearchCmd, strict limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "Hello world!\nThis is a test\n"
    .t2 search -regexp -strictlimits -- "world" 1.3 1.8
} {}
test text-20.193 {TextSearchCmd, strict limits} {
    deleteWindows
    pack [text .t2]
    .t2 insert 1.0 "Hello world!\nThis is a test\n"
    .t2 search -regexp -strictlimits -backward -- "world" 2.3 1.8
} {}

deleteWindows
text .t2 -highlightthickness 0 -bd 0 -relief flat -padx 0 -width 100
pack .t2
.t2 insert end "1\t2\t3\t4\t55.5"

test text-21.1 {TkTextGetTabs procedure} {
    list [catch {.t2 configure -tabs "\{{}"} msg] $msg
} {1 {unmatched open brace in list}}
test text-21.2 {TkTextGetTabs procedure} {
    list [catch {.t2 configure -tabs xyz} msg] $msg
} {1 {bad screen distance "xyz"}}
test text-21.3 {TkTextGetTabs procedure} {
    .t2 configure -tabs {100 200}
    update idletasks
    list [lindex [.t2 bbox 1.2] 0] [lindex [.t2 bbox 1.4] 0]
} {100 200}
test text-21.4 {TkTextGetTabs procedure} {
    .t2 configure -tabs {100 right 200 left 300 center 400 numeric}
    update idletasks
    list [expr [lindex [.t2 bbox 1.2] 0] + [lindex [.t2 bbox 1.2] 2]] \
	    [lindex [.t2 bbox 1.4] 0] \
	    [expr [lindex [.t2 bbox 1.6] 0] + [lindex [.t2 bbox 1.6] 2]/2] \
	    [lindex [.t2 bbox 1.10] 0]
} {100 200 300 400}
test text-21.5 {TkTextGetTabs procedure} {
    .t2 configure -tabs {105 r 205 l 305 c 405 n}
    update idletasks
    list [expr [lindex [.t2 bbox 1.2] 0] + [lindex [.t2 bbox 1.2] 2]] \
	    [lindex [.t2 bbox 1.4] 0] \
	    [expr [lindex [.t2 bbox 1.6] 0] + [lindex [.t2 bbox 1.6] 2]/2] \
	    [lindex [.t2 bbox 1.10] 0]
} {105 205 305 405}
test text-21.6 {TkTextGetTabs procedure} {
    list [catch {.t2 configure -tabs {100 left 200 lork}} msg] $msg
} {1 {bad tab alignment "lork": must be left, right, center, or numeric}}
test text-21.7 {TkTextGetTabs procedure} {
    list [catch {.t2 configure -tabs {100 !44 200 lork}} msg] $msg
} {1 {bad screen distance "!44"}}

deleteWindows
text .t
pack .t
.t insert 1.0 "One Line"
.t mark set insert 1.0

test text-22.1 {TextDumpCmd procedure, bad args} {
    list [catch {.t dump} msg] $msg
} {1 {Usage: .t dump ?-all -image -text -mark -tag -window? ?-command script? index ?index2?}}
test text-22.2 {TextDumpCmd procedure, bad args} {
    list [catch {.t dump -all} msg] $msg
} {1 {Usage: .t dump ?-all -image -text -mark -tag -window? ?-command script? index ?index2?}}
test text-22.3 {TextDumpCmd procedure, bad args} {
    list [catch {.t dump -command} msg] $msg
} {1 {Usage: .t dump ?-all -image -text -mark -tag -window? ?-command script? index ?index2?}}
test text-22.4 {TextDumpCmd procedure, bad args} {
    list [catch {.t dump -bogus} msg] $msg
} {1 {bad option "-bogus": must be -all, -command, -image, -mark, -tag, -text, or -window}}
test text-22.5 {TextDumpCmd procedure, bad args} {
    list [catch {.t dump bogus} msg] $msg
} {1 {bad text index "bogus"}}
test text-22.6 {TextDumpCmd procedure, one index} {
    .t dump -text 1.2
} {text e 1.2}
test text-22.7 {TextDumpCmd procedure, two indices} {
    .t dump -text 1.0 1.end
} {text {One Line} 1.0}
test text-22.8 {TextDumpCmd procedure, "end" index} {
    .t dump -text 1.end end
} {text {
} 1.8}
test text-22.9 {TextDumpCmd procedure, same indices} {
    .t dump 1.5 1.5
} {}
test text-22.10 {TextDumpCmd procedure, negative range} {
    .t dump 1.5 1.0
} {}
.t delete 1.0 end
.t insert end "Line One\nLine Two\nLine Three\nLine Four"
.t mark set insert 1.0
.t mark set current 1.0
test text-22.11 {TextDumpCmd procedure, stop at begin-line} {
    .t dump -text 1.0 2.0
} {text {Line One
} 1.0}
test text-22.12 {TextDumpCmd procedure, span multiple lines} {
    .t dump -text 1.5 3.end
} {text {One
} 1.5 text {Line Two
} 2.0 text {Line Three} 3.0}
.t tag add x 2.0 2.end
.t tag add y 1.0 end
.t mark set m 2.4
.t mark set n 4.0
.t mark set END end
test text-22.13 {TextDumpCmd procedure, tags only} {
    .t dump -tag 2.1 2.8
} {}
test text-22.14 {TextDumpCmd procedure, tags only} {
    .t dump -tag 2.0 2.8
} {tagon x 2.0}
test text-22.15 {TextDumpCmd procedure, tags only} {
    .t dump -tag 1.0 4.end
} {tagon y 1.0 tagon x 2.0 tagoff x 2.8}
test text-22.16 {TextDumpCmd procedure, tags only} {
    .t dump -tag 1.0 end
} {tagon y 1.0 tagon x 2.0 tagoff x 2.8 tagoff y 5.0}
.t mark set insert 1.0
.t mark set current 1.0
test text-22.17 {TextDumpCmd procedure, marks only} {
    .t dump -mark 1.1 1.8
} {}
test text-22.18 {TextDumpCmd procedure, marks only} {
    .t dump -mark 2.0 2.8
} {mark m 2.4}
test text-22.19 {TextDumpCmd procedure, marks only} {
    .t dump -mark 1.1 4.end
} {mark m 2.4 mark n 4.0}
test text-22.20 {TextDumpCmd procedure, marks only} {
    .t dump -mark 1.0 end
} {mark current 1.0 mark insert 1.0 mark m 2.4 mark n 4.0 mark END 5.0}
button .hello -text Hello
.t window create 3.end -window .hello
for {set i 0} {$i < 100} {incr i} {
    .t insert end "-\n"
}
.t window create 100.0 -create { }
test text-22.21 {TextDumpCmd procedure, windows only} {
    .t dump -window 1.0 5.0
} {window .hello 3.10}
test text-22.22 {TextDumpCmd procedure, windows only} {
    .t dump -window 5.0 end
} {window {} 100.0}
.t delete 1.0 end
eval {.t mark unset} [.t mark names]
.t insert end "Line One\nLine Two\nLine Three\nLine Four"
.t mark set insert 1.0
.t mark set current 1.0
.t tag add x 2.0 2.end
.t mark set m 2.4
proc Append {varName key value index} {
    upvar #0 $varName x
    lappend x $key $index $value
}
test text-22.23 {TextDumpCmd procedure, command script} {
    set x {}
    .t dump -command {Append x} -all 1.0 end
    set x
} {mark 1.0 current mark 1.0 insert text 1.0 {Line One
} tagon 2.0 x text 2.0 Line mark 2.4 m text 2.4 { Two} tagoff 2.8 x text 2.8 {
} text 3.0 {Line Three
} text 4.0 {Line Four
}}
test text-22.24 {TextDumpCmd procedure, command script} {
    set x {}
    .t dump -mark -command {Append x} 1.0 end
    set x
} {mark 1.0 current mark 1.0 insert mark 2.4 m}
catch {unset x}
test text-22.25 {TextDumpCmd procedure, unicode characters} {
    catch {destroy .t}
    text .t
    .t delete 1.0 end
    .t insert 1.0 \xb1\xb1\xb1
    .t dump -all 1.0 2.0
} "text \xb1\xb1\xb1 1.0 mark insert 1.3 mark current 1.3 text {\n} 1.3"
test text-22.26 {TextDumpCmd procedure, unicode characters} {
    catch {destroy .t}
    text .t
    .t delete 1.0 end
    .t insert 1.0 abc\xb1\xb1\xb1
    .t dump -all 1.0 2.0
} "text abc\xb1\xb1\xb1 1.0 mark insert 1.6 mark current 1.6 text {\n} 1.6"

set l [interp hidden]
deleteWindows

test text-23.1 {text widget vs hidden commands} {
    catch {destroy .t}
    text .t
    interp hide {} .t
    destroy .t
    list [winfo children .] [interp hidden]
} [list {} $l]

test text-24.1 {bug fix - 1642} {
    catch {destroy .t}
    text .t
    pack .t
    .t insert end "line 1\n"
    .t insert end "line 2\n"
    .t insert end "line 3\n"
    .t insert end "line 4\n"
    .t insert end "line 5\n"
    tk::TextSetCursor .t 3.0
    .t search -backward -regexp "\$" insert 1.0
} {2.6}

test text-25.1 {TextEditCmd procedure, argument parsing} {
    list [catch {.t edit} msg] $msg
} {1 {wrong # args: should be ".t edit option ?arg arg ...?"}}
test text-25.2 {TextEditCmd procedure, argument parsing} {
    list [catch {.t edit gorp} msg] $msg
} {1 {bad edit option "gorp": must be modified, redo, reset, separator, or undo}}
test text-25.3 {TextEditUndo procedure, undoing changes} {
    catch {destroy .t}
    text .t -undo 1
    pack .t
    .t insert end "line 1\n"
    .t delete 1.4 1.6
    .t insert end "should be gone after undo\n"
    .t edit undo
    .t get 1.0 end
} "line\n\n"
test text-25.4 {TextEditRedo procedure, redoing changes} {
    catch {destroy .t}
    text .t -undo 1
    pack .t
    .t insert end "line 1\n"
    .t delete 1.4 1.6
    .t insert end "should be back after redo\n"
    .t edit undo
    .t edit redo
    .t get 1.0 end
} "line\nshould be back after redo\n\n"
test text-25.5 {TextEditUndo procedure, resetting stack} {
    catch {destroy .t}
    text .t -undo 1
    pack .t
    .t insert end "line 1\n"
    .t delete 1.4 1.6
    .t insert end "should be back after redo\n"
    .t edit reset
    catch {.t edit undo} msg
    set msg
} "nothing to undo"
test text-25.6 {TextEditCmd procedure, insert separator} {
    catch {destroy .t}
    text .t -undo 1
    pack .t
    .t insert end "line 1\n"
    .t edit separator
    .t insert end "line 2\n"
    .t edit undo
    .t get 1.0 end
} "line 1\n\n"
test text-25.7 {-autoseparators configuration option} {
    catch {destroy .t}
    text .t -undo 1 -autoseparators 0
    pack .t
    .t insert end "line 1\n"
    .t delete 1.4 1.6
    .t insert end "line 2\n"
    .t edit undo
    .t get 1.0 end
} "\n"
test text-25.8 {TextEditCmd procedure, modified flag} {
    catch {destroy .t}
    text .t
    pack .t
    .t insert end "line 1\n"
    .t edit modified
} {1}
test text-25.9 {TextEditCmd procedure, reset modified flag} {
    catch {destroy .t}
    text .t
    pack .t
    .t insert end "line 1\n"
    .t edit modified 0
    .t edit modified
} {0}
test text-25.10 {TextEditCmd procedure, set modified flag} {
    catch {destroy .t}
    text .t
    pack .t
    .t edit modified 1
    .t edit modified
} {1}
test text-25.11 {<<Modified>> virtual event} {
    set ::retval unmodified
    catch {destroy .t}
    text .t -undo 1
    pack .t
    bind .t <<Modified>> "set ::retval modified"
    update idletasks
    .t insert end "nothing special\n"
    set ::retval
} {modified}
test text-25.12 {<<Selection>> virtual event} {
    set ::retval no_selection
    catch {destroy .t}
    text .t -undo 1
    pack .t
    bind .t <<Selection>> "set ::retval selection_changed"
    update idletasks
    .t insert end "nothing special\n"
    .t tag add sel 1.0 1.1
    set ::retval
} {selection_changed}
test text-25.13 {-maxundo configuration option} {
    catch {destroy .t}
    text .t -undo 1  -autoseparators 1 -maxundo 2
    pack .t
    .t insert end "line 1\n"
    .t delete 1.4 1.6
    .t insert end "line 2\n"
    catch {.t edit undo}
    catch {.t edit undo}
    catch {.t edit undo}
    .t get 1.0 end
} "line 1\n\n"
test text-25.15 {bug fix 1536735 - undo with empty text} {
    catch {destroy .t}
    text .t -undo 1
    set r [.t edit modified]
    .t delete 1.0
    lappend r [.t edit modified]
    lappend r [catch {.t edit undo}]
    lappend r [.t edit modified]
} {0 0 1 0}

test text-26.1 {bug fix - 624372, ControlUtfProc long lines} {
    destroy .t
    pack [text .t -wrap none]
    .t insert end [string repeat "\1" 500]
} {}

test text-27.1 {tabs - must be positive and must be increasing} {
    destroy .t
    pack [text .t -wrap none]
    list [catch {.t configure -tabs {0}} msg] $msg
} {1 {tab stop "0" is not at a positive distance}}
test text-27.2 {tabs - must be positive and must be increasing} {
    destroy .t
    pack [text .t -wrap none]
    list [catch {.t configure -tabs {-5}} msg] $msg
} {1 {tab stop "-5" is not at a positive distance}}
test text-27.3 {tabs - must be positive and must be increasing} {knownBug} {
    # This bug will be fixed in Tk 9.0, when we can allow a minor
    # incompatibility with Tk 8.x
    destroy .t
    pack [text .t -wrap none]
    list [catch {.t configure -tabs {10c 5c}} msg] $msg
} {1 {tabs must be monotonically increasing, but "5c" is smaller than or equal to the previous tab}}
test text-27.4 {tabs - must be positive and must be increasing} {
    destroy .t
    pack [text .t -wrap none]
    .t insert end "a\tb\tc\td\te"
    catch {.t configure -tabs {10c 5c}}
    update ; update ; update
    # This test must simply not go into an infinite loop to succeed
    set result 1
} {1}

test text-28.0 {repeated insert and scroll} {
    foreach subcmd {
	{moveto 1}
	{scroll 1 pages}
	{scroll 100 pixels}
	{scroll 10 units}
    } {
	destroy .t
	pack [text .t]
	for {set i 0} {$i < 30} {incr i} {
	    .t insert end "blabla\n"
	    eval .t yview $subcmd
	}
    }
    # This test must simply not crash to succeed
    set result 1
} {1}

test text-29.0 {peer widgets} {
    destroy .t .tt
    toplevel .tt
    pack [text .t]
    pack [.t peer create .tt.t]
    destroy .t .tt
} {}
test text-29.1 {peer widgets} {
    destroy .t .t1 .t2
    toplevel .t1
    toplevel .t2
    pack [text .t]
    pack [.t peer create .t1.t]
    pack [.t peer create .t2.t]
    .t insert end "abcd\nabcd"
    update
    destroy .t1
    update
    .t insert end "abcd\nabcd"
    update
    destroy .t .t2
    update
} {}
test text-29.2 {peer widgets} {
    destroy .t .t1 .t2
    toplevel .t1
    toplevel .t2
    pack [text .t]
    pack [.t peer create .t1.t]
    pack [.t peer create .t2.t]
    .t insert end "abcd\nabcd"
    update
    destroy .t
    update
    .t2.t insert end "abcd\nabcd"
    update
    destroy .t .t2
    update
} {}
test text-29.3 {peer widgets} {
    destroy .t .tt
    toplevel .tt
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    pack [.t peer create .tt.t -start 5 -end 11]
    update
    destroy .t .tt
} {}
test text-29.4 {peer widgets} {
    destroy .t .tt
    toplevel .tt
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    pack [.t peer create .tt.t -start 5 -end 11]
    pack [.tt.t peer create .tt.t2]
    set res [list [.tt.t index end] [.tt.t2 index end]]
    update
    destroy .t .tt
    set res
} {7.0 7.0}
test text-29.4.1 {peer widgets} {
    destroy .t .tt
    toplevel .tt
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    pack [.t peer create .tt.t -start 5 -end 11]
    pack [.tt.t peer create .tt.t2 -start {} -end {}]
    set res [list [.tt.t index end] [.tt.t2 index end]]
    update
    destroy .t .tt
    set res
} {7.0 21.0}
test text-29.5 {peer widgets} {
    destroy .t .tt
    toplevel .tt
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    pack [.t peer create .tt.t -start 5 -end 11]
    update ; update
    set p1 [.tt.t count -update -ypixels 1.0 end]
    set p2 [.t count -update -ypixels 5.0 11.0]
    if {$p1 == $p2} { 
	set res "ok" 
    } else {
        set res "$p1 and $p2 not equal"
    }
    destroy .t .tt
    set res
} {ok}
test text-29.6 {peer widgets} {
    destroy .t .tt
    toplevel .tt
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    pack [.t peer create .tt.t -start 5 -end 11]
    update ; update
    .t delete 3.0 6.0
    set res [.tt.t index end]
    destroy .t .tt
    set res
} {6.0}
test text-29.7 {peer widgets} {
    destroy .t .tt
    toplevel .tt
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    pack [.t peer create .tt.t -start 5 -end 11]
    update ; update
    .t delete 8.0 12.0
    set res [.tt.t index end]
    destroy .t .tt
    set res
} {4.0}
test text-29.8 {peer widgets} {
    destroy .t .tt
    toplevel .tt
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    pack [.t peer create .tt.t -start 5 -end 11]
    update ; update
    .t delete 3.0 13.0
    set res [.tt.t index end]
    destroy .t .tt
    set res
} {1.0}
test text-29.9 {peer widgets} {
    destroy .t
    pack [text .t]
    for {set i 1} {$i < 100} {incr i} {
	.t insert end "Line $i\n"
    }
    .t tag add sel 1.0 end-1c
    set res {}
    lappend res [.t tag ranges sel]
    .t configure -start 10 -end 20
    lappend res [.t tag ranges sel]
    destroy .t
    set res
} {{1.0 100.0} {1.0 11.0}}
test text-29.10 {peer widgets} {
    destroy .t
    pack [text .t]
    for {set i 1} {$i < 100} {incr i} {
	.t insert end "Line $i\n"
    }
    .t tag add sel 1.0 end-1c
    set res {}
    lappend res [.t tag ranges sel]
    .t configure -start 11
    lappend res [.t tag ranges sel]
    destroy .t
    set res
} {{1.0 100.0} {1.0 90.0}}
test text-29.11 {peer widgets} {
    destroy .t
    pack [text .t]
    for {set i 1} {$i < 100} {incr i} {
	.t insert end "Line $i\n"
    }
    .t tag add sel 1.0 end-1c
    set res {}
    lappend res [.t tag ranges sel]
    .t configure -end 90
    lappend res [.t tag ranges sel]
    destroy .t
    set res
} {{1.0 100.0} {1.0 90.0}}
test text-29.12 {peer widgets} {
    destroy .t
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    .t tag add sel 1.0 3.0 5.0 7.0 9.0 11.0 13.0 15.0 17.0 19.0 
    set res {}
    lappend res [.t tag prevrange sel 1.0]
    .t configure -start 6 -end 12
    lappend res [.t tag ranges sel]
    lappend res "next" [.t tag nextrange sel 4.0] \
      [.t tag nextrange sel 5.0] [.t tag nextrange sel 6.0] \
      [.t tag nextrange sel 7.0]
    lappend res "prev" [.t tag prevrange sel 1.0] \
      [.t tag prevrange sel 2.0] [.t tag prevrange sel 3.0] \
      [.t tag prevrange sel 4.0]
    destroy .t
    set res
} {{} {1.0 2.0 4.0 6.0} next {4.0 6.0} {} {} {} prev {} {1.0 2.0} {1.0 2.0} {1.0 2.0}}
test text-29.13 {peer widgets} {
    destroy .t
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    .t tag add sel 1.0 3.0 9.0 11.0 13.0 15.0 17.0 19.0 
    set res {}
    .t configure -start 6 -end 12
    lappend res [.t tag ranges sel]
    lappend res "next" [.t tag nextrange sel 4.0] \
      [.t tag nextrange sel 5.0] [.t tag nextrange sel 6.0] \
      [.t tag nextrange sel 7.0]
    lappend res "prev" [.t tag prevrange sel 1.0] \
      [.t tag prevrange sel 2.0] [.t tag prevrange sel 3.0] \
      [.t tag prevrange sel 4.0]
    destroy .t
    set res
} {{4.0 6.0} next {4.0 6.0} {} {} {} prev {} {} {} {}}
test text-29.14 {peer widgets} {
    destroy .t
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    .t tag add sel 1.0 7.0 9.0 11.0 13.0 15.0 17.0 19.0 
    set res {}
    .t configure -start 6 -end 12
    lappend res [.t tag ranges sel]
    lappend res "next" [.t tag nextrange sel 4.0] \
      [.t tag nextrange sel 5.0] [.t tag nextrange sel 6.0] \
      [.t tag nextrange sel 7.0]
    lappend res "prev" [.t tag prevrange sel 1.0] \
      [.t tag prevrange sel 2.0] [.t tag prevrange sel 3.0] \
      [.t tag prevrange sel 4.0]
    destroy .t
    set res
} {{1.0 2.0 4.0 6.0} next {4.0 6.0} {} {} {} prev {} {1.0 2.0} {1.0 2.0} {1.0 2.0}}
test text-29.15 {peer widgets} {
    destroy .t
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    set res {}
    .t tag add sel 1.0 11.0
    lappend res [.t tag ranges sel]
    lappend res [catch {.t configure -start 15 -end 10}]
    lappend res [.t tag ranges sel]
    .t configure -start 6 -end 12
    lappend res [.t tag ranges sel]
    .t configure -start {} -end {}
    lappend res [.t tag ranges sel]
    destroy .t
    set res
} {{1.0 11.0} 1 {1.0 11.0} {1.0 6.0} {1.0 11.0}}
test text-29.16 {peer widgets} {
    destroy .t
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    set res {}
    .t tag add sel 1.0 11.0
    lappend res [.t index sel.first]
    lappend res [.t index sel.last]
    destroy .t
    set res
} {1.0 11.0} 
test text-29.17 {peer widgets} {
    destroy .t
    pack [text .t]
    for {set i 1} {$i < 20} {incr i} {
	.t insert end "Line $i\n"
    }
    set res {}
    .t tag delete sel
    set res [list [catch {.t index sel.first} msg] $msg]
    destroy .t
    set res
} {1 {text doesn't contain any characters tagged with "sel"}} 

proc makeText {} {
    set w .g
    set font "Times 11"
    destroy .g
    toplevel .g
    frame $w.f -highlightthickness 2 -borderwidth 2 -relief sunken
    set t $w.f.text
    text $t -yscrollcommand "$w.scroll set" -setgrid true -font $font -width 70 \
	    -height 35 -wrap word -highlightthickness 0 -borderwidth 0
    pack $t -expand  yes -fill both
    scrollbar $w.scroll -command "$t yview"
    pack $w.scroll -side right -fill y
    pack $w.f -expand yes -fill both
    $t tag configure center -justify center -spacing1 5m -spacing3 5m
    $t tag configure buttons -lmargin1 1c -lmargin2 1c -rmargin 1c \
	    -spacing1 3m -spacing2 0 -spacing3 0
    for {set i 0} {$i < 40} {incr i} {
	$t insert end "${i}word "
    }
    return $t
}

test text-30.1 {line heights on creation} {
    set w [makeText]
    update ; after 1000 ; update
    set before [$w count -ypixels 1.0 2.0]
    $w insert 1.0 "a"
    update
    set after [$w count -ypixels 1.0 2.0]
    destroy .g
    if {$before != $after} {
	set res "Count changed: $before $after"
    } else {
        set res "ok"
    }
} {ok}

destroy .t
text .t
test text-31.1 {TextWidgetCmd procedure, "peer" option} {
    list [catch {.t peer foo 1} msg] $msg
} {1 {bad peer option "foo": must be create or names}}
test text-31.2 {TextWidgetCmd procedure, "peer" option} {
    list [catch {.t peer names foo} msg] $msg
} {1 {wrong # args: should be ".t peer names"}}
test text-31.3 {TextWidgetCmd procedure, "peer" option} {
    list [catch {.t p names} msg] $msg
} {0 {}}
test text-31.4 {TextWidgetCmd procedure, "peer" option} {
    .t peer names
} {}
test text-31.5 {TextWidgetCmd procedure, "peer" option} {
    list [catch {.t peer create foo} msg] $msg
} {1 {bad window path name "foo"}}
test text-31.6 {TextWidgetCmd procedure, "peer" option} {
    .t peer create .t2
    set res {}
    lappend res [.t peer names]
    lappend res [.t2 peer names]
    destroy .t2
    lappend res [.t peer names]
} {.t2 .t {}}
test text-31.7 {peer widget -start, -end} {
    set res [list [catch {.t configure -start 10 -end 5} msg] $msg]
    .t configure -start {} -end {}
    set res
} {0 {}}
test text-31.8 {peer widget -start, -end} {
    .t delete 1.0 end
    for {set i 1} {$i < 100} {incr i} {
	.t insert end "Line $i\n"
    }
    list [catch {.t configure -start 10 -end 5} msg] $msg
} {1 {-startline must be less than or equal to -endline}}
test text-31.9 {peer widget -start, -end} {
    .t delete 1.0 end
    for {set i 1} {$i < 100} {incr i} {
	.t insert end "Line $i\n"
    }
    set res [list [catch {.t configure -start 5 -end 10} msg] $msg]
    .t configure -start {} -end {}
    set res
} {0 {}}
test text-31.10 {peer widget -start, -end} {
    .t delete 1.0 end
    for {set i 1} {$i < 100} {incr i} {
	.t insert end "Line $i\n"
    }
    set res [.t index end]
    lappend res [catch {.t configure -start 5 -end 10 -tab foo}]
    lappend res [.t index end]
    lappend res [catch {.t configure -tab foo -start 15 -end 20}]
    lappend res [.t index end]
    .t configure -start {} -end {}
    lappend res [.t index end]
    set res
} {101.0 1 101.0 1 101.0 101.0}
test text-31.11 {peer widget -start, -end} {
    .t delete 1.0 end
    for {set i 1} {$i < 100} {incr i} {
	.t insert end "Line $i\n"
    }
    set res [.t index end]
    lappend res [catch {.t configure -start 5 -end 15}]
    lappend res [.t index end]
    lappend res [catch {.t configure -start 10 -end 40}]
    lappend res [.t index end]
    .t configure -start {} -end {}
    lappend res [.t index end]
    set res
} {101.0 0 11.0 0 31.0 101.0}

test text-32.1 {peer widget -start, -end and selection} {
    .t delete 1.0 end
    for {set i 1} {$i < 100} {incr i} {
	.t insert end "Line $i\n"
    }
    .t tag add sel 10.0 20.0
    set res {}
    lappend res [.t tag ranges sel]
    .t configure -start 5 -end 30
    lappend res [.t tag ranges sel]
    .t configure -start 5 -end 15
    lappend res [.t tag ranges sel]
    .t configure -start 15 -end 30
    lappend res [.t tag ranges sel]
    .t configure -start 15 -end 16
    lappend res [.t tag ranges sel]
    .t configure -start 25 -end 30
    lappend res [.t tag ranges sel]
    .t configure -start {} -end {}
    lappend res [.t tag ranges sel]
    set res
} {{10.0 20.0} {6.0 16.0} {6.0 11.0} {1.0 6.0} {1.0 2.0} {} {10.0 20.0}}

test text-33.1 {widget dump -command alters tags} {
    .t delete 1.0 end
    .t insert end "abc\n" a "---" {} "def" b "   \n" {} "ghi\n" c
    .t tag configure b -background red
    proc Dumpy {key value index} {
      #puts "KK: $key, $value"
      .t tag add $value [list $index linestart] [list $index lineend]
    }
    .t dump -all -command Dumpy 1.0 end
    set result "ok"
} {ok}
test text-33.2 {widget dump -command makes massive changes} {
    .t delete 1.0 end
    .t insert end "abc\n" a "---" {} "def" b "   \n" {} "ghi\n" c
    .t tag configure b -background red
    proc Dumpy {key value index} {
      #puts "KK: $key, $value"
      .t delete 1.0 end
    }
    .t dump -all -command Dumpy 1.0 end
    set result "ok"
} {ok}
test text-33.3 {widget dump -command destroys widget} {
    .t delete 1.0 end
    .t insert end "abc\n" a "---" {} "def" b "   \n" {} "ghi\n" c
    .t tag configure b -background red
    proc Dumpy {key value index} {
      #puts "KK: $key, $value"
      destroy .t
    }
    .t dump -all -command Dumpy 1.0 end
    set result "ok"
} {ok}

deleteWindows
option clear

# cleanup
cleanupTests
return

__END__