# radio.pl

sub radio {

    # Create a top-level window that displays a bunch of radio buttons.

    my($demo) = @ARG;

    $RADIO->destroy if Exists($RADIO);
    $RADIO = $mw->Toplevel;
    my $w = $RADIO;
    dpos $w;
    $w->title('Radiobutton Demonstration');
    $w->iconname('radio');
    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '5i',
        -justify    => 'left',
        -text       => 'Two groups of radiobuttons are displayed below.  If you click on a button then the button will become selected exclusively among all the buttons in its group.  A Perl variable is associated with each group to indicate which of the group\'s buttons is selected.  Click the "See Variables" button to see the current values of the variables.',
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
        -command => [\&seeVars, $w, qw(size color)],
    );
    $w_var->pack(qw(-side left -expand 1));

    my $w_left = $w->Frame;
    my $w_right = $w->Frame;
    @pl = (-side => 'left', -expand => 'yes', -padx => '.5c', -pady => '.5c');
    $w_left->pack(@pl);
    $w_right->pack(@pl);

    $size = '' if not defined $size;
    $color = '' if not defined $color;
    my($r, $p, $c);
    foreach $p (10, 12, 18, 24) {
	$r = $w_left->Radiobutton(
            -text     => "Point Size $p",
            -variable => \$size,
            -relief   => 'flat',
            -value => $p,
        );
	$r->pack(-side => 'top', -pady => '2', -anchor => 'w');
    }

    foreach $c (qw(Red Green Blue Yellow Orange Purple)) {
	$r = $w_right->Radiobutton(
            -text     => $c,
            -variable => \$color,
            -relief => 'flat',
            -value => lc($c),
        );
	$r->pack(-side => 'top', -pady => '2', -anchor => 'w');
    }

} # end radio

1;
