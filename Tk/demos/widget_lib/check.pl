# check.pl

sub check {

    # Create a top-level window that displays a bunch of check buttons.

    my($demo) = @ARG;

    $CHECK->destroy if Exists($CHECK);
    $CHECK = $mw->Toplevel;
    my $w = $CHECK;
    dpos $w;
    $w->title('Checkbutton Demonstration');
    $w->iconname('check');
    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => 'Three checkbuttons are displayed below.  If you click on a button, it will toggle the button\'s selection state and set a Perl variable to a value indicating the state of the checkbutton.  Click the "See Variables" button to see the current values of the variables.',
    );
    $w_msg->pack(-side => 'top');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw( -side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => ['destroy', $w],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));
    my $w_var = $w_buttons->Button(
        -text    => 'See Variables',
        -command => [\&seeVars, $w, qw(wipers brakes sober)],
    );
    $w_var->pack(qw(-side left -expand 1));

    $wipers = 0 if not defined $wipers;
    $brakes = 0 if not defined $brakes;
    $sober = 0 if not defined $sober;
    my $w_b1 = $w->Checkbutton(-text => 'Wipers OK', -variable => \$wipers,
			       -relief => 'flat');
    my $w_b2 = $w->Checkbutton(-text => 'Brakes OK', -variable => \$brakes,
			       -relief => 'flat');
    my $w_b3 = $w->Checkbutton(-text => 'Driver Sober', -variable => \$sober,
			       -relief => 'flat');
    my(@pl) = (-side => 'top', -pady => '2', -anchor => 'w');
    $w_b1->pack(@pl);
    $w_b2->pack(@pl);
    $w_b3->pack(@pl);

} # end check

1;
